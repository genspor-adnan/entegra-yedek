object MasrafGelirSecDlg: TMasrafGelirSecDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Masraf / Gelir Se'#231'imi Ekran'#305
  ClientHeight = 534
  ClientWidth = 579
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 579
    Height = 80
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 15
      Top = 35
      Width = 28
      Height = 14
      Caption = '&Kodu'
      FocusControl = AraKod
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelAdi: TLabel
      Left = 97
      Top = 35
      Width = 18
      Height = 14
      Caption = 'A&d'#305
      FocusControl = AraStokAdi
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 399
      Top = 35
      Width = 26
      Height = 14
      Caption = 'Adet'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelBarkod: TLabel
      Left = 287
      Top = 35
      Width = 46
      Height = 14
      Caption = 'Barkodu'
      FocusControl = AraBarkod
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelSube: TLabel
      Left = 447
      Top = 35
      Width = 28
      Height = 14
      Caption = #350'&ube'
      FocusControl = AraStokAdi
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object AraKod: TEdit
      Left = 10
      Top = 53
      Width = 81
      Height = 21
      TabOrder = 1
      OnKeyUp = AraKodKeyUp
    end
    object AraStokAdi: TEdit
      Left = 96
      Top = 52
      Width = 302
      Height = 21
      TabOrder = 2
      OnKeyUp = AraKodKeyUp
    end
    object Adet: TEdit
      Left = 400
      Top = 52
      Width = 26
      Height = 21
      TabOrder = 4
      Text = '1'
    end
    object UpDown1: TUpDown
      Left = 426
      Top = 52
      Width = 16
      Height = 21
      Associate = Adet
      Min = 1
      Position = 1
      TabOrder = 5
    end
    object AraBarkod: TEdit
      Left = 283
      Top = 52
      Width = 116
      Height = 21
      TabOrder = 3
    end
    object ToolBar3: TToolBar
      Left = 1
      Top = 1
      Width = 577
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 55
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
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object SecTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Se'#231
        ImageIndex = 23
        OnClick = SecTusClick
      end
      object ToolButton4: TToolButton
        Left = 55
        Top = 0
        Width = 339
        Caption = 'ToolButton4'
        ImageIndex = 6
        Style = tbsSeparator
      end
      object KapatlTus: TToolButton
        Left = 394
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 5
        OnClick = KapatlTusClick
      end
    end
    object ComboSube: TcxImageComboBox
      Left = 448
      Top = 51
      RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      Properties.Alignment.Horz = taLeftJustify
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboSubePropertiesEditValueChanged
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBlack
      TabOrder = 6
      Width = 124
    end
  end
  object cxDBTreeList1: TcxDBTreeList
    Left = 0
    Top = 80
    Width = 579
    Height = 454
    Align = alClient
    Bands = <
      item
        Caption.Text = 'Hesap Plan'#305
      end>
    DataController.DataSource = DtsMasrafListe
    DataController.ParentField = 'ROOTKOD'
    DataController.KeyField = 'KOD'
    DefaultRowHeight = 15
    LookAndFeel.SkinName = 'LondonLiquidSky'
    Navigator.Buttons.CustomButtons = <>
    OptionsBehavior.IncSearch = True
    OptionsData.Appending = True
    OptionsData.Inserting = True
    OptionsData.CheckHasChildren = False
    OptionsData.SmartRefresh = True
    OptionsSelection.CellSelect = False
    PopupMenu = PopupMenu1
    RootValue = -1
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 1
    OnDblClick = cxDBTreeList1DblClick
    object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
      Caption.Text = 'Kod'
      DataBinding.FieldName = 'KOD'
      Width = 129
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn
      Caption.Text = 'Ad'
      DataBinding.FieldName = 'AD'
      Width = 314
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListSUBE: TcxDBTreeListColumn
      PropertiesClassName = 'TcxImageComboBoxProperties'
      Properties.Items = <>
      Properties.Revertable = True
      RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      Caption.Text = #350'ube'
      DataBinding.FieldName = 'SUBEID'
      Width = 100
      Position.ColIndex = 2
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object TabMasrafListe: TFDQuery
    Connection = Tablo.FDCnn
    Left = 273
    Top = 119
  end
  object DtsMasrafListe: TDataSource
    DataSet = TabMasrafListe
    Left = 362
    Top = 119
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 172
    Top = 208
    object ListeyiYenile1: TMenuItem
      Caption = 'Listeyi Yenile'
      ImageIndex = 9
      OnClick = ListeyiYenile1Click
    end
  end
end
