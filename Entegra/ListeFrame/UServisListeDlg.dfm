object ServisListeDlg: TServisListeDlg
  Left = 0
  Top = 0
  Width = 944
  Height = 497
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 255
    Width = 944
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = cxPageControl1
    Color = clBlue
    ParentColor = False
    ExplicitWidth = 8
  end
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 263
    Width = 944
    Height = 234
    Align = alBottom
    TabOrder = 1
    Properties.ActivePage = cxTabSheet2
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControl1Change
    ClientRectBottom = 230
    ClientRectLeft = 4
    ClientRectRight = 940
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Bilgi/A'#231#305'klama'
      ImageIndex = 22
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 936
        Height = 203
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.SkinName = 'MoneyTwins'
        object cxGridDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridServisViewKOD1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = False
            Width = 53
          end
          object GridServisViewACIKLAMA1: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 538
          end
          object GridServisViewADET1: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = False
            Width = 34
          end
          object GridServisViewBIRIM1: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 42
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
      object GridKabul: TcxGrid
        Left = 0
        Top = 0
        Width = 936
        Height = 203
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        LookAndFeel.SkinName = 'LondonLiquidSky'
        object GridKabulView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridKabulViewCanFocusRecord
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridKabulViewStylesGetContentStyle
          object cxGridDBColumn1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = False
            Width = 53
          end
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 538
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = False
            Width = 34
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 42
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = GridKabulView
        end
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'Hareketler'
      ImageIndex = 32
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridHareketler: TcxGrid
        Left = 0
        Top = 0
        Width = 489
        Height = 203
        Align = alLeft
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridHareketlerDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsHareketler
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.CellHints = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideFocusRectOnExit = False
          OptionsSelection.InvertSelect = False
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridHareketlerDBTableView1DURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repServisDurum
          end
          object GridHareketlerDBTableView1PERSONEL: TcxGridDBColumn
            Caption = 'Personel'
            DataBinding.FieldName = 'PERSONEL'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesiHerkes
          end
          object GridHareketlerDBTableView1BASLAMA: TcxGridDBColumn
            Caption = 'Ba'#351'lama'
            DataBinding.FieldName = 'BASLAMA'
            DataBinding.IsNullValueType = True
          end
          object GridHareketlerDBTableView1BITIS: TcxGridDBColumn
            Caption = 'Biti'#351
            DataBinding.FieldName = 'BITIS'
            DataBinding.IsNullValueType = True
          end
          object GridHareketlerDBTableView1SURE: TcxGridDBColumn
            Caption = 'Sure'
            DataBinding.FieldName = 'SURE'
            DataBinding.IsNullValueType = True
            Width = 100
          end
          object GridHareketlerDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxLabelProperties'
            Properties.WordWrap = True
            Width = 155
          end
          object GridHareketlerDBTableView1UYARITURU: TcxGridDBColumn
            Caption = #304#231
            DataBinding.FieldName = 'UYARITURU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repUyariTurleri
            Width = 24
          end
          object GridHareketlerDBTableView1DISUYARITURU: TcxGridDBColumn
            Caption = 'D'#305#351
            DataBinding.FieldName = 'DISUYARITURU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repUyariTurleri
            Width = 24
          end
        end
        object GridHareketlerLevel1: TcxGridLevel
          GridView = GridHareketlerDBTableView1
        end
      end
      object cxSplitterHareket: TcxSplitter
        Left = 489
        Top = 0
        Width = 8
        Height = 203
        HotZoneClassName = 'TcxMediaPlayer8Style'
        Control = GridHareketler
      end
      object PanelMedya: TPanel
        Left = 497
        Top = 0
        Width = 439
        Height = 203
        Align = alClient
        TabOrder = 2
        object Panel4: TPanel
          Left = 1
          Top = 161
          Width = 437
          Height = 41
          Align = alBottom
          TabOrder = 0
          object MemoChat: TcxRichEdit
            Left = 1
            Top = 1
            Align = alClient
            Properties.ScrollBars = ssVertical
            TabOrder = 1
            Height = 39
            Width = 289
          end
          object BtnMesajGonder: TcxButton
            Left = 290
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
            Left = 375
            Top = 1
            Width = 61
            Height = 39
            Align = alRight
            DropDownMenu = YorumAtacMenu
            Kind = cxbkDropDown
            OptionsImage.ImageIndex = 38
            OptionsImage.Images = Tablo.cxImageList1
            TabOrder = 2
          end
        end
        object labelFileName: TcxLabel
          Left = 1
          Top = 141
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
          ExplicitTop = 140
          AnchorX = 438
        end
        object GridYorum: TcxGrid
          Left = 1
          Top = 1
          Width = 437
          Height = 140
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
    end
    object TabSheetGenel: TcxTabSheet
      Caption = 'Genel'
      ImageIndex = 11
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GenelTreeList: TcxDBTreeList
        Left = 0
        Top = 0
        Width = 936
        Height = 203
        Align = alClient
        Bands = <
          item
            Caption.Text = 'aa'
          end>
        DataController.DataSource = DtsGenel
        DataController.ParentField = 'USTID'
        DataController.KeyField = 'ID'
        DefaultRowHeight = 20
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        LookAndFeel.SkinName = 'LondonLiquidSky'
        Navigator.Buttons.CustomButtons = <>
        OptionsBehavior.CopyCaptionsToClipboard = False
        OptionsBehavior.IncSearch = True
        OptionsData.Appending = True
        OptionsData.Inserting = True
        OptionsData.CheckHasChildren = False
        OptionsData.SmartRefresh = True
        OptionsSelection.MultiSelect = True
        OptionsView.CellAutoHeight = True
        OptionsView.Buttons = False
        OptionsView.Headers = False
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 2
        object GenelTreeListROOTKOD: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'ROOTKOD'
          Options.Editing = False
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object GenelTreeListID: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'ID'
          Options.Editing = False
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object GenelTreeListSERVISID: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'SERVISID'
          Options.Editing = False
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object GenelTreeListKOD: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'KOD'
          Options.Editing = False
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object GenelTreeListGRUP: TcxDBTreeListColumn
          Styles.Content = Tablo.cxStSerinoCikilmis
          DataBinding.FieldName = 'GRUP'
          Options.Editing = False
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object GenelTreeListAD: TcxDBTreeListColumn
          DataBinding.FieldName = 'AD'
          Options.Editing = False
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object GenelTreeListACIKLAMA: TcxDBTreeListColumn
          PropertiesClassName = 'TcxButtonEditProperties'
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          DataBinding.FieldName = 'ACIKLAMA'
          Width = 200
          Position.ColIndex = 6
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object GenelTreeListCOZUM: TcxDBTreeListColumn
          PropertiesClassName = 'TcxButtonEditProperties'
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          DataBinding.FieldName = 'COZUM'
          Width = 550
          Position.ColIndex = 7
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object SQLGenelCokTus: TcxMemo
        Left = 208
        Top = 3
        Lines.Strings = (
          'declare @SrvId int'
          'set @SrvId = :PRM1'
          ''
          'SELECT * FROM ('
          
            'select ROOTKOD=G.DEGER,ID=0,SERVISID=0, SERVISLISTEID=0, KOD=CON' +
            'VERT(VARCHAR(20),G.DEGER),GRUP=G.ANAHTAR,AD='#39#39',ACIKLAMA='#39#39', COZU' +
            'M='#39#39
          'from GENINI G WHERE BOLUM=-3015'
          
            'AND EXISTS (SELECT SERVISTUR FROM SERVISBILGI SB WHERE ISNULL(CO' +
            'NVERT(VARCHAR(20),SB.SERVISTUR),'#39#39')=CONVERT(VARCHAR(20),G.DEGER)'
          'and SERVISID=@SrvId)'
          ''
          'UNION ALL'
          'select ROOTKOD=cast(SB.SERVISTUR as varchar(5)),'
          
            'SB.ID,SERVISID,SB.SERVISLISTEID, KOD = cast(SB.SERVISTUR as varc' +
            'har(5))+'#39'.'#39'+SL.KOD,GRUP='#39#39',SL.AD, SB.ACIKLAMA, SB.COZUM '
          ''
          
            'from SERVISBILGI SB inner join SERVISLISTE SL on SL.ID=SB.SERVIS' +
            'LISTEID'
          'where'
          'SERVISID=@SrvId'
          ') AS X'
          'order by KOD')
        Properties.WordWrap = False
        TabOrder = 1
        Visible = False
        Height = 38
        Width = 588
      end
      object SQLGenelTekTus: TcxMemo
        Left = 224
        Top = 47
        Lines.Strings = (
          'select ROOTKOD=cast(SB.SERVISTUR as varchar(5)),'
          'SB.ID,SERVISID,SB.SERVISLISTEID, '
          
            'KOD = cast(SB.SERVISTUR as varchar(5))+'#39'.'#39'+(select KOD from SERV' +
            'ISLISTE SL where SL.ID=SB.SERVISLISTEID),'
          
            'GRUP=(select top 1 ANAHTAR from GENINI G WHERE BOLUM=-3015 and D' +
            'EGER=SB.SERVISTUR),'
          
            'AD=(select AD from SERVISLISTE SL where SL.ID=SB.SERVISLISTEID),' +
            ' '
          'SB.ACIKLAMA, SB.COZUM ,SB.USTID'
          ''
          'from SERVISBILGI SB'
          'where'
          'SB.SERVISTUR <>200'
          'and'
          'SERVISID=:PRM1')
        Properties.WordWrap = False
        TabOrder = 0
        Visible = False
        Height = 45
        Width = 588
      end
    end
    object cxTabSheet3: TcxTabSheet
      Caption = 'Belgeler'
      ImageIndex = 19
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGridBelgeler: TcxGrid
        Left = 0
        Top = 0
        Width = 936
        Height = 203
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridBelgelerDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsServisBelge
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideFocusRectOnExit = False
          OptionsSelection.InvertSelect = False
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.GroupByBox = False
          object cxGridBelgelerDBTableView1TUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleri
            Width = 78
          end
          object cxGridBelgelerDBTableView1KAYNAK: TcxGridDBColumn
            Caption = 'Kaynak Belge'
            DataBinding.FieldName = 'KAYNAK'
            DataBinding.IsNullValueType = True
            Width = 105
          end
          object cxGridBelgelerDBTableView1HEDEF: TcxGridDBColumn
            Caption = 'Hedef Belge'
            DataBinding.FieldName = 'HEDEF'
            DataBinding.IsNullValueType = True
            Width = 98
          end
          object cxGridBelgelerDBTableView1TARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            Width = 69
          end
          object cxGridBelgelerDBTableView1BELGENO: TcxGridDBColumn
            Caption = 'Belgeno'
            DataBinding.FieldName = 'BELGENO'
            DataBinding.IsNullValueType = True
          end
          object cxGridBelgelerDBTableView1TUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            Width = 106
          end
          object cxGridBelgelerDBTableView1KUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
          object cxGridBelgelerDBTableView1FIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 133
          end
          object cxGridBelgelerDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 280
          end
        end
        object cxGridBelgelerLevel1: TcxGridLevel
          GridView = cxGridBelgelerDBTableView1
        end
      end
    end
  end
  object SQLMemo: TcxMemo
    Left = 445
    Top = 134
    Lines.Strings = (
      'select distinct'
      #9'S.*,SH.BASLAMA,SH.BITIS,SH.TOPLAM_SURE,SH.CALISMA_SURESI,'
      
        #9'SORUN_TIPI=SL.AD, SORUN_ACIKLAMA=SB.ACIKLAMA,SORUN_SONUCU=SB.CO' +
        'ZUM,'
      
        #9'KABUL_EDENAD=(select FIRMA from REHBER R7 where R7.ID = S.EKLEY' +
        'EN),'
      
        #9'KATEGORIAD=case when S.DEMIRBAS=1 then (select STOKADI from DEM' +
        'IRBAS_URUN DU inner join DEMIRBAS D on D.KATEGORIID=DU.ID where ' +
        'D.ID=S.EKIPMANID) else (select AD from KATEGORI K  where K.ID=S.' +
        'EKIPMANID) end ,'
      
        #9'EKIPMANAD=case when S.DEMIRBAS=1 then (select DEMIRBASADI from ' +
        'DEMIRBAS D where D.ID=S.EKIPMANID) else (select AD from EKIPMANL' +
        'AR E  where E.ID=S.EKIPMANID) end ,'
      #9'R1.FIRMA,'
      #9'SORUMLUAD=(SELECT [dbo].[fn_ServisKisiler](S.DURUM, S.ID)),'
      #9'RP.FIRMA as MUS_ILGILIAD,'
      
        #9'LOKASYON =(select ACIKLAMA from LOKASYON L where L.ID=S.LOKASYO' +
        'NID),'
      
        #9'ONAYLAYANAD=(select R5.FIRMA from REHBER R5 where R5.GRUP=334 A' +
        'ND R5.ID = S.DISONAY),'
      
        #9'TESLIM_ALANAD=(select R5.FIRMA from REHBER R5 where R5.GRUP=334' +
        ' AND  R5.ID = S.TESLIM_ALAN),'
      
        #9'ONAYSEKLIAD=(select ANAHTAR from GENINI G where BOLUM=-3005 and' +
        ' G.DEGER=S.ONAYSEKLI ),'
      #9'FB.FATURATARIH, FB.FATURANO,FB.FATURA_TUTARI,'
      #9'SERVIS_ADRESI=RI.AD'
      'from SERVIS S '
      'left outer join V_Servis_Hareket_Ozet SH on SH.SERVISID=S.ID '
      'left outer join REHBER R1 on R1.ID=S.REHBERID'
      'left outer join REHBER RP on RP.ID=S.MUS_ILGILI and RP.GRUP=334'
      
        'left outer join FATBASLIK FB on FB.SERVISID=S.ID and FB.TUR in (' +
        '15,16)'
      
        'left outer join (select *,SIRANO=ROW_NUMBER() over (partition by' +
        ' SB2.SERVISID order by SB2.ID) from SERVISBILGI SB2 where SB2.SE' +
        'RVISTUR=210) SB on SB.SIRANO=1 and SB.SERVISID=S.ID'
      'left outer join SERVISLISTE SL on SL.ID=SB.SERVISLISTEID'
      
        'left outer join REHBERILETISIM RI on RI.REHBERID=S.REHBERID and ' +
        'RI.ID=S.SERVISADRESI')
    Properties.WordWrap = False
    TabOrder = 2
    Visible = False
    Height = 59
    Width = 588
  end
  object PageControlServis: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 944
    Height = 255
    Align = alClient
    TabOrder = 3
    Properties.ActivePage = TabServis
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlServisChange
    ClientRectBottom = 251
    ClientRectLeft = 4
    ClientRectRight = 940
    ClientRectTop = 27
    object TabServis: TcxTabSheet
      Caption = 'Servis'
      ImageIndex = 7
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 930
        Height = 29
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 74
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
          ImageIndex = 7
          ImageName = 'PngImage6'
          OnClick = YeniTusClick
        end
        object SilTus: TToolButton
          Left = 74
          Top = 0
          Caption = 'Sil'
          ImageIndex = 8
          ImageName = 'PngImage7'
          OnClick = SilTusClick
        end
        object ToolButton3: TToolButton
          Left = 148
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 17
          ImageName = 'PngImage16'
          Style = tbsSeparator
        end
        object DegisTus: TToolButton
          Left = 156
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 9
          ImageName = 'PngImage8'
          Style = tbsTextButton
          OnClick = DegisTusClick
        end
        object ToolButton1: TToolButton
          Left = 230
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 22
          ImageName = 'PngImage22'
          Style = tbsSeparator
        end
        object YaziciYaz: TToolButton
          Left = 238
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          ImageName = 'PngImage15'
        end
      end
      object GridServis: TcxGrid
        Left = 0
        Top = 35
        Width = 936
        Height = 189
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        PopupMenu = PopupMenuServis
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridServisView: TcxGridDBTableView
          OnDblClick = DegisTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridServisViewCanFocusRecord
          OnFocusedRecordChanged = GridServisViewFocusedRecordChanged
          OnSelectionChanged = GridServisViewSelectionChanged
          DataController.DataSource = DtsServisler
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
            end
            item
              Kind = skSum
              Position = spFooter
            end
            item
              Kind = skSum
              Position = spFooter
            end
            item
              Kind = skCount
              Position = spFooter
              Column = GridServisViewFIRMA
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'FATURA_MATRAHI'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'KDV_TUTARI'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'FATURA_TUTARI'
            end
            item
              Kind = skCount
              Column = GridServisViewFIRMA
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridServisViewStylesGetContentStyle
          object GridServisViewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repServisDurum
            Width = 60
          end
          object GridServisViewEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Ekleme Tarihi'
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Width = 110
          end
          object GridServisViewBASLAMATARIHI: TcxGridDBColumn
            Caption = 'Ba'#351'lama'
            DataBinding.FieldName = 'BASLAMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Width = 111
          end
          object GridServisViewBITISTARIHI: TcxGridDBColumn
            Caption = 'Biti'#351
            DataBinding.FieldName = 'BITIS'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Width = 113
          end
          object GridServisViewTOPLAM_SURE: TcxGridDBColumn
            Caption = 'Toplam S'#252're'
            DataBinding.FieldName = 'TOPLAM_SURE'
            DataBinding.IsNullValueType = True
            Width = 80
          end
          object GridServisViewCALISMA_SURESI: TcxGridDBColumn
            Caption = #199'al'#305#351'ma S'#252'resi'
            DataBinding.FieldName = 'CALISMA_SURESI'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object GridServisViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 23
          end
          object GridServisViewServisNO: TcxGridDBColumn
            Caption = 'Servis No'
            DataBinding.FieldName = 'ServisNO'
            DataBinding.IsNullValueType = True
            Width = 63
          end
          object GridServisViewTURU: TcxGridDBColumn
            Caption = 'T'#252'r'#252
            DataBinding.FieldName = 'TURU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repServisTuru
          end
          object GridServisViewKATEGORIAD: TcxGridDBColumn
            Caption = 'Kategori'
            DataBinding.FieldName = 'KATEGORIAD'
            DataBinding.IsNullValueType = True
            Width = 57
          end
          object GridServisViewKONU: TcxGridDBColumn
            Caption = 'Konu'
            DataBinding.FieldName = 'KONUSU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 141
          end
          object GridServisViewURUNADI: TcxGridDBColumn
            Caption = #220'r'#252'n Ad'#305
            DataBinding.FieldName = 'EKIPMANAD'
            DataBinding.IsNullValueType = True
            Width = 137
          end
          object GridServisViewFIRMA: TcxGridDBColumn
            Caption = 'Talep Eden'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 127
          end
          object GridServisViewSORUN_TIPI: TcxGridDBColumn
            Caption = 'Sorun Tipi'
            DataBinding.FieldName = 'SORUN_TIPI'
            DataBinding.IsNullValueType = True
            Width = 274
          end
          object GridServisViewSORUN_ACIKLAMA: TcxGridDBColumn
            Caption = 'Sorun A'#231#305'klama'
            DataBinding.FieldName = 'SORUN_ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 500
          end
          object GridServisViewSORUN_SONUCU: TcxGridDBColumn
            Caption = 'Sorun Sonu'#231
            DataBinding.FieldName = 'SORUN_SONUCU'
            DataBinding.IsNullValueType = True
            Width = 500
          end
          object GridServisViewSORUMLUAD: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'SORUMLUAD'
            DataBinding.IsNullValueType = True
            Width = 81
          end
          object GridServisViewFATURATARIH: TcxGridDBColumn
            Caption = 'Fatura Tarihi'
            DataBinding.FieldName = 'FATURATARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Width = 74
          end
          object GridServisViewFATURANO: TcxGridDBColumn
            Caption = 'Fatura No'
            DataBinding.FieldName = 'FATURANO'
            DataBinding.IsNullValueType = True
            Width = 65
          end
          object GridServisViewFATURA_TUTARI: TcxGridDBColumn
            Caption = 'Fatura Tutar'#305
            DataBinding.FieldName = 'FATURA_TUTARI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 90
          end
          object GridServisViewNOTLAR: TcxGridDBColumn
            DataBinding.FieldName = 'NOTLAR'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridServisViewSUBEID: TcxGridDBColumn
            Caption = #350'ube'
            DataBinding.FieldName = 'SUBEID'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
            Width = 59
          end
          object GridServisViewSERINO: TcxGridDBColumn
            Caption = 'Seri No'
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
          end
          object GridServisViewKABUL_EDENAD: TcxGridDBColumn
            Caption = 'Kabul Eden'
            DataBinding.FieldName = 'KABUL_EDENAD'
            DataBinding.IsNullValueType = True
            Width = 88
          end
          object GridServisViewKABUL_SEKLI: TcxGridDBColumn
            Caption = 'Kabul '#350'ekli'
            DataBinding.FieldName = 'KABUL_SEKLI'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repServisKabulSekli
          end
          object GridServisViewKABULNOTU: TcxGridDBColumn
            Caption = 'Kabul Notu'
            DataBinding.FieldName = 'KABULNOTU'
            DataBinding.IsNullValueType = True
          end
          object GridServisViewKABUL_YAZISI_TURU: TcxGridDBColumn
            Caption = 'Kabul Yaz'#305's'#305
            DataBinding.FieldName = 'KABUL_YAZISI_TURU'
            DataBinding.IsNullValueType = True
          end
          object GridServisViewTESLIM_ALANAD: TcxGridDBColumn
            Caption = 'Teslim Alan'
            DataBinding.FieldName = 'TESLIM_ALANAD'
            DataBinding.IsNullValueType = True
            Width = 73
          end
          object GridServisViewTESLIM_EDENAD: TcxGridDBColumn
            Caption = 'Teslim Eden'
            DataBinding.FieldName = 'TESLIM_EDENAD'
            DataBinding.IsNullValueType = True
          end
          object GridServisViewTESLIM_TARIHI: TcxGridDBColumn
            Caption = 'Teslim Tarihi'
            DataBinding.FieldName = 'TESLIM_TARIHI'
            DataBinding.IsNullValueType = True
            Width = 76
          end
          object GridServisViewTESLIM_SEKLI: TcxGridDBColumn
            Caption = 'Teslim '#350'ekli'
            DataBinding.FieldName = 'TESLIM_SEKLI'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repServisKabulSekli
          end
          object GridServisViewTESLIMNOTU: TcxGridDBColumn
            Caption = 'Teslim Notu'
            DataBinding.FieldName = 'TESLIMNOTU'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object GridServisViewKAPSAM: TcxGridDBColumn
            Caption = 'Garanti'
            DataBinding.FieldName = 'KAPSAM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repServisKapsam
          end
          object GridServisViewACIL: TcxGridDBColumn
            Caption = 'Acil'
            DataBinding.FieldName = 'ACIL'
            DataBinding.IsNullValueType = True
          end
          object GridServisViewDISSERVIS: TcxGridDBColumn
            Caption = 'D'#305#351' Servis'
            DataBinding.FieldName = 'DISSERVIS'
            DataBinding.IsNullValueType = True
          end
          object GridServisViewSERVISADRESI: TcxGridDBColumn
            Caption = 'Servis Adresi'
            DataBinding.FieldName = 'SERVIS_ADRESI'
            DataBinding.IsNullValueType = True
            Width = 142
          end
          object GridServisViewMUS_ILGILIAD: TcxGridDBColumn
            Caption = 'Bildirimi Yapan'
            DataBinding.FieldName = 'MUS_ILGILIAD'
            DataBinding.IsNullValueType = True
            Width = 86
          end
          object GridServisViewLokasyon: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'LOKASYON'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 122
          end
          object GridServisViewEKLEYEN: TcxGridDBColumn
            Caption = 'Ekleyen'
            DataBinding.FieldName = 'EKLEYEN'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesi
          end
        end
        object GridServisLevel1: TcxGridLevel
          GridView = GridServisView
        end
      end
    end
    object Tabhareket: TcxTabSheet
      Caption = 'Hareket'
      ImageIndex = 32
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 930
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
        object HareketServisEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Servis'
          ImageIndex = 7
          ImageName = 'PngImage6'
          OnClick = HareketServisEkleTusClick
        end
        object HareketEkleTus: TToolButton
          Left = 82
          Top = 0
          Caption = 'Hareket'
          DropdownMenu = PopupMenuHareket
          ImageIndex = 7
          ImageName = 'PngImage6'
          Style = tbsDropDown
          OnClick = HareketEkleTusClick
        end
        object HareketSilTus: TToolButton
          Left = 179
          Top = 0
          Caption = 'Sil'
          ImageIndex = 8
          ImageName = 'PngImage7'
          Visible = False
          OnClick = HareketSilTusClick
        end
        object ToolButton5: TToolButton
          Left = 261
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 17
          ImageName = 'PngImage16'
          Style = tbsSeparator
        end
        object ButtonServis: TToolButton
          Left = 269
          Top = 0
          Caption = 'Servis'
          ImageIndex = 9
          ImageName = 'PngImage8'
          OnClick = ButtonServisClick
        end
        object HareketDegisTus: TToolButton
          Left = 351
          Top = 0
          Caption = 'Hareket'
          ImageIndex = 9
          ImageName = 'PngImage8'
          Style = tbsTextButton
          Visible = False
          OnClick = HareketDegisTusClick
        end
        object ToolButton7: TToolButton
          Left = 433
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 22
          ImageName = 'PngImage22'
          Style = tbsSeparator
        end
        object ToolButton8: TToolButton
          Left = 441
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          ImageName = 'PngImage15'
        end
      end
      object GridHareket: TcxGrid
        Left = 0
        Top = 43
        Width = 936
        Height = 181
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridHareketView: TcxGridDBTableView
          OnDblClick = HareketDegisTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridHareketViewCanFocusRecord
          OnFocusedRecordChanged = GridHareketViewFocusedRecordChanged
          OnSelectionChanged = GridServisViewSelectionChanged
          DataController.DataSource = DtsHAREKET
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
            end
            item
              Kind = skSum
              Position = spFooter
            end
            item
              Kind = skSum
              Position = spFooter
            end
            item
              Kind = skCount
              Position = spFooter
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skCount
              FieldName = 'FIRMA'
              Column = GridHareketViewFIRMA
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridServisViewStylesGetContentStyle
          object GridHareketViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewSHID: TcxGridDBColumn
            DataBinding.FieldName = 'SERVISID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridHareketViewBITISSEC: TcxGridDBColumn
            Caption = 'Bitmi'#351
            DataBinding.FieldName = 'BITISSEC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ValueGrayed = 'False'
          end
          object GridHareketViewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repServisDurum
          end
          object GridHareketViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridHareketViewSERVISNO: TcxGridDBColumn
            Caption = 'Servis No'
            DataBinding.FieldName = 'SERVISNO'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewFIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewMUS_ILGILIAD: TcxGridDBColumn
            Caption = 'Bildirim Yapan'
            DataBinding.FieldName = 'MUS_ILGILIAD'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewBASLAMA: TcxGridDBColumn
            Caption = 'Ba'#351'lama'
            DataBinding.FieldName = 'BASLAMATARIHI'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewBITIS: TcxGridDBColumn
            Caption = 'Biti'#351
            DataBinding.FieldName = 'BITISTARIHI'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewCALISMA_SURESI: TcxGridDBColumn
            Caption = 'S'#252're'
            DataBinding.FieldName = 'CALISMA_SURESI'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewEKIPMANAD: TcxGridDBColumn
            Caption = 'Ekipman'
            DataBinding.FieldName = 'EKIPMANAD'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewKONUSU: TcxGridDBColumn
            Caption = 'Konusu'
            DataBinding.FieldName = 'KONUSU'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Ekleme Tarihi'
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Width = 78
          end
          object GridHareketViewHAREKETEKLEYENAD: TcxGridDBColumn
            Caption = 'Ekleyen'
            DataBinding.FieldName = 'HAREKETEKLEYENAD'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewPERSONEL: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'PERSONELAD'
            DataBinding.IsNullValueType = True
          end
          object GridHareketViewPROJEAD: TcxGridDBColumn
            Caption = 'Proje Ad'#305
            DataBinding.FieldName = 'PROJEAD'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = GridHareketView
        end
      end
    end
  end
  object DtsServisler: TDataSource
    DataSet = SERVIS
    Left = 56
    Top = 197
  end
  object SERVIS: TFDQuery
    AfterOpen = SERVISAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from vServislistesi S')
    Left = 597
    Top = 130
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 175
    Top = 157
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
  object frxServis: TfrxDBDataset
    UserName = 'Servis'
    CloseDataSource = False
    DataSet = SERVIS
    BCDToCurrency = False
    DataSetOptions = []
    Left = 52
    Top = 244
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 343
    Top = 148
  end
  object TabGenel: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    Left = 149
    Top = 223
  end
  object DtsGenel: TDataSource
    DataSet = TabGenel
    Left = 149
    Top = 269
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
    Left = 264
    Top = 232
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
  end
  object DtsSmsEPosta: TDataSource
    DataSet = TabSmsEPosta
    Left = 264
    Top = 280
  end
  object TabHareketler: TFDQuery
    AfterScroll = TabHareketlerAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *,'
      'SURE=[dbo].[fn_TarihFarkiFormatli] (BASLAMA,BITIS)'
      ' from SERVISHAREKET where SERVISID=:PServisID order by ID')
    Left = 330
    Top = 220
    ParamData = <
      item
        Name = 'PServisID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
  end
  object DtsHareketler: TDataSource
    DataSet = TabHareketler
    Left = 331
    Top = 270
  end
  object TabServisBelge: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'EXEC sp_Prg_Servis_Belgeler :PSerID')
    Left = 428
    Top = 224
    ParamData = <
      item
        Name = 'PSerID'
        DataType = ftWideString
        Size = 4
        Value = '1108'
      end>
  end
  object DtsServisBelge: TDataSource
    DataSet = TabServisBelge
    Left = 431
    Top = 269
  end
  object frxServisBelge: TfrxDBDataset
    UserName = 'SERVISBELGE'
    CloseDataSource = False
    DataSet = TabServisBelge
    BCDToCurrency = False
    DataSetOptions = []
    Left = 430
    Top = 320
  end
  object frxHareketler: TfrxDBDataset
    UserName = 'SERVISHAREKETLER'
    CloseDataSource = False
    DataSet = TabHareketler
    BCDToCurrency = False
    DataSetOptions = []
    Left = 334
    Top = 336
  end
  object frxGENEL: TfrxDBDataset
    UserName = 'SERVISGENEL'
    CloseDataSource = False
    DataSet = TabGenel
    BCDToCurrency = False
    DataSetOptions = []
    Left = 150
    Top = 328
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 587
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 32
    Top = 104
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
    object N4: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      ImageIndex = 19
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 19
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
    Left = 585
    Top = 369
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
  object cxGridPopupYorumlar: TcxGridPopupMenu
    PopupMenus = <
      item
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 768
    Top = 400
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
    Left = 207
    Top = 404
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      ImageName = 'PngImage0'
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      ImageName = 'PngImage16'
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object HAREKET: TFDQuery
    AfterOpen = HAREKETAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *'
      'from VServisHareket S')
    Left = 733
    Top = 162
  end
  object DtsHAREKET: TDataSource
    DataSet = HAREKET
    Left = 784
    Top = 141
  end
  object PopupMenuHareket: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupMenuHareketPopup
    Left = 151
    Top = 101
    object MenuItem1: TMenuItem
      Tag = 102648
      Caption = 'Kay'#305't Kabul Mod'#252'l'#252' Geli'#351'tirme '#304'ste'#287'i'
      ImageIndex = 0
    end
  end
  object PopupMenuServis: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 335
    Top = 85
    object ServisInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = ServisInfoMenuClick
    end
  end
end
