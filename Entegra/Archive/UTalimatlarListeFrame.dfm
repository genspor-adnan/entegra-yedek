object TalimatlarListeFrame: TTalimatlarListeFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
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
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 59
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      Visible = False
      OnClick = SilTusClick
    end
  end
  object cxGrid: TcxGrid
    Left = 0
    Top = 32
    Width = 451
    Height = 66
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    ExplicitTop = 35
    ExplicitHeight = 63
    object GridTview: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      OnCanFocusRecord = GridTviewCanFocusRecord
      OnCellDblClick = GridTviewCellDblClick
      DataController.DataSource = DtsTalimatlar
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
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.MultiSelect = True
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = GridTviewStylesGetContentStyle
      object GridTviewODEMETARIHI: TcxGridDBColumn
        Caption = #304#351'lem Tarihi'
        DataBinding.FieldName = 'ODEMETARIHI'
        Width = 134
      end
      object GridTviewTALIMATADI: TcxGridDBColumn
        Caption = 'Talimat'
        DataBinding.FieldName = 'TALIMATADI'
        Width = 351
      end
      object GridTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        Width = 118
      end
      object GridTviewTutar: TcxGridDBColumn
        Caption = 'Toplam Tutar'
        DataBinding.FieldName = 'TOPLAM'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 91
      end
      object GridTviewKur: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        Width = 44
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = GridTview
    end
  end
  object PageControlSekme: TcxPageControl
    Left = 0
    Top = 105
    Width = 451
    Height = 199
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = PageSurec
    Properties.CustomButtons.Buttons = <>
    OnPageChanging = PageControlSekmePageChanging
    ClientRectBottom = 195
    ClientRectLeft = 4
    ClientRectRight = 447
    ClientRectTop = 24
    object PageSurec: TcxTabSheet
      Caption = 'S'#252're'#231'ler'
      ImageIndex = 7
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid2: TcxGrid
        Left = 0
        Top = 0
        Width = 874
        Height = 171
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        ExplicitWidth = 443
        object cxGridSurec: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsSurec
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
            end
            item
              Format = ',0.00;(,0.00)'
            end
            item
              Format = ',0.00;(,0.00)'
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
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.Content = AnaForm.cxStyle1
          object cxGridSurecPERSONEL: TcxGridDBColumn
            Caption = 'Personel'
            DataBinding.FieldName = 'FIRMA'
            Width = 199
          end
          object cxGridSurecSURECTURU: TcxGridDBColumn
            Caption = 'S'#252're'#231' T'#252'r'#252
            DataBinding.FieldName = 'TURU'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 196
          end
          object cxGridSurecDURUM: TcxGridDBColumn
            Caption = 'Sonuc'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 279
          end
        end
        object cxGridDBTableView2: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DetailKeyFieldNames = 'CEKID'
          DataController.MasterKeyFieldNames = 'CEKID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          Styles.ContentOdd = AnaForm.cxStyle1
          Styles.GroupByBox = AnaForm.cxStyle1
          Styles.Header = AnaForm.cxStyle1
          object cxGridDBColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object cxGridDBColumn2: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            Width = 130
          end
          object cxGridDBColumn3: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object cxGridDBColumn4: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            Width = 354
          end
          object cxGridDBColumn5: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = cxGridSurec
        end
      end
    end
    object PageDetay: TcxTabSheet
      Caption = #304#351'lem Detaylar'#305
      ImageIndex = 6
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 874
        Height = 171
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object cxGridDetay: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsDetay
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
            end
            item
              Format = ',0.00;(,0.00)'
            end
            item
              Format = ',0.00;(,0.00)'
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
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object cxGridDetayPLANTARIHI: TcxGridDBColumn
            Caption = 'Plan Tarhi'
            DataBinding.FieldName = 'PLANTARIHI'
            PropertiesClassName = 'TcxDateEditProperties'
            Width = 63
          end
          object cxGridDetayFIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            Width = 137
          end
          object cxGridDetayACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Width = 221
          end
          object cxGridDetayCIKAN: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'ALACAK'
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 87
          end
          object cxGridDetayKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            Width = 53
          end
          object cxGridDetayAD: TcxGridDBColumn
            Caption = 'Masraf Merkezi'
            DataBinding.FieldName = 'AD'
            Width = 148
          end
          object cxGridDetayDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Yeni'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Tamamland'#305
                Value = 2
              end
              item
                Description = #304'ptal'
                Value = 0
              end>
            Width = 118
          end
        end
        object cxGrid1DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DetailKeyFieldNames = 'CEKID'
          DataController.MasterKeyFieldNames = 'CEKID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          Styles.ContentOdd = AnaForm.cxStyle1
          Styles.GroupByBox = AnaForm.cxStyle1
          Styles.Header = AnaForm.cxStyle1
          object cxGrid1DBTableView1DURUM: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object cxGrid1DBTableView1VADE: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            Width = 130
          end
          object cxGrid1DBTableView1SERINO: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object cxGrid1DBTableView1HESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            Width = 354
          end
          object cxGrid1DBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
          end
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGridDetay
        end
      end
    end
    object PageBelge: TcxTabSheet
      Caption = #304#351'lemdeki Belgeler'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid3: TcxGrid
        Left = 0
        Top = 0
        Width = 874
        Height = 171
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object cxGridDBTableViewBelge: TcxGridDBTableView
          OnDblClick = cxGridDBTableViewBelgeDblClick
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsBelge
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
            end
            item
              Format = ',0.00;(,0.00)'
            end
            item
              Format = ',0.00;(,0.00)'
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
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.Content = AnaForm.cxStyle1
          Styles.OnGetContentStyle = cxGridDBTableViewBelgeStylesGetContentStyle
          object cxGridDBTableViewBelgeBELGEADI: TcxGridDBColumn
            Caption = 'Belge Ad'#305
            DataBinding.FieldName = 'BELGEADI'
            Width = 329
          end
          object cxGridDBTableViewBelgeSUREC: TcxGridDBColumn
            Caption = 'S'#252're'#231
            DataBinding.FieldName = 'SUREC'
            Width = 68
          end
          object cxGridDBTableViewBelgeDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            Width = 75
          end
          object cxGridDBTableViewBelgeEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Ekleme Tarihi'
            DataBinding.FieldName = 'EKLEMETARIHI'
            Width = 123
          end
          object cxGridDBTableViewBelgeColumn1: TcxGridDBColumn
            Caption = 'Id'
            DataBinding.FieldName = 'ID'
            Width = 42
          end
        end
        object cxGridDBTableView3: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DetailKeyFieldNames = 'CEKID'
          DataController.MasterKeyFieldNames = 'CEKID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          Styles.ContentOdd = AnaForm.cxStyle1
          Styles.GroupByBox = AnaForm.cxStyle1
          Styles.Header = AnaForm.cxStyle1
          object cxGridDBColumn12: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object cxGridDBColumn13: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            Width = 130
          end
          object cxGridDBColumn14: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object cxGridDBColumn15: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            Width = 354
          end
          object cxGridDBColumn16: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = cxGridDBTableViewBelge
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 98
    Width = 451
    Height = 7
    AlignSplitter = salBottom
    Control = PageControlSekme
  end
  object DtsTalimatlar: TDataSource
    DataSet = TabTalimatlar
    Left = 95
    Top = 294
  end
  object TabTalimatlar: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabTalimatlarAfterOpen
    AfterScroll = TabTalimatlarAfterScroll
    ParamData = <
      item
        Name = 'pTARIH1'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = Null
      end
      item
        Name = 'pTARIH2'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = Null
      end>
    SQL.Strings = (
      'select '
      '        T.ID,'
      #9'T.TURU,'
      '        T.ODEMETARIHI,'
      '        T.TALIMATADI,'
      '        T.DURUM,'
      '        TOPLAM= SUM(K.ALACAK),'
      #9'KUR=K.KUR'
      'from '
      '        TALIMATLAR T inner join  '
      #9#9'TALIMATDETAY TD on '
      #9#9#9'TD.TALIMATID=T.ID left outer join '
      #9#9'KASA K on'
      #9#9#9'TD.KASAID=K.ID'
      'WHERE '
      #9'isnull(TD.KASAID,0)<>0'#9'and '
      '        T.ODEMETARIHI BETWEEN :pTARIH1 AND :pTARIH2'
      #9#9
      'group by '
      '        T.ID,'
      #9'T.TURU,'
      '        T.ODEMETARIHI,'
      '        T.TALIMATADI,'
      '        T.DURUM,'
      '        K.KUR'#9)
    Left = 96
    Top = 239
  end
  object TabSurec: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabTalimatlarAfterOpen
    ParamData = <
      item
        Name = 'PTalimatID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select '
      '        A.ID,R.FIRMA,A.SORUMLU,'
      '        A.TURU,'
      '       A.DURUM'
      'from '
      '        AKTIVITELER A INNER JOIN '
      '        REHBER R ON '
      #9#9#9'A.SORUMLU=R.ID'
      'WHERE '
      '        A.TALIMATID=:PTalimatID'
      '')
    Left = 159
    Top = 239
  end
  object DtsSurec: TDataSource
    DataSet = TabSurec
    Left = 160
    Top = 296
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabTalimatlarAfterOpen
    ParamData = <
      item
        Name = 'PTalimatID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select '
      
        '    K.ID,R.FIRMA,K.PLANTARIHI,K.ACIKLAMA,ALACAK=K.ALACAK-K.BORC,' +
        'K.KUR,M.AD,K.KASA,TD.AKIBETSONUC,TD.DURUM'
      ''
      'from '
      #9'TALIMATDETAY TD left outer join '
      #9'KASA K on'
      #9#9'K.ID=TD.KASAID left outer join  '
      #9'REHBER R ON '#9#9
      #9#9'K.REHBERID=R.ID LEFT OUTER JOIN '
      #9'MASRAFGELIR M ON '
      #9#9'M.ID=K.MASRAFID'
      'WHERE '
      '        TD.TALIMATID=:PTalimatID')
    Left = 219
    Top = 239
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 219
    Top = 286
  end
  object PopupMenu1: TPopupMenu
    Left = 119
    Top = 130
    object AkibetAl: TMenuItem
      Caption = 'Ak'#305'bet Al'
      OnClick = AkibetAlClick
    end
  end
  object TabBelge: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabTalimatlarAfterOpen
    ParamData = <
      item
        Name = 'PTalimatID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 35
      end>
    SQL.Strings = (
      
        'select BELGEADI,SUREC,DURUM,EKLEMETARIHI,ID,BELGE   from TALIMAT' +
        'BELGELER where TALIMATID=:PTalimatID   order by 4')
    Left = 276
    Top = 240
  end
  object DtsBelge: TDataSource
    DataSet = TabBelge
    Left = 281
    Top = 296
  end
  object SaveDialog1: TSaveDialog
    Filter = 'asdasdsd|*.asd'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton, ofEnableSizing]
    Left = 551
    Top = 172
  end
end

