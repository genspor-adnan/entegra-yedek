object CiroEdileceklerDlg: TCiroEdileceklerDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 409
  ClientWidth = 1067
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1061
    Height = 22
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 20
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
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object YeniCekEkle: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kendi '#199'ekimizi Ekle'
      ImageIndex = 7
      OnClick = YeniCekEkleClick
    end
    object ToolButton2: TToolButton
      Left = 102
      Top = 0
      Width = 406
      Caption = 'ToolButton2'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object ToolButton3: TToolButton
      Left = 508
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 18
      OnClick = ToolButton3Click
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 25
    Width = 1067
    Height = 339
    Align = alClient
    Caption = 'Portf'#246'ydeki ciro yap'#305'labilecek '#231'ek listesi'
    TabOrder = 1
    object cxGrid: TcxGrid
      Left = 370
      Top = 151
      Width = 535
      Height = 130
      TabOrder = 0
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = False
      object GridTvieweski: TcxGridDBTableView
        OnDblClick = btnTamamClick
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsCekler
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
            FieldName = 'TUTAR'
            Column = GridTvieweskiTUTAR
            DisplayText = ',0.00;(,0.00)'
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsSelection.MultiSelect = True
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        object GridTvieweskiSEC: TcxGridDBColumn
          Caption = 'Se'#231
          DataBinding.FieldName = 'CIROLU'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.NullStyle = nssUnchecked
          Width = 29
        end
        object GridTvieweskiCEKSENETID: TcxGridDBColumn
          DataBinding.FieldName = 'CEKSENETID'
          Visible = False
          Options.Editing = False
        end
        object GridTvieweskiCARIKOD: TcxGridDBColumn
          Caption = 'Cari Kodu'
          DataBinding.FieldName = 'CARIKOD'
          Options.Editing = False
          Width = 70
        end
        object GridTvieweskiCARIUNVAN: TcxGridDBColumn
          Caption = 'Cari '#220'nvan'#305
          DataBinding.FieldName = 'CARIUNVAN'
          Options.Editing = False
          Width = 145
        end
        object GridTvieweskiTUTAR: TcxGridDBColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'TUTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;'
          Options.Editing = False
          Width = 78
        end
        object GridTvieweskiKUR: TcxGridDBColumn
          Caption = 'Kur'
          DataBinding.FieldName = 'KUR'
          Options.Editing = False
          Width = 34
        end
        object GridTvieweskiBANKAADI: TcxGridDBColumn
          Caption = 'Banka Ad'#305
          DataBinding.FieldName = 'BANKAADI'
          Options.Editing = False
          Width = 145
        end
        object GridTvieweskiTUR: TcxGridDBColumn
          Caption = 'T'#252'r'
          DataBinding.FieldName = 'TUR'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              Description = 'M'#252#351'teri '#199'eki'
              ImageIndex = 0
              Value = 23
            end
            item
              Description = 'Kendi '#199'ekimiz'
              Value = 33
            end>
          Visible = False
          Options.Editing = False
          Width = 73
        end
        object GridTvieweskiBORDRO: TcxGridDBColumn
          Caption = 'Bordro'
          DataBinding.FieldName = 'BORDRO'
          Visible = False
          Options.Editing = False
          Width = 44
        end
        object GridTvieweskiVADE: TcxGridDBColumn
          Caption = 'Vade'
          DataBinding.FieldName = 'VADE'
          Options.Editing = False
          Width = 81
        end
        object GridTvieweskiSeriNo: TcxGridDBColumn
          Caption = 'Seri No'
          DataBinding.FieldName = 'SERINO'
          Visible = False
          Options.Editing = False
          Width = 77
        end
        object GridTvieweskiODEMEYERI: TcxGridDBColumn
          Caption = #214'deme Yeri'
          DataBinding.FieldName = 'ODEMEYERI'
          Visible = False
          Options.Editing = False
          Width = 110
        end
        object GridTvieweskiTARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
          Visible = False
          Options.Editing = False
          Width = 64
        end
        object GridTvieweskiDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          Visible = False
          Options.Editing = False
          Width = 61
        end
        object GridTvieweskiKOD: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KOD'
          Visible = False
          Options.Editing = False
          Width = 56
        end
        object GridTvieweskiID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
          Options.Editing = False
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = GridTvieweski
      end
    end
    object Grid: TcxGrid
      Left = 2
      Top = 15
      Width = 1063
      Height = 322
      Align = alClient
      TabOrder = 1
      object GridBandedTview: TcxGridDBBandedTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsCekler
        DataController.KeyFieldNames = 'ID'
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
            Column = GridBandedTviewTutar
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsView.ColumnAutoWidth = True
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        Bands = <
          item
            Width = 33
          end
          item
            Width = 563
          end>
        object GridBandedTviewSec: TcxGridDBBandedColumn
          Caption = 'Se'#231
          DataBinding.ValueType = 'Boolean'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Properties.OnChange = GridBandedTviewSecPropertiesChange
          HeaderAlignmentHorz = taCenter
          Width = 149
          Position.BandIndex = 0
          Position.ColIndex = 0
          Position.RowIndex = 0
        end
        object GridBandedTviewID: TcxGridDBBandedColumn
          DataBinding.FieldName = 'ID'
          Visible = False
          Width = 42
          Position.BandIndex = 1
          Position.ColIndex = 5
          Position.RowIndex = 0
        end
        object GridBandedTviewCariKod: TcxGridDBBandedColumn
          Caption = 'Cari Kod'
          DataBinding.FieldName = 'CARIKOD'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 89
          Position.BandIndex = 1
          Position.ColIndex = 1
          Position.RowIndex = 0
        end
        object GridBandedTviewCariUnvani: TcxGridDBBandedColumn
          Caption = 'Cari '#220'nvan'#305
          DataBinding.FieldName = 'CARIUNVAN'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 220
          Position.BandIndex = 1
          Position.ColIndex = 2
          Position.RowIndex = 0
        end
        object GridBandedTviewTutar: TcxGridDBBandedColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'TUTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00;'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 91
          Position.BandIndex = 1
          Position.ColIndex = 3
          Position.RowIndex = 0
        end
        object GridBandedTviewKur: TcxGridDBBandedColumn
          Caption = 'P.Birimi'
          DataBinding.FieldName = 'KUR'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 43
          Position.BandIndex = 1
          Position.ColIndex = 4
          Position.RowIndex = 0
        end
        object GridBandedTviewBankaAdi: TcxGridDBBandedColumn
          Caption = 'Banka Ad'#305
          DataBinding.FieldName = 'BANKAADI'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 149
          Position.BandIndex = 1
          Position.ColIndex = 6
          Position.RowIndex = 0
        end
        object GridBandedTviewVade: TcxGridDBBandedColumn
          Caption = 'Vade'
          DataBinding.FieldName = 'VADE'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 109
          Position.BandIndex = 1
          Position.ColIndex = 0
          Position.RowIndex = 0
        end
        object GridBandedTviewRehberID: TcxGridDBBandedColumn
          DataBinding.FieldName = 'REHBERID'
          Visible = False
          Position.BandIndex = 0
          Position.ColIndex = 1
          Position.RowIndex = 0
        end
      end
      object Level: TcxGridLevel
        GridView = GridBandedTview
      end
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 364
    Width = 1067
    Height = 45
    Align = alBottom
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    DesignSize = (
      1067
      45)
    object Label45: TcxLabel
      Left = 316
      Top = 12
      Caption = 'Se'#231'ilenler Toplam'#305
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object GridMakbuzToplam: TStringGrid
      Left = 32455
      Top = -37
      Width = 260
      Height = 118
      Anchors = []
      Color = clBtnFace
      ColCount = 3
      DefaultColWidth = 128
      DefaultRowHeight = 19
      FixedCols = 2
      RowCount = 6
      FixedRows = 0
      Font.Charset = TURKISH_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      GridLineWidth = 0
      ParentFont = False
      ScrollBars = ssNone
      TabOrder = 0
    end
    object EditToplam: TcxCurrencyEdit
      Left = 425
      Top = 11
      Enabled = False
      Properties.Alignment.Horz = taRightJustify
      Properties.DisplayFormat = ',0.00;(,0.00)'
      Properties.EditFormat = ',0.00;(,0.00)'
      Properties.ReadOnly = True
      StyleDisabled.Color = clWindow
      StyleDisabled.TextColor = clBtnText
      TabOrder = 1
      Width = 74
    end
    object btnTamam: TcxButton
      Left = 585
      Top = 6
      Width = 77
      Height = 32
      Caption = 'Tamam'
      TabOrder = 3
      OnClick = btnTamamClick
    end
  end
  object TabCekSenet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 137
    Top = 136
  end
  object DtsCekler: TDataSource
    DataSet = TabCekSenet
    Left = 202
    Top = 142
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 256
    Top = 144
    object Cirola1: TMenuItem
      Caption = 'Ciro Et'
      ImageIndex = 15
    end
  end
end

