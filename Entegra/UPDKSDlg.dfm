object PDKSDlg: TPDKSDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Personel Devam Kontrol Sistemleri '
  ClientHeight = 570
  ClientWidth = 1222
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControlPDKS: TcxPageControl
    Left = 0
    Top = 93
    Width = 1222
    Height = 443
    Align = alClient
    TabOrder = 2
    Properties.ActivePage = TabSheetGenel
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 439
    ClientRectLeft = 4
    ClientRectRight = 1218
    ClientRectTop = 24
    object TabSheetGenel: TcxTabSheet
      Caption = 'PDKS Liste'
      ImageIndex = 0
      object PDKSListe: TcxGrid
        Left = 0
        Top = 27
        Width = 984
        Height = 388
        Align = alClient
        PopupMenu = PmSagClick
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object PDKSListeTV: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          OnCanFocusRecord = PDKSListeTVCanFocusRecord
          OnCellDblClick = PDKSListeTVCellDblClick
          DataController.DataSource = dtsTabPDKS
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skCount
              FieldName = 'FIRMA'
              Column = PDKSListeTVFIRMA
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.Indicator = True
          object PDKSListeTVFIRMA: TcxGridDBColumn
            Caption = 'Ad Soyad'
            DataBinding.FieldName = 'FIRMA'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 115
          end
          object PDKSListeTVGUNADI: TcxGridDBColumn
            Caption = 'G'#252'n'
            DataBinding.FieldName = 'GUNADI'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 90
          end
          object PDKSListeTVGIRIS: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'GIRIS'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 102
          end
          object PDKSListeTVGIRISSAAT: TcxGridDBColumn
            Caption = 'Giri'#351' Saati'
            DataBinding.FieldName = 'GIRIS'
            PropertiesClassName = 'TcxTimeEditProperties'
            Properties.TimeFormat = tfHourMin
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 108
          end
          object PDKSListeTVCIKIS: TcxGridDBColumn
            Caption = #199#305'k'#305#351
            DataBinding.FieldName = 'CIKIS'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Visible = False
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 64
          end
          object PDKSListeTVGIRFARK: TcxGridDBColumn
            Caption = 'Giri'#351' Fark'
            DataBinding.FieldName = 'GIRFARK'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 85
          end
          object PDKSListeTVCIKISSAAT: TcxGridDBColumn
            Caption = #199#305'k'#305#351' Saati'
            DataBinding.FieldName = 'CIKIS'
            PropertiesClassName = 'TcxTimeEditProperties'
            Properties.TimeFormat = tfHourMin
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 94
          end
          object PDKSListeTVCIKFARK: TcxGridDBColumn
            Caption = #199#305'k'#305#351' Fark'
            DataBinding.FieldName = 'CIKFARK'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 76
          end
          object PDKSListeTVVARGIRISCIKIS: TcxGridDBColumn
            Caption = 'Vardiya Giri'#351' - '#199#305'k'#305#351
            DataBinding.FieldName = 'VARGIRISCIKIS'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 119
          end
          object PDKSListeTVCALFARK: TcxGridDBColumn
            Caption = #199'al'#305#351'ma Fark'
            DataBinding.FieldName = 'CALFARK'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 85
          end
          object PDKSListeTVCALSURE: TcxGridDBColumn
            Caption = 'Top. '#199'al'#305#351't'#305#287#305' S'#252're'
            DataBinding.FieldName = 'CALSURE'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 104
          end
          object PDKSListeTVID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object PDKSListeTVSUBEID: TcxGridDBColumn
            Caption = #350'ube'
            DataBinding.FieldName = 'SUBEID'
            RepositoryItem = Tablo.RepSubeler
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 91
          end
          object PDKSListeTVDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.cxImageListPDKS
            Properties.Items = <>
            RepositoryItem = Tablo.RepPDKSDurum
            Options.Editing = False
          end
          object PDKSListeTVREHBERID: TcxGridDBColumn
            DataBinding.FieldName = 'REHBERID'
            Visible = False
          end
        end
        object PDKSListeLevel1: TcxGridLevel
          GridView = PDKSListeTV
        end
      end
      object ToolBarCihazYoksa: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1208
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 36
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
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
        Visible = False
        object YeniTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          DropdownMenu = PmYeniEkle
          ImageIndex = 0
        end
        object SilTus: TToolButton
          Left = 36
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SilTusClick
        end
        object ToolButton3: TToolButton
          Left = 72
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 17
          Style = tbsSeparator
        end
        object btnGiris: TToolButton
          Tag = 3
          Left = 80
          Top = 0
          Caption = 'Giri'#351
          ImageIndex = 21
          OnClick = btnGirisClick
        end
        object btnCikis: TToolButton
          Tag = 54
          Left = 116
          Top = 0
          Caption = #199#305'k'#305#351
          ImageIndex = 21
          OnClick = btnGirisClick
        end
      end
      object cxGrid1: TcxGrid
        Left = 984
        Top = 27
        Width = 230
        Height = 388
        Align = alRight
        PopupMenu = PmSagClick
        TabOrder = 2
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object cxGridDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          OnCanFocusRecord = PDKSListeTVCanFocusRecord
          OnCellDblClick = PDKSListeTVCellDblClick
          DataController.DataSource = DtsTOPLAM
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skSum
              FieldName = 'SAYI'
              Column = cxGridDBColumn2
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.Indicator = True
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'Toplam'
            DataBinding.FieldName = 'SAYI'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 90
          end
          object cxGridDBColumn14: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.cxImageListPDKS
            Properties.Items = <>
            RepositoryItem = Tablo.RepPDKSDurum
            Options.Editing = False
            Width = 76
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
    object TabSheetGrafik: TcxTabSheet
      Caption = 'Grafik'
      ImageIndex = 1
      object GridPDKSGrafik: TcxGrid
        Left = 0
        Top = 0
        Width = 1214
        Height = 415
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object GridPDKSGrafikBandedTV: TcxGridDBBandedTableView
          Navigator.Buttons.CustomButtons = <>
          OnCanFocusRecord = GridPDKSGrafikBandedTVCanFocusRecord
          DataController.DataSource = dtsTabPDKS
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.Indicator = True
          Bands = <
            item
              Width = 322
            end
            item
              Caption = #199'al'#305#351'ma Aral'#305#287#305
            end
            item
            end>
          object cxSaatKolonAdSoyad: TcxGridDBBandedColumn
            Caption = 'Ad Soyad'
            DataBinding.FieldName = 'FIRMA'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 100
            Position.BandIndex = 0
            Position.ColIndex = 0
            Position.RowIndex = 0
          end
          object cxSaatKolonTARIH: TcxGridDBBandedColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'GIRIS'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 75
            Position.BandIndex = 0
            Position.ColIndex = 1
            Position.RowIndex = 0
          end
          object cxSaatKolonGUNADI: TcxGridDBBandedColumn
            Caption = 'G'#252'nler'
            DataBinding.FieldName = 'GUNADI'
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 58
            Position.BandIndex = 0
            Position.ColIndex = 2
            Position.RowIndex = 0
          end
          object cxSaatKolonGiris: TcxGridDBBandedColumn
            Caption = 'Giri'#351
            DataBinding.FieldName = 'GIRIS'
            PropertiesClassName = 'TcxTimeEditProperties'
            Properties.TimeFormat = tfHourMin
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 44
            Position.BandIndex = 0
            Position.ColIndex = 3
            Position.RowIndex = 0
          end
          object cxSaatKolonCikis: TcxGridDBBandedColumn
            Caption = #199#305'k'#305#351
            DataBinding.FieldName = 'CIKIS'
            PropertiesClassName = 'TcxTimeEditProperties'
            Properties.TimeFormat = tfHourMin
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Width = 45
            Position.BandIndex = 0
            Position.ColIndex = 4
            Position.RowIndex = 0
          end
          object cxSaatKolon7: TcxGridDBBandedColumn
            Caption = '07:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 0
            Position.RowIndex = 0
          end
          object cxSaatKolon8: TcxGridDBBandedColumn
            Caption = '08:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 1
            Position.RowIndex = 0
          end
          object cxSaatKolon9: TcxGridDBBandedColumn
            Caption = '09:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 2
            Position.RowIndex = 0
          end
          object cxSaatKolon10: TcxGridDBBandedColumn
            Caption = '10:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 3
            Position.RowIndex = 0
          end
          object cxSaatKolon11: TcxGridDBBandedColumn
            Caption = '11:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 4
            Position.RowIndex = 0
          end
          object cxSaatKolon12: TcxGridDBBandedColumn
            Caption = '12:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 5
            Position.RowIndex = 0
          end
          object cxSaatKolon13: TcxGridDBBandedColumn
            Caption = '13:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 6
            Position.RowIndex = 0
          end
          object cxSaatKolon14: TcxGridDBBandedColumn
            Caption = '14:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 7
            Position.RowIndex = 0
          end
          object cxSaatKolon15: TcxGridDBBandedColumn
            Caption = '15:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 8
            Position.RowIndex = 0
          end
          object cxSaatKolon16: TcxGridDBBandedColumn
            Caption = '16:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 9
            Position.RowIndex = 0
          end
          object cxSaatKolon17: TcxGridDBBandedColumn
            Caption = '17:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 10
            Position.RowIndex = 0
          end
          object cxSaatKolon18: TcxGridDBBandedColumn
            Caption = '18:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            OnGetCellHint = cxSaatKolon9GetCellHint
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 11
            Position.RowIndex = 0
          end
          object cxSaatKolon19: TcxGridDBBandedColumn
            Caption = '19:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 12
            Position.RowIndex = 0
          end
          object cxSaatKolon20: TcxGridDBBandedColumn
            Caption = '20:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 13
            Position.RowIndex = 0
          end
          object cxSaatKolon21: TcxGridDBBandedColumn
            Caption = '21:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 14
            Position.RowIndex = 0
          end
          object cxSaatKolon22: TcxGridDBBandedColumn
            Caption = '22:00'
            OnCustomDrawCell = cxSaatKolon7CustomDrawCell
            HeaderAlignmentHorz = taCenter
            Options.Editing = False
            Options.Filtering = False
            Width = 60
            Position.BandIndex = 1
            Position.ColIndex = 15
            Position.RowIndex = 0
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridPDKSGrafikBandedTV
        end
      end
    end
  end
  object ToolBar9: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1216
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 44
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
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object YaziciYaz: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 8
      Style = tbsTextButton
    end
    object ToolButton1: TToolButton
      Left = 44
      Top = 0
      Width = 825
      ImageIndex = 0
      Style = tbsSeparator
    end
    object BtnKapat: TToolButton
      Left = 869
      Top = 0
      Caption = 'Kapat '
      ImageIndex = 14
      OnClick = BtnKapatClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 27
    Width = 1222
    Height = 66
    Align = alTop
    TabOrder = 1
    object GroupBox2: TGroupBox
      Left = 219
      Top = 30
      Width = 191
      Height = 31
      Caption = #199#305'k'#305#351
      TabOrder = 3
      object RbCikisTumu: TcxRadioButton
        Left = 38
        Top = 11
        Width = 50
        Height = 17
        Caption = 'T'#252'm'#252
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = YenileClick
      end
      object RbCikisErken: TcxRadioButton
        Left = 90
        Top = 11
        Width = 51
        Height = 17
        Caption = 'Erken'
        TabOrder = 1
        OnClick = YenileClick
      end
      object RbCikisGec: TcxRadioButton
        Left = 142
        Top = 11
        Width = 43
        Height = 17
        Caption = 'Ge'#231
        TabOrder = 2
        OnClick = YenileClick
      end
    end
    object GroupBox1: TGroupBox
      Left = 219
      Top = 1
      Width = 191
      Height = 30
      Caption = 'Giri'#351
      TabOrder = 0
      object RbGirisGec: TcxRadioButton
        Left = 142
        Top = 10
        Width = 39
        Height = 17
        Caption = 'Ge'#231
        TabOrder = 2
        OnClick = YenileClick
      end
      object RbGirisErken: TcxRadioButton
        Left = 90
        Top = 10
        Width = 52
        Height = 17
        Caption = 'Erken'
        TabOrder = 1
        OnClick = YenileClick
      end
      object RbGirisTumu: TcxRadioButton
        Left = 38
        Top = 10
        Width = 50
        Height = 17
        Caption = 'T'#252'm'#252
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = YenileClick
      end
    end
    object TarihBas: TcxDateEdit
      Left = 64
      Top = 11
      Properties.ImmediatePost = True
      Properties.OnCloseUp = TarihBasPropertiesCloseUp
      TabOrder = 1
      Width = 124
    end
    object TarihBit: TcxDateEdit
      Left = 64
      Top = 34
      Properties.OnCloseUp = YenileClick
      TabOrder = 5
      Width = 124
    end
    object ComboPersonel: TcxButtonEdit
      Left = 504
      Top = 34
      ParentShowHint = False
      Properties.Alignment.Horz = taLeftJustify
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
      Properties.ReadOnly = True
      Properties.OnButtonClick = ComboKabuledenPropertiesButtonClick
      ShowHint = True
      TabOrder = 7
      Width = 151
    end
    object cxLabel3: TcxLabel
      Left = 450
      Top = 35
      Caption = 'Personel '
      Transparent = True
    end
    object CbCikisNull: TcxCheckBox
      Left = 743
      Top = 33
      Caption = 'Sadece giri'#351'-'#231#305'k'#305#351' yapanlar'
      TabOrder = 4
      Transparent = True
      OnClick = YenileClick
      Width = 161
    end
    object LblSube: TcxLabel
      Left = 450
      Top = 13
      Caption = #350'ube'
      Transparent = True
    end
    object ComboSube: TcxImageComboBox
      Left = 504
      Top = 8
      RepositoryItem = Tablo.RepSubeler
      Properties.Items = <>
      Properties.OnCloseUp = YenileClick
      TabOrder = 2
      Width = 151
    end
    object cxLabel1: TcxLabel
      Tag = 5
      Left = 918
      Top = 6
      Cursor = crHandPoint
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      ParentColor = False
      Style.Color = clBtnFace
      Style.TextColor = clNavy
      Transparent = True
      OnClick = HepsiniSe1Click
    end
    object cxLabel4: TcxLabel
      Tag = 6
      Left = 918
      Top = 25
      Cursor = crHandPoint
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      ParentColor = False
      Style.Color = clBtnFace
      Style.TextColor = clNavy
      Transparent = True
      OnClick = HepsiniSe1Click
    end
    object cxLabel5: TcxLabel
      Tag = 7
      Left = 918
      Top = 43
      Cursor = crHandPoint
      Caption = 'Se'#231'imi Ters '#199'evir'
      ParentColor = False
      Style.Color = clBtnFace
      Style.TextColor = clNavy
      Transparent = True
      OnClick = HepsiniSe1Click
    end
    object ComboDurum: TcxImageComboBox
      Left = 741
      Top = 6
      RepositoryItem = Tablo.RepPDKSDurum
      Properties.DropDownRows = 16
      Properties.Items = <
        item
          ImageIndex = 0
          Value = 0
        end>
      Properties.OnEditValueChanged = ComboDurumPropertiesEditValueChanged
      TabOrder = 12
      Width = 149
    end
    object cxLabel2: TcxLabel
      Left = 697
      Top = 10
      Caption = 'Durum '
      Transparent = True
    end
    object cxLabel6: TcxLabel
      Left = 8
      Top = 10
      Caption = 'Ba'#351'lama'
      Transparent = True
    end
    object cxLabel7: TcxLabel
      Left = 7
      Top = 33
      Caption = 'Biti'#351
      Transparent = True
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 536
    Width = 1222
    Height = 34
    Align = alBottom
    TabOrder = 3
  end
  object TabPDKS: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabPDKSAfterOpen
    ParamData = <>
    SQL.Strings = (
      'SELECT'
      
        '  PP.ID,R.ID AS REHBERID,R.FIRMA,PV.GUNADI,PP.GIRIS,PP.CIKIS,PP.' +
        'SUBEID,PP.DURUM,'
      
        '  (convert(varchar,PV.GIRIS,108) +'#39' / '#39'+convert(varchar,PV.CIKIS' +
        ',108)) as VARGIRISCIKIS, '
      
        '  GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP' +
        '.GIRIS),'#39'00:00'#39'),'
      
        '  CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS' +
        ')),'#39'00:00'#39'),'
      
        '  CALFARK= CASE WHEN  charindex('#39'*'#39',dbo.fn_SaatOlarak(DATEDIFF(m' +
        'i,PP.GIRIS,PP.CIKIS)))=0 THEN '
      
        '  dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn' +
        '_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE '#39'00:00'#39' END,'
      
        '  CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo' +
        '.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),'#39'00:00' +
        #39'),
      
        '  CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo' +
        '.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),'#39'00:00' +
        #39')'
      'from PERS_PDKS PP'
      'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID'
      'left outer join PERS_VARDIYATANIM PV on'
      
        '  PV.REHBERID=CASE WHEN EXISTS(SELECT TOP 1 ISNULL(REHBERID,-1) ' +
        'FROM dbo.PERS_VARDIYATANIM WHERE REHBERID=PP.REHBERID)THEN'
      
        '  PP.REHBERID ELSE -1 END and PV.GUN=DATEPART(WEEKDAY,PP.GIRIS) ' +
        'Where AY = 0 and PP.REHBERID <> 0  and PP.REHBERID <> 0  ')
    Left = 560
    Top = 216
  end
  object dtsTabPDKS: TDataSource
    DataSet = TabPDKS
    Left = 648
    Top = 224
  end
  object PopupMenuYaz: TPopupMenu
    Left = 37
    Top = 240
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxTabPDKS: TfrxDBDataset
    UserName = 'TabPDKS'
    CloseDataSource = False
    FieldAliases.Strings = (
      'FIRMA=FIRMA'
      'GUNADI=GUNADI'
      'GIRIS=GIRIS'
      'CIKIS=CIKIS'
      'VARGIRISCIKIS=VARGIRISCIKIS'
      'GIRFARK=GIRFARK'
      'CALSURE=CALSURE'
      'CALFARK=CALFARK'
      'CIKFARK=CIKFARK')
    DataSet = TabPDKS
    BCDToCurrency = False
    Left = 366
    Top = 209
  end
  object PmSagClick: TPopupMenu
    OnPopup = PmSagClickPopup
    Left = 128
    Top = 184
    object HepsiniSe1: TMenuItem
      Tag = 5
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      OnClick = HepsiniSe1Click
    end
    object mnKaldr1: TMenuItem
      Tag = 6
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      OnClick = HepsiniSe1Click
    end
    object SeimiTersevir1: TMenuItem
      Tag = 7
      Caption = 'Se'#231'imi Ters '#199'evir'
      OnClick = HepsiniSe1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object GrupA1: TMenuItem
      Tag = 1
      Caption = 'Grup A'#231'(-)'
      OnClick = GrupKapa1Click
    end
    object GrupKapa1: TMenuItem
      Caption = 'Grup Kapat(+)'
      OnClick = GrupKapa1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object DurumDegisMenu: TMenuItem
      Caption = 'Durum De'#287'i'#351'tir'
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object GiriSaatDzenle1: TMenuItem
      Tag = 53
      Caption = 'Giri'#351' Saat D'#252'zenle'
      OnClick = btnGirisClick
    end
    object kSaatDzenle1: TMenuItem
      Tag = 54
      Caption = #199#305'k'#305#351' Saat D'#252'zenle'
      OnClick = btnGirisClick
    end
  end
  object PmYeniEkle: TPopupMenu
    Left = 144
    Top = 256
    object MenuItemTekEkle: TMenuItem
      Tag = 2
      Caption = 'Tek Ekle'
      OnClick = MenuItemTekEkleClick
    end
    object MenuItemTumEkle: TMenuItem
      Tag = 3
      Caption = 'T'#252'm'#252'n'#252' Ekle'
      OnClick = MenuItemTekEkleClick
    end
  end
  object TOPLAM: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 784
    Top = 296
    object TOPLAMDURUM: TWordField
      FieldName = 'DURUM'
    end
    object TOPLAMSAYI: TIntegerField
      FieldName = 'SAYI'
      ReadOnly = True
    end
  end
  object DtsTOPLAM: TDataSource
    DataSet = TOPLAM
    Left = 888
    Top = 304
  end
end

