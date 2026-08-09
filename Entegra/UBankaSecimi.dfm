object BankaSecimDlg: TBankaSecimDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Banka Se'#231'im Ekran'#305
  ClientHeight = 451
  ClientWidth = 975
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 18
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 969
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 126
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
    object GuncelleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'TCMB'#39'den G'#252'ncelle'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Visible = False
      OnClick = GuncelleTusClick
    end
    object SecTus: TToolButton
      Left = 126
      Top = 0
      Caption = 'Se'#231
      ImageIndex = 11
      ImageName = 'PngImage10'
      OnClick = SecTusClick
    end
    object YeniTus: TToolButton
      Left = 252
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object btnKapat: TToolButton
      Left = 378
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      ImageName = 'PngImage17'
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
    object KaydetTus: TToolButton
      Left = 504
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Visible = False
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 630
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Visible = False
      OnClick = IptalTusClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 312
    Height = 416
    Align = alLeft
    TabOrder = 1
    ExplicitTop = 32
    ExplicitHeight = 419
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 310
      Height = 41
      Align = alTop
      TabOrder = 0
      object cxLabel1: TcxLabel
        Left = 6
        Top = 8
        Caption = 'Bankalar'
        Transparent = True
      end
      object cxRadioButton1: TcxRadioButton
        Left = 98
        Top = 12
        Width = 66
        Height = 17
        Caption = 'S'#305'k Kul.'
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = cxRadioButton2Click
        Transparent = True
      end
      object cxRadioButton2: TcxRadioButton
        Left = 223
        Top = 12
        Width = 66
        Height = 17
        Caption = 'T'#252'm'#252
        TabOrder = 2
        OnClick = cxRadioButton2Click
        Transparent = True
      end
    end
    object cxGridBanka: TcxGrid
      Left = 1
      Top = 42
      Width = 310
      Height = 373
      Align = alClient
      PopupMenu = PopupBanka
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      object GridViewBanka: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = GridViewBankaCanFocusRecord
        OnCellClick = GridViewBankaCellClick
        DataController.DataSource = DtsBankalar
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Inserting = False
        OptionsView.ScrollBars = ssVertical
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object GridViewBankaSEC: TcxGridDBColumn
          Caption = 'S'#305'k K.'
          DataBinding.FieldName = 'SEC'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Width = 42
        end
        object GridViewBankaLOGO: TcxGridDBColumn
          Caption = 'Banka'
          DataBinding.FieldName = 'LOGO'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageProperties'
          Properties.FitMode = ifmNormal
          Properties.GraphicClassName = 'TdxPNGImage'
          Width = 121
        end
        object GridViewBankaBANKAKODU: TcxGridDBColumn
          DataBinding.FieldName = 'BANKAKODU'
          DataBinding.IsNullValueType = True
          Visible = False
        end
        object GridViewBankaBANKAADI: TcxGridDBColumn
          Caption = 'Banka Ad'#305
          DataBinding.FieldName = 'BANKAADI'
          DataBinding.IsNullValueType = True
          Options.Editing = False
          Width = 169
        end
        object GridViewBankaColumn1: TcxGridDBColumn
          DataBinding.IsNullValueType = True
        end
      end
      object cxGridLevel3: TcxGridLevel
        GridView = GridViewBanka
      end
    end
  end
  object Panel3: TPanel
    Left = 312
    Top = 35
    Width = 663
    Height = 416
    Align = alClient
    TabOrder = 2
    ExplicitTop = 32
    ExplicitHeight = 419
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 661
      Height = 41
      Align = alTop
      TabOrder = 0
      object cxLabel2: TcxLabel
        Left = 6
        Top = 8
        Caption = 'Bilgiler'
        Transparent = True
      end
      object EditAra: TcxTextEdit
        Left = 140
        Top = 7
        TabOrder = 1
        OnKeyUp = EditAraKeyUp
        Width = 167
      end
      object cxLabel10: TcxLabel
        Left = 94
        Top = 8
        Caption = 'Ara'
        Transparent = True
      end
    end
    object cxPageControl1: TcxPageControl
      Properties.Images = Tablo.PNGImageList2
      Left = 1
      Top = 42
      Width = 661
      Height = 373
      Align = alClient
      TabOrder = 1
      Properties.CustomButtons.Buttons = <>
      ClientRectBottom = 369
      ClientRectLeft = 4
      ClientRectRight = 657
      ClientRectTop = 4
    end
    object Memo1: TMemo
      Left = 212
      Top = 73
      Width = 387
      Height = 89
      TabOrder = 3
      Visible = False
    end
    object cxGrid1: TcxGrid
      Left = 1
      Top = 42
      Width = 661
      Height = 373
      Align = alClient
      PopupMenu = PopupSube
      TabOrder = 2
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      object cxGridDBTableView1: TcxGridDBTableView
        OnDblClick = SecTusClick
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = cxGridDBTableView1CanFocusRecord
        DataController.DataSource = DtsSubeler
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.ScrollBars = ssVertical
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object cxGridDBTableView1BANKAADI: TcxGridDBColumn
          Caption = 'Banka'
          DataBinding.FieldName = 'BANKAADI'
          DataBinding.IsNullValueType = True
          Width = 79
        end
        object cxGridDBTableView1BANKAKODU: TcxGridDBColumn
          DataBinding.FieldName = 'BANKAKODU'
          DataBinding.IsNullValueType = True
          Visible = False
        end
        object cxGridDBTableView1SUBEKODU: TcxGridDBColumn
          Caption = #350'ube Kodu'
          DataBinding.FieldName = 'SUBEKODU'
          DataBinding.IsNullValueType = True
          Width = 77
        end
        object cxGridDBTableView1SUBEADI: TcxGridDBColumn
          Caption = #350'ube Ad'#305
          DataBinding.FieldName = 'SUBEADI'
          DataBinding.IsNullValueType = True
          Width = 154
        end
        object cxGridDBTableView1ILNO: TcxGridDBColumn
          Caption = #304'li'
          DataBinding.FieldName = 'ILNO'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxTextEditProperties'
          Visible = False
        end
        object cxGridDBTableView1ILADI: TcxGridDBColumn
          Caption = #304'li'
          DataBinding.FieldName = 'ILADI'
          DataBinding.IsNullValueType = True
          Width = 78
        end
        object cxGridDBTableView1Column2: TcxGridDBColumn
          Caption = 'Para Birimi'
          DataBinding.FieldName = 'KUR'
          DataBinding.IsNullValueType = True
        end
        object cxGridDBTableView1HESAPKODU1: TcxGridDBColumn
          Caption = 'Hesap Kodu'
          DataBinding.FieldName = 'HESAPKODU'
          DataBinding.IsNullValueType = True
          Width = 81
        end
        object cxGridDBTableView1HESAPADI: TcxGridDBColumn
          Caption = 'Hesap Ad'#305
          DataBinding.FieldName = 'HESAPADI'
          DataBinding.IsNullValueType = True
          Width = 100
        end
        object cxGridDBTableView1HESAPNO1: TcxGridDBColumn
          Caption = 'Hesap No'
          DataBinding.FieldName = 'HESAPNO'
          DataBinding.IsNullValueType = True
          Width = 79
        end
        object cxGridDBTableView1Column1: TcxGridDBColumn
          DataBinding.FieldName = 'BHID'
          DataBinding.IsNullValueType = True
          Visible = False
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = cxGridDBTableView1
      end
    end
  end
  object XMLDocument1: TXMLDocument
    Left = 72
    Top = 112
    DOMVendorDesc = 'MSXML'
  end
  object DtsBankalar: TDataSource
    DataSet = TabBankalar
    Left = 461
    Top = 191
  end
  object TabBankalar: TFDQuery
    BeforeEdit = TabBankalarBeforeEdit
    AfterPost = TabBankalarAfterPost
    AfterCancel = TabBankalarAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from BANKALAR where SEC=:PSEC order by BANKAADI')
    Left = 459
    Top = 141
  end
  object DtsSubeler: TDataSource
    DataSet = TabSubeler
    Left = 528
    Top = 187
  end
  object TabSubeler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ' SELECT  BANKAKODU,SUBEKODU,SUBEADI,BS.ILNO,ILADI,BH.ID as BHID,'
      ' BH.HESAPKODU,BH.HESAPNO,BH.HESAPADI,BH.KUR'
      ' FROM BANKAHESAPLAR BH'
      '  inner join BANKASUBELER BS on BS.ID = BH.BANKASUBELERID'
      '  left outer join ILLER I ON BS.ILNO=I.ILNO'
      '  where'
      '  REHBERID = -1'
      '  and BH.HESAPADI like '#39'%%'#39)
    Left = 527
    Top = 141
  end
  object PopupSube: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 544
    Top = 304
    object ubeEkle2: TMenuItem
      Caption = #350'ube Ekle'
      ImageIndex = 13
      OnClick = ubeEkle2Click
    end
  end
  object PopupBanka: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 88
    Top = 200
    object BankaMenu: TMenuItem
      Caption = 'Banka Ekle'
      ImageIndex = 0
      OnClick = BankaMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object BankaSilMenu: TMenuItem
      Caption = 'Banka Sil'
      ImageIndex = 1
      OnClick = BankaSilMenuClick
    end
  end
end
