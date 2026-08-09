object EvrakListeFrame: TEvrakListeFrame
  Left = 0
  Top = 0
  Width = 1078
  Height = 654
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
  OnMouseMove = FrameMouseMove
  object SQLMemo: TMemo
    Left = 74
    Top = 128
    Width = 783
    Height = 220
    Lines.Strings = (
      'SELECT DK.ID KLASORID, DK.USTID KLASORUSTID '
      '  , KLASORAD = CAST ( DK.AD AS NVARCHAR ( 260 ) ) '
      '  -- , AD = CAST ( DK.AD AS NVARCHAR ( 260 ) ) '
      
        '  --, (SELECT AD FROM DOKUMANKLASOR WHERE USTID = DK.USTID) AS K' +
        'LASORAD '
      
        '  , D.ID, D.BELGENO, D.DURUM, D.AD, D.KONU, D.TUR, D.KLASOR,D.ES' +
        'KIKLASOR'
      
        '  , D.EKLEYEN, D.EKLEMETARIHI, D.GIZLILIKDERECESI, D.TARIH, D.GE' +
        'LEN_EVRAK_NUMARASI'
      
        '  , D.EVRAK_DOSYA_KODU,D.EVRAK_ICERIGI, D.ACIKLAMA, D.GIDECEGI_Y' +
        'ER_REF'
      
        '  , IMAJ.ID IMAJ_ID, IMAJ.VARSAYILAN, IMAJ.REHBERID'#9'IMAJ_REHBERI' +
        'D, IMAJ.ICDIS, IMAJ.YERI IMAJ_YERI'
      
        '  , IMAJ.YER_ID IMAJ_YER_ID, IMAJ.DURUM IMAJ_DURUM, IMAJ.BELGENO' +
        ' IMAJ_BELGENO'
      
        '  , IMAJ.SURUM IMAJ_SURUM, IMAJ.TUR IMAJ_TUR, IMAJ.BELGEADI IMAJ' +
        '_BELGEADI'
      
        '  , IMAJ.BELGE IMAJ_BELGE, IMAJ.ACIKLAMA IMAJ_ACIKLAMA, IMAJ.EKL' +
        'EYEN IMAJ_EKLEYEN'
      
        '  , IMAJ.EKLEMETARIHI IMAJ_EKLEMETARIHI, IMAJ.DEGISTIREN IMAJ_DE' +
        'GISTIREN'
      
        '  , IMAJ.DEGISTIRMETARIHI IMAJ_DEGISTIRMETARIHI, IMAJ.SUBEID IMA' +
        'J_SUBEID, IMAJ.ONAY IMAJ_ONAY'
      
        '  , IMAJ.BELGETURU IMAJ_BELGETURU, IMAJ.BOYUT IMAJ_BOYUT, IMAJ.O' +
        'NAYLAYACAK IMAJ_ONAYLAYACAK'
      'FROM DOKUMANKLASOR DK'
      '   JOIN DOKUMAN  D ON D.KLASOR = DK.ID'
      '      JOIN IMAJ  ON IMAJ.YER_ID = D.ID '
      
        '     --INNER JOIN DOKUMANYETKI DY ON DY.YERI= 321 AND DY.YERID=D' +
        '.ID AND DY.REHBERID>0'
      '')
    TabOrder = 2
  end
  object SQLMemo2: TMemo
    Left = 27
    Top = 223
    Width = 621
    Height = 66
    Lines.Strings = (
      ''
      'select '
      
        '  distinct   D.*,DTIP=0,KISAYOLID=DK.ID,Firma.FIRMA as KURUM,Lok' +
        'asyon.ACIKLAMA as LOKASYONAD,Sorumlu.FIRMA as '
      'SORUMLUAD,'
      
        'EXT=case when D.AD like '#39'%.%'#39' then '#39'.'#39'+REVERSE( SUBSTRING(REVERS' +
        'E(isnull(D.AD,'#39'.'#39')),1,CHARINDEX('#39'.'#39',REVERSE(isnull'
      '(D.AD,'#39'.'#39')),1)-1)) else '#39#39' end,I.SURUM,'
      'I.BOYUT,'
      'KLASORAD=(SELECT AD FROM Dizin where ID=D.KLASOR),'
      'ONAYLAYACAKAD=(SELECT FIRMA FROM REHBER where ID=I.ONAYLAYACAK),'
      'ONAYLAYANAD=(SELECT FIRMA FROM REHBER where ID=I.ONAY),'
      'EKLEYENAD=(SELECT FIRMA FROM REHBER where ID=D.EKLEYEN),'
      'DEGISTIRENAD=(SELECT FIRMA FROM REHBER where ID=D.DEGISTIREN)'
      'from '
      #9'DOKUMANKISAYOL DK '
      #9'inner join DOKUMAN D on DK.DOKUMANID=D.ID'
      
        #9'LEFT OUTER JOIN IMAJ I ON I.ID = (select top 1 ID from IMAJ whe' +
        're YERI=1 AND YER_ID=D.ID order by ID desc)'
      ' '#9'LEFT OUTER JOIN REHBER Firma on Firma.ID=D.REHBERID'
      
        ' '#9'LEFT OUTER JOIN LOKASYON AS Lokasyon ON  Lokasyon.ID=D.LOKASYO' +
        'N  '
      ' '#9'LEFT OUTER JOIN REHBER AS Sorumlu ON Sorumlu.ID = I.REHBERID')
    TabOrder = 3
  end
  object SQLMemo_SAP: TMemo
    Left = 419
    Top = 91
    Width = 629
    Height = 57
    Lines.Strings = (
      ' '
      'WITH Dizin AS'
      '('
      '    SELECT ID,USTID,AD=CAST(AD AS NVARCHAR(260))'
      '    FROM DOKUMANKLASOR'
      '    WHERE USTID=0'
      '    UNION ALL'
      '    SELECT A.ID'
      '    , A.USTID,'
      '    AD=CAST(V.AD+'#39'\'#39'+A.AD AS NVARCHAR(260))'
      '    FROM DOKUMANKLASOR A'
      '    INNER JOIN Dizin V ON'
      '        V.ID = A.USTID'
      ')'
      ''
      'select distinct'
      ' D.*,'
      
        'DTIP=1,KISAYOLID=0,Firma.CardName as KURUM,Lokasyon.ACIKLAMA as ' +
        'LOKASYONAD,'
      'Sorumlu.FIRMA as SORUMLUAD,'
      'EXT='#39'.'#39'+I.BELGETURU,I.SURUM,'
      'I.BOYUT,'
      'KLASORAD=(SELECT AD FROM Dizin where ID=D.KLASOR),'
      'ONAYLAYACAKAD=(SELECT FIRMA FROM REHBER where ID=I.ONAYLAYACAK),'
      'ONAYLAYANAD=(SELECT FIRMA FROM REHBER where ID=I.ONAY),'
      'EKLEYENAD=(SELECT FIRMA FROM REHBER where ID=D.EKLEYEN),'
      'DEGISTIRENAD=(SELECT FIRMA FROM REHBER where ID=D.DEGISTIREN)'
      'from DOKUMAN D'
      
        ' INNER JOIN IMAJ I ON I.ID = (select top 1 ID from IMAJ where YE' +
        'RI=1 AND YER_ID=D.ID order by ID desc)'
      ' --LEFT OUTER JOIN REHBER Firma on Firma.ID=D.REHBERID'
      
        ' LEFT OUTER JOIN [SAP_DB_AD].dbo.[OCRD] Firma on Firma.DocEntry=' +
        'D.REHBERID'
      ''
      
        ' LEFT OUTER JOIN LOKASYON AS Lokasyon ON Lokasyon.ID=D.LOKASYON ' +
        ' '
      ' LEFT OUTER JOIN REHBER AS Sorumlu ON Sorumlu.ID = I.REHBERID'
      
        ' LEFT OUTER JOIN DOKUMANYETKI DY ON DY.YERI=321 AND DY.YERID = D' +
        '.ID  '
      ' '
      ' ')
    TabOrder = 5
  end
  object SQLMemo2_SAP: TMemo
    Left = 419
    Top = 226
    Width = 621
    Height = 66
    Lines.Strings = (
      ''
      'select '
      
        '  distinct   D.*,DTIP=0,KISAYOLID=DK.ID, Firma.CardName as KURUM' +
        ',Lokasyon.ACIKLAMA as LOKASYONAD,Sorumlu.FIRMA '
      'as '
      'SORUMLUAD,'
      
        'EXT=case when D.AD like '#39'%.%'#39' then '#39'.'#39'+REVERSE( SUBSTRING(REVERS' +
        'E(isnull(D.AD,'#39'.'#39')),1,CHARINDEX('#39'.'#39',REVERSE(isnull'
      '(D.AD,'#39'.'#39')),1)-1)) else '#39#39' end,I.SURUM,'
      'I.BOYUT,'
      'KLASORAD=(SELECT AD FROM Dizin where ID=D.KLASOR),'
      'ONAYLAYACAKAD=(SELECT FIRMA FROM REHBER where ID=I.ONAYLAYACAK),'
      'ONAYLAYANAD=(SELECT FIRMA FROM REHBER where ID=I.ONAY),'
      'EKLEYENAD=(SELECT FIRMA FROM REHBER where ID=D.EKLEYEN),'
      'DEGISTIRENAD=(SELECT FIRMA FROM REHBER where ID=D.DEGISTIREN)'
      'from '
      #9'DOKUMANKISAYOL DK '
      #9'inner join DOKUMAN D on DK.DOKUMANID=D.ID'
      
        #9'INNER JOIN IMAJ I ON I.ID = (select top 1 ID from IMAJ where YE' +
        'RI=1 AND YER_ID=D.ID order by ID desc)'
      
        ' '#9'LEFT OUTER JOIN [SAP_DB_AD].dbo.[OCRD] Firma on Firma.DocEntry' +
        '=D.REHBERID'
      
        ' '#9'LEFT OUTER JOIN LOKASYON AS Lokasyon ON  Lokasyon.ID=D.LOKASYO' +
        'N  '
      ' '#9'LEFT OUTER JOIN REHBER AS Sorumlu ON Sorumlu.ID = I.REHBERID')
    TabOrder = 7
  end
  object GridEvrak: TcxGrid
    Left = 0
    Top = 109
    Width = 1078
    Height = 343
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    LookAndFeel.Kind = lfFlat
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    LookAndFeel.SkinName = ''
    RootLevelOptions.DetailTabsPosition = dtpTop
    object EvrakTview: TcxGridDBTableView
      DragMode = dmAutomatic
      OnDblClick = FormAcTusClick
      OnDragOver = EvrakTviewDragOver
      OnKeyUp = EvrakTviewKeyUp
      OnMouseMove = EvrakTviewMouseMove
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = EvrakTviewCanFocusRecord
      OnCellDblClick = EvrakTviewCellDblClick
      OnSelectionChanged = EvrakTviewSelectionChanged
      DataController.DataSource = DtsDokuman
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = 'Adet :  ######'
          Kind = skCount
          FieldName = 'AD'
          DisplayText = 'Toplam Adet'
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'BOYUT'
          DisplayText = 'Toplam Boyut'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.ColumnMergedGrouping = True
      OptionsBehavior.ExpandMasterRowOnDblClick = False
      OptionsBehavior.HotTrackSelection = False
      OptionsBehavior.ImmediateEditor = False
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.HideFocusRectOnExit = False
      OptionsView.CellAutoHeight = True
      OptionsView.FooterAutoHeight = True
      OptionsView.FooterMultiSummaries = True
      OptionsView.GridLineColor = clMedGray
      OptionsView.GridLines = glHorizontal
      OptionsView.GroupRowHeight = 34
      OptionsView.HeaderHeight = 28
      Preview.Column = EvrakTviewBELGENO
      Styles.Content = Tablo.cxStyle_EvrakContents
      Styles.OnGetContentStyle = EvrakTviewStylesGetContentStyle
      Styles.Group = Tablo.cxStyle_EvrakGroup
      Styles.Header = Tablo.cxStyle_EvrakGroup
      object EvrakTviewKLASORUSTID: TcxGridDBColumn
        DataBinding.FieldName = 'KLASORUSTID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewDURUM: TcxGridDBColumn
        Caption = '?'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Width = 50
      end
      object EvrakTviewKLASORAD: TcxGridDBColumn
        Caption = 'Klas'#246'r'
        DataBinding.FieldName = 'KLASORAD'
        DataBinding.IsNullValueType = True
        Styles.Header = Tablo.cxStyle_EvrakHeader
        Width = 107
      end
      object EvrakTviewBELGENO: TcxGridDBColumn
        DataBinding.FieldName = 'BELGENO'
        DataBinding.IsNullValueType = True
        GroupIndex = 0
        Width = 67
      end
      object EvrakTviewAD: TcxGridDBColumn
        Caption = 'Evrak Ad'#305
        DataBinding.FieldName = 'AD'
        DataBinding.IsNullValueType = True
        Width = 144
      end
      object EvrakTviewKONU: TcxGridDBColumn
        Caption = 'Konu'
        DataBinding.FieldName = 'KONU'
        DataBinding.IsNullValueType = True
        Width = 150
      end
      object EvrakTviewGIDECEGI_YER: TcxGridDBColumn
        Caption = 'Gitti'#287'i Yer'
        DataBinding.FieldName = 'GIDECEGI_YER_REF'
        DataBinding.IsNullValueType = True
        Width = 160
      end
      object EvrakTviewACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        Width = 141
      end
      object EvrakTviewIMAJ_BELGEADI: TcxGridDBColumn
        Caption = 'Belge Ad'#305
        DataBinding.FieldName = 'IMAJ_BELGEADI'
        DataBinding.IsNullValueType = True
        Width = 150
      end
      object EvrakTviewIMAJ_BELGE: TcxGridDBColumn
        Caption = 'Belge'
        DataBinding.FieldName = 'IMAJ_BELGE'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewEKLEYEN: TcxGridDBColumn
        Caption = 'Ekleyen'
        DataBinding.FieldName = 'EKLEYEN'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewEKLEMETARIHI: TcxGridDBColumn
        Caption = 'Ekleme Tarihi'
        DataBinding.FieldName = 'EKLEMETARIHI'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewKLASORID: TcxGridDBColumn
        Caption = 'Klas'#246'rID'
        DataBinding.FieldName = 'KLASORID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object EvrakTviewKLASOR: TcxGridDBColumn
        DataBinding.FieldName = 'KLASOR'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object EvrakTviewESKIKLASOR: TcxGridDBColumn
        DataBinding.FieldName = 'ESKIKLASOR'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewGELEN_EVRAK_NUMARASI: TcxGridDBColumn
        Caption = 'Evrak No'
        DataBinding.FieldName = 'GELEN_EVRAK_NUMARASI'
        DataBinding.IsNullValueType = True
        Width = 83
      end
      object EvrakTviewTARIH: TcxGridDBColumn
        Caption = 'Evrak Tarihi'
        DataBinding.FieldName = 'TARIH'
        DataBinding.IsNullValueType = True
        Visible = False
        GroupIndex = 1
        Width = 72
      end
      object EvrakTviewEVRAK_DOSYA_KODU: TcxGridDBColumn
        Caption = 'Evrak Dosya Kodu'
        DataBinding.FieldName = 'EVRAK_DOSYA_KODU'
        DataBinding.IsNullValueType = True
        Width = 113
      end
      object EvrakTviewEVRAK_ICERIGI: TcxGridDBColumn
        Caption = 'Evrak '#304#231'eri'#287'i'
        DataBinding.FieldName = 'EVRAK_ICERIGI'
        DataBinding.IsNullValueType = True
        Width = 83
      end
      object EvrakTviewVARSAYILAN: TcxGridDBColumn
        DataBinding.FieldName = 'VARSAYILAN'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object EvrakTviewIMAJ_REHBERID: TcxGridDBColumn
        DataBinding.FieldName = 'IMAJ_REHBERID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewIMAJ_YERI: TcxGridDBColumn
        DataBinding.FieldName = 'IMAJ_YERI'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewTUR: TcxGridDBColumn
        DataBinding.FieldName = 'TUR'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_BELGETURU: TcxGridDBColumn
        Caption = 'Belge T'#252'r'#252
        DataBinding.FieldName = 'IMAJ_BELGETURU'
        DataBinding.IsNullValueType = True
        Width = 69
      end
      object EvrakTviewIMAJ_BELGENO: TcxGridDBColumn
        Caption = 'I.BelgeNo'
        DataBinding.FieldName = 'IMAJ_BELGENO'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_SURUM: TcxGridDBColumn
        Caption = 'S'#252'r'#252'm'
        DataBinding.FieldName = 'IMAJ_SURUM'
        DataBinding.IsNullValueType = True
        Width = 55
      end
      object EvrakTviewIMAJ_YER_ID: TcxGridDBColumn
        DataBinding.FieldName = 'IMAJ_YER_ID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewIMAJ_ACIKLAMA: TcxGridDBColumn
        Caption = 'Belge A'#231#305'klama'
        DataBinding.FieldName = 'IMAJ_ACIKLAMA'
        DataBinding.IsNullValueType = True
        Width = 150
      end
      object EvrakTviewGIZLILIKDERECESI: TcxGridDBColumn
        Caption = 'Gizlilik'
        DataBinding.FieldName = 'GIZLILIKDERECESI'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_TUR: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'IMAJ_TUR'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_EKLEYEN: TcxGridDBColumn
        Caption = 'Belge Ekleyen'
        DataBinding.FieldName = 'IMAJ_EKLEYEN'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_EKLEMETARIHI: TcxGridDBColumn
        Caption = 'Belge Ekleme Tarihi'
        DataBinding.FieldName = 'IMAJ_EKLEMETARIHI'
        DataBinding.IsNullValueType = True
        Width = 142
      end
      object EvrakTviewIMAJ_DEGISTIREN: TcxGridDBColumn
        Caption = 'Belge De'#287'i'#351'tiren'
        DataBinding.FieldName = 'IMAJ_DEGISTIREN'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_DEGISTIRMETARIHI: TcxGridDBColumn
        Caption = 'Belge De'#287'i'#351'tirme Tarihi'
        DataBinding.FieldName = 'IMAJ_DEGISTIRMETARIHI'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_SUBEID: TcxGridDBColumn
        DataBinding.FieldName = 'IMAJ_SUBEID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewIMAJ_ONAY: TcxGridDBColumn
        DataBinding.FieldName = 'IMAJ_ONAY'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewIMAJ_BOYUT: TcxGridDBColumn
        Caption = 'Belge Boyut'
        DataBinding.FieldName = 'IMAJ_BOYUT'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_ONAYLAYACAK: TcxGridDBColumn
        DataBinding.FieldName = 'IMAJ_ONAYLAYACAK'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object EvrakTviewICDIS: TcxGridDBColumn
        Caption = #304#231' / D'#305#351
        DataBinding.FieldName = 'ICDIS'
        DataBinding.IsNullValueType = True
      end
      object EvrakTviewIMAJ_DURUM: TcxGridDBColumn
        Caption = 'Belge Durum'
        DataBinding.FieldName = 'IMAJ_DURUM'
        DataBinding.IsNullValueType = True
        Width = 55
      end
      object EvrakTviewIMAJ_ID: TcxGridDBColumn
        DataBinding.FieldName = 'IMAJ_ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
    end
    object GridEvrakDBCardView1: TcxGridDBCardView
      DragMode = dmAutomatic
      OnDragOver = EvrakTviewDragOver
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DtsDokuman
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      LayoutDirection = ldVertical
      OptionsSelection.MultiSelect = True
      OptionsView.CardAutoWidth = True
      OptionsView.CardIndent = 7
      OptionsView.CardWidth = 69
      OptionsView.CellAutoHeight = True
      OptionsView.RowCaptionAutoHeight = True
      object GridEvrakDBCardView1EXT: TcxGridDBCardViewRow
        DataBinding.FieldName = 'EXT'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repFileExtensionList
        Options.Editing = False
        Options.ShowCaption = False
        Position.BeginsLayer = True
        Position.LineCount = 2
      end
      object GridEvrakDBCardView1AD: TcxGridDBCardViewRow
        DataBinding.FieldName = 'AD'
        DataBinding.IsNullValueType = True
        Options.Editing = False
        Options.ShowCaption = False
        Position.BeginsLayer = True
        Position.LineCount = 3
      end
    end
    object EvrakBandedView: TcxGridDBBandedTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DtsDokuman
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.ExpandMasterRowOnDblClick = False
      OptionsCustomize.BandMoving = False
      OptionsCustomize.BandsQuickCustomizationShowCommands = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.CheckBoxVisibility = [cbvGroupRow]
      OptionsView.FocusRect = False
      OptionsView.NoDataToDisplayInfoText = '. . .'
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupRowHeight = 30
      OptionsView.HeaderEndEllipsis = True
      OptionsView.HeaderHeight = 30
      OptionsView.RowSeparatorColor = clGray
      OptionsView.RowSeparatorWidth = 2
      Styles.Group = Tablo.cxStyle_EvrakGroup
      Styles.Header = Tablo.cxStyle_EvrakGroup
      Styles.BandHeader = Tablo.cxStyle_EvrakGroup
      Bands = <
        item
          AlternateCaption = ' '
          Caption = 'Evrak No / Tarih'
          Width = 157
        end
        item
          Caption = 'Gitti'#287'i Yer / Konusu'
        end
        item
          Caption = 'Belge Dosya'
          Width = 944
        end>
      object EvrakBandedViewBELGENO: TcxGridDBBandedColumn
        DataBinding.FieldName = 'BELGENO'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        GroupIndex = 0
        Options.CellMerging = True
        Position.BandIndex = 0
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object EvrakBandedViewTARIH: TcxGridDBBandedColumn
        DataBinding.FieldName = 'TARIH'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.Alignment.Horz = taCenter
        Position.BandIndex = 0
        Position.ColIndex = 0
        Position.RowIndex = 1
      end
      object EvrakBandedViewKONU: TcxGridDBBandedColumn
        Caption = 'Konu'
        DataBinding.FieldName = 'KONU'
        DataBinding.IsNullValueType = True
        Options.CellMerging = True
        Width = 150
        Position.BandIndex = 1
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object EvrakBandedViewGIDECEGI_YER: TcxGridDBBandedColumn
        Caption = 'Gidece'#287'i Yer'
        DataBinding.FieldName = 'GIDECEGI_YER_REF'
        DataBinding.IsNullValueType = True
        Options.CellMerging = True
        Width = 150
        Position.BandIndex = 1
        Position.ColIndex = 0
        Position.RowIndex = 1
      end
      object EvrakBandedViewKLASORAD: TcxGridDBBandedColumn
        DataBinding.FieldName = 'KLASORAD'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Width = 128
        Position.BandIndex = 2
        Position.ColIndex = 0
        Position.RowIndex = 1
      end
      object EvrakBandedViewAD: TcxGridDBBandedColumn
        DataBinding.FieldName = 'AD'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 4
        Position.RowIndex = 0
      end
      object EvrakBandedViewTUR: TcxGridDBBandedColumn
        DataBinding.FieldName = 'TUR'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 5
        Position.RowIndex = 0
      end
      object EvrakBandedViewEKLEMETARIHI: TcxGridDBBandedColumn
        DataBinding.FieldName = 'EKLEMETARIHI'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 8
        Position.RowIndex = 0
      end
      object EvrakBandedViewGIZLILIKDERECESI: TcxGridDBBandedColumn
        Caption = 'Gizlilik Derecesi'
        DataBinding.FieldName = 'GIZLILIKDERECESI'
        DataBinding.IsNullValueType = True
        Width = 135
        Position.BandIndex = 2
        Position.ColIndex = 13
        Position.RowIndex = 0
      end
      object EvrakBandedViewGELEN_EVRAK_NUMARASI: TcxGridDBBandedColumn
        Caption = 'Gelen/Giden EvrakNo'
        DataBinding.FieldName = 'GELEN_EVRAK_NUMARASI'
        DataBinding.IsNullValueType = True
        Width = 146
        Position.BandIndex = 2
        Position.ColIndex = 1
        Position.RowIndex = 0
      end
      object EvrakBandedViewEVRAK_DOSYA_KODU: TcxGridDBBandedColumn
        Caption = 'Dosya Kodu'
        DataBinding.FieldName = 'EVRAK_DOSYA_KODU'
        DataBinding.IsNullValueType = True
        Width = 103
        Position.BandIndex = 2
        Position.ColIndex = 9
        Position.RowIndex = 0
      end
      object EvrakBandedViewEVRAK_ICERIGI: TcxGridDBBandedColumn
        Caption = #304#231'erik'
        DataBinding.FieldName = 'EVRAK_ICERIGI'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 19
        Position.RowIndex = 0
      end
      object EvrakBandedViewACIKLAMA: TcxGridDBBandedColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        Options.CellMerging = True
        Width = 442
        Position.BandIndex = 2
        Position.ColIndex = 2
        Position.RowIndex = 2
      end
      object EvrakBandedViewID: TcxGridDBBandedColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 2
        Position.RowIndex = 0
      end
      object EvrakBandedViewKLASORID: TcxGridDBBandedColumn
        DataBinding.FieldName = 'KLASORID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object EvrakBandedViewDURUM: TcxGridDBBandedColumn
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 3
        Position.RowIndex = 0
      end
      object EvrakBandedViewKLASOR: TcxGridDBBandedColumn
        DataBinding.FieldName = 'KLASOR'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 6
        Position.RowIndex = 0
      end
      object EvrakBandedViewESKIKLASOR: TcxGridDBBandedColumn
        DataBinding.FieldName = 'ESKIKLASOR'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 7
        Position.RowIndex = 0
      end
      object EvrakBandedViewEKLEYEN: TcxGridDBBandedColumn
        Caption = 'Ekleyen'
        DataBinding.FieldName = 'EKLEYEN'
        DataBinding.IsNullValueType = True
        Width = 109
        Position.BandIndex = 2
        Position.ColIndex = 10
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_ID: TcxGridDBBandedColumn
        DataBinding.FieldName = 'IMAJ_ID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 11
        Position.RowIndex = 0
      end
      object EvrakBandedViewVARSAYILAN: TcxGridDBBandedColumn
        DataBinding.FieldName = 'VARSAYILAN'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 12
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_REHBERID: TcxGridDBBandedColumn
        Caption = 'RehberID'
        DataBinding.FieldName = 'IMAJ_REHBERID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 14
        Position.RowIndex = 0
      end
      object EvrakBandedViewICDIS: TcxGridDBBandedColumn
        DataBinding.FieldName = 'ICDIS'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 15
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_YERI: TcxGridDBBandedColumn
        DataBinding.FieldName = 'IMAJ_YERI'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 16
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_YER_ID: TcxGridDBBandedColumn
        Caption = 'Dosya Ref'
        DataBinding.FieldName = 'IMAJ_YER_ID'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 17
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_DURUM: TcxGridDBBandedColumn
        DataBinding.FieldName = 'IMAJ_DURUM'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 18
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_BELGENO: TcxGridDBBandedColumn
        DataBinding.FieldName = 'IMAJ_BELGENO'
        DataBinding.IsNullValueType = True
        Width = 107
        Position.BandIndex = 2
        Position.ColIndex = 1
        Position.RowIndex = 2
      end
      object EvrakBandedViewIMAJ_SURUM: TcxGridDBBandedColumn
        Caption = 'S'#252'r'#252'm'
        DataBinding.FieldName = 'IMAJ_SURUM'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Width = 79
        Position.BandIndex = 2
        Position.ColIndex = 20
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_TUR: TcxGridDBBandedColumn
        DataBinding.FieldName = 'IMAJ_TUR'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 21
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_BELGEADI: TcxGridDBBandedColumn
        Caption = 'Belge Dosya Ad'#305
        DataBinding.FieldName = 'IMAJ_BELGEADI'
        DataBinding.IsNullValueType = True
        Width = 250
        Position.BandIndex = 2
        Position.ColIndex = 0
        Position.RowIndex = 2
      end
      object EvrakBandedViewIMAJ_BELGE: TcxGridDBBandedColumn
        Caption = 'Belge'
        DataBinding.FieldName = 'IMAJ_BELGE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageProperties'
        Properties.GraphicClassName = 'TdxSmartImage'
        Properties.ReadOnly = True
        Width = 194
        Position.BandIndex = 2
        Position.ColIndex = 27
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_ACIKLAMA: TcxGridDBBandedColumn
        Caption = 'Belge Dosya A'#231#305'klama'
        DataBinding.FieldName = 'IMAJ_ACIKLAMA'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 120
        Position.BandIndex = 2
        Position.ColIndex = 22
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_EKLEYEN: TcxGridDBBandedColumn
        DataBinding.FieldName = 'IMAJ_EKLEYEN'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 23
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_EKLEMETARIHI: TcxGridDBBandedColumn
        Caption = 'Dosya ekleme Tarihi'
        DataBinding.FieldName = 'IMAJ_EKLEMETARIHI'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 24
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_DEGISTIRMETARIHI: TcxGridDBBandedColumn
        Caption = 'De'#287'i'#351'tirme Tarihi'
        DataBinding.FieldName = 'IMAJ_DEGISTIRMETARIHI'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Position.BandIndex = 2
        Position.ColIndex = 25
        Position.RowIndex = 0
      end
      object EvrakBandedViewIMAJ_BELGETURU: TcxGridDBBandedColumn
        Caption = 'Belge Dosya T'#252'r'#252
        DataBinding.FieldName = 'IMAJ_BELGETURU'
        DataBinding.IsNullValueType = True
        Width = 112
        Position.BandIndex = 2
        Position.ColIndex = 26
        Position.RowIndex = 0
      end
    end
    object cxGridLevel1: TcxGridLevel
      Caption = 'Liste'
      GridView = EvrakBandedView
    end
    object GridEvrakLevel1: TcxGridLevel
      Caption = 'Simge'
      GridView = GridEvrakDBCardView1
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 60
    Width = 1072
    Height = 49
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 47
    ButtonWidth = 47
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
    object TaraTus: TToolButton
      Left = 47
      Top = 0
      Caption = 'Tara'
      ImageIndex = 38
      ImageName = 'PngImage38'
      OnClick = TaraTusClick
    end
    object ToolButton9: TToolButton
      Left = 94
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 13
      ImageName = 'PngImage12'
      Style = tbsSeparator
    end
    object Gortus: TToolButton
      Left = 102
      Top = 0
      Caption = 'G'#246'r'
      ImageIndex = 46
      ImageName = 'PngImage47'
      OnClick = GortusClick
    end
    object DegistirTus: TToolButton
      Left = 149
      Top = 0
      Caption = 'De'#287'i'#351'tir'
      ImageIndex = 47
      ImageName = 'PngImage46'
      OnClick = DegistirTusClick
    end
    object FormAcTus: TToolButton
      Left = 196
      Top = 0
      Caption = 'Form A'#231
      ImageIndex = 48
      ImageName = 'PngImage48'
      Style = tbsTextButton
      OnClick = FormAcTusClick
    end
    object ToolButton5: TToolButton
      Left = 243
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 13
      ImageName = 'PngImage12'
      Style = tbsSeparator
    end
    object KesTus: TToolButton
      Left = 251
      Top = 0
      Caption = 'Kes'
      ImageIndex = 36
      ImageName = 'PngImage36'
      OnClick = KesMenuClick
    end
    object KopyalaTus: TToolButton
      Left = 298
      Top = 0
      Caption = 'Kopyala'
      ImageIndex = 35
      ImageName = 'PngImage35'
      OnClick = KopyalaMenuClick
    end
    object YapistirTus: TToolButton
      Left = 345
      Top = 0
      Caption = 'Yap'#305#351't'#305'r'
      ImageIndex = 37
      ImageName = 'PngImage37'
      OnClick = YapistirMenuClick
    end
    object ToolButton1: TToolButton
      Left = 392
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 42
      ImageName = 'PngImage42'
      Style = tbsSeparator
    end
    object SilTus: TToolButton
      Left = 400
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton6: TToolButton
      Left = 447
      Top = 0
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 14
      ImageName = 'PngImage13'
      Style = tbsSeparator
    end
    object VerTus: TToolButton
      Left = 455
      Top = 0
      Caption = 'Ver'
      ImageIndex = 42
      ImageName = 'PngImage42'
      OnClick = VerTusClick
    end
    object EPostaTus: TToolButton
      Left = 502
      Top = 0
      Caption = 'E-Posta'
      ImageIndex = 41
      ImageName = 'PngImage41'
      OnClick = EPostaMenuClick
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 452
    Width = 1078
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer9Style'
    AlignSplitter = salBottom
    Control = PageDokuman
    Visible = False
    ExplicitWidth = 8
  end
  object PageDokuman: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 460
    Width = 1078
    Height = 194
    Align = alBottom
    TabOrder = 4
    Properties.ActivePage = TabSheetGenel
    Properties.CustomButtons.Buttons = <>
    Properties.Style = 8
    OnChange = PageDokumanChange
    ClientRectBottom = 194
    ClientRectRight = 1078
    ClientRectTop = 27
    object TabSheetGenel: TcxTabSheet
      Caption = '  Genel  '
      ImageIndex = 11
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PanelGenel: TPanel
        Left = 0
        Top = 0
        Width = 1078
        Height = 167
        Align = alClient
        Color = 16771797
        ParentBackground = False
        TabOrder = 0
        object Label2: TcxLabel
          Left = 271
          Top = 14
          Caption = 'Dok'#252'man Ad'#305'  '
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel4: TcxLabel
          Left = 1
          Top = 115
          Caption = 'Konusu'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel5: TcxLabel
          Left = 0
          Top = 40
          Hint = 'StokKart_Durum'
          Caption = 'S'#252'r'#252'm'#252
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object Label1: TcxLabel
          Left = 0
          Top = 14
          Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
          Caption = 'Dok'#252'man No'
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Properties.WordWrap = True
          Transparent = True
          Width = 65
        end
        object cxLabel10: TcxLabel
          Left = 0
          Top = 65
          Caption = 'Y'#246'n'#252
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxDBLabel1: TcxDBLabel
          Left = 103
          Top = 13
          DataBinding.DataField = 'BELGENO'
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Height = 21
          Width = 81
        end
        object cxDBLabel2: TcxDBLabel
          Left = 103
          Top = 40
          DataBinding.DataField = 'SURUM'
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Height = 21
          Width = 66
        end
        object cxDBLabel4: TcxDBLabel
          Left = 386
          Top = 14
          AutoSize = True
          DataBinding.DataField = 'AD'
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
        end
        object cxDBLabel5: TcxDBLabel
          Left = 104
          Top = 115
          AutoSize = True
          DataBinding.DataField = 'KONU'
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
        end
        object LblYon: TcxDBLabel
          Left = 103
          Top = 65
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Height = 21
          Width = 56
        end
        object LabelMasrafMerkezi: TcxLabel
          Left = 595
          Top = 66
          Caption = 'Kurum'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel6: TcxLabel
          Left = 595
          Top = 92
          Cursor = crHandPoint
          Hint = 'StokKart_Durum'
          Caption = 'Departman'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel7: TcxLabel
          Left = 0
          Top = 91
          Caption = 'Lokasyon'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel13: TcxLabel
          Left = 271
          Top = 40
          Caption = 'Gizlilik Derecesi  '
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Properties.WordWrap = True
          Transparent = True
          Width = 89
        end
        object LblKurum: TcxDBLabel
          Left = 694
          Top = 66
          AutoSize = True
          DataBinding.DataField = 'KURUM'
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LblBolum: TcxDBLabel
          Left = 694
          Top = 92
          AutoSize = True
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LblLokasyon: TcxDBLabel
          Left = 103
          Top = 91
          AutoSize = True
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LblGizlilik: TcxDBLabel
          Left = 386
          Top = 40
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Height = 21
          Width = 81
        end
        object cxDBLabel8: TcxDBLabel
          Left = 666
          Top = 13
          DataBinding.DataField = 'BOLUM'
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
          Visible = False
          Height = 21
          Width = 37
        end
        object cxLabel3: TcxLabel
          Left = 595
          Top = 40
          Caption = 'Sorumlusu'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LblSorumlu: TcxDBLabel
          Left = 694
          Top = 40
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
          Height = 20
          Width = 55
        end
        object cxLabel12: TcxLabel
          Left = 271
          Top = 66
          Caption = 'Boyut (KB)'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LblBoyut: TcxDBLabel
          Left = 386
          Top = 66
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Height = 21
          Width = 54
        end
        object cxLabel14: TcxLabel
          Left = 271
          Top = 90
          Caption = 'Ar'#351'iv S'#252'resi'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LblArsiv: TcxDBLabel
          Left = 386
          Top = 90
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Height = 18
          Width = 95
        end
        object cxLabel1: TcxLabel
          Left = 1
          Top = 138
          Caption = 'Anahtar Kelimeler'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxDBLabel3: TcxDBLabel
          Left = 104
          Top = 138
          AutoSize = True
          DataBinding.DataField = 'ANAHTAR'
          DataBinding.DataSource = DtsDokuman
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
        end
      end
    end
    object TabSheetRevize: TcxTabSheet
      Caption = 'Revize'
      ImageIndex = 19
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridAktDetay: TcxGrid
        Left = 0
        Top = 0
        Width = 1078
        Height = 167
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridRevizeView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsRevize
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.CellAutoHeight = True
          OptionsView.GroupByBox = False
          Styles.Content = Tablo.cxStyle1
          object GridRevizeViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridRevizeViewSURUM: TcxGridDBColumn
            Caption = 'S'#252'r'#252'm'
            DataBinding.FieldName = 'SURUM'
            DataBinding.IsNullValueType = True
          end
          object GridRevizeViewEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'DEGISTIRMETARIHI'
            DataBinding.IsNullValueType = True
            Width = 123
          end
          object GridRevizeViewREHBERID: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'REHBERID'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesiHerkes
            Width = 156
          end
          object GridRevizeViewONAYLAYACAK: TcxGridDBColumn
            Caption = 'Onaylayacak'
            DataBinding.FieldName = 'ONAYLAYACAK'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesiHerkes
            Width = 118
          end
          object GridRevizeViewONAY: TcxGridDBColumn
            Caption = 'Onaylayan'
            DataBinding.FieldName = 'ONAY'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesiHerkes
            Width = 168
          end
          object GridRevizeViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 338
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = GridRevizeView
        end
      end
    end
    object TabSheetIlgili: TcxTabSheet
      Caption = ' '#304'lgili Dok'#252'man '
      ImageIndex = 19
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridIlgili: TcxGrid
        Left = 0
        Top = 0
        Width = 1078
        Height = 167
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridIlgiliView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsIlgili
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.CellAutoHeight = True
          OptionsView.GroupByBox = False
          Styles.Content = Tablo.cxStyle1
          object GridIlgiliViewDOKUMANILGILIID: TcxGridDBColumn
            DataBinding.FieldName = 'DOKUMANILGILIID'
            Visible = False
            VisibleForCustomization = False
          end
          object GridIlgiliViewAD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            Width = 191
          end
          object GridIlgiliViewKLASOR: TcxGridDBColumn
            Caption = 'Klas'#246'r'
            DataBinding.FieldName = 'KLASOR'
            Width = 506
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = GridIlgiliView
        end
      end
    end
    object TabSheetYetki: TcxTabSheet
      Caption = 'Yetkilendirme'
      ImageIndex = 29
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridYetki: TcxGrid
        Left = 0
        Top = 0
        Width = 1078
        Height = 167
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridYetkiDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsYetki
          DataController.KeyFieldNames = 'ID'
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
          OptionsView.GroupByBox = False
          object GridYetkiDBTableView1Tur: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TURU'
            DataBinding.IsNullValueType = True
          end
          object GridYetkiDBTableView1KULLANICI: TcxGridDBColumn
            Caption = 'Kullan'#305'c'#305' Ad'#305
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 168
          end
          object GridYetkiDBTableView1GOR: TcxGridDBColumn
            Caption = 'G'#246'rme'
            DataBinding.FieldName = 'GOR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
          object GridYetkiDBTableView1EKLE: TcxGridDBColumn
            Caption = 'Revize'
            DataBinding.FieldName = 'EKLE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
          object GridYetkiDBTableView1DEGISTIR: TcxGridDBColumn
            Caption = 'De'#287'i'#351'tirme'
            DataBinding.FieldName = 'DEGISTIR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
          object GridYetkiDBTableView1SIL: TcxGridDBColumn
            Caption = 'Silme'
            DataBinding.FieldName = 'SIL'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 95
          end
        end
        object GridYetkiLevel1: TcxGridLevel
          GridView = GridYetkiDBTableView1
        end
      end
    end
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 1078
    Height = 57
    Align = alTop
    ParentBackground = False
    TabOrder = 8
    object PanelMenu: TPanel
      AlignWithMargins = True
      Left = 688
      Top = 1
      Width = 386
      Height = 55
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        AlignWithMargins = True
        Left = 3
        Top = 4
        Width = 104
        Height = 47
        Margins.Top = 4
        Margins.Bottom = 4
        Action = act_ListeYazdir
        Align = alRight
        ImageMargins.Left = 4
        Images = dmEvrakModule.ImagesEvrak
        TabOrder = 0
        StyleName = 'Sapphire Kamri'
      end
      object Button2: TButton
        AlignWithMargins = True
        Left = 113
        Top = 4
        Width = 109
        Height = 47
        Margins.Top = 4
        Margins.Bottom = 4
        Align = alRight
        Caption = 'Evrak Bilgileri'
        DropDownMenu = popupEvrakBilgileri
        ImageIndex = 93
        ImageMargins.Left = 2
        Images = dmEvrakModule.ImagesEvrak
        PopupMenu = popupEvrakBilgileri
        Style = bsSplitButton
        TabOrder = 1
        StyleName = 'Sapphire Kamri'
      end
      object Button3: TButton
        AlignWithMargins = True
        Left = 228
        Top = 4
        Width = 80
        Height = 47
        Margins.Top = 4
        Margins.Bottom = 4
        Action = actTanimlar
        Align = alRight
        DropDownMenu = popupAyarlar
        ImageMargins.Left = 4
        Images = dmEvrakModule.ImagesEvrak
        PopupMenu = popupAyarlar
        Style = bsSplitButton
        TabOrder = 2
        StyleName = 'Sapphire Kamri'
      end
      object Button4: TButton
        AlignWithMargins = True
        Left = 314
        Top = 4
        Width = 69
        Height = 47
        Margins.Top = 4
        Margins.Bottom = 4
        Action = act_Yardim
        Align = alRight
        ImageMargins.Left = 2
        Images = dmEvrakModule.ImagesEvrak
        TabOrder = 3
        StyleName = 'Sapphire Kamri'
      end
    end
    object PageControlMenu: TJvPageControl
      Left = 1
      Top = 1
      Width = 684
      Height = 55
      ActivePage = TabSheet13
      Align = alClient
      MultiLine = True
      TabOrder = 1
      object TabSheet1: TTabSheet
        Caption = 'GELBev'
      end
      object TabSheet2: TTabSheet
        Caption = 'GEL'#252#231
        ImageIndex = 1
        object buttonGelenYeniEvrak: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 98
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_UzerindeCalistigimYeniEvrak
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
        object Button6: TButton
          AlignWithMargins = True
          Left = 107
          Top = 0
          Width = 88
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_UzerindeCalistigimHavaleEt
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 1
        end
        object Button7: TButton
          AlignWithMargins = True
          Left = 201
          Top = 0
          Width = 110
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_UzerindeCalistigimDosyayaKaldir
          Align = alLeft
          ImageIndex = 74
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 2
        end
        object Button8: TButton
          AlignWithMargins = True
          Left = 317
          Top = 0
          Width = 82
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_UzerindeCalistigimIptalEt
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 3
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'GELta'
        ImageIndex = 2
        object Button9: TButton
          AlignWithMargins = True
          Left = 287
          Top = 0
          Width = 104
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_TeslimAlGeriGonder
          Align = alLeft
          ImageMargins.Left = 6
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
        object Button10: TButton
          AlignWithMargins = True
          Left = 201
          Top = 0
          Width = 80
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_TeslimALiptalEt
          Align = alLeft
          ImageMargins.Left = 6
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 1
        end
        object Button11: TButton
          AlignWithMargins = True
          Left = 99
          Top = 0
          Width = 96
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_TeslimAlBarkodile
          Align = alLeft
          ImageMargins.Left = 6
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 2
        end
        object Button12: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 90
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_TeslimAl
          Align = alLeft
          ImageMargins.Left = 6
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 3
        end
      end
      object TabSheet4: TTabSheet
        Caption = 'GELhe'
        ImageIndex = 3
        object Button13: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 126
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_HavaleEtigimGeriAl
          Align = alLeft
          ImageMargins.Left = 6
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
      end
      object TabSheet5: TTabSheet
        Caption = 'GELdk'
        ImageIndex = 4
        object Button14: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 145
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_DosyaladigimGeriAl
          Align = alLeft
          ImageMargins.Left = 6
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
      end
      object TabSheet6: TTabSheet
        Caption = 'GELipt'
        ImageIndex = 5
        object Button15: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 145
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_IptalEttigimGeriAl
          Align = alLeft
          ImageMargins.Left = 6
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
      end
      object TabSheet7: TTabSheet
        Caption = 'gidBEV'
        ImageIndex = 6
        object Label4: TLabel
          Left = 0
          Top = 0
          Width = 105
          Height = 16
          Align = alLeft
          Caption = 'Giden B'#252't'#252'n Evraklar'
          Layout = tlCenter
        end
      end
      object TabSheet8: TTabSheet
        Caption = 'gid'#220#199
        ImageIndex = 7
        object butttonGidenYeniEvrak: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 98
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGiden_UzerindeCalisitimYeniEvrak
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
        object Button17: TButton
          AlignWithMargins = True
          Left = 107
          Top = 0
          Width = 88
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_UzerindeCalistigimHavaleEt
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 1
        end
        object Button18: TButton
          AlignWithMargins = True
          Left = 201
          Top = 0
          Width = 110
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_UzerindeCalistigimDosyayaKaldir
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 2
        end
        object Button19: TButton
          AlignWithMargins = True
          Left = 317
          Top = 0
          Width = 82
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGelen_UzerindeCalistigimIptalEt
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 3
        end
        object Button5: TButton
          AlignWithMargins = True
          Left = 405
          Top = 0
          Width = 82
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGiden_UzerindeCalistigimEvrakNoAl
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 4
        end
        object Button16: TButton
          AlignWithMargins = True
          Left = 493
          Top = 0
          Width = 109
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGiden_UzerindeCalistigimEEvrakGonder
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 5
          StyleName = 'Sapphire Kamri'
        end
      end
      object TabSheet9: TTabSheet
        Caption = 'gidG'#214'N'
        ImageIndex = 8
        object Label3: TLabel
          Left = 0
          Top = 0
          Width = 106
          Height = 16
          Align = alLeft
          Caption = 'Giden G'#246'nderdiklerim'
          Layout = tlCenter
        end
      end
      object TabSheet10: TTabSheet
        Caption = 'gidIMZ'
        ImageIndex = 9
        object Label5: TLabel
          Left = 0
          Top = 0
          Width = 110
          Height = 16
          Align = alLeft
          Caption = 'Giden '#304'mzaya gidenler'
          Layout = tlCenter
        end
      end
      object TabSheet11: TTabSheet
        Caption = 'gidHE'
        ImageIndex = 10
        object Button20: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 118
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGiden_HavaleEttiklerimGeriAl
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
      end
      object TabSheet12: TTabSheet
        Caption = 'gidDK'
        ImageIndex = 11
        object Button21: TButton
          AlignWithMargins = True
          Left = 3
          Top = 0
          Width = 145
          Height = 24
          Margins.Top = 0
          Margins.Bottom = 0
          Action = actGiden_DosyaladigimGeriAl
          Align = alLeft
          ImageMargins.Left = 4
          Images = dmEvrakModule.ImagesEvrak
          TabOrder = 0
        end
      end
      object TabSheet13: TTabSheet
        Caption = 'gidIE'
        ImageIndex = 12
        object Label6: TLabel
          Left = 0
          Top = 0
          Width = 87
          Height = 16
          Align = alLeft
          Caption = 'Giden '#304'za '#304'ptal Et'
          Layout = tlCenter
        end
      end
    end
  end
  object DtsDokuman: TDataSource
    AutoEdit = False
    DataSet = DOKUMAN
    Left = 361
    Top = 192
  end
  object DOKUMAN: TFDQuery
    Connection = Tablo.FDCnn
    BeforeOpen = DOKUMANBeforeOpen
    AfterOpen = DOKUMANAfterOpen
    AfterScroll = DOKUMANAfterScroll
    ParamData = <>
    SQL.Strings = (
      'SELECT DK.ID KLASORID, DK.USTID KLASORUSTID '
      '  , KLASORAD = CAST ( DK.AD AS NVARCHAR ( 260 ) ) '
      '   -- , AD = CAST ( DK.AD AS NVARCHAR ( 260 ) ) '
      
        '   --, (SELECT AD FROM DOKUMANKLASOR WHERE USTID = DK.USTID) AS ' +
        'KLASORAD '
      
        '   , D.ID, D.BELGENO, D.DURUM, D.AD, D.KONU, D.TUR, D.KLASOR,D.E' +
        'SKIKLASOR'
      
        '   , D.EKLEYEN, D.EKLEMETARIHI, D.GIZLILIKDERECESI, D.TARIH, D.G' +
        'ELEN_EVRAK_NUMARASI'
      
        '   , D.EVRAK_DOSYA_KODU,D.EVRAK_ICERIGI, D.ACIKLAMA, D.GIDECEGI_' +
        'YER_REF'
      ''
      
        '  , IMAJ.ID IMAJ_ID, IMAJ.VARSAYILAN, IMAJ.REHBERID'#9'IMAJ_REHBERI' +
        'D, IMAJ.ICDIS, IMAJ.YERI IMAJ_YERI, IMAJ.YER_ID'#9'IMAJ_YER_ID'
      
        '  , IMAJ.DURUM IMAJ_DURUM, IMAJ.BELGENO IMAJ_BELGENO, IMAJ.SURUM' +
        #9'IMAJ_SURUM, IMAJ.TUR IMAJ_TUR, IMAJ.BELGEADI IMAJ_BELGEADI'
      
        '  , IMAJ.BELGE IMAJ_BELGE, IMAJ.ACIKLAMA IMAJ_ACIKLAMA, IMAJ.EKL' +
        'EYEN IMAJ_EKLEYEN, IMAJ.EKLEMETARIHI IMAJ_EKLEMETARIHI'
      
        '  , IMAJ.DEGISTIREN IMAJ_DEGISTIREN, IMAJ.DEGISTIRMETARIHI IMAJ_' +
        'DEGISTIRMETARIHI, IMAJ.SUBEID'#9'IMAJ_SUBEID, IMAJ.ONAY IMAJ_ONAY'
      
        '  , IMAJ.BELGETURU IMAJ_BELGETURU, IMAJ.BOYUT IMAJ_BOYUT, IMAJ.O' +
        'NAYLAYACAK IMAJ_ONAYLAYACAK'
      #9'FROM DOKUMANKLASOR DK'
      #9'  INNER JOIN DOKUMAN  D ON D.KLASOR = DK.ID'
      #9'   LEFT JOIN IMAJ  ON IMAJ.YER_ID = D.ID '
      
        #9'   --INNER JOIN DOKUMANYETKI DY ON DY.YERI= 321 AND DY.YERID=D.' +
        'ID AND DY.REHBERID>0'
      'WHERE DK.ID<-999 AND DK.ID>-5000')
    Left = 33
    Top = 191
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 36
    Top = 317
    object Gr1: TMenuItem
      Caption = 'G'#246'r'
      ImageIndex = 37
      OnClick = GortusClick
    end
    object Deitir1: TMenuItem
      Caption = 'D'#252'zenle'
      ImageIndex = 7
      OnClick = DegistirTusClick
    end
    object DegisMenu: TMenuItem
      Caption = 'Form A'#231
      ImageIndex = 6
      OnClick = FormAcTusClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Yeni1: TMenuItem
      Caption = 'Yeni'
      ImageIndex = 0
      OnClick = YeniTusClick
    end
    object ara1: TMenuItem
      Caption = 'Tara'
      ImageIndex = 38
      OnClick = TaraTusClick
    end
    object BurayaKisayololusturMenu: TMenuItem
      Caption = 'Buraya k'#305'sayol olu'#351'tur'
      ImageIndex = 39
      OnClick = BurayaKisayololusturMenuClick
    end
    object Baskayerekisayololustur1: TMenuItem
      Caption = 'Ba'#351'ka yere k'#305'sayol olu'#351'tur'
      ImageIndex = 39
      OnClick = Baskayerekisayololustur1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object KesMenu: TMenuItem
      Caption = 'Kes'
      ImageIndex = 40
      OnClick = KesMenuClick
    end
    object KopyalaMenu: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = KopyalaMenuClick
    end
    object YapistirMenu: TMenuItem
      Caption = 'Yap'#305#351't'#305'r'
      ImageIndex = 41
      Enabled = False
      OnClick = YapistirMenuClick
    end
    object SilMenu: TMenuItem
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = SilTusClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object VerMenu: TMenuItem
      Caption = 'Ver (Export)'
      ImageIndex = 15
      OnClick = VerTusClick
    end
    object DuyuruOlarakYaynla1: TMenuItem
      Caption = 'Duyuru olarak yay'#305'nla'
      ImageIndex = 42
      OnClick = DuyuruOlarakYaynla1Click
    end
    object EPostaMenu: TMenuItem
      Caption = 'E-Posta olarak g'#246'nder'
      ImageIndex = 17
      OnClick = EPostaMenuClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object EPostaAl1: TMenuItem
      Caption = 'E-Posta Al'
      ImageIndex = 17
      OnClick = EPostaAl1Click
    end
    object Yetkilendirme1: TMenuItem
      Caption = 'Yetkilendirme'
      ImageIndex = 29
      Visible = False
      OnClick = Yetkilendirme1Click
    end
  end
  object popcop: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 552
    Top = 128
    object Sil1: TMenuItem
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = Sil1Click
    end
    object GeriYkle1: TMenuItem
      Caption = 'Geri Y'#252'kle'
      ImageIndex = 15
      OnClick = GeriYkle1Click
    end
    object GeriDnmBoalt1: TMenuItem
      Caption = 'Geri D'#246'n'#252#351#252'm'#252' Bo'#351'alt'
      ImageIndex = 15
      OnClick = GeriDnmBoalt1Click
    end
  end
  object DtsKeywords: TDataSource
    Left = 912
    Top = 664
  end
  object TabYetki: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'YERI'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'YERID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'declare @yeri int,@yerid int'
      'set @yeri=:YERI'
      'set @yerid=:YERID '
      ''
      
        'select         TURU=case when TUR=0 THEN '#39'Kullan'#305'c'#305#39'  else '#39'Rol'#39 +
        ' end,'
      '                   DY.*,'
      ''
      '  FIRMA=CASE '
      #9'   --T'#252'm'
      #9'   WHEN TUR=5 THEN '#39'T'#252'm Kullan'#305'c'#305'lar'#39' '
      #9'   --ki'#351'i/'#351'ube'
      
        #9'   WHEN TUR in (1,4) THEN (SELECT FIRMA FROM REHBER WHERE ID=DY' +
        '.REHBERID)'
      '       --departman'
      
        #9'  WHEN TUR=3 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BOL' +
        'UM=-2251 AND DEGER = DY.REHBERID AND DIL=-1 )'
      '       --g'#246'rev'
      
        #9'   WHEN TUR=2 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BO' +
        'LUM=-2252 AND DEGER = DY.REHBERID AND DIL=-1 )'
      #9'   END'
      ''
      ' from '
      '       DOKUMANYETKI DY '
      '       where'
      '       yerID=@yerid '
      ' order by DY.TUR, DY.REHBERID asc')
    Left = 840
    Top = 221
  end
  object DtsYetki: TDataSource
    DataSet = TabYetki
    Left = 872
    Top = 677
  end
  object TabRevize: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'pYERID'#39
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      
        'select ID,BELGEADI, SURUM,  REHBERID, ONAYLAYACAK, ONAY,EKLEMETA' +
        'RIHI,DEGISTIRMETARIHI, DURUM, ACIKLAMA'
      ' from IMAJ'
      'where '
      '      YERI =1 and '
      '           YER_ID = :pYERID'#39
      'order by DEGISTIRMETARIHI')
    Left = 790
    Top = 189
  end
  object DtsRevize: TDataSource
    DataSet = TabRevize
    Left = 828
    Top = 667
  end
  object TabIlgili: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'pDID1'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      
        '  select DOKUMANILGILIID,D.AD,KLASOR = K.AD from DOKUMANILGILI I' +
        ' '
      '  inner join DOKUMAN D on D.ID = I.DOKUMANILGILIID'
      '  inner join DOKUMANKLASOR K on K.ID = D.KLASOR'
      '  '
      'where '
      'DOKUMANID = :pDID1'
      '--and'
      '--DOKUMANILGILIID = :pDID2')
    Left = 737
    Top = 174
    object TabIlgiliDOKUMANILGILIID: TIntegerField
      FieldName = 'DOKUMANILGILIID'
    end
    object TabIlgiliAD: TWideStringField
      FieldName = 'AD'
      Size = 100
    end
    object TabIlgiliKLASOR: TWideStringField
      FieldName = 'KLASOR'
    end
  end
  object DtsIlgili: TDataSource
    DataSet = TabIlgili
    Left = 783
    Top = 666
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 230
    Top = 221
  end
  object PNGImageList1: TPngImageList
    ShareImages = True
    PngImages = <
      item
        Background = clWindow
        Name = 'PngImage1'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D650046722031392044657A
          20323030332031343A35393A3435202B303130309EA896800000000774494D45
          07D3030515172D72B1F7BB000000097048597300000AF000000AF00142AC3498
          000003224944415478DAA5D35B4853011807F0FFD9CED6769C6EC3CCB4745EBA
          684BBA585A762FA2821E2AA1A77A10BAD7431788340A022BA22822BA58041545
          172B0929579865E9D2AEA6D9664E9D8A764E7ACE8E679EB69D73E6A906057BEE
          FFF0C1F7F2E37BF87F04FE33C49F71E3B33A7BA245D995AC61F2F53A32BD9353
          F5F5DF04903A1DF4DA114952B43CA5098458966DABEAB13619AC9927AB77187F
          FC03EA7B556692A66F4C6B7BDBEF4D8329D95928BF7B1B66B3196969E9A0691A
          9E4E2F6C29E3B070C9526C2FF7C94E26F6CAE0F1F49D11E0688DD856B264D4A4
          FE3E1A34C3C0EFF7C3E572A1AEAE0E85EBD6419265C89284E4E4244CC8B421D5
          4260CE05496C3C68374580922AA1B2789EBA3A1C0E434BEA20CB0A388E43DCEF
          0B4C2613F43A3D02C120D8A161708282C70D344A9D4A6BE84ADED408B0FF91EF
          F4D67CFD1E5B0C015190F1EAAD137E3100BB7D3A6452035156D1EEED05C32B90
          61C657568727DEE0A3E1F3796B22C0AE7BCCB6C599B11755AA16EFB867B83E7C
          0E8C57C1A9B83274F3BDC8D6CC45885491946107C329B8F95E4057100706CFE4
          9E88000F5D6A46670FDFD1CAEF05B5DC8D4F0E0129DF72619A41422D6886E7C6
          581C2AB8042630828F2D5EDCF118916436E67C289DFA2502A8AA4A1C79EA13B3
          125F189F33B7D0F29A86634B2D36BF2A823CBD091D4E0DB653E7C1295A747573
          B8D79F186A2E9B15934E1061E26F210E560FBAF7E51B261738A6618365134607
          C663E584F558E3B6232C4B3816DF88CA37F5082926DCE76D1EF16CF6C47F3DF8
          937D55B4E3F882C415AB1C8BE0B13622414940063B076C68087E414471CE037C
          F274A189A5503B60A8193A9DB52C0A28ADE78EE5C512C5F3E3B528A93E0AA7A9
          1C5A418B8D0927400E59A1B524E16B7B3F5EF453E8314D2E1A3C6CBD16055430
          EA72DACD3FDB369FC23BA70B65CEAB5896520818487CF174C2189F8ADEEF3F51
          D117878C9C99D31A7750CD51805B55F5B76AC597F35234733B6A2A10F2F3B024
          8CC3F7011A128C208DA9F0C9F138DB220594CBB9668220E428E06F7657D245AC
          4F5D1B4B19D284E1A08DE17EC60CF0FE115E5442BEE048F7F84CDBA6D6BD890D
          51DFF83FF90592B96C20B338E05C0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage0'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D65004D6F2033204D727A20
          323030332032323A34323A3130202B30313030FF26557B0000000774494D4507
          D304021031162958BBF9000000097048597300000AF000000AF00142AC349800
          0001B54944415478DABD93DD2B43611CC7BF67E78CBC262FF39A5C284A286B8C
          92BF80A294524AEC4252A670E33FF00728E54A7999C85B335A5ECA950B454B29
          63C734660BDB313B7BCECBE370B192B012CFE5F3FC3E9F8BEFEFFB30F8E561FE
          57308D628660554FB92412927B308193C4054BC86783CCC168BDA5E2F8F110CE
          E333973A86EAC404CBC8C32DF6461BFAAB9CBE35501D03D759D02F8FAB057141
          F969568D1C54CA3CE7C22606A0C6E105643301EC5A1BFA6AF76E3721EB145CB8
          C3D128256DB0C2F92E28DFCEB4D4A599A64451607784A319B11D16ED9AC2862C
          DCC13962EE33BEC11214B83D61319A4ADE261CF110CD1B95FEEABC22032FB8E1
          135FE00A05A6F18031EDD56135F59AF7FD0E485A7A5797422CA2271D1884FDC3
          160CB3E9EB95B939AD1CCB4055296E9EC270FB9EEE871B7B0D07812DC42881C7
          239008473A3578FDF31A17918A10ECC682C296648E05516414A694C0FBEC0581
          0C9E17240DEED2E095AF7BB086747861AF293234B31C8398A4807214D7BC2047
          58D2ADC1B69F8B348B0C04E0A828CD69E29275F0F221394C490F86309F781327
          918928E6F549AC51D229235A9473DF55E49FFFC25F085E01B075B81134FC22DB
          0000000049454E44AE426082}
      end>
    Left = 672
    Top = 164
  end
  object ActionListEvrak: TActionList
    Images = dmEvrakModule.ImagesEvrak
    Left = 696
    Top = 96
    object actGelen_UzerindeCalistigimYeniEvrak: TAction
      Tag = 1
      Category = 'Gelen'
      Caption = 'Yeni Evrak'
      ImageIndex = 0
      OnExecute = actGelen_UzerindeCalistigimYeniEvrakExecute
    end
    object actGelen_UzerindeCalistigimHavaleEt: TAction
      Tag = 1
      Category = 'Gelen'
      Caption = 'Havale Et'
      ImageIndex = 60
      OnExecute = actGelen_UzerindeCalistigimHavaleEtExecute
    end
    object actGelen_UzerindeCalistigimDosyayaKaldir: TAction
      Tag = 1
      Category = 'Gelen'
      Caption = 'Dosyaya Kald'#305'r'
      ImageIndex = 43
      OnExecute = actGelen_UzerindeCalistigimDosyayaKaldirExecute
    end
    object actGelen_UzerindeCalistigimIptalEt: TAction
      Tag = 1
      Category = 'Gelen'
      Caption = #304'ptal Et'
      ImageIndex = 7
      OnExecute = actGelen_UzerindeCalistigimIptalEtExecute
    end
    object act_ListeYazdir: TAction
      Tag = -20000
      Category = 'Menu'
      Caption = 'Listeyi Yazd'#305'r'
      ImageIndex = 12
      OnExecute = act_ListeYazdirExecute
    end
    object act_EvrakBilgi_Altta: TAction
      Tag = -20000
      Category = 'Menu'
      Caption = 'Evrak Bilgisi Altta'
      OnExecute = act_EvrakBilgi_AlttaExecute
    end
    object act_EvrakBilgi_Sagda: TAction
      Tag = -20000
      Category = 'Menu'
      Caption = 'Evrak Bilgisi Sa'#287'da'
      OnExecute = act_EvrakBilgi_SagdaExecute
    end
    object act_EvrakBilgi_Gizle: TAction
      Tag = -20000
      Category = 'Menu'
      AutoCheck = True
      Caption = 'Evrak Bilgisi Gizle'
      Checked = True
      OnExecute = act_EvrakBilgi_GizleExecute
    end
    object act_OtomatikTeslimAl: TAction
      Tag = -20000
      Category = 'Menu'
      AutoCheck = True
      Caption = 'Otomatik Teslim Al'
      OnExecute = act_OtomatikTeslimAlExecute
    end
    object act_Yardim: TAction
      Tag = -20000
      Category = 'Menu'
      Caption = 'Yard'#305'm'
      ImageIndex = 92
      OnExecute = act_YardimExecute
    end
    object actGelen_TeslimAl: TAction
      Tag = 2
      Category = 'Gelen'
      Caption = 'Teslim Al'
      ImageIndex = 113
      OnExecute = actGelen_TeslimAlExecute
    end
    object actGelen_TeslimAlBarkodile: TAction
      Tag = 2
      Category = 'Gelen'
      Caption = 'Barkod '#304'le Al'
      ImageIndex = 41
      OnExecute = actGelen_TeslimAlBarkodileExecute
    end
    object actGelen_TeslimALiptalEt: TAction
      Tag = 2
      Category = 'Gelen'
      Caption = #304'ptal Et'
      ImageIndex = 19
      OnExecute = actGelen_TeslimALiptalEtExecute
    end
    object actGelen_TeslimAlGeriGonder: TAction
      Tag = 2
      Category = 'Gelen'
      Caption = 'Geri Gonder'
      ImageIndex = 98
      OnExecute = actGelen_TeslimAlGeriGonderExecute
    end
    object actGelen_HavaleEtigimGeriAl: TAction
      Tag = 3
      Category = 'Gelen'
      Caption = 'Havale Geri Al'
      ImageIndex = 37
      OnExecute = actGelen_HavaleEtigimGeriAlExecute
    end
    object actGelen_DosyaladigimGeriAl: TAction
      Tag = 4
      Category = 'Gelen'
      Caption = 'Dosyadan Geri Al'
      ImageIndex = 45
      OnExecute = actGelen_DosyaladigimGeriAlExecute
    end
    object actGelen_IptalEttigimGeriAl: TAction
      Category = 'Gelen'
      Caption = #304'ptali Geri Al'
      ImageIndex = 68
      OnExecute = actGelen_IptalEttigimGeriAlExecute
    end
    object actGiden_UzerindeCalisitimYeniEvrak: TAction
      Tag = 7
      Category = 'Giden'
      Caption = 'Yeni Evrak'
      ImageIndex = 0
      OnExecute = actGiden_UzerindeCalisitimYeniEvrakExecute
    end
    object actGiden_UzerindeCalistigimImzayaGonder: TAction
      Tag = 7
      Category = 'Giden'
      Caption = #304'mzaya G'#246'nder'
      ImageIndex = 10
      OnExecute = actGiden_UzerindeCalistigimImzayaGonderExecute
    end
    object actGiden_UzerindeCalistigimDosyayaKaldir: TAction
      Category = 'Giden'
      Caption = 'Dosyaya Kald'#305'r'
      ImageIndex = 102
      OnExecute = actGiden_UzerindeCalistigimDosyayaKaldirExecute
    end
    object actGiden_UzerindeCalistigimIptalet: TAction
      Tag = 7
      Category = 'Giden'
      Caption = #304'ptal Et'
      ImageIndex = 107
      OnExecute = actGiden_UzerindeCalistigimIptaletExecute
    end
    object actGiden_UzerindeCalistigimEvrakNoAl: TAction
      Tag = 7
      Category = 'Giden'
      Caption = 'Evrak No Al'
      ImageIndex = 110
      OnExecute = actGiden_UzerindeCalistigimEvrakNoAlExecute
    end
    object actGiden_UzerindeCalistigimEEvrakGonder: TAction
      Tag = 7
      Category = 'Giden'
      Caption = 'E-Evrak G'#246'nder'
      ImageIndex = 51
      OnExecute = actGiden_UzerindeCalistigimEEvrakGonderExecute
    end
    object actGiden_UzerindeCalistigimEImzala: TAction
      Tag = 7
      Category = 'Giden'
      Caption = 'E-'#304'mzala'
      ImageIndex = 4
      OnExecute = actGiden_UzerindeCalistigimEImzalaExecute
    end
    object actGiden_UzerindeCalistigimimzala: TAction
      Tag = 9
      Category = 'Giden'
      Caption = #304'mzala'
      ImageIndex = 115
      OnExecute = actGiden_UzerindeCalistigimimzalaExecute
    end
    object actGiden_UzerindeCalistigimEditor: TAction
      Tag = 7
      Category = 'Giden'
      Caption = 'Edit'#246'r'
      ImageIndex = 105
      OnExecute = actGiden_UzerindeCalistigimEditorExecute
    end
    object actGiden_UzerindeCalistigimGeriGonder: TAction
      Tag = 7
      Category = 'Giden'
      Caption = 'Geri Gonder'
      OnExecute = actGiden_UzerindeCalistigimGeriGonderExecute
    end
    object actTanimlar: TAction
      Category = 'Menu'
      Caption = 'Ayarlar'
      ImageIndex = 21
      OnExecute = actTanimlarExecute
    end
    object actGiden_HavaleEttiklerimGeriAl: TAction
      Category = 'Giden'
      Caption = 'Havale Geri Al'
      ImageIndex = 37
      OnExecute = actGiden_HavaleEttiklerimGeriAlExecute
    end
    object actGiden_DosyaladigimGeriAl: TAction
      Category = 'Giden'
      Caption = 'Dosyadan  Geri Al'
      ImageIndex = 47
      OnExecute = actGiden_DosyaladigimGeriAlExecute
    end
    object actGiden_IptalEttiklerimGeriAl: TAction
      Category = 'Giden'
      Caption = #304'ptal Ettiklerimi Geri Al'
      ImageIndex = 67
    end
    object actGiden_Gor: TAction
      Category = 'Giden'
      Caption = 'G'#246'r'
      ImageIndex = 96
      OnExecute = actGiden_GorExecute
      OnUpdate = actGiden_GorUpdate
    end
  end
  object popupEvrakBilgileri: TPopupMenu
    Images = dmEvrakModule.ImagesEvrak
    Left = 720
    Top = 288
    object EvrakBilgisiAltta1: TMenuItem
      Action = act_EvrakBilgi_Altta
    end
    object EvrakBilgisiSada1: TMenuItem
      Action = act_EvrakBilgi_Sagda
    end
    object EvrakBilgisiGizle1: TMenuItem
      Action = act_EvrakBilgi_Gizle
      AutoCheck = True
    end
  end
  object popupAyarlar: TPopupMenu
    Images = dmEvrakModule.ImagesEvrak
    Left = 736
    Top = 352
    object actOtomatikTeslimAl1: TMenuItem
      Action = act_OtomatikTeslimAl
      AutoCheck = True
    end
  end
  object PopupGelenEvrak: TPopupMenu
    Images = dmEvrakModule.ImagesEvrak
    Left = 496
    Top = 224
    object YeniEvrak1: TMenuItem
      Tag = 1
      Action = actGelen_UzerindeCalistigimYeniEvrak
    end
    object HavaleEt1: TMenuItem
      Tag = 1
      Action = actGelen_UzerindeCalistigimHavaleEt
    end
    object DosyayaKaldr1: TMenuItem
      Tag = 1
      Action = actGelen_UzerindeCalistigimDosyayaKaldir
    end
    object ptalEt1: TMenuItem
      Tag = 1
      Action = actGelen_UzerindeCalistigimIptalEt
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object eslimAl1: TMenuItem
      Tag = 2
      Action = actGelen_TeslimAl
    end
    object BarkodleAl1: TMenuItem
      Tag = 2
      Action = actGelen_TeslimAlBarkodile
    end
    object ptalEt2: TMenuItem
      Tag = 2
      Action = actGelen_TeslimALiptalEt
    end
    object GeriGonder1: TMenuItem
      Tag = 2
      Action = actGelen_TeslimAlGeriGonder
    end
    object GeriGonder2: TMenuItem
      Caption = '-'
      ImageIndex = 98
      OnClick = actGelen_TeslimAlGeriGonderExecute
    end
    object HavaleGeriAl1: TMenuItem
      Tag = 3
      Action = actGelen_HavaleEtigimGeriAl
    end
    object DosyadanGeriAl1: TMenuItem
      Tag = 4
      Action = actGelen_DosyaladigimGeriAl
    end
    object ptaliGeriAl1: TMenuItem
      Tag = 5
      Action = actGelen_IptalEttigimGeriAl
    end
  end
  object PopupGidenEvrak: TPopupMenu
    Images = dmEvrakModule.ImagesEvrak
    Left = 616
    Top = 232
    object dmEvrakModuleImagesEvrak1: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalisitimYeniEvrak
    end
    object mzayaGnder1: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimImzayaGonder
    end
    object DosyayaKaldr2: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimDosyayaKaldir
    end
    object ptalEt3: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimIptalet
    end
    object EvrakNoAl1: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimEvrakNoAl
    end
    object EEvrakGnder1: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimEEvrakGonder
    end
    object Editr1: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimEditor
    end
    object GeriGonder3: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimGeriGonder
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Gr2: TMenuItem
      Action = actGiden_Gor
    end
    object actGidenUzerindeCalistigimimzala1: TMenuItem
      Tag = 7
      Action = actGiden_UzerindeCalistigimimzala
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object HavaleGeriAl2: TMenuItem
      Tag = 10
      Action = actGiden_HavaleEttiklerimGeriAl
    end
    object DosyadanGeriAl2: TMenuItem
      Tag = 11
      Action = actGiden_DosyaladigimGeriAl
    end
    object ptalEttiklerimiGeriAl1: TMenuItem
      Action = actGiden_IptalEttiklerimGeriAl
    end
  end
end

