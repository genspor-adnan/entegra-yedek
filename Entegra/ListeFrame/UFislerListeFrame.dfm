object FislerListeFrame: TFislerListeFrame
  Left = 0
  Top = 0
  Width = 1086
  Height = 441
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
  object cxGrid: TcxGrid
    Left = 0
    Top = 35
    Width = 1086
    Height = 406
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridTview: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridTviewCanFocusRecord
      DataController.DataSource = DtsFisler
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Kind = skCount
          Position = spFooter
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          Position = spFooter
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skCount
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'TUTAR'
        end
        item
          Kind = skSum
          Column = GridTviewFATURA_TUTARI
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
      OptionsView.Footer = True
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      object GridTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewFATURATARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'FATURATARIH'
        DataBinding.IsNullValueType = True
      end
      object GridTviewTUR: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TUR'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewTIPI: TcxGridDBColumn
        Caption = 'Tip'
        DataBinding.FieldName = 'TIPI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepFatTipi
      end
      object GridTviewFATURANO: TcxGridDBColumn
        Caption = 'No'
        DataBinding.FieldName = 'FATURANO'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewDEPO: TcxGridDBColumn
        Caption = 'Depo'
        DataBinding.FieldName = 'GIRISDEPO'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepStokDepolarTumu
      end
      object GridTviewBASLIK: TcxGridDBColumn
        Caption = 'Ba'#351'l'#305'k'
        DataBinding.FieldName = 'BASLIK'
        DataBinding.IsNullValueType = True
        Width = 171
      end
      object GridTviewADRES: TcxGridDBColumn
        Caption = 'Adres'
        DataBinding.FieldName = 'ADRES'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewILCE: TcxGridDBColumn
        Caption = 'Il'#231'e'
        DataBinding.FieldName = 'ILCE'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewIL: TcxGridDBColumn
        Caption = 'Il'
        DataBinding.FieldName = 'IL'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewVD: TcxGridDBColumn
        DataBinding.FieldName = 'VD'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewVNO: TcxGridDBColumn
        Caption = 'VNo'
        DataBinding.FieldName = 'VNO'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewKDVDURUM: TcxGridDBColumn
        Caption = 'KDV Durum'
        DataBinding.FieldName = 'KDVDURUM'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewFATURA_MATRAHI: TcxGridDBColumn
        Caption = 'Matrah'
        DataBinding.FieldName = 'FATURA_MATRAHI'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewKDV_TUTARI: TcxGridDBColumn
        Caption = 'KDV Tutar'#305
        DataBinding.FieldName = 'KDV_TUTARI'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewFATURA_TUTARI: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'FATURA_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
      end
      object GridTviewKUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewDOVIZ_TUTARI: TcxGridDBColumn
        Caption = 'D'#246'v. Tutar'#305
        DataBinding.FieldName = 'DOVIZ_TUTARI'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewDOVIZ_CINSI: TcxGridDBColumn
        Caption = 'D'#246'v. Cinsi'
        DataBinding.FieldName = 'DOVIZ_CINSI'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
      end
      object GridTviewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewYETKIKODU: TcxGridDBColumn
        Caption = 'Yetki Kodu'
        DataBinding.FieldName = 'YETKIKODU'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewDETAYBOLUMU: TcxGridDBColumn
        Caption = 'Detay'
        DataBinding.FieldName = 'DETAYBOLUMU'
        DataBinding.IsNullValueType = True
        Visible = False
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = GridTview
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1080
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
    TabOrder = 1
    Transparent = True
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      DropdownMenu = PopupFis
      ImageIndex = 7
      ImageName = 'PngImage6'
    end
    object SilTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 148
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      ImageName = 'PngImage9'
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
  end
  object SQLMemo: TcxMemo
    Left = 111
    Top = 312
    Lines.Strings = (
      'select distinct FB.* from FATBASLIK FB')
    Properties.WordWrap = False
    TabOrder = 2
    Visible = False
    Height = 25
    Width = 588
  end
  object DtsFisler: TDataSource
    DataSet = TabFisler
    Left = 228
    Top = 114
  end
  object TabFisler: TFDQuery
    AfterScroll = TabFislerAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select F.* from FATBASLIK F ')
    Left = 209
    Top = 259
  end
  object TabFisDetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select F.* from FATURA F where FATBASID=:PFatBasID')
    Left = 217
    Top = 339
    ParamData = <
      item
        Name = 'PFatBasID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 423
    Top = 156
  end
  object PopupFis: TPopupMenu
    Left = 488
    Top = 208
  end
end
