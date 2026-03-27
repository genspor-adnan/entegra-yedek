object DeAktivasyonDlg: TDeAktivasyonDlg
  Left = 0
  Top = 0
  Caption = 'DeAktivasyon '#304#351'lemleri'
  ClientHeight = 396
  ClientWidth = 822
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 822
    Height = 54
    Align = alTop
    TabOrder = 0
    ExplicitTop = 32
    object TxtDeAktivasyonAciklama: TcxTextEdit
      Left = 8
      Top = 27
      TabOrder = 0
      Width = 318
    end
    object cxLabel1: TcxLabel
      Left = 8
      Top = 9
      Caption = 'A'#231#305'klama'
    end
    object LBLDeAktivasyonSebebi: TcxLabel
      Left = 332
      Top = 9
      Caption = 'DeAktivasyon Sebebi'
    end
    object CmbDeAktivasyonTipi: TcxImageComboBox
      Left = 332
      Top = 27
      EditValue = 'M'
      Properties.DefaultImageIndex = 0
      Properties.Items = <
        item
          Description = 'Sistemden '#199#305'karma'
          ImageIndex = 0
          Value = '10'
        end
        item
          Description = #220'retim Fireleri'
          Value = '20'
        end
        item
          Description = 'Geri '#199'ekme Sebebiyle '#304'mha'
          Value = '30'
        end
        item
          Description = 'Miat Sebebiyle '#304'mha'
          Value = '40'
        end
        item
          Description = 'Revizyon'
          Value = '50'
        end
        item
          Description = 'Sarf'
          Value = '60'
        end>
      TabOrder = 3
      Width = 150
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 816
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 68
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
    HotImages = Tablo.PNGImageList1
    HotTrackColor = 65408
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 10
      Style = tbsSeparator
    end
    object BtnSatisYazdir: TToolButton
      Left = 8
      Top = 0
      Caption = 'Yazd'#305'r'
      ImageIndex = 16
      Visible = False
    end
    object BtnSatisBildir: TToolButton
      Left = 76
      Top = 0
      Caption = 'Bildir'
      ImageIndex = 12
      OnClick = BtnSatisBildirClick
    end
  end
  object GridDeAktivasyon: TcxGrid
    Left = 0
    Top = 89
    Width = 822
    Height = 307
    Align = alClient
    TabOrder = 2
    object TvDeaktivasyon: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = Tablo.DtsDeAktivasyon
      DataController.KeyFieldNames = 'ID'
      DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      object cxGridDBColumn24: TcxGridDBColumn
        Caption = 'Fatura Tarihi'
        DataBinding.FieldName = 'FATURATARIH'
        Visible = False
        GroupIndex = 0
        Width = 80
      end
      object cxGridDBColumn35: TcxGridDBColumn
        Caption = 'Fatura Ba'#351'l'#305#287#305
        DataBinding.FieldName = 'BASLIK'
        Visible = False
        GroupIndex = 1
        Width = 100
      end
      object cxGridDBColumn36: TcxGridDBColumn
        Caption = #220'r'#252'n Kodu'
        DataBinding.FieldName = 'URUNBARKOD'
        Width = 100
      end
      object cxGridDBColumn37: TcxGridDBColumn
        Caption = 'S'#305'ra No'
        DataBinding.FieldName = 'SIRANO'
        Options.Editing = False
        Width = 100
      end
      object cxGridDBColumn38: TcxGridDBColumn
        Caption = 'Lot No'
        DataBinding.FieldName = 'LOTNO'
        Options.Editing = False
        Width = 75
      end
      object cxGridDBColumn39: TcxGridDBColumn
        Caption = 'Son Kullan'#305'm Tarihi'
        DataBinding.FieldName = 'SONKULLANIM'
        Options.Editing = False
        Width = 100
      end
      object cxGridDBColumn40: TcxGridDBColumn
        Caption = 'DeAktivasyon Durum'
        DataBinding.FieldName = 'DEAKTIVASYON_DURUM'
        Options.Editing = False
        Width = 350
      end
      object cxGridDBColumn41: TcxGridDBColumn
        Caption = 'DeAktivasyon Bildirim Tarih'
        DataBinding.FieldName = 'DEAKTIVASYON_BILDIRIM_TARIH'
        Options.Editing = False
        Width = 100
      end
    end
    object cxGridLevel5: TcxGridLevel
      GridView = TvDeaktivasyon
    end
  end
end
