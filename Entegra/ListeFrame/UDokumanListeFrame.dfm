object DokumanListeFrame: TDokumanListeFrame
  Left = 0
  Top = 0
  Width = 1037
  Height = 484
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
  object GridDokuman: TcxGrid
    Left = 0
    Top = 52
    Width = 1037
    Height = 231
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    RootLevelOptions.DetailTabsPosition = dtpTop
    object DokumanTview: TcxGridDBTableView
      DragMode = dmAutomatic
      OnDblClick = FormAcTusClick
      OnDragOver = DokumanTviewDragOver
      OnKeyUp = DokumanTviewKeyUp
      OnMouseMove = DokumanTviewMouseMove
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = DokumanTviewCanFocusRecord
      OnCellDblClick = DokumanTviewCellDblClick
      OnSelectionChanged = DokumanTviewSelectionChanged
      DataController.DataSource = DtsDokuman
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = 'Adet :  ######'
          Kind = skCount
          FieldName = 'AD'
          Column = DokumanTviewAD
          DisplayText = 'Toplam Adet'
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'BOYUT'
          Column = DokumanTviewBOYUT
          DisplayText = 'Toplam Boyut'
        end>
      DataController.Summary.SummaryGroups = <>
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
      OptionsView.Footer = True
      OptionsView.FooterAutoHeight = True
      OptionsView.FooterMultiSummaries = True
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = DokumanTviewStylesGetContentStyle
      object DokumanTviewTip: TcxGridDBColumn
        Caption = 'Tip'
        DataBinding.FieldName = 'DTIP'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repDokumanTip
        Visible = False
      end
      object DokumanTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Images = PNGImageList1
        Properties.Items = <
          item
            ImageIndex = 0
            Value = 0
          end
          item
            ImageIndex = 1
            Tag = 1
            Value = 1
          end>
      end
      object DokumanTviewEXT: TcxGridDBColumn
        Caption = 'Tipi'
        DataBinding.FieldName = 'EXT'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxHyperLinkEditProperties'
        RepositoryItem = Tablo.repFileExtensionList
        Width = 52
      end
      object DokumanTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
        Styles.Footer = AnaForm.cxStyle1
      end
      object DokumanTviewTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        DataBinding.IsNullValueType = True
      end
      object DokumanTviewBELGENO: TcxGridDBColumn
        Caption = 'Dok'#252'man No'
        DataBinding.FieldName = 'BELGENO'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object DokumanTviewYON: TcxGridDBColumn
        Caption = 'Y'#246'n'#252
        DataBinding.FieldName = 'YON'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepDokumanYonu
        Visible = False
      end
      object DokumanTviewMODUL: TcxGridDBColumn
        Caption = 'Mod'#252'l'
        DataBinding.FieldName = 'MODUL'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepDokumanModul
        Visible = False
      end
      object DokumanTviewKATEGORI: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'KATEGORI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepDokumanKategor
      end
      object DokumanTviewAD: TcxGridDBColumn
        Caption = 'D'#246'k'#252'man Ad'#305
        DataBinding.FieldName = 'AD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxHyperLinkEditProperties'
        Properties.LinkColor = clBlack
        Properties.Prefix = ''
        Width = 124
      end
      object DokumanTviewSURUM: TcxGridDBColumn
        Caption = 'S'#252'r'#252'm'
        DataBinding.FieldName = 'SURUM'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object DokumanTviewKONU: TcxGridDBColumn
        Caption = 'Konusu'
        DataBinding.FieldName = 'KONU'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 119
      end
      object DokumanTviewBOLUM: TcxGridDBColumn
        Caption = 'Departman'
        DataBinding.FieldName = 'BOLUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepCariBolum
        Visible = False
        Width = 119
      end
      object DokumanTviewKURUM: TcxGridDBColumn
        Caption = 'Kurum'
        DataBinding.FieldName = 'KURUM'
        DataBinding.IsNullValueType = True
        Width = 200
      end
      object DokumanTviewBOYUT: TcxGridDBColumn
        Caption = 'Boyut (KB)'
        DataBinding.FieldName = 'BOYUT'
        DataBinding.IsNullValueType = True
        Styles.Footer = AnaForm.cxStyle1
        Width = 70
      end
      object DokumanTviewSORUMLUAD: TcxGridDBColumn
        Caption = 'Sorumlu'
        DataBinding.FieldName = 'SORUMLUAD'
        DataBinding.IsNullValueType = True
        Width = 57
      end
      object DokumanTviewLOKASYONAD: TcxGridDBColumn
        Caption = 'Lokasyonu'
        DataBinding.FieldName = 'LOKASYONAD'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object DokumanTviewKLASOR: TcxGridDBColumn
        Caption = 'Klas'#246'r'
        DataBinding.FieldName = 'KLASORAD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Visible = False
        Width = 74
      end
      object DokumanTviewONAYLAYACAKAD: TcxGridDBColumn
        Caption = 'Onaylayacak'
        DataBinding.FieldName = 'ONAYLAYACAKAD'
        DataBinding.IsNullValueType = True
      end
      object DokumanTviewONAYLAYANAD: TcxGridDBColumn
        Caption = 'Onalayan'
        DataBinding.FieldName = 'ONAYLAYANAD'
        DataBinding.IsNullValueType = True
      end
      object DokumanTviewEKLEYEN: TcxGridDBColumn
        Caption = 'Ekleyen'
        DataBinding.FieldName = 'EKLEYENAD'
        DataBinding.IsNullValueType = True
      end
      object DokumanTviewEKLEMETARIHI: TcxGridDBColumn
        Caption = 'Ekleme Tarihi'
        DataBinding.FieldName = 'EKLEMETARIHI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
      end
      object DokumanTviewDEGISTIREN: TcxGridDBColumn
        Caption = 'De'#287'i'#351'tiren'
        DataBinding.FieldName = 'DEGISTIRENAD'
        DataBinding.IsNullValueType = True
      end
      object DokumanTviewDEGISTIRMETARIHI: TcxGridDBColumn
        Caption = 'De'#287'i'#351'tirme Tarihi'
        DataBinding.FieldName = 'DEGISTIRMETARIHI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
      end
      object DokumanTviewKISAYOLID: TcxGridDBColumn
        Caption = 'K'#305'sayol Id'
        DataBinding.FieldName = 'KISAYOLID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
    end
    object GridDokumanDBCardView1: TcxGridDBCardView
      DragMode = dmAutomatic
      OnDragOver = DokumanTviewDragOver
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
      object GridDokumanDBCardView1EXT: TcxGridDBCardViewRow
        DataBinding.FieldName = 'EXT'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repFileExtensionList
        Options.Editing = False
        Options.ShowCaption = False
        Position.BeginsLayer = True
        Position.LineCount = 2
      end
      object GridDokumanDBCardView1AD: TcxGridDBCardViewRow
        DataBinding.FieldName = 'AD'
        DataBinding.IsNullValueType = True
        Options.Editing = False
        Options.ShowCaption = False
        Position.BeginsLayer = True
        Position.LineCount = 3
      end
    end
    object cxGridLevel1: TcxGridLevel
      Caption = 'Liste'
      GridView = DokumanTview
    end
    object GridDokumanLevel1: TcxGridLevel
      Caption = 'Simge'
      GridView = GridDokumanDBCardView1
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1031
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
  object SQLMemo: TMemo
    Left = 27
    Top = 163
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
      
        'DTIP=1,KISAYOLID=0,Firma.FIRMA as KURUM,Lokasyon.ACIKLAMA as LOK' +
        'ASYONAD,'
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
      ' LEFT OUTER JOIN REHBER Firma on Firma.ID=D.REHBERID'
      
        ' LEFT OUTER JOIN LOKASYON AS Lokasyon ON Lokasyon.ID=D.LOKASYON ' +
        ' '
      ' LEFT OUTER JOIN REHBER AS Sorumlu ON Sorumlu.ID = I.REHBERID'
      
        ' LEFT OUTER JOIN DOKUMANYETKI DY ON DY.YERI=321 AND DY.YERID = D' +
        '.ID '
      ' '
      ' ')
    TabOrder = 2
    Visible = False
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
      
        #9'INNER JOIN IMAJ I ON I.ID = (select top 1 ID from IMAJ where YE' +
        'RI=1 AND YER_ID=D.ID order by ID desc)'
      ' '#9'LEFT OUTER JOIN REHBER Firma on Firma.ID=D.REHBERID'
      
        ' '#9'LEFT OUTER JOIN LOKASYON AS Lokasyon ON  Lokasyon.ID=D.LOKASYO' +
        'N  '
      ' '#9'LEFT OUTER JOIN REHBER AS Sorumlu ON Sorumlu.ID = I.REHBERID')
    TabOrder = 3
    Visible = False
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 283
    Width = 1037
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer9Style'
    AlignSplitter = salBottom
    Control = PageDokuman
    Visible = False
  end
  object PageDokuman: TcxPageControl
    Left = 0
    Top = 291
    Width = 1037
    Height = 193
    Align = alBottom
    TabOrder = 5
    Properties.ActivePage = TabSheetGenel
    Properties.CustomButtons.Buttons = <>
    Properties.Style = 8
    OnChange = PageDokumanChange
    ClientRectBottom = 193
    ClientRectRight = 1037
    ClientRectTop = 27
    object TabSheetGenel: TcxTabSheet
      Caption = '  Genel  '
      ImageIndex = 0
      object PanelGenel: TPanel
        Left = 0
        Top = 0
        Width = 1037
        Height = 166
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
        object ComboModul: TcxDBImageComboBox
          Left = 319
          Top = 138
          RepositoryItem = Tablo.repDokumanTip
          DataBinding.DataField = 'MODUL'
          DataBinding.DataSource = DtsDokuman
          Properties.Items = <
            item
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Proje'
              Value = 1
            end
            item
              Description = 'Aktivite'
              Value = 2
            end
            item
              Description = 'Fatura'
              Value = 3
            end
            item
              Description = #199'ek'
              Value = 4
            end
            item
              Description = 'Senet'
              Value = 5
            end>
          TabOrder = 18
          Visible = False
          Width = 148
        end
        object ComboBolum: TcxDBImageComboBox
          Left = 460
          Top = 136
          RepositoryItem = Tablo.RepCariBolum
          DataBinding.DataField = 'BOLUM'
          DataBinding.DataSource = DtsDokuman
          Properties.Items = <>
          TabOrder = 19
          Visible = False
          Width = 148
        end
        object cxDBLabel8: TcxDBLabel
          Left = 674
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
          AutoSize = True
          DataBinding.DataField = 'SORUMLUAD'
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
        object ComboGizlilik: TcxDBImageComboBox
          Left = 610
          Top = 126
          RepositoryItem = Tablo.RepDokumanGizlilik
          DataBinding.DataField = 'GIZLILIKDERECESI'
          DataBinding.DataSource = DtsDokuman
          Properties.Items = <
            item
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Proje'
              Value = 1
            end
            item
              Description = 'Aktivite'
              Value = 2
            end
            item
              Description = 'Fatura'
              Value = 3
            end
            item
              Description = #199'ek'
              Value = 4
            end
            item
              Description = 'Senet'
              Value = 5
            end>
          TabOrder = 27
          Visible = False
          Width = 148
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
      ImageIndex = 1
      object GridAktDetay: TcxGrid
        Left = 0
        Top = 0
        Width = 1037
        Height = 166
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
      ImageIndex = 2
      object GridIlgili: TcxGrid
        Left = 0
        Top = 0
        Width = 1037
        Height = 166
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
      ImageIndex = 3
      object GridYetki: TcxGrid
        Left = 0
        Top = 0
        Width = 1037
        Height = 166
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
    TabOrder = 6
    Visible = False
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
    Visible = False
  end
  object DtsDokuman: TDataSource
    AutoEdit = False
    DataSet = DOKUMAN
    Left = 361
    Top = 192
  end
  object DOKUMAN: TFDQuery
    BeforeOpen = DOKUMANBeforeOpen
    AfterOpen = DOKUMANAfterOpen
    AfterScroll = DOKUMANAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      '*'
      'from DOKUMAN D'
      '')
    Left = 89
    Top = 159
  end
  object PopupMenu1: TPopupMenu
    Left = 52
    Top = 221
    object Gr1: TMenuItem
      Caption = 'G'#246'r'
      OnClick = GortusClick
    end
    object Deitir1: TMenuItem
      Caption = 'D'#252'zenle'
      OnClick = DegistirTusClick
    end
    object DegisMenu: TMenuItem
      Caption = 'Form A'#231
      OnClick = FormAcTusClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Yeni1: TMenuItem
      Caption = 'Yeni'
      OnClick = YeniTusClick
    end
    object ara1: TMenuItem
      Caption = 'Tara'
      OnClick = TaraTusClick
    end
    object BurayaKisayololusturMenu: TMenuItem
      Caption = 'Buraya k'#305'sayol olu'#351'tur'
      OnClick = BurayaKisayololusturMenuClick
    end
    object Baskayerekisayololustur1: TMenuItem
      Caption = 'Ba'#351'ka yere k'#305'sayol olu'#351'tur'
      OnClick = Baskayerekisayololustur1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object KesMenu: TMenuItem
      Caption = 'Kes'
      OnClick = KesMenuClick
    end
    object KopyalaMenu: TMenuItem
      Caption = 'Kopyala'
      OnClick = KopyalaMenuClick
    end
    object YapistirMenu: TMenuItem
      Caption = 'Yap'#305#351't'#305'r'
      Enabled = False
      OnClick = YapistirMenuClick
    end
    object SilMenu: TMenuItem
      Caption = 'Sil'
      OnClick = SilTusClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object VerMenu: TMenuItem
      Caption = 'Ver (Export)'
      OnClick = VerTusClick
    end
    object DuyuruOlarakYaynla1: TMenuItem
      Caption = 'Duyuru olarak yay'#305'nla'
      OnClick = DuyuruOlarakYaynla1Click
    end
    object EPostaMenu: TMenuItem
      Caption = 'E-Posta olarak g'#246'nder'
      OnClick = EPostaMenuClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object EPostaAl1: TMenuItem
      Caption = 'E-Posta Al'
      OnClick = EPostaAl1Click
    end
    object Yetkilendirme1: TMenuItem
      Caption = 'Yetkilendirme'
      OnClick = Yetkilendirme1Click
    end
  end
  object popcop: TPopupMenu
    Left = 552
    Top = 128
    object Sil1: TMenuItem
      Caption = 'Sil'
      OnClick = Sil1Click
    end
    object GeriYkle1: TMenuItem
      Caption = 'Geri Y'#252'kle'
      OnClick = GeriYkle1Click
    end
    object GeriDnmBoalt1: TMenuItem
      Caption = 'Geri D'#246'n'#252#351#252'm'#252' Bo'#351'alt'
      OnClick = GeriDnmBoalt1Click
    end
  end
  object DtsKeywords: TDataSource
    Left = 912
    Top = 664
  end
  object TabYetki: TFDQuery
    Connection = Tablo.FDCnn
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
    ParamData = <
      item
        Name = 'YERI'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'YERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsYetki: TDataSource
    DataSet = TabYetki
    Left = 872
    Top = 677
  end
  object TabRevize: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select ID,BELGEADI, SURUM,  REHBERID, ONAYLAYACAK, ONAY,EKLEMETA' +
        'RIHI,DEGISTIRMETARIHI, DURUM, ACIKLAMA'
      ' from IMAJ'
      'where '
      '      YERI =1 and '
      '           YER_ID = :pYERID'
      'order by DEGISTIRMETARIHI')
    Left = 790
    Top = 221
    ParamData = <
      item
        Name = 'pYERID'#39
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsRevize: TDataSource
    DataSet = TabRevize
    Left = 828
    Top = 667
  end
  object TabIlgili: TFDQuery
    Connection = Tablo.FDCnn
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
    Left = 745
    Top = 222
    ParamData = <
      item
        Name = 'pDID1'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
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
end
