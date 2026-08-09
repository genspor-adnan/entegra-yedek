object HizmetAraDlg: THizmetAraDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = #220'r'#252'n Arama Ekran'#305
  ClientHeight = 474
  ClientWidth = 919
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 919
    Height = 79
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 15
      Top = 37
      Width = 28
      Height = 16
      Caption = '&Kodu'
      FocusControl = AraKod
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelAdi: TLabel
      Left = 97
      Top = 37
      Width = 18
      Height = 16
      Caption = 'A&d'#305
      FocusControl = AraStokAdi
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelBirim: TLabel
      Left = 448
      Top = 38
      Width = 27
      Height = 16
      Caption = 'Birim'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 399
      Top = 39
      Width = 26
      Height = 16
      Caption = 'Adet'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelYer: TLabel
      Left = 578
      Top = 36
      Width = 28
      Height = 16
      Caption = 'Depo'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelBarkod: TLabel
      Left = 287
      Top = 36
      Width = 46
      Height = 16
      Caption = 'Barkodu'
      FocusControl = AraBarkod
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object AraKod: TEdit
      Left = 15
      Top = 52
      Width = 81
      Height = 24
      TabOrder = 0
      OnKeyUp = AraKodKeyUp
    end
    object AraStokAdi: TEdit
      Left = 96
      Top = 52
      Width = 302
      Height = 24
      TabOrder = 1
      OnKeyUp = AraKodKeyUp
    end
    object Adet: TEdit
      Left = 400
      Top = 52
      Width = 26
      Height = 24
      TabOrder = 3
      Text = '1'
    end
    object UpDown1: TUpDown
      Left = 426
      Top = 52
      Width = 16
      Height = 24
      Associate = Adet
      Min = 1
      Position = 1
      TabOrder = 9
    end
    object RadioButton1: TRadioButton
      Left = 123
      Top = 37
      Width = 68
      Height = 13
      Caption = 'Ba'#351'layan'
      Checked = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clTeal
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      TabStop = True
    end
    object RadioButton2: TRadioButton
      Left = 192
      Top = 37
      Width = 90
      Height = 13
      Caption = #304#231'inde Ge'#231'en'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clTeal
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
    end
    object AraBarkod: TEdit
      Left = 283
      Top = 52
      Width = 116
      Height = 24
      TabOrder = 2
      OnKeyPress = AraBarkodKeyPress
    end
    object ToolBar3: TToolBar
      Left = 1
      Top = 1
      Width = 917
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 87
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
      TabOrder = 8
      Transparent = True
      object YeniHizmetTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni Hizmet'
        ImageIndex = 0
        Visible = False
      end
      object YeniStokTus: TToolButton
        Left = 87
        Top = 0
        Caption = 'Yeni Stok'
        ImageIndex = 0
        OnClick = YeniStokTusClick
      end
      object ToolButton2: TToolButton
        Left = 174
        Top = 0
        Width = 398
        Caption = 'ToolButton2'
        ImageIndex = 2
        Style = tbsSeparator
      end
      object SecTus: TToolButton
        Left = 572
        Top = 0
        Caption = 'Se'#231
        ImageIndex = 6
        OnClick = SecTusClick
      end
      object ToolButton4: TToolButton
        Left = 659
        Top = 0
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 6
        Style = tbsSeparator
      end
      object KapatlTus: TToolButton
        Left = 667
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 5
        OnClick = KapatlTusClick
      end
    end
    object comboBirim: TcxImageComboBox
      Left = 448
      Top = 52
      Properties.Items = <>
      Properties.OnEditValueChanged = cbFiyatAdiPropertiesEditValueChanged
      Style.LookAndFeel.Kind = lfStandard
      StyleDisabled.LookAndFeel.Kind = lfStandard
      StyleFocused.LookAndFeel.Kind = lfStandard
      StyleHot.LookAndFeel.Kind = lfStandard
      TabOrder = 4
      Width = 121
    end
    object cbStokDepo: TcxImageComboBox
      Left = 575
      Top = 52
      Properties.Items = <>
      Properties.OnEditValueChanged = cbFiyatAdiPropertiesEditValueChanged
      TabOrder = 5
      Width = 137
    end
  end
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 79
    Width = 919
    Height = 395
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = shtStokAra
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControl1Change
    ClientRectBottom = 391
    ClientRectLeft = 4
    ClientRectRight = 915
    ClientRectTop = 27
    object shtHizmetAra: TcxTabSheet
      Caption = 'Hizmet F1'
      ImageIndex = 19
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxDBTreeList1: TcxDBTreeList
        Left = 0
        Top = 0
        Width = 915
        Height = 365
        Align = alClient
        Bands = <
          item
            Caption.Text = 'Hesap Plan'#305
          end>
        DataController.DataSource = DtsMasrafListe
        DataController.ParentField = 'ROOTKOD'
        DataController.KeyField = 'KOD'
        LookAndFeel.SkinName = 'LondonLiquidSky'
        Navigator.Buttons.CustomButtons = <>
        OptionsBehavior.IncSearch = True
        OptionsData.Inserting = True
        OptionsData.CheckHasChildren = False
        OptionsData.SmartRefresh = True
        OptionsSelection.CellSelect = False
        PopupMenu = PopupMenu1
        RootValue = -1
        TabOrder = 0
        OnDblClick = cxDBTreeList1DblClick
        object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
          Caption.Text = 'Kod'
          DataBinding.FieldName = 'KOD'
          Width = 138
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn
          Caption.Text = 'Ad'
          DataBinding.FieldName = 'AD'
          Width = 303
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListColumn3: TcxDBTreeListColumn
          Caption.Text = 'Fiyat'
          DataBinding.FieldName = 'FIYAT'
          Width = 96
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn
          Caption.Text = 'Kur'
          DataBinding.FieldName = 'KUR'
          Width = 63
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
    object shtStokAra: TcxTabSheet
      Caption = 'Stok F2'
      ImageIndex = 12
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object DBGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 765
        Height = 364
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        ExplicitWidth = 769
        ExplicitHeight = 365
        object tvStokAraListeview: TcxGridDBTableView
          OnDblClick = SecTusClick
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DataSource1
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnFiltering = False
          OptionsCustomize.ColumnHorzSizing = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Background = cxStyle1
          Styles.Content = cxStyle1
          object tvStokAraListeviewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            Width = 76
          end
          object tvStokAraListeviewAD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            Width = 175
          end
          object tvStokAraListeviewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            Width = 45
          end
          object tvStokAraListeviewSKT: TcxGridDBColumn
            DataBinding.FieldName = 'SKT'
            Width = 60
          end
          object tvStokAraListeviewADET: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            Width = 50
          end
          object tvStokAraListeviewANABIRIM: TcxGridDBColumn
            Caption = 'Ana Birim'
            DataBinding.FieldName = 'ANABIRIM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 60
          end
          object tvStokAraListeviewMARKA: TcxGridDBColumn
            Caption = 'Marka'
            DataBinding.FieldName = 'STOKMARKA'
          end
          object tvStokAraListeviewMODEL: TcxGridDBColumn
            Caption = 'Model'
            DataBinding.FieldName = 'STOKMODEL'
          end
          object tvStokAraListeviewMINSTOK: TcxGridDBColumn
            Caption = 'Min.Stok'
            DataBinding.FieldName = 'MINSTOK'
          end
          object tvStokAraListeviewFIYAT: TcxGridDBColumn
            Caption = 'Fiyat'
            DataBinding.FieldName = 'FIYAT'
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 70
          end
          object tvStokAraListeviewKUR: TcxGridDBColumn
            DataBinding.FieldName = 'KUR'
            Width = 20
            IsCaptionAssigned = True
          end
        end
        object DBGrid1Level1: TcxGridLevel
          GridView = tvStokAraListeview
        end
      end
      object LogoResim: TcxImage
        Left = 765
        Top = 0
        Align = alRight
        Properties.GraphicClassName = 'TJPEGImage'
        Style.BorderColor = clBtnFace
        Style.Color = clBtnFace
        Style.Edges = []
        StyleDisabled.BorderStyle = ebsNone
        StyleFocused.BorderStyle = ebsNone
        TabOrder = 1
        ExplicitLeft = 769
        ExplicitHeight = 365
        Height = 364
        Width = 146
      end
      object MemoIadeUrunAra: TMemo
        Left = 64
        Top = 61
        Width = 497
        Height = 281
        Lines.Strings = (
          'DECLARE @REHBERID INT ,'
          #9#9'@KOD VARCHAR(30),'
          #9#9'@STOKADI VARCHAR(100),'
          #9#9'@BARKOD VARCHAR(100)'
          ''
          'SET @REHBERID  = :PREHBERID'
          'SET @KOD = :PKOD'
          'SET @STOKADI = :PSTOKADI'
          'SET @BARKOD = :PBARKOD'
          ''
          
            'SELECT URUNID, KOD, AD, TUR, SKT, SUM(ADET) AS ADET, ANABIRIM, B' +
            'IRIM2, MINSTOK, '
          
            #9#9'MASRAFID, KDV, FIYAT, KUR, IZLEME, TIPI, BARKOD, STOKMARKA, ST' +
            'OKMODEL'
          'FROM'
          '('
          'select '
          
            '    S.ID AS URUNID, S.KOD, STOKADI AS AD, CAST('#39'STOK'#39' AS VARCHAR' +
            '(5)) AS TUR,'
          
            '    ISNULL(FATURA.SKT,'#39'1900-01-01'#39') AS SKT , FATURA.MIKTAR AS AD' +
            'ET, '
          '    ANABIRIM, BIRIM2, ISNULL(MINSTOK,0) AS MINSTOK,'
          
            '    S.MASRAFID, FATURA.KDV, SF.FIYAT, SF.KUR, S.IZLEME, S.TIPI, ' +
            'S.BARKOD, StokMarka.ANAHTAR STOKMARKA, StokModel.ANAHTAR STOKMOD' +
            'EL'
          'FROM'
          #9'FATBASLIK FB '
          #9#9#9'INNER JOIN FATURA ON FB.ID = FATURA.FATBASID '
          #9#9#9'INNER JOIN STOKLAR S ON S.ID = FATURA.URUNID'
          #9#9#9'INNER JOIN STOKFIYAT SF (nolock) ON S.ID = SF.STOKID   '
          
            '                 LEFT OUTER JOIN GENINI StokMarka ON  StokMarka.' +
            'DEGER = S.MARKA and StokMarka.BOLUM=-2701'
          
            '             LEFT OUTER JOIN GENINI StokModel ON StokModel.BOLUM' +
            ' = convert(int,'#39'-2701'#39'+convert(varchar(10),S.MARKA))'
          ' '
          'WHERE FB.REHBERID = @REHBERID AND'
          #9'  FB.TUR = 16 AND '
          #9'  FB.DURUM = 16  '
          #9'  AND S.KOD LIKE @KOD'
          #9'  AND S.STOKADI LIKE @STOKADI'
          #9'  AND 1= CASE WHEN @BARKOD = '#39#39' THEN 1'
          #9#9#9'  WHEN (@BARKOD <> '#39#39' AND @BARKOD = S.BARKOD )THEN 1'
          #9#9'ELSE 0 END'#9'  '
          #9'   AND StokMarka.BOLUM = '#39'StokKart_Marka'#39
          'UNION ALL'
          ''
          'select '
          
            '    S.ID AS URUNID, S.KOD, STOKADI AS AD, CAST('#39'STOK'#39' AS VARCHAR' +
            '(5)) AS TUR,'
          
            '    ISNULL(FATURA.SKT,'#39'1900-01-01'#39') AS SKT , (-1 * FATURA.MIKTAR' +
            ') AS ADET, '
          '    ANABIRIM, BIRIM2, ISNULL(MINSTOK,0) AS MINSTOK,'
          
            '    S.MASRAFID, FATURA.KDV, SF.FIYAT, SF.KUR, S.IZLEME, S.TIPI, ' +
            'S.BARKOD, StokMarka.ANAHTAR STOKMARKA, StokModel.ANAHTAR STOKMOD' +
            'EL'
          'FROM'
          #9'FATBASLIK FB '
          #9#9#9'INNER JOIN FATURA ON FB.ID = FATURA.FATBASID '
          #9#9#9'INNER JOIN STOKLAR S ON S.ID = FATURA.URUNID'
          #9#9#9'INNER JOIN STOKFIYAT SF (nolock) ON S.ID = SF.STOKID    '
          
            '                 LEFT OUTER JOIN GENINI StokMarka ON  StokMarka.' +
            'DEGER = S.MARKA and StokMarka.BOLUM=-2701 '
          
            '  LEFT OUTER JOIN GENINI StokModel ON StokModel.BOLUM = convert(' +
            'int,'#39'-2701'#39'+convert(varchar(10),S.MARKA))'
          'WHERE FB.REHBERID = @REHBERID AND'
          #9'  FB.TUR = 12 AND  '
          #9'  FB.DURUM = 12   '
          #9'  AND S.KOD LIKE @KOD'
          #9'  AND S.STOKADI LIKE @STOKADI'
          #9'  AND 1= CASE WHEN @BARKOD = '#39#39' THEN 1'
          #9#9#9'  WHEN (@BARKOD <> '#39#39' AND @BARKOD = S.BARKOD )THEN 1'
          #9#9'ELSE 0 END'#9
          '                 AND StokMarka.BOLUM = '#39'StokKart_Marka'#39'  '
          #9'  '
          ') AS X'#9'  '#9'  '
          'GROUP BY URUNID, KOD, AD, TUR, SKT, ANABIRIM, BIRIM2, MINSTOK, '
          #9#9'MASRAFID, KDV, FIYAT, KUR, IZLEME, TIPI, BARKOD'
          'HAVING SUM(ADET) > 0'#9#9)
        TabOrder = 2
        Visible = False
        WordWrap = False
      end
    end
  end
  object cxLabel1: TcxLabel
    Left = 118
    Top = 84
    Caption = 'Son Eklenen : '
    Transparent = True
  end
  object LabelEklenen: TcxLabel
    Left = 188
    Top = 84
    Caption = '---'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = [fsBold]
    Style.TransparentBorder = True
    Style.IsFontAssigned = True
    Transparent = True
  end
  object lbFiyatAdi: TcxLabel
    Left = 537
    Top = 83
    Caption = 'Fiyat Ad'#305
    Transparent = True
  end
  object cbFiyatAdi: TcxImageComboBox
    Left = 590
    Top = 79
    RepositoryItem = Tablo.RepFiyatAdlari
    Properties.Items = <>
    Properties.OnEditValueChanged = cbFiyatAdiPropertiesEditValueChanged
    TabOrder = 5
    Width = 122
  end
  object DataSource1: TDataSource
    DataSet = QueryIslem
    Left = 291
    Top = 223
  end
  object QueryIslem: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = QueryIslemAfterOpen
    AfterScroll = QueryIslemAfterScroll
    ParamData = <>
    Left = 188
    Top = 206
  end
  object PopupUcret: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 86
    Top = 134
    object Y00: TMenuItem
      Tag = 1
      Caption = '% 0 '#304'ndirim'
      ImageIndex = 34
    end
    object Y10: TMenuItem
      Tag = 1
      Caption = '% 10 '#304'ndirim'
      ImageIndex = 34
    end
    object Y15: TMenuItem
      Tag = 1
      Caption = '% 15 '#304'ndirim'
      ImageIndex = 34
    end
    object Y20: TMenuItem
      Tag = 1
      Caption = '% 20 '#304'ndirim'
      ImageIndex = 34
    end
    object Y25: TMenuItem
      Tag = 1
      Caption = '% 25 '#304'ndirim'
      ImageIndex = 34
    end
    object Y30: TMenuItem
      Tag = 1
      Caption = '% 30 '#304'ndirim'
      ImageIndex = 34
    end
    object Y35: TMenuItem
      Tag = 1
      Caption = '% 35 '#304'ndirim'
      ImageIndex = 34
    end
    object Y40: TMenuItem
      Tag = 1
      Caption = '% 40 '#304'ndirim'
      ImageIndex = 34
    end
    object Y45: TMenuItem
      Tag = 1
      Caption = '% 45 '#304'ndirim'
      ImageIndex = 34
    end
    object Ozel: TMenuItem
      Tag = 1
      Caption = #214'zel %...'
      ImageIndex = 34
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object ExceleGnder1: TMenuItem
      Caption = 'Excel'#39'e G'#246'nder..'
      ImageIndex = 32
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object HepsiniSil1: TMenuItem
      Caption = 'Hepsini Sil'
      ImageIndex = 1
    end
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 345
    Top = 195
    object IsleminUcretiniSorMenu: TMenuItem
      Caption = #304#351'lemin '#220'cretini Gir'
      ImageIndex = 30
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 33
    Top = 151
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14670239
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      TextColor = clWindowText
    end
  end
  object cxStyleRepository2: TcxStyleRepository
    Left = 33
    Top = 208
    PixelsPerInch = 96
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 14670239
      TextColor = clWindowText
    end
  end
  object cxStyleRepository3: TcxStyleRepository
    Left = 32
    Top = 257
    PixelsPerInch = 96
    object SKTAzKalanRenk: TcxStyle
      AssignedValues = [svTextColor]
      TextColor = clRed
    end
    object SKTGecenRenk: TcxStyle
      AssignedValues = [svTextColor]
      TextColor = clBlue
    end
    object MinimumStokRenk: TcxStyle
      AssignedValues = [svTextColor]
      TextColor = clBlack
    end
  end
  object TabMasrafListe: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 254
    Top = 148
  end
  object DtsMasrafListe: TDataSource
    DataSet = TabMasrafListe
    Left = 371
    Top = 149
  end
  object TabPaketListe: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'Declare @YerID int'
      'Declare @Stok bit'
      'Declare @IslemSay int'
      ''
      'Set @Stok = :PStok'
      'Set @YerID = :PYerID'
      ''
      'if @Stok=0'
      #9'set @IslemSay=0'
      'else if @Stok=1 '
      #9'select @IslemSay=COUNT(*) from PAKETDETAY where PAKETID=@YerID'
      #9#9
      'if @IslemSay=0'
      #9'select @YerID,@Stok,1'
      'else'
      #9'select URUNID,STOK,ADET from PAKETDETAY where PAKETID=@YerID')
    Left = 595
    Top = 174
  end
end
