object BankaHareketKuralDlg: TBankaHareketKuralDlg
  Left = 0
  Top = 0
  Caption = 'Banka Hareket Kurallar'#305
  ClientHeight = 548
  ClientWidth = 1231
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
    Width = 1231
    Height = 35
    Align = alTop
    Alignment = taLeftJustify
    Caption = '---'
    TabOrder = 0
    OnDblClick = Panel1DblClick
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 38
    Width = 1225
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 116
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
    Wrapable = False
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 116
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      Visible = False
      OnClick = SilTusClick
    end
    object ToolButton9: TToolButton
      Left = 232
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object KaydetTus: TToolButton
      Left = 240
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      Visible = False
      OnClick = KaydetTusClick
    end
    object ToolButton2: TToolButton
      Left = 356
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object IptalTus: TToolButton
      Left = 364
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton3: TToolButton
      Left = 480
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object AtilacakKelimlerTus: TToolButton
      Left = 488
      Top = 0
      Caption = 'At'#305'lacak Kelimler'
      ImageIndex = 2
      Visible = False
      OnClick = AtilacakKelimlerTusClick
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 70
    Width = 1231
    Height = 478
    Align = alClient
    TabOrder = 2
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 474
    ClientRectLeft = 4
    ClientRectRight = 1227
    ClientRectTop = 24
    object cxTabSheet1: TcxTabSheet
      Caption = 'Sabit Hesap / Masraf Aktar'#305'mlar'
      ImageIndex = 0
      object GridHareket: TcxGrid
        Left = 0
        Top = 0
        Width = 945
        Height = 450
        Align = alClient
        TabOrder = 0
        object GridHareketView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsKural
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object GridHareketViewKULLANICI: TcxGridDBColumn
            Caption = 'Kullan'#305'c'#305
            DataBinding.FieldName = 'KULLANICI'
            PropertiesClassName = 'TcxCheckBoxProperties'
          end
          object GridHareketViewTARAMA_KOLONU: TcxGridDBColumn
            Caption = 'Excel Taranacak Alan'
            DataBinding.FieldName = 'TARAMA_KOLONU'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = #304#350'LEM T'#304'P'#304
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'A'#199'IKLAMA'
                Value = 2
              end>
            Width = 148
          end
          object GridHareketViewKOLON: TcxGridDBColumn
            Caption = 'Excel '#304#231'inde Ge'#231'en'
            DataBinding.FieldName = 'DEGER_GECEN'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = GridHareketViewKOLONPropertiesButtonClick
            Width = 486
          end
          object GridHareketViewISLEM: TcxGridDBColumn
            Caption = 'Prg. '#304#351'lem Tipi'
            DataBinding.FieldName = 'PRGISLEMTIPI'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepBankaHareketTipi
            Width = 81
          end
          object GridHareketViewBANKAKODU: TcxGridDBColumn
            DataBinding.FieldName = 'BANKAKODU'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 95
          end
        end
        object GridHareketLevel1: TcxGridLevel
          GridView = GridHareketView
        end
      end
      object Panel4: TPanel
        Left = 945
        Top = 0
        Width = 278
        Height = 450
        Align = alRight
        Alignment = taLeftJustify
        TabOrder = 1
        object PanelOdemeTipi: TPanel
          Left = 1
          Top = 279
          Width = 276
          Height = 35
          Align = alTop
          Alignment = taLeftJustify
          TabOrder = 0
          object LabelOdemeTipi: TcxLabel
            Left = 5
            Top = 6
            Caption = #214'deme Tipi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object ComboOdemeTipi: TcxDBImageComboBox
            Left = 70
            Top = 6
            DataBinding.DataField = 'ODEMETIPI'
            Properties.Items = <
              item
                Description = 'Maa'#351
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Prim'
                Value = 11
              end
              item
                Description = 'Yemek Paras'#305
                Value = 5
              end
              item
                Description = 'Yol Paras'#305
                Value = 7
              end
              item
                Description = #304'zin Paras'#305
                Value = 9
              end
              item
                Description = 'Maa'#351' Avans'#305
                Value = 196
              end
              item
                Description = #304#351' Avans'#305
                Value = 195
              end
              item
                Description = 'Avsns Geri '#214'demesi'
                Value = 231
              end>
            TabOrder = 1
            Width = 115
          end
        end
        object Panel8: TPanel
          Left = 1
          Top = 1
          Width = 276
          Height = 70
          Align = alTop
          Alignment = taLeftJustify
          Caption = ' Programa Kaydedilecek'
          Color = clSilver
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentFont = False
          TabOrder = 1
        end
        object PanelHesap: TPanel
          Left = 1
          Top = 106
          Width = 276
          Height = 69
          Align = alTop
          Alignment = taLeftJustify
          TabOrder = 2
          object cxLabel3: TcxLabel
            Left = 2
            Top = 38
            Caption = 'Hesap Ad'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditHesapAd: TcxTextEdit
            Left = 73
            Top = 38
            TabOrder = 1
            Width = 200
          end
          object cxLabel4: TcxLabel
            Left = 2
            Top = 14
            Caption = 'Hesap Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditHesapKod: TcxButtonEdit
            Left = 73
            Top = 14
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end
              item
                Caption = '-'
                Hint = 'Temizle'
                Kind = bkText
              end>
            Properties.OnButtonClick = EditHesapKodPropertiesButtonClick
            TabOrder = 3
            Width = 200
          end
        end
        object Panel5: TPanel
          Left = 1
          Top = 71
          Width = 276
          Height = 35
          Align = alTop
          Alignment = taLeftJustify
          TabOrder = 3
          object cxLabel5: TcxLabel
            Left = 0
            Top = 6
            Caption = 'Prg.'#304#351'lem Tipi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object ComboPRGISLEMTIPI: TcxDBImageComboBox
            Left = 76
            Top = 8
            RepositoryItem = Tablo.RepBankaHareketTipi
            DataBinding.DataField = 'PRGISLEMTIPI'
            DataBinding.DataSource = DtsKural
            Properties.Items = <
              item
                Description = 'Maa'#351
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Prim'
                Value = 11
              end
              item
                Description = 'Yemek Paras'#305
                Value = 5
              end
              item
                Description = 'Yol Paras'#305
                Value = 7
              end
              item
                Description = #304'zin Paras'#305
                Value = 9
              end
              item
                Description = 'Maa'#351' Avans'#305
                Value = 196
              end
              item
                Description = #304#351' Avans'#305
                Value = 195
              end
              item
                Description = 'Avsns Geri '#214'demesi'
                Value = 231
              end>
            TabOrder = 1
            Width = 200
          end
        end
        object Panel2: TPanel
          Left = 1
          Top = 175
          Width = 276
          Height = 69
          Align = alTop
          Alignment = taLeftJustify
          TabOrder = 4
          object cxLabel1: TcxLabel
            Left = 1
            Top = 15
            Caption = 'Masraf Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditMasrafKodu: TcxButtonEdit
            Left = 70
            Top = 14
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end
              item
                Caption = '-'
                Hint = 'Temizle'
                Kind = bkText
              end>
            Properties.OnButtonClick = EditMasrafKoduPropertiesButtonClick
            TabOrder = 1
            Width = 200
          end
          object cxLabel6: TcxLabel
            Left = 1
            Top = 38
            Caption = 'Masraf Ad'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditMasrafAd: TcxTextEdit
            Left = 70
            Top = 38
            TabOrder = 3
            Width = 200
          end
        end
        object PanelProje: TPanel
          Left = 1
          Top = 244
          Width = 276
          Height = 35
          Align = alTop
          Alignment = taLeftJustify
          TabOrder = 5
          object cxLabel2: TcxLabel
            Left = 1
            Top = 11
            Caption = 'Proje Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditProje: TcxButtonEdit
            Left = 70
            Top = 7
            Properties.Buttons = <
              item
                Caption = '++'
                Default = True
                Kind = bkText
              end
              item
                Caption = '+'
                Kind = bkText
              end
              item
                Caption = '-'
                Kind = bkText
              end>
            TabOrder = 1
            Width = 200
          end
        end
      end
    end
    object TabSheetSatSut: TcxTabSheet
      Caption = 'Sat'#305'r/S'#252'tun Ayarlar'#305
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 1227
        Height = 451
        Align = alClient
        TabOrder = 0
        object cxGridDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSatSut
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          Filtering.ColumnAddValueItems = False
          Filtering.ColumnMRUItemsList = False
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object cxGridDBColumn1: TcxGridDBColumn
            Caption = 'Bilgi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            Width = 186
          end
          object cxGridDBTableView1Column1: TcxGridDBColumn
            Caption = 'Sat'#305'r/S'#252'tun'
            DataBinding.FieldName = 'SATSUT'
            DataBinding.IsNullValueType = True
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Form'#252'l'
            DataBinding.FieldName = 'DEGER_GECEN'
            DataBinding.IsNullValueType = True
            Width = 289
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
  end
  object DtsKural: TDataSource
    DataSet = TabKural
    OnStateChange = DtsKuralStateChange
    Left = 131
    Top = 133
  end
  object TabKural: TFDQuery
    AfterScroll = TabKuralAfterScroll
    OnNewRecord = TabKuralNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * '
      'FROM BANKAKURAL'
      'WHERE '
      '(BANKAKODU = 0 or BANKAKODU = :Prm) '
      'AND TUR=2'
      'order by PRGISLEMTIPI,KULLANICI desc, TARAMA_KOLONU ')
    Left = 75
    Top = 132
    object TabKuralID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabKuralBANKAKODU: TSmallintField
      FieldName = 'BANKAKODU'
    end
    object TabKuralKULLANICI: TBooleanField
      FieldName = 'KULLANICI'
    end
    object TabKuralTUR: TWordField
      FieldName = 'TUR'
    end
    object TabKuralISLEM: TSmallintField
      FieldName = 'PRGISLEMTIPI'
    end
    object TabKuralTARAMA_KOLONU: TWordField
      FieldName = 'TARAMA_KOLONU'
    end
    object TabKuralTUTAR: TSmallintField
      FieldName = 'TUTAR'
    end
    object TabKuralHESAPID: TIntegerField
      FieldName = 'HESAPID'
    end
    object TabKuralMASRAFID: TIntegerField
      FieldName = 'MASRAFID'
    end
    object TabKuralDEGER_GECEN: TWideStringField
      FieldName = 'DEGER_GECEN'
      Size = 100
    end
    object TabKuralESITLIK: TWordField
      FieldName = 'ESITLIK'
    end
    object TabKuralDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabKuralDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
  end
  object DtsSatSut: TDataSource
    DataSet = TabSatSut
    OnStateChange = DtsKuralStateChange
    Left = 131
    Top = 253
  end
  object TabSatSut: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT BANKAKODU,TUR,'
      
        'BILGI=(SELECT G.ANAHTAR FROM GENINI G WHERE B.PRGISLEMTIPI=G.DEG' +
        'ER AND G.BOLUM=25010),'
      'PRGISLEMTIPI, SATSUT= HESAPID, DEGER_GECEN'
      'FROM BANKAKURAL B  '
      'WHERE BANKAKODU = :Prm AND TUR=1'
      'order by ID ')
    Left = 75
    Top = 252
  end
end
