object HizliGirisPDKSDlg: THizliGirisPDKSDlg
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 635
  ClientWidth = 999
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 40
    Width = 993
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 102
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
      Caption = 'Aksiyon'
      ImageIndex = 1
      OnClick = YeniTusClick
    end
    object btnGirisSaat: TToolButton
      Tag = 3
      Left = 102
      Top = 0
      Caption = 'Giri'#351
      ImageIndex = 43
      OnClick = btnGirisSaatClick
    end
    object ToolButton1: TToolButton
      Left = 204
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnCikisSaat: TToolButton
      Tag = 4
      Left = 212
      Top = 0
      Caption = #199#305'k'#305#351
      ImageIndex = 43
      OnClick = btnGirisSaatClick
    end
    object BtnTumunuSec: TToolButton
      Left = 314
      Top = 0
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      ImageIndex = 11
      OnClick = BtnTumunuSecClick
    end
    object BtnTumunuBirak: TToolButton
      Left = 416
      Top = 0
      Caption = 'T'#252'm'#252'n'#252' B'#305'rak'
      ImageIndex = 31
      OnClick = BtnTumunuBirakClick
    end
    object PersonelEkleTus: TToolButton
      Left = 518
      Top = 0
      Caption = 'Personel Ekle'
      ImageIndex = 44
      OnClick = PersonelEkleTusClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 72
    Width = 999
    Height = 563
    Align = alClient
    BevelOuter = bvNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Panel2: TPanel
      Left = 0
      Top = 528
      Width = 999
      Height = 35
      Align = alBottom
      TabOrder = 2
      object cxLabel2: TcxLabel
        Left = 12
        Top = 8
        Caption = 'Kay'#305't Say'#305's'#305' :'
      end
      object lblKayitSayisi: TcxLabel
        Left = 86
        Top = 8
      end
      object cxLabel3: TcxLabel
        Left = 148
        Top = 8
        Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305' :'
      end
      object lblSeciliKayit: TcxLabel
        Left = 250
        Top = 8
        AutoSize = False
        Height = 20
        Width = 39
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 999
      Height = 41
      Align = alTop
      TabOrder = 0
      object LblSube: TcxLabel
        Left = 475
        Top = 7
        Caption = #350'ube'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxLabel1: TcxLabel
        Left = 12
        Top = 7
        Caption = 'Tarih'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object DateTarih: TcxDateEdit
        Left = 59
        Top = 11
        Enabled = False
        Properties.OnCloseUp = YenileClick
        StyleDisabled.Color = clWhite
        StyleDisabled.TextColor = clWindowText
        TabOrder = 3
        Width = 185
      end
      object ComboSube: TcxImageComboBox
        Left = 522
        Top = 10
        RepositoryItem = Tablo.RepSubeler
        Properties.Items = <>
        Properties.OnCloseUp = YenileClick
        StyleDisabled.Color = clWhite
        StyleDisabled.TextColor = clWindowText
        TabOrder = 2
        Width = 188
      end
    end
    object GridPDKS: TcxGrid
      Left = 0
      Top = 41
      Width = 999
      Height = 487
      Align = alClient
      TabOrder = 1
      object GridPDKSDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
      end
      object GridPDKSView: TcxGridDBCardView
        PopupMenu = pmGridStil
        OnMouseDown = GridPDKSViewMouseDown
        OnMouseUp = GridPDKSViewMouseUp
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = dtsTabPDKS
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        LayoutDirection = ldVertical
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.MultiSelect = True
        OptionsView.CardIndent = 7
        OptionsView.CardWidth = 240
        Styles.OnGetContentStyle = GridPDKSViewStylesGetContentStyle
        object GridPDKSViewFIRMA: TcxGridDBCardViewRow
          Caption = 'Ad'
          DataBinding.FieldName = 'FIRMA'
          Options.Editing = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
        end
        object GridPDKSViewDURUM: TcxGridDBCardViewRow
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepPDKSDurum
          Options.Editing = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
        end
        object GridPDKSViewGIRIS: TcxGridDBCardViewRow
          Caption = 'Giri'#351' Saat'
          DataBinding.FieldName = 'GIRIS'
          PropertiesClassName = 'TcxTimeEditProperties'
          Properties.TimeFormat = tfHourMin
          Options.Editing = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
        end
        object GridPDKSViewCIKIS: TcxGridDBCardViewRow
          Caption = #199#305'k'#305#351' Saat'
          DataBinding.FieldName = 'CIKIS'
          PropertiesClassName = 'TcxTimeEditProperties'
          Properties.TimeFormat = tfHourMin
          Options.Editing = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
        end
        object GridPDKSViewID: TcxGridDBCardViewRow
          DataBinding.FieldName = 'ID'
          Visible = False
          Position.BeginsLayer = True
        end
      end
      object GridPDKSLevel1: TcxGridLevel
        GridView = GridPDKSView
      end
    end
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 999
    Height = 37
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clGray
    ColorTo = clBlack
    ImageIndex = 0
    object KapatTus: TJvNavPanelButton
      Left = 919
      Top = 0
      Width = 80
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
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
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = KapatTusClick
      ExplicitLeft = 1087
      ExplicitTop = 1
    end
    object cxLabel9: TcxLabel
      Left = 6
      Top = 1
      AutoSize = False
      Caption = 'Personel Devam Kontrol Sistemi'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -24
      Style.Font.Name = 'Microsoft Sans Serif'
      Style.Font.Style = [fsBold, fsItalic]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Transparent = True
      Height = 33
      Width = 415
    end
  end
  object TabPDKS: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'Select PP.ID,R.FIRMA,PV.GUNADI,PP.GIRIS,PP.CIKIS,(convert(varcha' +
        'r,PV.GIRIS,108) +'#39' / '#39'+ convert(varchar,PV.CIKIS,108)) as VARGIR' +
        'ISCIKIS,'
      
        'GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP.G' +
        'IRIS),'#39'00:00'#39'),'
      
        'CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))' +
        ','#39'00:00'#39'),'
      
        'CALFARK= CASE WHEN  charindex('#39'*'#39',dbo.fn_SaatOlarak(DATEDIFF(mi,' +
        'PP.GIRIS,PP.CIKIS)))=0 THEN '
      
        'dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn_S' +
        'aatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE '#39'00:00'#39' END,'
      
        'CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.' +
        'fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),'#39'00:00'#39')'
      'from PERS_PDKS PP'
      'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID'
      
        'left outer join PERS_VARDIYATANIM PV on PV.REHBERID=PP.REHBERID ' +
        'and PV.GUN=DATEPART(WEEKDAY,PP.GIRIS)'
      'Where PV.AY = 0 and PP.REHBERID <> 0 and PP.CIKIS <> '#39#39
      'Union All'
      ''
      
        'Select PP.ID,R.FIRMA,PV.GUNADI,PP.GIRIS,PP.CIKIS,(convert(varcha' +
        'r,PV.GIRIS,108) +'#39' / '#39'+ convert(varchar,PV.CIKIS,108)) as VARGIR' +
        'ISCIKIS,'
      
        'GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP.G' +
        'IRIS),'#39'00:00'#39'),'
      
        'CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))' +
        ','#39'00:00'#39'),'
      
        'CALFARK= CASE WHEN  charindex('#39'*'#39',dbo.fn_SaatOlarak(DATEDIFF(mi,' +
        'PP.GIRIS,PP.CIKIS)))=0 THEN '
      
        'dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn_S' +
        'aatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE '#39'00:00'#39' END,'
      
        'CIKFARK=case When (PV.CIKIS='#39'1900-01-01 00:00:00'#39' or PV.GIRIS='#39'1' +
        '900-01-01 00:00:00'#39') then'
      
        '     isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),'#39'09:00'#39 +
        ',PP.GIRIS,PP.CIKIS),'#39'00:00'#39')'
      '   else '
      
        '     isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.fn_' +
        'SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),'#39'00:00'#39')'
      '   end'
      'from PERS_PDKS PP'
      'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID'
      
        'left outer join PERS_VARDIYATANIM PV on PV.REHBERID=PP.REHBERID ' +
        'and PV.GUN=DATEPART(DAY,PP.GIRIS) and PV.AY=DATEPART(MONTH,PP.GI' +
        'RIS)'
      
        'Where PV.AY <> 0 and PV.YIL <> 0 and PP.REHBERID <> 0 and PP.CIK' +
        'IS <> '#39#39
      ''
      'ORDER BY PP.GIRIS,PP.CIKIS')
    Left = 576
    Top = 144
  end
  object dtsTabPDKS: TDataSource
    DataSet = TabPDKS
    Left = 512
    Top = 152
  end
  object pmGridStil: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = pmGridStilPopup
    Left = 559
    Top = 243
    object StilOlutur1: TMenuItem
      Caption = 'Stil D'#252'zenle'
      ImageIndex = 7
      OnClick = StilOlutur1Click
    end
  end
end


