object SatinAlmaListeDlg: TSatinAlmaListeDlg
  Left = 0
  Top = 0
  Width = 1172
  Height = 461
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
  object BeniDegistir: TPanel
    Left = 0
    Top = 0
    Width = 1172
    Height = 461
    Align = alClient
    Caption = 
      'TabKrediKarti nesnesindeki SQL ifadelerini degistirmeyi unutmayi' +
      'n.'
    TabOrder = 0
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1164
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
    object cxGrid: TcxGrid
      Left = 1
      Top = 36
      Width = 1170
      Height = 417
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      PopupMenu = PmPopupMenu
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      object GridTview: TcxGridDBTableView
        OnDblClick = DegisTusClick
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsTabSatinAlma
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
          end
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
          end
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.CellAutoHeight = True
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        object GridTviewTALEPTARIHI: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TALEPTARIHI'
          DataBinding.IsNullValueType = True
          Width = 172
        end
        object GridTviewTALEPNO: TcxGridDBColumn
          Caption = 'Talep No.'
          DataBinding.FieldName = 'TALEPNO'
          DataBinding.IsNullValueType = True
          Width = 116
        end
        object GridTviewTALEPEDEN: TcxGridDBColumn
          Caption = 'Talep Eden'
          DataBinding.FieldName = 'FIRMA'
          DataBinding.IsNullValueType = True
          Width = 137
        end
        object GridTviewTALEPEDENBOLUM: TcxGridDBColumn
          Caption = 'B'#246'l'#252'm'
          DataBinding.FieldName = 'TALEPEDENBOLUM'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.RepCariBolum
          Width = 163
        end
        object GridTviewDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.RepAktifPasif
          Width = 72
        end
        object GridTviewSUBEID: TcxGridDBColumn
          Caption = #350'ube'
          DataBinding.FieldName = 'SUBEID'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
          Width = 128
        end
        object GridTviewASAMA: TcxGridDBColumn
          Caption = 'A'#351'ama'
          DataBinding.FieldName = 'ASAMA'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepSatinalmaAsama
          Width = 192
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = GridTview
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 1
      Top = 453
      Width = 1170
      Height = 7
      AlignSplitter = salBottom
    end
    object SqlMemo: TMemo
      Left = 174
      Top = 56
      Width = 635
      Height = 33
      Lines.Strings = (
        
          'Select *,R.FIRMA from SATINALMA SA left outer join REHBER R on R' +
          '.ID=SA.TALEPEDEN ')
      TabOrder = 2
      Visible = False
    end
  end
  object DtsTabSatinAlma: TDataSource
    DataSet = TabSatinAlma
    Left = 232
    Top = 136
  end
  object TabSatinAlma: TFDQuery
    Connection = Tablo.FDCnn
    Left = 135
    Top = 136
  end
  object PmPopupMenu: TPopupMenu
    Left = 510
    Top = 113
    object AcilisKaydiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
    end
    object DevirFiiGir1: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir'
      Visible = False
    end
  end
end
