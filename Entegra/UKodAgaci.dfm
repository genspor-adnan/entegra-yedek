object KodAgaciDlg: TKodAgaciDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Kod A'#287'ac'#305
  ClientHeight = 438
  ClientWidth = 673
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object cxDBTreeList1: TcxDBTreeList
    Left = 0
    Top = 58
    Width = 673
    Height = 380
    Align = alClient
    Bands = <
      item
      end>
    DataController.DataSource = DtsKodAgaci
    DataController.ParentField = 'ROOKOD'
    DataController.KeyField = 'KOD'
    DragCursor = crDrag
    DragMode = dmAutomatic
    Navigator.Buttons.CustomButtons = <>
    OptionsCustomizing.ColumnsQuickCustomization = True
    OptionsData.CancelOnExit = False
    OptionsData.Editing = False
    OptionsData.Deleting = False
    OptionsData.SmartRefresh = True
    PopupMenus.ColumnHeaderMenu.UseBuiltInMenu = True
    RootValue = -1
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 0
    OnCustomDrawDataCell = cxDBTreeList1CustomDrawDataCell
    OnDblClick = cxDBTreeList1DblClick
    OnDragOver = cxDBTreeList1DragOver
    OnMouseDown = cxDBTreeList1MouseDown
    ExplicitTop = 55
    ExplicitHeight = 383
    object cxDBTreeList1cxDBTreeListSEC: TcxDBTreeListColumn
      PropertiesClassName = 'TcxCheckBoxProperties'
      BestFitMaxWidth = 50
      Caption.Text = 'Se'#231
      Options.Editing = False
      Width = 84
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 667
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
    ExplicitHeight = 29
    object SecTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Se'#231
      ImageIndex = 11
      ImageName = 'PngImage10'
      OnClick = SecTusClick
    end
    object ToolButton2: TToolButton
      Left = 74
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
    object YeniTus: TToolButton
      Left = 82
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      Visible = False
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 156
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      Visible = False
      OnClick = SilTusClick
    end
    object ToolButton5: TToolButton
      Left = 230
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
    object BtnKaydet: TToolButton
      Left = 238
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Visible = False
      OnClick = BtnKaydetClick
    end
    object BtnIptal: TToolButton
      Left = 312
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Visible = False
      OnClick = BtnIptalClick
    end
    object BtnDuzenle: TToolButton
      Left = 386
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      OnClick = BtnDuzenleClick
    end
    object BtnKapat: TToolButton
      Left = 460
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      ImageName = 'PngImage17'
      OnClick = BtnKapatClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 673
    Height = 23
    Align = alTop
    TabOrder = 2
    DesignSize = (
      673
      23)
    object EditKod: TcxTextEdit
      Left = 2
      Top = 1
      TabOrder = 0
      OnKeyUp = EditKodKeyUp
      Width = 121
    end
    object EditAciklama: TcxTextEdit
      Left = 128
      Top = 1
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnKeyUp = EditKodKeyUp
      Width = 412
    end
  end
  object DtsKodAgaci: TDataSource
    DataSet = TabKodAgaci
    Left = 59
    Top = 229
  end
  object TabKodAgaci: TFDQuery
    OnNewRecord = TabKodAgaciNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      '')
    Left = 172
    Top = 179
  end
end
