object GorevListeDlg: TGorevListeDlg
  Left = 0
  Top = 0
  Width = 1021
  Height = 607
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object cxSplitterTakvim: TcxSplitter
    Left = 655
    Top = 0
    Width = 8
    Height = 607
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salRight
    Control = PanelTakvim
  end
  object PanelListe: TPanel
    Left = 0
    Top = 0
    Width = 655
    Height = 607
    Align = alClient
    TabOrder = 1
    object PanelYeniIs: TJvNavPanelHeader
      Left = 1
      Top = 1
      Width = 653
      Height = 41
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 14540253
      ColorTo = 11776947
      ImageIndex = 0
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 653
        Height = 41
        Align = alTop
        Caption = 'Panel9'
        TabOrder = 0
        object ToolBar6: TToolBar
          Left = 1
          Top = 1
          Width = 208
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
          object YenileTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yenile'
            ImageIndex = 9
            ImageName = 'PngImage9'
            OnClick = YenileTusClick
          end
          object ToolButton4: TToolButton
            Left = 46
            Top = 0
            Width = 8
            Caption = 'ToolButton4'
            ImageIndex = 8
            ImageName = 'PngImage15'
            Style = tbsSeparator
          end
          object GorevEkleTus: TToolButton
            Left = 54
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = GorevEkleTusClick
          end
          object GorevSilTus: TToolButton
            Left = 100
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = IsiSilMenuClick
          end
          object ToolButton15: TToolButton
            Left = 146
            Top = 0
            Width = 8
            Caption = 'ToolButton6'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object GorevDuzenleTus: TToolButton
            Left = 154
            Top = 0
            Caption = 'D'#252'zenle'
            ImageIndex = 7
            ImageName = 'PngImage7'
            OnClick = DuzenleMenuClick
          end
          object ToolButton5: TToolButton
            Left = 200
            Top = 0
            Width = 8
            Caption = 'ToolButton5'
            ImageIndex = 8
            ImageName = 'PngImage15'
            Style = tbsSeparator
          end
        end
        object JvNavPanelHeader1: TJvNavPanelHeader
          Left = 209
          Top = 1
          Width = 443
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
            Left = 30
            Top = 6
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
            Left = 207
            Top = 6
            RepositoryItem = Tablo.RepGorevSonKac
            ParentFont = False
            Properties.Items = <>
            Style.Color = clSilver
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWhite
            Style.Font.Height = -15
            Style.Font.Name = 'Arial'
            Style.Font.Style = [fsBold]
            Style.TextColor = clBlack
            Style.IsFontAssigned = True
            TabOrder = 1
            Visible = False
            Width = 154
          end
        end
      end
    end
    object cxSplitter2: TcxSplitter
      Left = 1
      Top = 405
      Width = 653
      Height = 8
      HotZoneClassName = 'TcxMediaPlayer8Style'
      AlignSplitter = salBottom
      Control = cxPageControl1
      ExplicitWidth = 8
    end
    object cxPageControl1: TcxPageControl
      Properties.Images = Tablo.PNGImageList2
      Left = 1
      Top = 413
      Width = 653
      Height = 193
      Align = alBottom
      TabOrder = 5
      Properties.ActivePage = cxTabSheet1
      Properties.CustomButtons.Buttons = <>
      OnChange = cxPageControl1Change
      ClientRectBottom = 189
      ClientRectLeft = 4
      ClientRectRight = 649
      ClientRectTop = 26
      object cxTabSheet1: TcxTabSheet
        Caption = #304#231'erik'
        ImageIndex = 19
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object MemoNOTLAR: TcxDBMemo
          Left = 0
          Top = 33
          Align = alLeft
          DataBinding.DataField = 'NOTLAR'
          DataBinding.DataSource = DtsIcerik
          Properties.ScrollBars = ssVertical
          Style.Color = clSkyBlue
          TabOrder = 0
          Height = 130
          Width = 293
        end
        object cxDBLabel1: TcxDBLabel
          Left = 0
          Top = 0
          Align = alTop
          DataBinding.DataField = 'KONUSU'
          DataBinding.DataSource = DtsIcerik
          ParentColor = False
          Style.Color = clSkyBlue
          Height = 33
          Width = 645
        end
        object PanelYorum: TPanel
          Left = 293
          Top = 33
          Width = 352
          Height = 130
          Align = alClient
          Caption = 'PanelYorum'
          TabOrder = 2
          DesignSize = (
            352
            130)
          object Panel10: TPanel
            Left = 1
            Top = 68
            Width = 350
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
              Width = 202
            end
            object BtnMesajGonder: TcxButton
              Left = 203
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
              Left = 288
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
            Top = 109
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
            ExplicitTop = 108
            AnchorX = 351
          end
          object GridYorum: TcxGrid
            Left = 1
            Top = 1
            Width = 350
            Height = 67
            Align = alClient
            TabOrder = 2
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
              object cxGridDBCardViewYORUM: TcxGridDBCardViewRow
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
            object cxGridLevel1: TcxGridLevel
              GridView = GridYorumDBCardView1
            end
          end
          object CheckZenginMetin: TcxCheckBox
            Left = 256
            Top = 111
            Anchors = [akTop, akRight]
            Caption = 'Zengin Metin'
            TabOrder = 3
          end
        end
      end
    end
    object PageControlUst: TcxPageControl
      Properties.Images = Tablo.PNGImageList2
      Left = 1
      Top = 42
      Width = 653
      Height = 363
      Align = alClient
      TabOrder = 4
      Properties.ActivePage = TabSheetListe
      Properties.CustomButtons.Buttons = <>
      OnChange = PageControlUstChange
      ClientRectBottom = 359
      ClientRectLeft = 4
      ClientRectRight = 649
      ClientRectTop = 26
      object TabSheetListe: TcxTabSheet
        Caption = 'Liste'
        ImageIndex = 32
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object GridGorev: TcxGrid
          Left = 0
          Top = 0
          Width = 645
          Height = 333
          Align = alClient
          PopupMenu = GorevlerMenu
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridGorevView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridGorevViewCanFocusRecord
            OnCellDblClick = GridGorevViewCellDblClick
            OnSelectionChanged = GridGorevViewSelectionChanged
            Styles.OnGetContentStyle = GridGorevViewStylesGetContentStyle
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsGorevler
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = '###,###,##0.00'
                Kind = skSum
                Position = spFooter
                FieldName = 'LISTEFIYATI'
              end
              item
                Format = '###,###,##0.00'
                Kind = skSum
                Position = spFooter
                FieldName = 'SATISFIYATI'
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = '###,###,##0.00'
                Kind = skSum
                FieldName = 'SATISFIYATI'
              end
              item
                Format = '###,###,##0.00'
                Kind = skSum
                FieldName = 'LISTEFIYATI'
              end
              item
                Kind = skCount
                FieldName = 'FIRMA'
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.CellHints = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.MultiSelect = True
            OptionsView.Footer = True
            OptionsView.GroupFooterMultiSummaries = True
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.Indicator = True
            Preview.MaxLineCount = 0
            object GridGorevViewACKAPA: TcxGridDBColumn
              DataBinding.FieldName = 'ACKAPA'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
              IsCaptionAssigned = True
            end
            object GridGorevViewLISTEID: TcxGridDBColumn
              DataBinding.FieldName = 'LISTEID'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepIsKlasorListesi
            end
            object GridGorevViewGOREV_ID: TcxGridDBColumn
              DataBinding.FieldName = 'GOREV_ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridGorevViewKONUSU: TcxGridDBColumn
              DataBinding.FieldName = 'KONUSU'
              DataBinding.IsNullValueType = True
              Width = 167
            end
            object GridGorevViewTUR: TcxGridDBColumn
              Caption = 'T'#220'R'#220
              DataBinding.FieldName = 'TURU'
              DataBinding.IsNullValueType = True
              Width = 151
            end
            object GridGorevViewCARIAD: TcxGridDBColumn
              Caption = 'CAR'#304' AD '
              DataBinding.FieldName = 'CARIAD'
              DataBinding.IsNullValueType = True
              Width = 205
            end
            object GridGorevViewATANAN: TcxGridDBColumn
              Caption = 'ATANAN'
              DataBinding.FieldName = 'ATANAN1'
              DataBinding.IsNullValueType = True
              Width = 126
            end
            object GridGorevViewDURUM: TcxGridDBColumn
              DataBinding.FieldName = 'DURUM'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepGorevDurum
            end
            object GridGorevViewREH_ID: TcxGridDBColumn
              DataBinding.FieldName = 'REH_ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridGorevViewEKLEYEN: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEYEN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridGorevViewBAYRAK: TcxGridDBColumn
              DataBinding.FieldName = 'BAYRAK'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
              Width = 54
            end
            object GridGorevViewNOTLAR_BIT: TcxGridDBColumn
              Caption = 'NOTLAR'
              DataBinding.FieldName = 'NOTLAR_BIT'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
            end
            object GridGorevViewYORUM_BIT: TcxGridDBColumn
              Caption = 'YORUM'
              DataBinding.FieldName = 'YORUM_BIT'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
            end
            object GridGorevViewEKLEMETARIHI: TcxGridDBColumn
              Caption = 'TAR'#304'H'
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
            end
            object GridGorevViewBASLAMATARIHI: TcxGridDBColumn
              Caption = 'BA'#350'LAMA'
              DataBinding.FieldName = 'BASLAMATARIHI'
              DataBinding.IsNullValueType = True
            end
            object GridGorevViewBITISTARIHI: TcxGridDBColumn
              Caption = 'B'#304'T'#304#350
              DataBinding.FieldName = 'BITISTARIHI'
              DataBinding.IsNullValueType = True
            end
            object GridGorevViewPROJEKODU: TcxGridDBColumn
              DataBinding.FieldName = 'PROJEKODU'
              DataBinding.IsNullValueType = True
              Width = 220
            end
            object GridGorevViewEKLEYENAD: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEYENAD'
              DataBinding.IsNullValueType = True
              Width = 250
            end
          end
          object cxGridLevel3: TcxGridLevel
            GridView = GridGorevView
          end
        end
      end
      object TabSheetGrup: TcxTabSheet
        Caption = 'Grup'
        ImageIndex = 19
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object FTileControl: TdxTileControl
          Left = 0
          Top = 0
          Width = 645
          Height = 333
          ActionBars.IndentHorz = 10
          BorderStyle = cxcbsDefault
          OptionsBehavior.FocusItemOnCycle = False
          OptionsView.GroupMaxRowCount = 20
          OptionsView.IndentHorz = 5
          OptionsView.IndentVert = 5
          OptionsView.ItemHeight = 75
          OptionsView.ItemIndent = 5
          OptionsView.ItemWidth = 100
          TabOrder = 0
          OnItemDragBegin = FTileControlItemDragBegin
          OnItemDragEnd = FTileControlItemDragEnd
          object FTileControlActionBarItem1: TdxTileControlActionBarItem
            Caption = 'qqqqq'
          end
          object FTileControlActionBarItem2: TdxTileControlActionBarItem
            Caption = 'yennn'
          end
          object FTileControlItem1: TdxTileControlItem
            GroupIndex = -1
            IndexInGroup = -1
            RowCount = 5
            Size = tcisSmall
            Style.Stretch = smTile
            Text1.AssignedValues = []
            Text2.AssignedValues = []
            Text3.AssignedValues = []
            Text4.AssignedValues = []
          end
          object FTileControlItem2: TdxTileControlItem
            GroupIndex = -1
            IndexInGroup = -1
            Size = tcisSmall
            Text1.AssignedValues = []
            Text2.AssignedValues = []
            Text3.AssignedValues = []
            Text4.AssignedValues = []
          end
          object FTileControlItem3: TdxTileControlItem
            GroupIndex = -1
            IndexInGroup = -1
            Size = tcisSmall
            Text1.AssignedValues = []
            Text2.AssignedValues = []
            Text3.AssignedValues = []
            Text4.AssignedValues = []
            Visible = False
          end
          object FTileControlItem4: TdxTileControlItem
            GroupIndex = -1
            IndexInGroup = -1
            Size = tcisSmall
            Text1.AssignedValues = []
            Text2.AssignedValues = []
            Text3.AssignedValues = []
            Text4.AssignedValues = []
          end
        end
      end
    end
    object SQLKullan: TMemo
      Left = 70
      Top = 120
      Width = 480
      Height = 33
      Lines.Strings = (
        ''
        'select ID='#39'1'#39'+convert(varchar(8),R.ID),Ad=R.FIRMA,'
        'G'#246'rev=(select ANAHTAR from GENINI where BOLUM=-2205 and DEGER = '
        'ROL.GOREVID), '
        
          'Departman=(select ANAHTAR from GENINI where BOLUM=-2206 and DEGE' +
          'R = '
        'ROL.DEPARTMAN),'
        #350'ube=(SELECT FIRMA FROM REHBER WHERE ID=R.SUBEID),'
        'Kategori='#39'Personel'#39',T'#252'r=1'
        'from REHBER R '
        'inner join KULLANICI K on R.ID=K.REHBERID '
        'left outer join ROLLER ROL on ROL.ID=R.SINIF'
        'where '
        'R.GRUP=335 and R.DURUM=1 '
        ''
        'order by 2')
      TabOrder = 0
      Visible = False
    end
    object SQLGorevMemo: TMemo
      Left = 174
      Top = 271
      Width = 480
      Height = 74
      Lines.Strings = (
        'select   distinct G.ID, G.ACKAPA, '
        'LISTEID=G.LISTEID, LISTEADI=GL.ADI,'
        'G.KONUSU,'
        
          'TURU=(SELECT top 1 ANAHTAR FROM GENINI where BOLUM=-21044 and DI' +
          'L=-1 and '
        'DEGER=G.TURU),'
        'G.EKLEYEN,'
        'G.REHBERID,CARIAD=(SELECT FIRMA FROM REHBER R WHERE '
        'R.ID=G.REHBERID),'
        
          'MUS_ILGILI = (SELECT FIRMA FROM REHBER R WHERE R.ID=G.MUS_ILGILI' +
          '),'
        'ATANAN1=(SELECT [dbo].[fn_GorevVerilenKisiler](11, G.ID)),'
        'G.BASLAMATARIHI,G.BITISTARIHI,'
        
          'TEKRAR_BIT=convert(bit, (CASE WHEN TEKRARID>0 THEN 1 ELSE 0 END)' +
          '),'
        
          'ANIMSAT_BIT=convert(bit, (CASE WHEN ANIMSAT>0 THEN 1 ELSE 0 END)' +
          '),'
        'G.BAYRAK, G.DURUM, G.EKLEMETARIHI, '
        'PROJEKODU=(SELECT PROJEKODU FROM PROJELER P '
        'WHERE '
        'P.ID=G.PROJEID),'
        ''
        ''
        ''
        ''
        ''
        ''
        'EKLEYENAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN)'
        'from '
        #9'GOREVLER G'
        #9'INNER JOIN GOREVLISTE GL on G.LISTEID=GL.ID'
        #9'LEFT JOIN GOREVYORUM GY ON G.ID=GY.GOREVID '
        #9'--GK'
        'WHERE  1=1  '
        ''
        '')
      TabOrder = 3
      Visible = False
    end
  end
  object PanelTakvim: TPanel
    Left = 663
    Top = 0
    Width = 358
    Height = 607
    Align = alRight
    TabOrder = 2
    object Scheduler: TcxScheduler
      Left = 1
      Top = 59
      Width = 356
      Height = 547
      ViewDay.Active = True
      ViewDay.AlwaysShowEventTime = True
      ViewDay.ShowAllDayEventsInContentArea = True
      ViewDay.TimeRulerMinutes = True
      ViewGantt.Scales.MajorUnit = suYear
      ViewGantt.EventDetailInfo = True
      ViewGantt.ShowTimeAsClock = True
      ViewGantt.ShowExpandButtons = True
      ViewGantt.ShowTotalProgressLine = True
      Align = alClient
      ContentPopupMenu.PopupMenu = GorevlerMenu
      ContentPopupMenu.UseBuiltInPopupMenu = False
      ContentPopupMenu.Items = []
      ControlBox.Control = pnlControls
      DialogsLookAndFeel.SkinName = ''
      EventOperations.Creating = False
      EventOperations.Deleting = False
      EventOperations.DialogEditing = False
      EventOperations.DialogShowing = False
      EventOperations.InplaceEditing = False
      EventOperations.Intersection = False
      EventOperations.Sizing = False
      EventPopupMenu.PopupMenu = GorevlerMenu
      EventPopupMenu.UseBuiltInPopupMenu = False
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      OptionsBehavior.SelectOnRightClick = True
      OptionsView.AdditionalTimeZoneDaylightSaving = True
      OptionsView.CurrentTimeZoneDaylightSaving = True
      OptionsView.ResourceHeaders.Height = 10
      OptionsView.ResourceHeaders.MultilineCaptions = True
      OptionsView.ResourcesPerPage = 3
      OptionsView.WorkStart = 0.000000000000000000
      OptionsView.WorkFinish = 0.999305555555555600
      PopupMenu = GorevlerMenu
      Storage = SchedulerDBStorage
      TabOrder = 0
      OnDblClick = SchedulerDblClick
      OnDragDrop = SchedulerDragDrop
      OnDragOver = SchedulerDragOver
      Splitters = {
        D400000096000000630100009B000000CF00000001000000D400000022020000}
      StoredClientBounds = {01000000010000006301000022020000}
      object pnlControls: TPanel
        Left = 0
        Top = 0
        Width = 143
        Height = 391
        Align = alClient
        BevelOuter = bvNone
        Color = clWindow
        TabOrder = 0
        object Memo1: TMemo
          Left = 0
          Top = 52
          Width = 143
          Height = 339
          Align = alClient
          BorderStyle = bsNone
          Lines.Strings = (
            'Your '
            'controls can '
            'be placed '
            'here')
          TabOrder = 1
        end
        object GridPersonel: TcxGrid
          Left = 0
          Top = 52
          Width = 143
          Height = 339
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          object GridPersonelView: TcxGridDBTableView
            DragMode = dmAutomatic
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsPersonel
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'TUTAR'
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsSelection.MultiSelect = True
            OptionsView.DataRowHeight = 22
            OptionsView.GridLines = glNone
            OptionsView.GroupByBox = False
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.Header = False
            object GridPersonelViewSEC: TcxGridDBColumn
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.DisplayGrayed = 'False'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Properties.OnEditValueChanged = GridPersonelViewSECPropertiesEditValueChanged
              Width = 20
            end
            object GridPersonelViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridPersonelViewFIRMA: TcxGridDBColumn
              DataBinding.FieldName = 'FIRMA'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.ReadOnly = True
              Options.Editing = False
              Width = 119
              IsCaptionAssigned = True
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = GridPersonelView
          end
        end
        object PanelPersonelSec: TPanel
          Left = 0
          Top = 0
          Width = 143
          Height = 25
          Align = alTop
          BevelOuter = bvNone
          Caption = 'Personel Listesi'
          Color = clHighlight
          ParentBackground = False
          TabOrder = 2
          Visible = False
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 28
          Width = 137
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 60
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
          TabOrder = 3
          Transparent = True
          object PersonelHepsiSec: TToolButton
            Left = 0
            Top = 0
            Caption = 'Hepsi'
            ImageIndex = 23
            ImageName = 'PngImage23'
            OnClick = PersonelHepsiSecClick
          end
          object PersonelHepsiBirak: TToolButton
            Left = 60
            Top = 0
            Caption = 'Hi'#231'biri'
            ImageIndex = 24
            ImageName = 'PngImage24'
            OnClick = PersonelHepsiBirakClick
          end
        end
      end
    end
    object MemoServisSQL: TMemo
      Left = 102
      Top = 413
      Width = 553
      Height = 52
      Lines.Strings = (
        'select   distinct'
        #9'type = 0, '
        
          #9'start = convert(datetime, convert(varchar(20), G.BASLAMATARIHI,' +
          ' 120), 120) ,'
        
          #9'finish = convert(datetime, convert(varchar(20), G.BITISTARIHI, ' +
          '120),120),   '
        #9'options=3, '
        
          #9'caption = G.KONUSU+'#39' / '#39'+ (SELECT [dbo].[fn_GorevVerilenKisiler' +
          '](12, G.ID))+'#39' / '#39'+ ISNULL'
        '(Musteri.FIRMA,'#39#39') ,'
        #9'location='#39#39','
        #9'message='#39#39', '
        #9'state=0,   '
        #9'labelColor =  case when G.ACKAPA = 1 THEN 13882323 --Gri'
        '                    ELSE 16436871 END, --Mavi'
        '                --ResourceID = G.SORUMLU,'
        #9'Dosya='#39'SERVIS'#39', '
        #9'GOREV_ID=G.ID,'
        #9'REHBERID=G.REHBERID,'
        #9'EKLEYEN=G.EKLEYEN,'
        #9'ACKAPA=G.ACKAPA,'
        #9'BAYRAK=G.ACIL,'
        #9'LISTEID=-6,'
        #9'TUR=G.TURU'
        'from '
        #9'SERVIS G'
        #9'--INNER JOIN SERVISHAREKET SH ON G.ID='
        '--(SELECT TOP 1 SH.SERVISID FROM SERVISHAREKET '
        '--ORDER BY ACILIS)'
        
          #9'LEFT JOIN GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREVID AND GK1.TU' +
          'R=12 '
        #9'--left outer join REHBER Pers on Pers.ID=G.SORUMLU'
        #9'left outer join REHBER Musteri on Musteri.ID=G.REHBERID'
        #9#9' '
        'where 1=1'#9#9'           ')
      TabOrder = 1
      Visible = False
    end
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 350
      Height = 55
      Margins.Bottom = 0
      ButtonHeight = 24
      ButtonWidth = 87
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
      Images = Tablo.imgScheduler
      List = True
      ParentFont = False
      ShowCaptions = True
      AllowTextButtons = True
      TabOrder = 2
      object ToolButton8: TToolButton
        Left = 0
        Top = 0
        Caption = 'G'#252'nl'#252'k'
        ImageIndex = 0
        Style = tbsTextButton
        OnClick = AylikTusClick
      end
      object ToolButton2: TToolButton
        Tag = 7
        Left = 64
        Top = 0
        Caption = #304#351' G'#252'nleri'
        ImageIndex = 1
        Style = tbsTextButton
        OnClick = AylikTusClick
      end
      object HaftaTus: TToolButton
        Tag = 2
        Left = 142
        Top = 0
        Caption = 'Haftal'#305'k'
        ImageIndex = 2
        Style = tbsTextButton
        OnClick = AylikTusClick
      end
      object AylikTus: TToolButton
        Tag = 3
        Left = 212
        Top = 0
        Caption = 'Ayl'#305'k'
        ImageIndex = 3
        Style = tbsTextButton
        OnClick = AylikTusClick
      end
      object ToolButton3: TToolButton
        Tag = 8
        Left = 266
        Top = 0
        Caption = 'Y'#305'll'#305'k'
        ImageIndex = 5
        Wrap = True
        Style = tbsTextButton
        OnClick = AylikTusClick
      end
      object CheckSorumluGrupla: TcxCheckBox
        Left = 0
        Top = 24
        Caption = 'Sorumlulara G'#246're Grupla      * /  Takvim Say'#305's'#305
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        TabOrder = 1
        Transparent = True
      end
      object edTakvimSayisi: TSpinEdit
        Left = 121
        Top = 24
        Width = 43
        Height = 24
        MaxValue = 20
        MinValue = 1
        TabOrder = 0
        Value = 1
        Visible = False
      end
      object ToolButton1: TToolButton
        Tag = 6
        Left = 164
        Top = 24
        Caption = 'Gant '#350'emas'#305
        ImageIndex = 35
        Wrap = True
        Style = tbsTextButton
        OnClick = AylikTusClick
      end
    end
    object MemoPlanSQL: TMemo
      Left = -34
      Top = 271
      Width = 553
      Height = 49
      Lines.Strings = (
        
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'#GO' +
          'REV_SPID_%'#39')'
        'DROP TABLE #GOREV_SPID_'
        ''
        'declare @PERSONEL INT,'
        '        @SURE INT,'
        '        @ALANTURU INT,'
        '        @YETKIKONTROLET INT'
        ''
        '--SET @PERSONEL = PPERSONEL'
        '--SET @ALANTURU = PALANTURU'
        '--SET @YETKIKONTROLET = PYETKIKONTROL'
        ''
        ''
        'CREATE TABLE #GOREV_SPID_('
        #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
        #9'[type] [smallint] NULL,'
        #9'[start] [datetime]  NULL,'
        #9'[finish] [datetime]  NULL,'
        #9'[options] [smallint] NULL,'
        #9'[caption] [nvarchar](1000) NULL,'
        #9'[location] [nvarchar](10) NULL,'
        #9'[message] [nvarchar](10) NULL,'
        #9'[state] [smallint] NULL,'
        #9'[labelColor] [bigint] NULL,'
        '               -- [ResourceID] int NULL,'
        '    [DOSYA] [nvarchar](20) NULL,'
        '    [GOREV_ID] [int] NULL,'
        '    [REHBERID] [int] NULL,'
        '    [EKLEYEN] [int] NULL,'
        '    [ACKAPA] [bit] NULL,'
        '    [BAYRAK] [bit] NULL,'
        '    [LISTEID] [int] NULL,'
        '[TUR] [nvarchar](200) NULL    '
        ''
        ')'
        ''
        'INSERT INTO #GOREV_SPID_'
        ''
        '')
      TabOrder = 3
      Visible = False
    end
    object MemoGorevSQL: TMemo
      Left = 102
      Top = 358
      Width = 778
      Height = 49
      Color = 7661308
      Lines.Strings = (
        ''
        'select distinct  '
        #9'type = 0, '
        
          #9'start = convert(datetime, convert(varchar(20), G.BASLAMATARIHI,' +
          ' 120), 120) ,'
        
          #9'finish = convert(datetime, convert(varchar(20), G.BITISTARIHI, ' +
          '120),120),   '
        #9'options=3, '
        
          #9'caption = G.KONUSU+'#39' / '#39'+(select isnull(KOD,'#39#39') from KULLANICI ' +
          'K where K.REHBERID=G.EKLEYEN)+'#39' > '#39'+ (SELECT [dbo].'
        '[fn_GorevVerilenKisiler](11, '
        'G.ID)) +'#39' / '#39'+ '
        
          #9'           ISNULL(SUBSTRING(FIRMA, 1, CHARINDEX('#39' '#39', FIRMA, CHA' +
          'RINDEX('#39' '#39', FIRMA)+1)) ,'#39#39') ,'
        #9'location='#39#39','
        #9'message='#39#39', '
        #9'state=0,   '
        #9'labelColor = case when G.ACKAPA = 1 THEN 13882323 --Gri'
        '                            ELSE 55295 END, --Alt'#305'n'
        '       --         ResourceID = GK.REHBERID,'
        #9'Dosya='#39'GOREVLER'#39', '
        #9'GOREV_ID=G.ID,'
        #9'REHBERID=G.REHBERID,'
        #9'EKLEYEN=G.EKLEYEN,'
        #9'ACKAPA=G.ACKAPA,'
        #9'BAYRAK=G.BAYRAK,'
        #9'LISTEID=G.LISTEID,'
        #9'TUR=0'
        'from '
        #9'GOREVLER G'
        
          #9'--left outer join GOREVKULLANICI GK on GK.LISTGOREVID=G.ID and ' +
          'GK.TUR=11'
        #9'---- left outer join REHBER Pers on Pers.ID=GK.REHBERID'
        #9'--left outer join REHBER Musteri on Musteri.ID=G.REHBERID'
        '              LEFT JOIN GOREVLISTE GL on G.LISTEID=GL.ID '
        
          '              LEFT JOIN GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREV' +
          'ID AND GK1.TUR in (0,1,2,11)  '
        
          '             '#9#9#9' left outer join REHBER Musteri on Musteri.ID=G.' +
          'REHBERID'
        ''
        'where 1=1'
        #9'           '
        '  '#9#9'       ')
      TabOrder = 4
      Visible = False
    end
  end
  object DtsGorevler: TDataSource
    DataSet = TabGorevler
    Left = 35
    Top = 466
  end
  object TabGorevler: TFDQuery
    AfterOpen = TabGorevlerAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM [dbo].[fn_Prg_IsListesiListeler](2,0,9999,11)')
    Left = 118
    Top = 471
  end
  object GorevlerMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OnPopup = GorevlerMenuPopup
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
    Left = 344
    Top = 160
    object GorevInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = GorevInfoMenuClick
    end
    object BuTariheIsEkleMenu: TMenuItem
      Caption = 'Bu Tarihe '#304#351' Ekle'
      ImageIndex = 21
      OnClick = GorevEkleTusClick
    end
    object DuzenleMenu: TMenuItem
      Caption = 'D'#252'zenle'
      ImageIndex = 7
      OnClick = DuzenleMenuClick
    end
    object TamamlandiIsaretleMenu: TMenuItem
      Caption = #304#351'aretliler Tamamland'#305' / Tamamlanmad'#305
      ImageIndex = 23
      Visible = False
      OnClick = TamamlandiIsaretleMenuClick
    end
    object Bayraklaretle1: TMenuItem
      Caption = #304#351'aretliler  Bayrakl'#305' / Bayraks'#305'z'
      ImageIndex = 31
      Visible = False
      OnClick = Bayraklaretle1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object TarihBugunMenu: TMenuItem
      Caption = #304#351'aretlilerin Tarihi Bug'#252'n'
      ImageIndex = 21
      Visible = False
      OnClick = TarihBugunMenuClick
    end
    object arihYarn1: TMenuItem
      Tag = 1
      Caption = #304#351'aretlilerin Tarihi Yar'#305'n'
      ImageIndex = 21
      Visible = False
      OnClick = TarihBugunMenuClick
    end
    object TarihiKaldirMenu: TMenuItem
      Tag = -1
      Caption = #304#351'aretlilerin Tarihini Kald'#305'r'
      ImageIndex = 24
      Visible = False
      OnClick = TarihBugunMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
      Visible = False
    end
    object Atamayap1: TMenuItem
      Caption = 'Atama yap'
      ImageIndex = 15
      OnClick = Atamayap1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object MteriSe1: TMenuItem
      Caption = 'M'#252#351'teri Se'#231
      ImageIndex = 35
      OnClick = MteriSe1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object UstIsiAcMenu: TMenuItem
      Caption = 'Bu '#304#351'in Ba'#287'l'#305' Oldu'#287'u '#220'st '#304#351'i A'#231
      ImageIndex = 19
      Visible = False
      OnClick = UstIsiAcMenuClick
    end
    object AltIsiAcMenu: TMenuItem
      Caption = 'Bu '#304#351'e Ba'#287'l'#305' Alt '#304#351'i A'#231
      ImageIndex = 19
      Visible = False
      OnClick = AltIsiAcMenuClick
    end
    object N7: TMenuItem
      Caption = '-'
      Visible = False
    end
    object BuiIsiTasiMenu: TMenuItem
      Caption = #304#351'aretli  '#304#351'leri Ta'#351#305
      ImageIndex = 6
      Visible = False
      object MasaUstuMenu: TMenuItem
        Tag = -27
        Caption = 'Masa'#252'st'#252
        ImageIndex = 6
        OnClick = MenuItem1Click
      end
      object N8: TMenuItem
        Caption = '-'
      end
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object BuiiEPostaGnder1: TMenuItem
      Caption = 'Bu i'#351'i E-Posta G'#246'nder'
      ImageIndex = 17
      OnClick = BuiiEPostaGnder1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object ButenYeniBirListeOlutur1: TMenuItem
      Caption = 'Bu '#304#351'ten Yeni Bir Liste Olu'#351'tur'
      ImageIndex = 32
      OnClick = ButenYeniBirListeOlutur1Click
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
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 63
    Top = 396
  end
  object SchedulerDBStorage: TcxSchedulerDBStorage
    UseActualTimeRange = True
    Reminders.ReminderWindowLookAndFeel.NativeStyle = True
    Reminders.ReminderWindowLookAndFeel.SkinName = ''
    Resources.Items = <>
    CustomFields = <
      item
        FieldName = 'SyncIDField'
      end
      item
        FieldName = 'Dosya'
      end
      item
        FieldName = 'GOREV_ID'
      end
      item
        FieldName = 'REHBERID'
      end
      item
        FieldName = 'EKLEYEN'
      end
      item
        FieldName = 'ACKAPA'
      end
      item
        FieldName = 'BAYRAK'
      end
      item
        FieldName = 'LISTEID'
      end
      item
        FieldName = 'TUR'
      end>
    DataSource = SchedulerDataSource
    FieldNames.ActualFinish = 'Finish'
    FieldNames.ActualStart = 'Start'
    FieldNames.Caption = 'Caption'
    FieldNames.EventType = 'Type'
    FieldNames.Finish = 'Finish'
    FieldNames.ID = 'ID'
    FieldNames.LabelColor = 'LabelColor'
    FieldNames.Location = 'Location'
    FieldNames.Message = 'Message'
    FieldNames.Options = 'Options'
    FieldNames.ParentID = 'ParentID'
    FieldNames.RecurrenceIndex = 'RecurrenceIndex'
    FieldNames.RecurrenceInfo = 'RecurrenceInfo'
    FieldNames.ReminderDate = 'ReminderDate'
    FieldNames.ReminderMinutesBeforeStart = 'ReminderMinutes'
    FieldNames.ResourceID = 'ResourceID'
    FieldNames.Start = 'Start'
    FieldNames.State = 'State'
    Left = 664
    Top = 208
  end
  object SchedulerDataSource: TDataSource
    DataSet = TabGorevler
    Left = 682
    Top = 161
  end
  object AraQuery1: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      '   select KO.ID,  type = 0, '
      
        '       start = convert(datetime, convert(varchar(10), TARIH, 120' +
        ')+'#39' 00:00'#39', 120) ,'
      
        '       finish = convert(datetime, convert(varchar(10), TARIH+1, ' +
        '120)+'#39' 00:00'#39',120),   options=3,  '
      
        '       caption = '#39'Kredi '#39'+convert(varchar(20),TAKSIT)+   KUR+'#39' '#39 +
        '+isnull(KREDIKODU,'#39#39')+ '#39' '#39'+isnull(ACIKLAMA,'#39#39'),'
      '   location='#39#39',message='#39#39', state=0,   '
      '   labelColor = 8689404,Dosya='#39'KREDIODEME'#39', ID2=KO.ID,TUR=0'
      '    from KREDILER K inner join KREDIODEME KO on K.ID =KO.KREDIID')
    Left = 814
    Top = 155
  end
  object Query1: TFDQuery
    Connection = Tablo.FDCnn
    Left = 144
    Top = 408
  end
  object DtsPersonel: TDataSource
    DataSet = TabPersonel
    Left = 760
    Top = 224
  end
  object TabPersonel: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select R.ID,FIRMA from REHBER R'
      
        'where R.DURUM>0 and exists(select 1 from KULLANICI K  inner join' +
        ' ROLLER RO on RO.ID=K.ROLID '
      
        '  inner join YETKI Y on Y.ROLID=K.ROLID and Y.MODULID=213110 and' +
        ' Y.HAK=1 where R.ID=K.REHBERID and ((Y.HAK=1)or(RO.TY=1)))'
      'order by 2')
    Left = 856
    Top = 242
  end
  object tabTakvimKaynaklari: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select TOP 1 ID, FIRMA AS PERSONEL FROM REHBER order by 2')
    Left = 764
    Top = 321
  end
  object dtsTakvimKaynaklari: TDataSource
    DataSet = tabTakvimKaynaklari
    Left = 870
    Top = 333
  end
  object TabIcerik: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select KONUSU, NOTLAR=(select YORUM from GOREVYORUM where GOREVI' +
        'D=G.ID AND TUR=1)'
      'from GOREVLER G'
      'where G.ID=:PID')
    Left = 382
    Top = 407
    ParamData = <
      item
        Name = 'PID'
        DataType = ftWideString
        Size = 2
        Value = '13'
      end>
  end
  object DtsIcerik: TDataSource
    DataSet = TabIcerik
    Left = 299
    Top = 410
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
      'order by 3 DESC')
    Left = 421
    Top = 361
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftSmallint
        Precision = 5
        Size = 2
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
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 419
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 421
    Top = 552
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
    Left = 423
    Top = 276
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
    Grid = GridYorum
    PopupMenus = <
      item
        GridView = GridYorumDBCardView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 592
    Top = 336
  end
end
