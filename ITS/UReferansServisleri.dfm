object ReferansDlg: TReferansDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Referans Servisleri'
  ClientHeight = 666
  ClientWidth = 1113
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageReferanslar: TcxPageControl
    Left = 225
    Top = 0
    Width = 888
    Height = 666
    ActivePage = TsFirmalar
    Align = alClient
    HideTabs = True
    TabOrder = 0
    ExplicitWidth = 767
    ExplicitHeight = 474
    ClientRectBottom = 666
    ClientRectRight = 888
    ClientRectTop = 0
    object TsFirmalar: TcxTabSheet
      Caption = 'TsFirmalar'
      ImageIndex = 0
      ExplicitWidth = 767
      ExplicitHeight = 474
      object GlnTree: TcxTreeList
        Left = 0
        Top = 41
        Width = 153
        Height = 584
        BorderStyle = cxcbsNone
        Align = alLeft
        Bands = <
          item
          end>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        Images = Tablo.PngMenu
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = True
        OptionsCustomizing.DynamicSizing = True
        OptionsData.CancelOnExit = False
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsSelection.HideFocusRect = False
        OptionsSelection.InvertSelect = False
        OptionsView.CellAutoHeight = True
        OptionsView.CellEndEllipsis = True
        OptionsView.ColumnAutoWidth = True
        OptionsView.DynamicIndent = True
        OptionsView.Headers = False
        OptionsView.ShowRoot = False
        ParentFont = False
        TabOrder = 0
        OnCanSelectNode = GlnTreeCanSelectNode
        OnNodeChanged = GlnTreeNodeChanged
        ExplicitHeight = 392
        Data = {
          00000500040100000F00000044617461436F6E74726F6C6C6572310100000012
          000000546378537472696E6756616C75655479706505000000000007000000DC
          7265746963690000040000004465706F000009000000DD687261636174E7FD00
          000600000045637A616E6500000700000048617374616E650500000000000000
          0800110000002900000001000000FFFFFFFFFFFFFFFF01000000080016000000
          2900000002000000FFFFFFFFFFFFFFFF0200000008000C000000290000000300
          0000FFFFFFFFFFFFFFFF030000000800120000002900000004000000FFFFFFFF
          FFFFFFFF040000000800210000002900000005000000FFFFFFFFFFFFFFFF0A00
          05000000}
        object cxTreeList1Column1: TcxTreeListColumn
          DataBinding.ValueType = 'String'
          Width = 122
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object JvNavPanelHeader1: TJvNavPanelHeader
        Left = 0
        Top = 0
        Width = 888
        Height = 41
        Align = alTop
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ColorFrom = clBtnFace
        ColorTo = clSilver
        ImageIndex = 0
        ExplicitWidth = 767
      end
      object JvNavPanelHeader2: TJvNavPanelHeader
        Left = 0
        Top = 625
        Width = 888
        Height = 41
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ColorFrom = clBtnFace
        ColorTo = clSilver
        ImageIndex = 0
        ExplicitTop = 433
        ExplicitWidth = 767
      end
      object Panel1: TPanel
        Left = 153
        Top = 41
        Width = 735
        Height = 584
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 3
        ExplicitWidth = 614
        ExplicitHeight = 392
        object Panel13: TPanel
          Left = 0
          Top = 35
          Width = 735
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 0
          ExplicitWidth = 614
          object EdtGlnAdi: TcxTextEdit
            Left = 10
            Top = 17
            Properties.OnChange = EdtGlnAdiPropertiesChange
            TabOrder = 0
            Width = 137
          end
          object cxLabel1: TcxLabel
            Left = 10
            Top = 0
            Caption = 'Firma Ad'#305
          end
          object cxLabel2: TcxLabel
            Left = 150
            Top = 0
            Caption = 'Firma GLN'
          end
          object EdtGlnGln: TcxTextEdit
            Left = 150
            Top = 17
            Properties.OnChange = EdtGlnAdiPropertiesChange
            TabOrder = 3
            Width = 137
          end
        end
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 729
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 61
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
          ExplicitWidth = 608
          object ToolButton8: TToolButton
            Left = 0
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object ToolButton9: TToolButton
            Left = 8
            Top = 0
            Caption = 'Ara'
            ImageIndex = 0
          end
          object BtnGetir: TToolButton
            Left = 69
            Top = 0
            Caption = 'Getir'
            ImageIndex = 12
            OnClick = BtnGetirClick
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 76
          Width = 735
          Height = 508
          Align = alClient
          BevelOuter = bvNone
          Caption = 'Panel2'
          TabOrder = 2
          ExplicitWidth = 614
          ExplicitHeight = 316
          object PageGln: TcxPageControl
            Left = 0
            Top = 0
            Width = 735
            Height = 508
            ActivePage = PageTabHastane
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 614
            ExplicitHeight = 316
            ClientRectBottom = 508
            ClientRectRight = 735
            ClientRectTop = 24
            object PageTabUretici: TcxTabSheet
              Caption = #220'retici'
              ImageIndex = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 316
              object GridUretici: TcxGrid
                Left = 0
                Top = 0
                Width = 614
                Height = 292
                Align = alClient
                TabOrder = 0
                ExplicitHeight = 316
                object ViewUretici: TcxGridDBTableView
                  NavigatorButtons.ConfirmDelete = False
                  DataController.DataModeController.SmartRefresh = True
                  DataController.DataSource = DtsGlnUretici
                  DataController.KeyFieldNames = 'ID'
                  DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <
                    item
                      Kind = skCount
                      FieldName = 'ID'
                      Column = ViewUreticiISIM
                    end>
                  DataController.Summary.SummaryGroups = <>
                  OptionsData.Deleting = False
                  OptionsData.Inserting = False
                  OptionsView.ColumnAutoWidth = True
                  OptionsView.Footer = True
                  OptionsView.FooterAutoHeight = True
                  object ViewUreticiISIM: TcxGridDBColumn
                    Caption = 'Firma Unvan'
                    DataBinding.FieldName = 'ISIM'
                    Options.Editing = False
                    Width = 137
                  end
                  object ViewUreticiGLN: TcxGridDBColumn
                    DataBinding.FieldName = 'GLN'
                    Options.Editing = False
                    Width = 116
                  end
                  object ViewUreticiYETKILI: TcxGridDBColumn
                    Caption = 'Yetkili Ki'#351'i'
                    DataBinding.FieldName = 'YETKILI'
                    Options.Editing = False
                    Width = 65
                  end
                  object ViewUreticiEMAIL: TcxGridDBColumn
                    Caption = 'Yetkili E-MA'#304'L'
                    DataBinding.FieldName = 'EMAIL'
                    Options.Editing = False
                    Width = 61
                  end
                  object ViewUreticiTELEFON: TcxGridDBColumn
                    Caption = 'Telefon'
                    DataBinding.FieldName = 'TELEFON'
                    Options.Editing = False
                    Width = 36
                  end
                  object ViewUreticiIL: TcxGridDBColumn
                    Caption = #304'l'
                    DataBinding.FieldName = 'IL'
                    Options.Editing = False
                    Width = 39
                  end
                  object ViewUreticiILCE: TcxGridDBColumn
                    Caption = #304'l'#231'e'
                    DataBinding.FieldName = 'ILCE'
                    Options.Editing = False
                    Width = 36
                  end
                  object ViewUreticiADRES: TcxGridDBColumn
                    Caption = 'Adres'
                    DataBinding.FieldName = 'ADRES'
                    Options.Editing = False
                    Width = 39
                  end
                  object ViewUreticiALIMZAMANI: TcxGridDBColumn
                    Caption = 'Alim Zamani'
                    DataBinding.FieldName = 'ALIMZAMANI'
                    Options.Editing = False
                    Width = 38
                  end
                  object ViewUreticiID: TcxGridDBColumn
                    DataBinding.FieldName = 'ID'
                    Visible = False
                    Width = 20
                  end
                  object ViewUreticiAKTARIM: TcxGridDBColumn
                    Caption = 'Aktar'#305'm'
                    DataBinding.FieldName = 'AKTARIM'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Width = 50
                  end
                  object ViewUreticiAKTIF: TcxGridDBColumn
                    Caption = 'Aktif'
                    DataBinding.FieldName = 'AKTIF'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Options.Editing = False
                    Width = 50
                  end
                end
                object LvlUretici: TcxGridLevel
                  GridView = ViewUretici
                end
              end
            end
            object PageTabDepo: TcxTabSheet
              Caption = 'PageTabDepo'
              ImageIndex = 1
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 316
              object GridDepo: TcxGrid
                Left = 0
                Top = 0
                Width = 614
                Height = 292
                Align = alClient
                TabOrder = 0
                ExplicitHeight = 316
                object cxGridDBTableView1: TcxGridDBTableView
                  NavigatorButtons.ConfirmDelete = False
                  DataController.DataModeController.SmartRefresh = True
                  DataController.DataSource = DtsGlnDepo
                  DataController.KeyFieldNames = 'ID'
                  DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <
                    item
                      Kind = skCount
                      FieldName = 'ID'
                      Column = cxGridDBColumn1
                    end>
                  DataController.Summary.SummaryGroups = <>
                  OptionsData.Deleting = False
                  OptionsData.Inserting = False
                  OptionsView.ColumnAutoWidth = True
                  OptionsView.Footer = True
                  object cxGridDBColumn1: TcxGridDBColumn
                    Caption = 'Firma Unvan'
                    DataBinding.FieldName = 'ISIM'
                    Options.Editing = False
                    Width = 137
                  end
                  object cxGridDBColumn2: TcxGridDBColumn
                    DataBinding.FieldName = 'GLN'
                    Options.Editing = False
                    Width = 116
                  end
                  object cxGridDBColumn3: TcxGridDBColumn
                    Caption = 'Yetkili Ki'#351'i'
                    DataBinding.FieldName = 'YETKILI'
                    Options.Editing = False
                    Width = 65
                  end
                  object cxGridDBColumn4: TcxGridDBColumn
                    Caption = 'Yetkili E-MA'#304'L'
                    DataBinding.FieldName = 'EMAIL'
                    Options.Editing = False
                    Width = 61
                  end
                  object cxGridDBColumn5: TcxGridDBColumn
                    Caption = 'Telefon'
                    DataBinding.FieldName = 'TELEFON'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn6: TcxGridDBColumn
                    Caption = #304'l'
                    DataBinding.FieldName = 'IL'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn7: TcxGridDBColumn
                    Caption = #304'l'#231'e'
                    DataBinding.FieldName = 'ILCE'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn8: TcxGridDBColumn
                    Caption = 'Adres'
                    DataBinding.FieldName = 'ADRES'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn9: TcxGridDBColumn
                    Caption = 'Alim Zamani'
                    DataBinding.FieldName = 'ALIMZAMANI'
                    Options.Editing = False
                    Width = 38
                  end
                  object cxGridDBColumn10: TcxGridDBColumn
                    DataBinding.FieldName = 'ID'
                    Visible = False
                    Width = 20
                  end
                  object cxGridDBColumn11: TcxGridDBColumn
                    Caption = 'Aktar'#305'm'
                    DataBinding.FieldName = 'AKTARIM'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Width = 50
                  end
                  object cxGridDBColumn12: TcxGridDBColumn
                    Caption = 'Aktif'
                    DataBinding.FieldName = 'AKTIF'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Options.Editing = False
                    Width = 50
                  end
                end
                object cxGridLevel1: TcxGridLevel
                  GridView = cxGridDBTableView1
                end
              end
            end
            object PageTabIhracatci: TcxTabSheet
              Caption = 'PageTabIhracatci'
              ImageIndex = 2
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 316
              object GridIhracatci: TcxGrid
                Left = 0
                Top = 0
                Width = 614
                Height = 292
                Align = alClient
                TabOrder = 0
                ExplicitHeight = 316
                object cxGridDBTableView2: TcxGridDBTableView
                  NavigatorButtons.ConfirmDelete = False
                  DataController.DataModeController.SmartRefresh = True
                  DataController.DataSource = DtsGlnIhracatci
                  DataController.KeyFieldNames = 'ID'
                  DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <
                    item
                      Kind = skCount
                      FieldName = 'ID'
                      Column = cxGridDBColumn13
                    end>
                  DataController.Summary.SummaryGroups = <>
                  OptionsData.Deleting = False
                  OptionsData.Inserting = False
                  OptionsView.ColumnAutoWidth = True
                  OptionsView.Footer = True
                  object cxGridDBColumn13: TcxGridDBColumn
                    Caption = 'Firma Unvan'
                    DataBinding.FieldName = 'ISIM'
                    Options.Editing = False
                    Width = 137
                  end
                  object cxGridDBColumn14: TcxGridDBColumn
                    DataBinding.FieldName = 'GLN'
                    Options.Editing = False
                    Width = 116
                  end
                  object cxGridDBColumn15: TcxGridDBColumn
                    Caption = 'Yetkili Ki'#351'i'
                    DataBinding.FieldName = 'YETKILI'
                    Options.Editing = False
                    Width = 65
                  end
                  object cxGridDBColumn16: TcxGridDBColumn
                    Caption = 'Yetkili E-MA'#304'L'
                    DataBinding.FieldName = 'EMAIL'
                    Options.Editing = False
                    Width = 61
                  end
                  object cxGridDBColumn17: TcxGridDBColumn
                    Caption = 'Telefon'
                    DataBinding.FieldName = 'TELEFON'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn18: TcxGridDBColumn
                    Caption = #304'l'
                    DataBinding.FieldName = 'IL'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn19: TcxGridDBColumn
                    Caption = #304'l'#231'e'
                    DataBinding.FieldName = 'ILCE'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn20: TcxGridDBColumn
                    Caption = 'Adres'
                    DataBinding.FieldName = 'ADRES'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn21: TcxGridDBColumn
                    Caption = 'Alim Zamani'
                    DataBinding.FieldName = 'ALIMZAMANI'
                    Options.Editing = False
                    Width = 38
                  end
                  object cxGridDBColumn22: TcxGridDBColumn
                    DataBinding.FieldName = 'ID'
                    Visible = False
                    Width = 20
                  end
                  object cxGridDBColumn23: TcxGridDBColumn
                    Caption = 'Aktar'#305'm'
                    DataBinding.FieldName = 'AKTARIM'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Width = 50
                  end
                  object cxGridDBColumn24: TcxGridDBColumn
                    Caption = 'Aktif'
                    DataBinding.FieldName = 'AKTIF'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Options.Editing = False
                    Width = 50
                  end
                end
                object cxGridLevel2: TcxGridLevel
                  GridView = cxGridDBTableView2
                end
              end
            end
            object PageTabEczane: TcxTabSheet
              Caption = 'PageTabEczane'
              ImageIndex = 3
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 316
              object GridEczane: TcxGrid
                Left = 0
                Top = 0
                Width = 614
                Height = 292
                Align = alClient
                TabOrder = 0
                ExplicitHeight = 316
                object cxGridDBTableView3: TcxGridDBTableView
                  NavigatorButtons.ConfirmDelete = False
                  DataController.DataModeController.SmartRefresh = True
                  DataController.DataSource = DtsGlnEczane
                  DataController.KeyFieldNames = 'ID'
                  DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <
                    item
                      Kind = skCount
                      FieldName = 'ID'
                      Column = cxGridDBColumn25
                    end>
                  DataController.Summary.SummaryGroups = <>
                  OptionsData.Deleting = False
                  OptionsData.Inserting = False
                  OptionsView.ColumnAutoWidth = True
                  OptionsView.Footer = True
                  object cxGridDBColumn25: TcxGridDBColumn
                    Caption = 'Firma Unvan'
                    DataBinding.FieldName = 'ISIM'
                    Options.Editing = False
                    Width = 137
                  end
                  object cxGridDBColumn26: TcxGridDBColumn
                    DataBinding.FieldName = 'GLN'
                    Options.Editing = False
                    Width = 116
                  end
                  object cxGridDBColumn27: TcxGridDBColumn
                    Caption = 'Yetkili Ki'#351'i'
                    DataBinding.FieldName = 'YETKILI'
                    Options.Editing = False
                    Width = 65
                  end
                  object cxGridDBColumn28: TcxGridDBColumn
                    Caption = 'Yetkili E-MA'#304'L'
                    DataBinding.FieldName = 'EMAIL'
                    Options.Editing = False
                    Width = 61
                  end
                  object cxGridDBColumn29: TcxGridDBColumn
                    Caption = 'Telefon'
                    DataBinding.FieldName = 'TELEFON'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn30: TcxGridDBColumn
                    Caption = #304'l'
                    DataBinding.FieldName = 'IL'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn31: TcxGridDBColumn
                    Caption = #304'l'#231'e'
                    DataBinding.FieldName = 'ILCE'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn32: TcxGridDBColumn
                    Caption = 'Adres'
                    DataBinding.FieldName = 'ADRES'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn33: TcxGridDBColumn
                    Caption = 'Alim Zamani'
                    DataBinding.FieldName = 'ALIMZAMANI'
                    Options.Editing = False
                    Width = 38
                  end
                  object cxGridDBColumn34: TcxGridDBColumn
                    DataBinding.FieldName = 'ID'
                    Visible = False
                    Width = 20
                  end
                  object cxGridDBColumn35: TcxGridDBColumn
                    Caption = 'Aktar'#305'm'
                    DataBinding.FieldName = 'AKTARIM'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Width = 50
                  end
                  object cxGridDBColumn36: TcxGridDBColumn
                    Caption = 'Aktif'
                    DataBinding.FieldName = 'AKTIF'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Options.Editing = False
                    Width = 50
                  end
                end
                object cxGridLevel3: TcxGridLevel
                  GridView = cxGridDBTableView3
                end
              end
            end
            object PageTabHastane: TcxTabSheet
              Caption = 'PageTabHastane'
              ImageIndex = 4
              ExplicitWidth = 614
              ExplicitHeight = 292
              object GridHastane: TcxGrid
                Left = 0
                Top = 0
                Width = 735
                Height = 484
                Align = alClient
                TabOrder = 0
                ExplicitWidth = 614
                ExplicitHeight = 292
                object cxGridDBTableView4: TcxGridDBTableView
                  NavigatorButtons.ConfirmDelete = False
                  DataController.DataModeController.SmartRefresh = True
                  DataController.DataSource = DtsGlnHastane
                  DataController.KeyFieldNames = 'ID'
                  DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <
                    item
                      Kind = skCount
                      FieldName = 'ID'
                      Column = cxGridDBColumn37
                    end>
                  DataController.Summary.SummaryGroups = <>
                  OptionsData.Deleting = False
                  OptionsData.Inserting = False
                  OptionsView.ColumnAutoWidth = True
                  OptionsView.Footer = True
                  object cxGridDBColumn37: TcxGridDBColumn
                    Caption = 'Firma Unvan'
                    DataBinding.FieldName = 'ISIM'
                    Options.Editing = False
                    Width = 137
                  end
                  object cxGridDBColumn38: TcxGridDBColumn
                    DataBinding.FieldName = 'GLN'
                    Options.Editing = False
                    Width = 116
                  end
                  object cxGridDBColumn39: TcxGridDBColumn
                    Caption = 'Yetkili Ki'#351'i'
                    DataBinding.FieldName = 'YETKILI'
                    Options.Editing = False
                    Width = 65
                  end
                  object cxGridDBColumn40: TcxGridDBColumn
                    Caption = 'Yetkili E-MA'#304'L'
                    DataBinding.FieldName = 'EMAIL'
                    Options.Editing = False
                    Width = 61
                  end
                  object cxGridDBColumn41: TcxGridDBColumn
                    Caption = 'Telefon'
                    DataBinding.FieldName = 'TELEFON'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn42: TcxGridDBColumn
                    Caption = #304'l'
                    DataBinding.FieldName = 'IL'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn43: TcxGridDBColumn
                    Caption = #304'l'#231'e'
                    DataBinding.FieldName = 'ILCE'
                    Options.Editing = False
                    Width = 36
                  end
                  object cxGridDBColumn44: TcxGridDBColumn
                    Caption = 'Adres'
                    DataBinding.FieldName = 'ADRES'
                    Options.Editing = False
                    Width = 39
                  end
                  object cxGridDBColumn45: TcxGridDBColumn
                    Caption = 'Alim Zamani'
                    DataBinding.FieldName = 'ALIMZAMANI'
                    Options.Editing = False
                    Width = 38
                  end
                  object cxGridDBColumn46: TcxGridDBColumn
                    DataBinding.FieldName = 'ID'
                    Visible = False
                    Width = 20
                  end
                  object cxGridDBColumn47: TcxGridDBColumn
                    Caption = 'Aktar'#305'm'
                    DataBinding.FieldName = 'AKTARIM'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Width = 50
                  end
                  object cxGridDBColumn48: TcxGridDBColumn
                    Caption = 'Aktif'
                    DataBinding.FieldName = 'AKTIF'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                    Properties.ValueChecked = -1
                    Properties.ValueUnchecked = 0
                    FooterAlignmentHorz = taCenter
                    GroupSummaryAlignment = taCenter
                    HeaderAlignmentHorz = taCenter
                    Options.Editing = False
                    Width = 50
                  end
                end
                object cxGridLevel4: TcxGridLevel
                  GridView = cxGridDBTableView4
                end
              end
            end
          end
        end
      end
    end
    object TsIlaclar: TcxTabSheet
      Caption = 'TsIlaclar'
      ImageIndex = 1
      ExplicitWidth = 767
      ExplicitHeight = 474
      object JvNavPanelHeader4: TJvNavPanelHeader
        Left = 0
        Top = 433
        Width = 767
        Height = 41
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ColorFrom = clBtnFace
        ColorTo = clSilver
        ImageIndex = 0
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 761
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 61
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
        object BtnIlacAra: TToolButton
          Left = 8
          Top = 0
          Caption = 'Ara'
          ImageIndex = 0
        end
        object BtnIlacServisGetir: TToolButton
          Left = 69
          Top = 0
          Caption = 'Getir'
          ImageIndex = 12
          OnClick = BtnIlacServisGetirClick
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 35
        Width = 767
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        Color = 11776947
        ParentBackground = False
        TabOrder = 2
        ExplicitTop = 32
        object EdtIlacAdi: TcxTextEdit
          Left = 10
          Top = 17
          Properties.OnChange = EdtIlacAdiPropertiesChange
          TabOrder = 0
          Width = 137
        end
        object cxLabel3: TcxLabel
          Left = 10
          Top = 0
          Caption = #304'la'#231' Ad'#305
        end
        object cxLabel4: TcxLabel
          Left = 150
          Top = 0
          Caption = 'GTIN'
        end
        object EdtGTIN: TcxTextEdit
          Left = 150
          Top = 17
          Properties.OnChange = EdtIlacAdiPropertiesChange
          TabOrder = 3
          Width = 137
        end
      end
      object GridIlac: TcxGrid
        Left = 0
        Top = 76
        Width = 767
        Height = 357
        Align = alClient
        TabOrder = 3
        object TableViewIlac: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsIlac
          DataController.KeyFieldNames = 'ID'
          DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.Footer = True
          object TableViewIlacGTIN: TcxGridDBColumn
            DataBinding.FieldName = 'GTIN'
            Width = 75
          end
          object TableViewIlacADI: TcxGridDBColumn
            DataBinding.FieldName = 'ADI'
            Width = 250
          end
          object TableViewIlacURETICI_GLN: TcxGridDBColumn
            DataBinding.FieldName = 'URETICI_GLN'
            Width = 250
          end
          object TableViewIlacURETICI_AD: TcxGridDBColumn
            DataBinding.FieldName = 'URETICI_AD'
            Width = 350
          end
          object TableViewIlacITHAL: TcxGridDBColumn
            DataBinding.FieldName = 'ITHAL'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ValueChecked = -1
            Properties.ValueUnchecked = 0
          end
          object TableViewIlacURETIM: TcxGridDBColumn
            DataBinding.FieldName = 'URETIM'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ValueChecked = -1
            Properties.ValueUnchecked = 0
          end
          object TableViewIlacALIM_ZAMANI: TcxGridDBColumn
            DataBinding.FieldName = 'ALIM_ZAMANI'
          end
          object TableViewIlacAKTARIM: TcxGridDBColumn
            DataBinding.FieldName = 'AKTARIM'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ValueChecked = -1
            Properties.ValueUnchecked = 0
          end
          object TableViewIlacID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
          end
        end
        object GridLevelIlac: TcxGridLevel
          GridView = TableViewIlac
        end
      end
    end
    object TsHatalar: TcxTabSheet
      Caption = 'TsHatalar'
      ImageIndex = 3
      ExplicitWidth = 767
      ExplicitHeight = 474
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 761
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 61
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
        TabOrder = 0
        Transparent = True
        object ToolButton2: TToolButton
          Left = 0
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 10
          Style = tbsSeparator
        end
        object BtnHataGetir: TToolButton
          Left = 8
          Top = 0
          Caption = 'Getir'
          ImageIndex = 12
          OnClick = BtnHataGetirClick
        end
      end
      object JvNavPanelHeader3: TJvNavPanelHeader
        Left = 0
        Top = 433
        Width = 767
        Height = 41
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ColorFrom = clBtnFace
        ColorTo = clSilver
        ImageIndex = 0
      end
      object GridHata: TcxGrid
        Left = 0
        Top = 35
        Width = 767
        Height = 398
        Align = alClient
        TabOrder = 2
        object TableViewHata: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsHata
          DataController.KeyFieldNames = 'ID'
          DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.Footer = True
          object TableViewHataTIPI: TcxGridDBColumn
            Caption = 'Tipi'
            DataBinding.FieldName = 'TIPI'
            Options.Editing = False
          end
          object TableViewHataKODU: TcxGridDBColumn
            Caption = 'Kodu'
            DataBinding.FieldName = 'KODU'
            Options.Editing = False
          end
          object TableViewHataACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Options.Editing = False
            Width = 500
          end
          object TableViewHataBILGI: TcxGridDBColumn
            Caption = 'Bilgi'
            DataBinding.FieldName = 'BILGI'
            Options.Editing = False
            Width = 250
          end
          object TableViewHataALIM_ZAMANI: TcxGridDBColumn
            Caption = 'Al'#305'm Zaman'#305
            DataBinding.FieldName = 'ALIM_ZAMANI'
            Options.Editing = False
          end
          object TableViewHataAKTARIM: TcxGridDBColumn
            Caption = 'Aktar'#305'm'
            DataBinding.FieldName = 'AKTARIM'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ValueChecked = -1
            Properties.ValueUnchecked = 0
            Options.Editing = False
          end
        end
        object GridLevelHata: TcxGridLevel
          GridView = TableViewHata
        end
      end
    end
    object TsSubeler: TcxTabSheet
      Caption = 'TsSubeler'
      ImageIndex = 4
      ExplicitWidth = 767
      ExplicitHeight = 474
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 767
        Height = 474
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Panel6: TPanel
          Left = 0
          Top = 35
          Width = 767
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 0
          ExplicitTop = 32
          object cxTextEdit1: TcxTextEdit
            Left = 10
            Top = 17
            Properties.OnChange = EdtGlnAdiPropertiesChange
            TabOrder = 0
            Width = 137
          end
          object cxLabel5: TcxLabel
            Left = 10
            Top = 0
            Caption = 'Firma Ad'#305
          end
          object cxLabel6: TcxLabel
            Left = 150
            Top = 0
            Caption = 'Firma GLN'
          end
          object cxTextEdit2: TcxTextEdit
            Left = 150
            Top = 17
            Properties.OnChange = EdtGlnAdiPropertiesChange
            TabOrder = 3
            Width = 137
          end
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 761
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 61
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
          object ToolButton3: TToolButton
            Left = 0
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object ToolButton4: TToolButton
            Left = 8
            Top = 0
            Caption = 'Ara'
            ImageIndex = 0
          end
          object ToolButton5: TToolButton
            Left = 69
            Top = 0
            Caption = 'Getir'
            ImageIndex = 12
            OnClick = BtnGetirClick
          end
        end
        object Panel7: TPanel
          Left = 0
          Top = 76
          Width = 767
          Height = 398
          Align = alClient
          BevelOuter = bvNone
          Caption = 'Panel2'
          TabOrder = 2
          object GridSubeler: TcxGrid
            Left = 0
            Top = 0
            Width = 767
            Height = 398
            Align = alClient
            TabOrder = 0
            object TableViewSubeler: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsGlnUretici
              DataController.KeyFieldNames = 'ID'
              DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.Footer = True
              object cxGridDBColumn49: TcxGridDBColumn
                Caption = 'Firma Unvan'
                DataBinding.FieldName = 'ISIM'
                Options.Editing = False
                Width = 137
              end
              object cxGridDBColumn50: TcxGridDBColumn
                DataBinding.FieldName = 'GLN'
                Options.Editing = False
                Width = 116
              end
              object cxGridDBColumn51: TcxGridDBColumn
                Caption = 'Yetkili Ki'#351'i'
                DataBinding.FieldName = 'YETKILI'
                Options.Editing = False
                Width = 65
              end
              object cxGridDBColumn52: TcxGridDBColumn
                Caption = 'Yetkili E-MA'#304'L'
                DataBinding.FieldName = 'EMAIL'
                Options.Editing = False
                Width = 61
              end
              object cxGridDBColumn53: TcxGridDBColumn
                Caption = 'Telefon'
                DataBinding.FieldName = 'TELEFON'
                Options.Editing = False
                Width = 36
              end
              object cxGridDBColumn54: TcxGridDBColumn
                Caption = #304'l'
                DataBinding.FieldName = 'IL'
                Options.Editing = False
                Width = 39
              end
              object cxGridDBColumn55: TcxGridDBColumn
                Caption = #304'l'#231'e'
                DataBinding.FieldName = 'ILCE'
                Options.Editing = False
                Width = 36
              end
              object cxGridDBColumn56: TcxGridDBColumn
                Caption = 'Adres'
                DataBinding.FieldName = 'ADRES'
                Options.Editing = False
                Width = 39
              end
              object cxGridDBColumn57: TcxGridDBColumn
                Caption = 'Alim Zamani'
                DataBinding.FieldName = 'ALIMZAMANI'
                Options.Editing = False
                Width = 38
              end
              object cxGridDBColumn58: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Visible = False
                Width = 20
              end
              object cxGridDBColumn59: TcxGridDBColumn
                Caption = 'Aktar'#305'm'
                DataBinding.FieldName = 'AKTARIM'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ValueChecked = -1
                Properties.ValueUnchecked = 0
                FooterAlignmentHorz = taCenter
                GroupSummaryAlignment = taCenter
                HeaderAlignmentHorz = taCenter
                Width = 50
              end
              object cxGridDBColumn60: TcxGridDBColumn
                Caption = 'Aktif'
                DataBinding.FieldName = 'AKTIF'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ValueChecked = -1
                Properties.ValueUnchecked = 0
                FooterAlignmentHorz = taCenter
                GroupSummaryAlignment = taCenter
                HeaderAlignmentHorz = taCenter
                Options.Editing = False
                Width = 50
              end
            end
            object GridLevelSubeler: TcxGridLevel
              GridView = TableViewSubeler
            end
          end
        end
      end
    end
    object TsBos: TcxTabSheet
      Caption = 'TsBos'
      ImageIndex = 2
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label4: TLabel
        Left = 76
        Top = 73
        Width = 462
        Height = 22
        Caption = 
          'Sol taraftaki gezinme panelini kullanarak i'#351'lemleri ger'#231'ekle'#351'tir' +
          'in.'
        Font.Charset = TURKISH_CHARSET
        Font.Color = 16744448
        Font.Height = -16
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Shape1: TShape
        Left = 23
        Top = 66
        Width = 379
        Height = 1
      end
      object Label3: TLabel
        Left = 45
        Top = 18
        Width = 40
        Height = 16
        Caption = 'GenoTIP'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsItalic]
        ParentFont = False
        Transparent = True
      end
      object Label2: TLabel
        Left = 42
        Top = 33
        Width = 105
        Height = 29
        Caption = 'ENTEGRA'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 0
    Width = 225
    Height = 666
    Align = alLeft
    TabOrder = 1
    ExplicitHeight = 474
    object BtnGLNSubeServisi: TJvNavPanelButton
      Tag = 4
      Left = 1
      Top = 157
      Width = 223
      Height = 52
      Align = alTop
      Caption = 'GLN '#350'ube Servisi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 17
      Images = Tablo.PngMenu
      OnClick = JvNavPanelButton1Click
      ExplicitLeft = -4
      ExplicitTop = -5
      ExplicitWidth = 247
    end
    object JvNavPanelButton1: TJvNavPanelButton
      Tag = 1
      Left = 1
      Top = 1
      Width = 223
      Height = 52
      Align = alTop
      Caption = 'GLN Servisi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 17
      Images = Tablo.PngMenu
      OnClick = JvNavPanelButton1Click
      ExplicitLeft = -4
      ExplicitTop = -5
      ExplicitWidth = 247
    end
    object JvNavPanelButton2: TJvNavPanelButton
      Tag = 2
      Left = 1
      Top = 53
      Width = 223
      Height = 52
      Align = alTop
      Caption = #304'la'#231' Servisi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 17
      Images = Tablo.PngMenu
      OnClick = JvNavPanelButton1Click
      ExplicitLeft = -4
      ExplicitTop = -5
      ExplicitWidth = 247
    end
    object JvNavPanelButton3: TJvNavPanelButton
      Tag = 3
      Left = 1
      Top = 105
      Width = 223
      Height = 52
      Align = alTop
      Caption = 'Hata Servisi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 17
      Images = Tablo.PngMenu
      OnClick = JvNavPanelButton1Click
      ExplicitLeft = -4
      ExplicitTop = -5
      ExplicitWidth = 247
    end
  end
  object TabGlnHastane: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_GLN WHERE FIRMA_TUR = 5')
    Left = 856
    Top = 224
    object TabGlnHastaneID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGlnHastaneGLN: TStringField
      FieldName = 'GLN'
      Size = 250
    end
    object TabGlnHastaneISIM: TStringField
      FieldName = 'ISIM'
      Size = 250
    end
    object TabGlnHastaneYETKILI: TStringField
      FieldName = 'YETKILI'
      Size = 250
    end
    object TabGlnHastaneEMAIL: TStringField
      FieldName = 'EMAIL'
      Size = 250
    end
    object TabGlnHastaneTELEFON: TStringField
      FieldName = 'TELEFON'
      Size = 250
    end
    object TabGlnHastaneIL: TStringField
      FieldName = 'IL'
      Size = 250
    end
    object TabGlnHastaneILCE: TStringField
      FieldName = 'ILCE'
      Size = 250
    end
    object TabGlnHastaneADRES: TStringField
      FieldName = 'ADRES'
      Size = 250
    end
    object TabGlnHastaneFIRMA_TUR: TSmallintField
      FieldName = 'FIRMA_TUR'
    end
    object TabGlnHastaneALIMZAMANI: TDateTimeField
      FieldName = 'ALIMZAMANI'
    end
    object TabGlnHastaneAKTARIM: TSmallintField
      FieldName = 'AKTARIM'
    end
    object TabGlnHastaneAKTIF: TSmallintField
      FieldName = 'AKTIF'
    end
  end
  object DtsGlnHastane: TDataSource
    DataSet = TabGlnHastane
    Left = 928
    Top = 224
  end
  object TabGlnDepo: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_GLN WHERE FIRMA_TUR = 2')
    Left = 856
    Top = 72
    object TabGlnDepoID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGlnDepoGLN: TStringField
      FieldName = 'GLN'
      Size = 250
    end
    object TabGlnDepoISIM: TStringField
      FieldName = 'ISIM'
      Size = 250
    end
    object TabGlnDepoYETKILI: TStringField
      FieldName = 'YETKILI'
      Size = 250
    end
    object TabGlnDepoEMAIL: TStringField
      FieldName = 'EMAIL'
      Size = 250
    end
    object TabGlnDepoTELEFON: TStringField
      FieldName = 'TELEFON'
      Size = 250
    end
    object TabGlnDepoIL: TStringField
      FieldName = 'IL'
      Size = 250
    end
    object TabGlnDepoILCE: TStringField
      FieldName = 'ILCE'
      Size = 250
    end
    object TabGlnDepoADRES: TStringField
      FieldName = 'ADRES'
      Size = 250
    end
    object TabGlnDepoFIRMA_TUR: TSmallintField
      FieldName = 'FIRMA_TUR'
    end
    object TabGlnDepoALIMZAMANI: TDateTimeField
      FieldName = 'ALIMZAMANI'
    end
    object TabGlnDepoAKTARIM: TSmallintField
      FieldName = 'AKTARIM'
    end
    object TabGlnDepoAKTIF: TSmallintField
      FieldName = 'AKTIF'
    end
  end
  object DtsGlnDepo: TDataSource
    DataSet = TabGlnDepo
    Left = 928
    Top = 72
  end
  object TabGlnEczane: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_GLN WHERE FIRMA_TUR = 4')
    Left = 856
    Top = 176
    object TabGlnEczaneID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGlnEczaneGLN: TStringField
      FieldName = 'GLN'
      Size = 250
    end
    object TabGlnEczaneISIM: TStringField
      FieldName = 'ISIM'
      Size = 250
    end
    object TabGlnEczaneYETKILI: TStringField
      FieldName = 'YETKILI'
      Size = 250
    end
    object TabGlnEczaneEMAIL: TStringField
      FieldName = 'EMAIL'
      Size = 250
    end
    object TabGlnEczaneTELEFON: TStringField
      FieldName = 'TELEFON'
      Size = 250
    end
    object TabGlnEczaneIL: TStringField
      FieldName = 'IL'
      Size = 250
    end
    object TabGlnEczaneILCE: TStringField
      FieldName = 'ILCE'
      Size = 250
    end
    object TabGlnEczaneADRES: TStringField
      FieldName = 'ADRES'
      Size = 250
    end
    object TabGlnEczaneFIRMA_TUR: TSmallintField
      FieldName = 'FIRMA_TUR'
    end
    object TabGlnEczaneALIMZAMANI: TDateTimeField
      FieldName = 'ALIMZAMANI'
    end
    object TabGlnEczaneAKTARIM: TSmallintField
      FieldName = 'AKTARIM'
    end
    object TabGlnEczaneAKTIF: TSmallintField
      FieldName = 'AKTIF'
    end
  end
  object DtsGlnEczane: TDataSource
    DataSet = TabGlnEczane
    Left = 928
    Top = 176
  end
  object TabGlnUretici: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_GLN WHERE FIRMA_TUR = 1')
    Left = 856
    Top = 16
    object TabGlnUreticiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGlnUreticiGLN: TStringField
      FieldName = 'GLN'
      Size = 250
    end
    object TabGlnUreticiISIM: TStringField
      FieldName = 'ISIM'
      Size = 250
    end
    object TabGlnUreticiYETKILI: TStringField
      FieldName = 'YETKILI'
      Size = 250
    end
    object TabGlnUreticiEMAIL: TStringField
      FieldName = 'EMAIL'
      Size = 250
    end
    object TabGlnUreticiTELEFON: TStringField
      FieldName = 'TELEFON'
      Size = 250
    end
    object TabGlnUreticiIL: TStringField
      FieldName = 'IL'
      Size = 250
    end
    object TabGlnUreticiILCE: TStringField
      FieldName = 'ILCE'
      Size = 250
    end
    object TabGlnUreticiADRES: TStringField
      FieldName = 'ADRES'
      Size = 250
    end
    object TabGlnUreticiFIRMA_TUR: TSmallintField
      FieldName = 'FIRMA_TUR'
    end
    object TabGlnUreticiALIMZAMANI: TDateTimeField
      FieldName = 'ALIMZAMANI'
    end
    object TabGlnUreticiAKTARIM: TSmallintField
      FieldName = 'AKTARIM'
    end
    object TabGlnUreticiAKTIF: TSmallintField
      FieldName = 'AKTIF'
    end
  end
  object DtsGlnUretici: TDataSource
    DataSet = TabGlnUretici
    Left = 920
    Top = 16
  end
  object HTTPRIO1: THTTPRIO
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 528
    Top = 16
  end
  object TabGlnIhracatci: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_GLN WHERE FIRMA_TUR = 3')
    Left = 856
    Top = 128
    object TabGlnIhracatciID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGlnIhracatciGLN: TStringField
      FieldName = 'GLN'
      Size = 250
    end
    object TabGlnIhracatciISIM: TStringField
      FieldName = 'ISIM'
      Size = 250
    end
    object TabGlnIhracatciYETKILI: TStringField
      FieldName = 'YETKILI'
      Size = 250
    end
    object TabGlnIhracatciEMAIL: TStringField
      FieldName = 'EMAIL'
      Size = 250
    end
    object TabGlnIhracatciTELEFON: TStringField
      FieldName = 'TELEFON'
      Size = 250
    end
    object TabGlnIhracatciIL: TStringField
      FieldName = 'IL'
      Size = 250
    end
    object TabGlnIhracatciILCE: TStringField
      FieldName = 'ILCE'
      Size = 250
    end
    object TabGlnIhracatciADRES: TStringField
      FieldName = 'ADRES'
      Size = 250
    end
    object TabGlnIhracatciFIRMA_TUR: TSmallintField
      FieldName = 'FIRMA_TUR'
    end
    object TabGlnIhracatciALIMZAMANI: TDateTimeField
      FieldName = 'ALIMZAMANI'
    end
    object TabGlnIhracatciAKTARIM: TSmallintField
      FieldName = 'AKTARIM'
    end
    object TabGlnIhracatciAKTIF: TSmallintField
      FieldName = 'AKTIF'
    end
  end
  object DtsGlnIhracatci: TDataSource
    DataSet = TabGlnIhracatci
    Left = 928
    Top = 128
  end
  object TabIlac: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_ILAC ')
    Left = 856
    Top = 280
    object TabIlacID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabIlacGTIN: TStringField
      FieldName = 'GTIN'
      Size = 50
    end
    object TabIlacADI: TStringField
      FieldName = 'ADI'
      Size = 250
    end
    object TabIlacURETICI_GLN: TStringField
      FieldName = 'URETICI_GLN'
      Size = 250
    end
    object TabIlacURETICI_AD: TStringField
      FieldName = 'URETICI_AD'
      Size = 250
    end
    object TabIlacITHAL: TSmallintField
      FieldName = 'ITHAL'
    end
    object TabIlacURETIM: TSmallintField
      FieldName = 'URETIM'
    end
    object TabIlacALIM_ZAMANI: TDateTimeField
      FieldName = 'ALIM_ZAMANI'
    end
    object TabIlacAKTARIM: TSmallintField
      FieldName = 'AKTARIM'
    end
  end
  object DtsIlac: TDataSource
    DataSet = TabIlac
    Left = 928
    Top = 280
  end
  object TabHata: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_HATA')
    Left = 720
    Top = 256
    object TabHataID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabHataTIPI: TStringField
      FieldName = 'TIPI'
      Size = 10
    end
    object TabHataKODU: TStringField
      FieldName = 'KODU'
      Size = 10
    end
    object TabHataACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object TabHataBILGI: TStringField
      FieldName = 'BILGI'
      Size = 500
    end
    object TabHataALIM_ZAMANI: TDateTimeField
      FieldName = 'ALIM_ZAMANI'
    end
    object TabHataAKTARIM: TSmallintField
      FieldName = 'AKTARIM'
    end
  end
  object DtsHata: TDataSource
    DataSet = TabHata
    Left = 784
    Top = 256
  end
  object TabSubeler: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_SERVIS_HATA')
    Left = 720
    Top = 320
    object AutoIncField1: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object StringField1: TStringField
      FieldName = 'TIPI'
      Size = 10
    end
    object StringField2: TStringField
      FieldName = 'KODU'
      Size = 10
    end
    object StringField3: TStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object StringField4: TStringField
      FieldName = 'BILGI'
      Size = 500
    end
    object DateTimeField1: TDateTimeField
      FieldName = 'ALIM_ZAMANI'
    end
    object SmallintField1: TSmallintField
      FieldName = 'AKTARIM'
    end
  end
  object DtsSubeler: TDataSource
    DataSet = TabSubeler
    Left = 784
    Top = 320
  end
end
