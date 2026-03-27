object YetkiKategoriDlg: TYetkiKategoriDlg
  Left = 0
  Top = 0
  Caption = 'Demirba'#351' Kategori Yetki Ekran'#305
  ClientHeight = 361
  ClientWidth = 771
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 765
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 62
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    ExplicitWidth = 769
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Ekle'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 62
      Top = 0
      Caption = 'Kald'#305'r'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
  end
  object GridYetki: TcxGrid
    Left = 0
    Top = 32
    Width = 771
    Height = 329
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    ExplicitTop = 35
    ExplicitWidth = 775
    ExplicitHeight = 327
    object GridYetkiView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DtsYetkiEk
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Kind = skSum
          Position = spFooter
        end
        item
          Kind = skSum
        end
        item
          Kind = skSum
          Position = spFooter
        end
        item
          Kind = skSum
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skSum
        end
        item
          Kind = skSum
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object GridYetkiViewBILGI: TcxGridDBColumn
        Caption = 'ID'
        DataBinding.FieldName = 'BILGI'
        Width = 146
      end
      object GridYetkiViewKATEGORI: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'KATEGORI'
        Width = 615
      end
    end
    object GridY: TcxGridLevel
      GridView = GridYetkiView
    end
  end
  object TabYetkiEk: TFDQuery
    Connection = Tablo.FDCnn
    OnCalcFields = TabYetkiEkCalcFields
    OnNewRecord = TabYetkiEkNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from YETKIEK where ROLID=:Prm1  and MODULID= :Prm2')
    Left = 261
    Top = 105
    object TabYetkiEkID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabYetkiEkROLID: TIntegerField
      FieldName = 'ROLID'
    end
    object TabYetkiEkMODULID: TLargeintField
      FieldName = 'MODULID'
    end
    object TabYetkiEkBILGI: TWideStringField
      FieldName = 'BILGI'
      Size = 50
    end
    object TabYetkiEkEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabYetkiEkEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabYetkiEkDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabYetkiEkDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabYetkiEkSUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabYetkiEkKATEGORI: TStringField
      FieldKind = fkCalculated
      FieldName = 'KATEGORI'
      Size = 100
      Calculated = True
    end
  end
  object DtsYetkiEk: TDataSource
    DataSet = TabYetkiEk
    Left = 328
    Top = 105
  end
end



