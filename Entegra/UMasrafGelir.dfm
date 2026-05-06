object MasrafGelirDlg: TMasrafGelirDlg
  Left = 0
  Top = 0
  Width = 1450
  Height = 545
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
  object Panel5: TPanel
    Left = 375
    Top = 0
    Width = 1075
    Height = 545
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 1
    object Panel3: TPanel
      Left = 6
      Top = 41
      Width = 1063
      Height = 125
      Align = alTop
      Color = clSilver
      ParentBackground = False
      TabOrder = 0
      ExplicitTop = 38
      object DBText1: TDBText
        Left = 190
        Top = 13
        Width = 72
        Height = 17
        DataField = 'ID'
        DataSource = DtsMasrafGelir
        Transparent = True
      end
      object Label2: TcxLabel
        Left = 10
        Top = 11
        Caption = 'Kod'
        ParentColor = False
        ParentFont = False
        Style.Color = clWhite
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label3: TcxLabel
        Left = 10
        Top = 38
        Caption = 'Ad'
        ParentColor = False
        ParentFont = False
        Style.Color = clWhite
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label6: TcxLabel
        Left = 10
        Top = 91
        Caption = 'A'#231#305'klama'
        ParentColor = False
        ParentFont = False
        Style.Color = clWhite
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label7: TcxLabel
        Left = 274
        Top = 65
        Caption = 'Durum'
        FocusControl = ComboDURUM
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label13: TcxLabel
        Left = 169
        Top = 11
        Caption = 'ID'
        ParentColor = False
        ParentFont = False
        Style.Color = clWhite
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label14: TcxLabel
        Left = 10
        Top = 65
        Caption = 'KDV'
        ParentColor = False
        ParentFont = False
        Style.Color = clWhite
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditKASAKODU: TDBEdit
        Left = 57
        Top = 9
        Width = 106
        Height = 24
        Ctl3D = True
        DataField = 'KOD'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 0
      end
      object EditKASAADI: TDBEdit
        Left = 57
        Top = 36
        Width = 202
        Height = 24
        Ctl3D = True
        DataField = 'AD'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 1
      end
      object EditHESAPACIKLAMA: TDBEdit
        Left = 57
        Top = 90
        Width = 357
        Height = 24
        Ctl3D = True
        DataField = 'ACIKLAMA'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 4
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 316
        Top = 63
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsMasrafGelir
        Properties.ClearKey = 46
        Properties.Items = <
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = True
          end
          item
            Description = 'Pasif'
            Value = False
          end>
        Style.BorderStyle = ebs3D
        TabOrder = 7
        Width = 100
      end
      object cxDBSpinEdit1: TcxDBSpinEdit
        Left = 57
        Top = 64
        DataBinding.DataField = 'KDV'
        DataBinding.DataSource = DtsMasrafGelir
        Properties.MaxValue = 50.000000000000000000
        TabOrder = 2
        Width = 64
      end
      object cxDBImageComboBox3: TcxDBImageComboBox
        Left = 738
        Top = 46
        DataBinding.DataField = 'KISAYOLGRUBU'
        DataBinding.DataSource = DtsMasrafGelir
        Properties.Items = <>
        TabOrder = 18
        Visible = False
        Width = 90
      end
      object LblSube: TcxLabel
        Left = 282
        Top = 11
        Caption = #350'ube'
        Transparent = True
      end
      object ComboSube: TcxDBImageComboBox
        Left = 316
        Top = 9
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        DataBinding.DataField = 'SUBEID'
        DataBinding.DataSource = DtsMasrafGelir
        Properties.Alignment.Horz = taLeftJustify
        Properties.ImmediatePost = True
        Properties.Items = <>
        Properties.OnCloseUp = ComboSubePropertiesCloseUp
        StyleDisabled.Color = clWhite
        StyleDisabled.TextColor = clBlack
        TabOrder = 5
        OnKeyUp = ComboSubeKeyUp
        Width = 100
      end
      object LogoResim: TcxDBImage
        Left = 604
        Top = 9
        DataBinding.DataField = 'RESIM'
        DataBinding.DataSource = DtsMasrafGelir
        Properties.Caption = 'Resim i'#231'in sa'#287' t'#305'klay'#305'n'
        Properties.GraphicClassName = 'TdxSmartImage'
        TabOrder = 12
        Height = 97
        Width = 128
      end
      object cxDBCheckBox1: TcxDBCheckBox
        Left = 127
        Top = 65
        Caption = 'Maliyetleri De'#287'i'#351'tirsin'
        DataBinding.DataField = 'ZARFMALIYETDURUMU'
        DataBinding.DataSource = DtsMasrafGelir
        TabOrder = 3
      end
      object Label5: TcxLabel
        Left = 282
        Top = 38
        Cursor = crHandPoint
        Hint = 'StokKart_Anabirim'
        HelpType = htKeyword
        HelpKeyword = 'STOKLAR.ANABIRIM'
        Caption = 'Birim'
        FocusControl = ComboBIRIM
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboBIRIM: TcxDBImageComboBox
        Left = 316
        Top = 36
        RepositoryItem = Tablo.repStokAnaBirim
        DataBinding.DataField = 'BIRIM'
        DataBinding.DataSource = DtsMasrafGelir
        Properties.Items = <>
        TabOrder = 6
        Width = 100
      end
      object DBEditYETKIKODU: TDBEdit
        Left = 475
        Top = 61
        Width = 99
        Height = 24
        Ctl3D = True
        DataField = 'YETKIKODU'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 10
      end
      object DBEditOZELKOD: TDBEdit
        Left = 475
        Top = 9
        Width = 99
        Height = 24
        Ctl3D = True
        DataField = 'OZELKOD'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 8
      end
      object cxLabel1: TcxLabel
        Left = 418
        Top = 10
        Caption = #214'zel Kod'
        Transparent = True
      end
      object cxLabel2: TcxLabel
        Left = 418
        Top = 62
        Cursor = crHandPoint
        Hint = 'StokKart_Anabirim'
        HelpType = htKeyword
        HelpKeyword = 'STOKLAR.ANABIRIM'
        Caption = 'Yetki Kodu'
        FocusControl = ComboBIRIM
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object DBEditMUHKODU: TDBEdit
        Left = 474
        Top = 35
        Width = 99
        Height = 24
        Ctl3D = True
        DataField = 'MUHKODU'
        DataSource = DtsMasrafGelir
        ParentCtl3D = False
        TabOrder = 9
      end
      object cxLabel3: TcxLabel
        Left = 417
        Top = 36
        Cursor = crHandPoint
        Hint = 'StokKart_Anabirim'
        HelpType = htKeyword
        HelpKeyword = 'STOKLAR.ANABIRIM'
        Caption = 'Muh Kodu'
        FocusControl = ComboBIRIM
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object cxPageControl1: TcxPageControl
      Left = 6
      Top = 166
      Width = 1063
      Height = 373
      Align = alClient
      TabOrder = 1
      Properties.ActivePage = TabSheetFiyat
      Properties.CustomButtons.Buttons = <>
      OnChange = cxPageControl1Change
      ExplicitTop = 163
      ExplicitHeight = 376
      ClientRectBottom = 369
      ClientRectLeft = 4
      ClientRectRight = 1059
      ClientRectTop = 27
      object TabSheetFiyat: TcxTabSheet
        Caption = 'Fiyatlar'
        ImageIndex = 2
        ExplicitHeight = 345
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1049
          Height = 39
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 37
          ButtonWidth = 41
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
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object FiyatEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            Visible = False
            OnClick = FiyatEkleTusClick
          end
          object FiyatSilTus: TToolButton
            Left = 41
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            Visible = False
            OnClick = FiyatSilTusClick
          end
          object ComboSatis: TcxImageComboBox
            Left = 82
            Top = 7
            EditValue = '1'
            Properties.ImmediatePost = True
            Properties.Items = <
              item
                Description = 'Al'#305#351
                ImageIndex = 0
                Value = '0'
              end
              item
                Description = 'Sat'#305#351
                Value = '1'
              end>
            Properties.OnChange = ComboSatisPropertiesChange
            TabOrder = 0
            Width = 82
          end
          object FiyatKaydetTus: TToolButton
            Left = 164
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            OnClick = FiyatKaydetTusClick
          end
          object FiyatIptalTus: TToolButton
            Left = 205
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            OnClick = FiyatIptalTusClick
          end
        end
        object GridFiyat: TcxGrid
          Left = 0
          Top = 42
          Width = 1055
          Height = 300
          Align = alClient
          PopupMenu = PopupMenuFiyat
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          ExplicitHeight = 303
          object GridFiyatDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridFiyatDBTableView1CanFocusRecord
            DataController.DataSource = DtsFiyatlar
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.AlwaysShowEditor = True
            OptionsBehavior.FocusCellOnTab = True
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridFiyatDBTableView1FIYATADI1: TcxGridDBColumn
              Caption = 'Fiyat Ad'#305
              DataBinding.FieldName = 'FIYATADI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepFiyatAdlari
              Options.Editing = False
              Width = 120
            end
            object GridFiyatDBTableView1SEC1: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.FieldName = 'SEC'
              DataBinding.IsNullValueType = True
              Width = 27
            end
            object GridFiyatDBTableView1FIYAT1: TcxGridDBColumn
              Caption = 'Fiyat'
              DataBinding.FieldName = 'FIYAT'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              RepositoryItem = Tablo.RepCurrencyBF
              Width = 101
            end
            object GridFiyatDBTableView1KUR1: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxComboBoxProperties'
              Properties.DropDownListStyle = lsFixedList
              RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              Width = 60
            end
            object GridFiyatDBTableView1KDVDURUM1: TcxGridDBColumn
              Caption = 'KDV Durumu'
              DataBinding.FieldName = 'KDVDURUM'
              DataBinding.IsNullValueType = True
              Width = 68
            end
          end
          object GridFiyatLevel1: TcxGridLevel
            GridView = GridFiyatDBTableView1
          end
        end
      end
      object TabSheetButce: TcxTabSheet
        Caption = 'B'#252't'#231'e Bilgileri'
        ImageIndex = 1
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1049
          Height = 39
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 37
          ButtonWidth = 51
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
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object GirisTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Giri'#351' Yap'
            ImageIndex = 4
            ImageName = 'PngImage4'
            OnClick = GirisTusClick
          end
          object ButceSilTus: TToolButton
            Left = 51
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = ButceSilTusClick
          end
          object ButceKaydetTus: TToolButton
            Left = 102
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsTextButton
            OnClick = ButceKaydetTusClick
          end
          object ButceIptalTus: TToolButton
            Left = 153
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            Style = tbsTextButton
            OnClick = ButceIptalTusClick
          end
          object SEditButceYil: TcxSpinEdit
            Left = 204
            Top = 7
            Properties.ImmediatePost = True
            Properties.MaxValue = 2049.000000000000000000
            Properties.MinValue = 1990.000000000000000000
            Properties.OnEditValueChanged = SEditButceYilPropertiesEditValueChanged
            TabOrder = 0
            Value = 2011
            Width = 74
          end
          object YenileTus: TToolButton
            Left = 278
            Top = 0
            Caption = 'Yenile'
            ImageIndex = 9
            ImageName = 'PngImage9'
            Visible = False
            OnClick = YenileTusClick
          end
        end
        object cxGrid1: TcxGrid
          Left = 0
          Top = 42
          Width = 1055
          Height = 300
          Align = alClient
          PopupMenu = PopupMenuButce
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object cxGridDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = cxGridDBTableView1CanFocusRecord
            DataController.DataSource = DtsButce
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'PLANLANAN'
                Column = cxGridDBTableView1PLANLANAN
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'GERCEKLESEN'
                Column = cxGridDBTableView1GERCEKLESEN
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object cxGridDBTableView1AY: TcxGridDBColumn
              Caption = 'Ay'
              DataBinding.FieldName = 'AY'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 51
            end
            object cxGridDBTableView1GUN: TcxGridDBColumn
              Caption = 'G'#252'n'
              DataBinding.FieldName = 'GUN'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0;-,0'
              Properties.MaxValue = 31.000000000000000000
              Properties.MinValue = 1.000000000000000000
              Properties.UseDisplayFormatWhenEditing = True
              Width = 37
            end
            object cxGridDBTableView1PLANLANAN: TcxGridDBColumn
              Caption = 'Planlanan'
              DataBinding.FieldName = 'PLANLANAN'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 72
            end
            object cxGridDBTableView1GERCEKLESEN: TcxGridDBColumn
              Caption = 'Ger'#231'ekle'#351'en'
              DataBinding.FieldName = 'GERCEKLESEN'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Options.Editing = False
              Width = 70
            end
            object cxGridDBTableView1KUR: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
            end
            object cxGridDBTableView1GOR: TcxGridDBColumn
              Caption = 'Takvimde G'#246'ster'
              DataBinding.FieldName = 'GOR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Width = 96
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = cxGridDBTableView1
          end
        end
        object MemoButceFaturadan: TMemo
          Left = 28
          Top = 98
          Width = 689
          Height = 40
          Lines.Strings = (
            'DECLARE @MasrafID INT'
            'DECLARE @BASTAR DATETIME'
            'DECLARE @BITTAR DATETIME'
            'SET @MasrafID=:PMasrafID'
            'SET @BASTAR=:PBasTar'
            'SET @BITTAR=:PBitTar'
            'SELECT SUM(TUTAR)'
            'FROM ('
            #9'select '
            #9#9'TUTAR=CASE '
            
              #9#9#9'WHEN (FB.KDVDURUM='#39'Hari'#231#39') AND (FB.TUR IN(8,10,11,12)) THEN -' +
              'TUTAR*(100+KDV)/100'
            
              #9#9#9'WHEN (FB.KDVDURUM='#39'Hari'#231#39') AND (FB.TUR IN(14,15,16)) THEN TUT' +
              'AR*(100+KDV)/100'#9#9
            
              #9#9#9'WHEN (FB.KDVDURUM='#39'Dahil'#39') AND (FB.TUR IN(8,10,11,12)) THEN -' +
              'TUTAR'#9
            
              #9#9#9'WHEN (FB.KDVDURUM='#39'Dahil'#39') AND (FB.TUR IN(14,15,16)) THEN TUT' +
              'AR'#9#9#9
            #9#9'END'
            #9'from'
            #9#9'FATURA F INNER JOIN '
            #9#9'FATBASLIK FB ON F.FATBASID=FB.ID '
            #9'WHERE '
            #9#9'F.MASRAFID=@MasrafID and'
            #9#9'FB.FATURATARIH between @BASTAR and @BITTAR'
            #9#9
            #9'UNION ALL '
            ''
            #9'select '
            #9#9'TUTAR=CASE '
            #9#9#9'WHEN FB.TUR=13 THEN -FATURA_TUTARI'
            #9#9#9'WHEN FB.TUR=17 THEN FATURA_TUTARI'
            #9#9'END'
            #9'from'
            #9#9'FATBASLIK FB '
            #9'WHERE '
            #9#9'FB.MASRAFID=@MasrafID AND'
            #9#9'FB.TUR IN (13,17) and'
            #9#9'FB.FATURATARIH between @BASTAR and @BITTAR'
            ') AS ASD')
          TabOrder = 2
          Visible = False
          WordWrap = False
        end
        object MemoButceKasadan: TMemo
          Left = 28
          Top = 150
          Width = 690
          Height = 48
          Lines.Strings = (
            'select isnull(sum(ALACAK-BORC),0.0) '
            'from KASA '
            'where TUR not in (61,71) '
            'and MASRAFID =:PMasrafID'
            'and ISLEMTARIHI between :PBasTar and :PBitTar')
          TabOrder = 3
          Visible = False
          WordWrap = False
        end
      end
      object TabSheetYDil: TcxTabSheet
        Caption = 'Yabanc'#305' Dil'
        ImageIndex = 4
        object ToolBar4: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1049
          Height = 24
          Margins.Bottom = 0
          Anchors = [akLeft]
          AutoSize = True
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
          object YDilYeni: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = YDilYeniClick
          end
          object YDilKaydet: TToolButton
            Left = 61
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Visible = False
            OnClick = YDilKaydetClick
          end
          object YDilSil: TToolButton
            Left = 122
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = YDilSilClick
          end
          object YDilIptal: TToolButton
            Left = 183
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            Visible = False
            OnClick = YDilIptalClick
          end
        end
        object GridYDil: TcxGrid
          Left = 0
          Top = 27
          Width = 1055
          Height = 315
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          object GridYDilView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsYDil
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.DeletingConfirmation = False
            OptionsView.CellAutoHeight = True
            OptionsView.GroupByBox = False
            OptionsView.Header = False
            Styles.Content = Tablo.cxStyle1
            object GridYDilViewDIL: TcxGridDBColumn
              Caption = 'Dil'
              DataBinding.FieldName = 'DIL'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepDiller
            end
            object GridYDilViewBILGI: TcxGridDBColumn
              Caption = 'Bilgi'
              DataBinding.FieldName = 'BILGI'
              DataBinding.IsNullValueType = True
              Width = 600
            end
          end
          object cxGridLevel9: TcxGridLevel
            GridView = GridYDilView
          end
        end
      end
      object TabSheetEkstre: TcxTabSheet
        Caption = 'Ekstre'
        ImageIndex = 3
        object GridMasrafEkstre: TcxGrid
          Left = 0
          Top = 49
          Width = 1055
          Height = 293
          Align = alClient
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridMasrafEkstreView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridMasrafEkstreViewCanFocusRecord
            OnCellDblClick = GridMasrafEkstreViewCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsCariListe
            DataController.Options = [dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
                Column = GridMasrafEkstreViewBORC
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
                Column = GridMasrafEkstreViewALACAK
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Column = GridMasrafEkstreViewBORCBAKIYE
              end
              item
                Format = ',0.00;(,0.00)'
                Column = GridMasrafEkstreViewALACAKBAKIYE
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.FocusCellOnCycle = True
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.MultiSelect = True
            OptionsView.Footer = True
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.Indicator = True
            Styles.ContentEven = AnaForm.cxStyle1
            Styles.GroupByBox = AnaForm.cxStyle1
            Styles.Header = AnaForm.cxStyle1
            object GridMasrafEkstreViewTARIH: TcxGridDBColumn
              Caption = 'Kay'#305't'
              DataBinding.FieldName = 'TARIH'
              DataBinding.IsNullValueType = True
              Width = 68
            end
            object GridMasrafEkstreViewAKSIYONTARIH: TcxGridDBColumn
              Caption = 'Aksiyon/Vade'
              DataBinding.FieldName = 'AKSIYONTARIH'
              DataBinding.IsNullValueType = True
              Width = 79
            end
            object GridMasrafEkstreViewNO: TcxGridDBColumn
              Caption = 'No'
              DataBinding.FieldName = 'NO'
              DataBinding.IsNullValueType = True
              Width = 75
            end
            object GridMasrafEkstreViewTUR: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <
                item
                  Description = 'A'#231#305'l'#305#351' Fi'#351'i'
                  ImageIndex = 0
                  Value = 1
                end
                item
                  Description = 'Devir'
                  Value = 2
                end
                item
                  Description = 'Al'#305#351' Faturas'#305
                  ImageIndex = 0
                  Value = 11
                end
                item
                  Description = 'Al'#305#351' Fi'#351'i'
                  Value = 12
                end
                item
                  Description = 'Sat'#305#351' Faturas'#305
                  Value = 15
                end
                item
                  Description = 'Sat'#305#351' Fi'#351'i'
                  Value = 16
                end
                item
                  Description = 'Kasa Tahsilat'
                  Value = 21
                end
                item
                  Description = 'Banka Tahsilat'
                  Value = 22
                end
                item
                  Description = #199'ekle Tahsilat'
                  Value = 23
                end
                item
                  Description = 'Senetle Tahsilat'
                  Value = 24
                end
                item
                  Description = 'Kredi Kart'#305'yla Tahsilat'
                  Value = 25
                end
                item
                  Description = 'Kasa '#214'deme'
                  Value = 31
                end
                item
                  Description = 'Banka '#214'deme'
                  Value = 32
                end
                item
                  Description = #199'ekle '#214'deme'
                  Value = 33
                end
                item
                  Description = 'Senetle '#214'deme'
                  Value = 34
                end
                item
                  Description = 'Kredi Kart'#305'yla '#214'deme'
                  Value = 35
                end
                item
                  Description = 'Bankaya Yatan'
                  Value = 41
                end
                item
                  Description = 'Bankadan '#199'ekilen'
                  Value = 42
                end
                item
                  Description = 'Virman'
                  Value = 43
                end
                item
                  Description = 'D'#246'viz Al'#305#351
                  Value = 45
                end
                item
                  Description = 'D'#246'viz Sat'#305#351
                  Value = 46
                end
                item
                  Description = 'D'#246'viz Al'#305#351
                  Value = 47
                end
                item
                  Description = 'D'#246'viz Sat'#305#351
                  Value = 48
                end
                item
                  Description = #199'ek Bozduruldu'
                  Value = 51
                end
                item
                  Description = 'Senet Bozduruldu'
                  Value = 52
                end
                item
                  Description = #199'ek Bozduruldu'
                  Value = 53
                end
                item
                  Description = 'Senet Bozduruldu'
                  Value = 54
                end
                item
                  Description = 'Tahsilat Plan'#305
                  Value = 61
                end
                item
                  Description = 'D'#252'zenli Gelir'
                  Value = 62
                end
                item
                  Description = 'Avans Tahsilat Plan'#305
                  Value = 63
                end
                item
                  Description = #214'deme Plan'#305
                  Value = 71
                end
                item
                  Description = 'D'#252'zenli '#214'deme'
                  Value = 72
                end
                item
                  Description = 'Kredi '#214'deme'
                  Value = 75
                end
                item
                  Description = 'Tahakkuk'
                  Value = 81
                end
                item
                  Description = 'POS Giri'#351'i'
                  Value = 121
                end
                item
                  Description = 'Nakit Giri'#351'i'
                  Value = 122
                end>
              RepositoryItem = Tablo.RepKasaTurleri
            end
            object GridMasrafEkstreViewKOD: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 77
            end
            object GridMasrafEkstreViewAD: TcxGridDBColumn
              Caption = #220'nvan'
              DataBinding.FieldName = 'AD'
              DataBinding.IsNullValueType = True
              Width = 90
            end
            object GridMasrafEkstreViewACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 128
            end
            object GridMasrafEkstreViewHESAPKODU: TcxGridDBColumn
              Caption = 'Hesap Kodu'
              DataBinding.FieldName = 'HESAPKODU'
              DataBinding.IsNullValueType = True
              Width = 91
            end
            object GridMasrafEkstreViewHESAPADI: TcxGridDBColumn
              Caption = 'Hesap Ad'#305
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Width = 82
            end
            object GridMasrafEkstreViewBORC: TcxGridDBColumn
              Caption = 'Bor'#231
              DataBinding.FieldName = 'BORC'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 56
            end
            object GridMasrafEkstreViewALACAK: TcxGridDBColumn
              Caption = 'Alacak'
              DataBinding.FieldName = 'ALACAK'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 67
            end
            object GridMasrafEkstreViewKUR: TcxGridDBColumn
              Caption = 'Para Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Visible = False
              GroupIndex = 0
              Width = 69
            end
            object GridMasrafEkstreViewBORCBAKIYE: TcxGridDBColumn
              Caption = 'B.Bakiye'
              DataBinding.FieldName = 'BORCBAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 54
            end
            object GridMasrafEkstreViewALACAKBAKIYE: TcxGridDBColumn
              Caption = 'A.Bakiye'
              DataBinding.FieldName = 'ALACAKBAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 56
            end
            object GridMasrafEkstreViewYERELKUR: TcxGridDBColumn
              Caption = 'Y.Kur'
              DataBinding.FieldName = 'YERELKUR'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridMasrafEkstreViewYERELTUTAR: TcxGridDBColumn
              Caption = 'Y.Tutar'
              DataBinding.FieldName = 'YERELTUTAR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Visible = False
            end
            object GridMasrafEkstreViewYERELBAKIYE: TcxGridDBColumn
              Caption = 'Y.Bakiye'
              DataBinding.FieldName = 'YERELBAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Visible = False
            end
          end
          object cxGrid1DBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DetailKeyFieldNames = 'CEKID'
            DataController.MasterKeyFieldNames = 'CEKID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsView.GroupByBox = False
            Styles.ContentOdd = AnaForm.cxStyle1
            Styles.GroupByBox = AnaForm.cxStyle1
            Styles.Header = AnaForm.cxStyle1
            object cxGrid1DBTableView1DURUM: TcxGridDBColumn
              DataBinding.FieldName = 'DURUM'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 74
            end
            object cxGrid1DBTableView1VADE: TcxGridDBColumn
              DataBinding.FieldName = 'VADE'
              DataBinding.IsNullValueType = True
              Width = 130
            end
            object cxGrid1DBTableView1SERINO: TcxGridDBColumn
              DataBinding.FieldName = 'SERINO'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 109
            end
            object cxGrid1DBTableView1HESAPADI: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Width = 354
            end
            object cxGrid1DBTableView1Column1: TcxGridDBColumn
              DataBinding.FieldName = 'CEKID'
              DataBinding.IsNullValueType = True
            end
          end
          object cxGrid1Level1: TcxGridLevel
            GridView = GridMasrafEkstreView
          end
        end
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 1055
          Height = 49
          Align = alTop
          Caption = 'Panel4'
          TabOrder = 1
          object ToolBar11: TToolBar
            Left = 1
            Top = 1
            Width = 54
            Height = 47
            Margins.Bottom = 0
            Align = alLeft
            ButtonHeight = 47
            ButtonWidth = 51
            Caption = 'AletCubugu'
            DockSite = True
            DrawingStyle = dsGradient
            EdgeInner = esNone
            EdgeOuter = esNone
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            GradientEndColor = 11776947
            GradientStartColor = 14540253
            Images = Tablo.PNGImageList1
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            object YaziciYaz: TToolButton
              Left = 0
              Top = 0
              Caption = '  Yazd'#305'r  '
              DropdownMenu = PopupMenuYaz
              ImageIndex = 16
              ImageName = 'PngImage15'
              Style = tbsTextButton
            end
          end
          object JvNavPanelHeader1: TJvNavPanelHeader
            Left = 55
            Top = 1
            Width = 999
            Height = 47
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -16
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            ColorFrom = 14540253
            ColorTo = 11776947
            ImageIndex = 0
            object cxLabel6: TcxLabel
              Left = 3
              Top = 10
              Caption = 'Ba'#351'lama'
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              OnClick = cxLabel6Click
            end
            object CalendarEkstreBas: TcxDateEdit
              Left = 59
              Top = 9
              ParentFont = False
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -16
              Style.Font.Name = 'Arial'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
              TabOrder = 1
              Width = 121
            end
            object CalendarEkstreBit: TcxDateEdit
              Left = 225
              Top = 9
              ParentFont = False
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -16
              Style.Font.Name = 'Arial'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
              TabOrder = 2
              Width = 121
            end
            object cxLabel7: TcxLabel
              Left = 185
              Top = 12
              Caption = 'Biti'#351'   '
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object cxRadioButton1: TcxRadioButton
              Left = 376
              Top = 16
              Width = 81
              Height = 17
              Caption = 'Tahakkuk'
              Checked = True
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 4
              TabStop = True
            end
            object cxRadioButton2: TcxRadioButton
              Left = 463
              Top = 16
              Width = 82
              Height = 17
              Caption = #214'deme'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 5
            end
            object cxRadioButton3: TcxRadioButton
              Left = 551
              Top = 16
              Width = 82
              Height = 17
              Caption = 'T'#252'm'#252
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 6
            end
          end
        end
      end
      object cxTabSheetMuhKod: TcxTabSheet
        Caption = 'Muhasebe Hesaplar'#305
        ImageIndex = 4
        object v: TcxGrid
          Left = 0
          Top = 24
          Width = 1055
          Height = 318
          Align = alClient
          TabOrder = 0
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object vTableView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsStokMuhasebe
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object vTableViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewMUHASEBEID: TcxGridDBColumn
              DataBinding.FieldName = 'MUHASEBEID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewHESAPID: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewMASRAFID: TcxGridDBColumn
              DataBinding.FieldName = 'MASRAFID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewEKLEYEN: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEYEN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewEKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewDEGISTIREN: TcxGridDBColumn
              DataBinding.FieldName = 'DEGISTIREN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewDEGISTIRMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'DEGISTIRMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object vTableViewTURADI: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TURADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 269
            end
            object vTableViewHESAPKODU: TcxGridDBColumn
              Caption = 'Hesap Kodu'
              DataBinding.FieldName = 'HESAPKODU'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = vTableViewHESAPKODUPropertiesButtonClick
              Width = 75
            end
            object vTableViewHESAPADI: TcxGridDBColumn
              Caption = 'Hesap Ad'#305
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = vTableViewHESAPKODUPropertiesButtonClick
              Width = 185
            end
            object vTableViewMASRAFKODU: TcxGridDBColumn
              Caption = 'Masraf Kodu'
              DataBinding.FieldName = 'MASRAFKODU'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = vTableViewMASRAFKODUPropertiesButtonClick
              Width = 76
            end
            object vTableViewMASRAFADI: TcxGridDBColumn
              Caption = 'Masraf Ad'#305
              DataBinding.FieldName = 'MASRAFADI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = vTableViewMASRAFKODUPropertiesButtonClick
              Width = 185
            end
            object vTableViewDEGER: TcxGridDBColumn
              DataBinding.FieldName = 'DEGER'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object vLevel1: TcxGridLevel
            GridView = vTableView
          end
        end
        object ToolBar6: TToolBar
          Left = 0
          Top = 0
          Width = 1055
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
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
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          GradientEndColor = 11776947
          GradientStartColor = 14540253
          HotTrackColor = 65408
          Images = Tablo.PNGImageList2
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 1
          Transparent = True
          object ToolButton11: TToolButton
            Left = 0
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsTextButton
            Visible = False
            OnClick = ToolButton11Click
          end
          object ToolButton13: TToolButton
            Left = 62
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            Style = tbsTextButton
            Visible = False
            OnClick = ToolButton13Click
          end
        end
      end
    end
    object ToolBar2: TToolBar
      AlignWithMargins = True
      Left = 9
      Top = 9
      Width = 1057
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 86
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
      TabOrder = 2
      Transparent = True
      ExplicitHeight = 29
      object EkleTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 7
        ImageName = 'PngImage6'
        OnClick = EkleTusClick
      end
      object SilTus: TToolButton
        Left = 86
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        ImageName = 'PngImage7'
        OnClick = SilTusClick
      end
      object KaydetTus: TToolButton
        Left = 172
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 10
        ImageName = 'PngImage9'
        Style = tbsTextButton
        OnClick = KaydetTusClick
      end
      object IptalTus: TToolButton
        Left = 258
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 17
        ImageName = 'PngImage16'
        Style = tbsTextButton
        OnClick = IptalTusClick
      end
      object AnalizTus: TToolButton
        Left = 344
        Top = 0
        Caption = 'Analiz'
        ImageIndex = 22
        ImageName = 'PngImage22'
        OnClick = AnalizTusClick
      end
      object ToolButton1: TToolButton
        Left = 430
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 23
        ImageName = 'PngImage23'
        Style = tbsSeparator
      end
      object AksiyonTus: TToolButton
        Left = 438
        Top = 0
        Caption = 'Aksiyonlar'
        DropdownMenu = PopupMenuAksiyon
        ImageIndex = 1
        ImageName = 'PngImage0'
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 361
    Height = 545
    Align = alLeft
    BevelInner = bvLowered
    BorderWidth = 4
    Caption = 'Panel2'
    TabOrder = 0
    object Panel1: TPanel
      Left = 6
      Top = 6
      Width = 349
      Height = 52
      Align = alTop
      TabOrder = 0
      object Label1: TcxLabel
        Left = 2
        Top = 5
        Caption = 'Ara'
        Transparent = True
      end
      object ToolBar1: TToolBar
        Left = 394
        Top = 12
        Width = 90
        Height = 26
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 83
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esNone
        EdgeOuter = esNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
        ShowCaptions = True
        TabOrder = 4
      end
      object AraKod: TcxTextEdit
        Left = 47
        Top = 3
        TabOrder = 0
        OnKeyUp = AraKodKeyUp
        Width = 143
      end
      object LabelSubeSecimi: TcxLabel
        Left = 196
        Top = 5
        Caption = #350'ube'
        Transparent = True
      end
      object cbSubeSecimi: TcxImageComboBox
        Left = 235
        Top = 3
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        Properties.Items = <>
        Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
        TabOrder = 1
        Width = 111
      end
      object CheckPasif: TcxCheckBox
        Left = 45
        Top = 29
        Caption = 'Pasifleri de g'#246'ster'
        TabOrder = 5
        OnClick = CheckPasifClick
      end
    end
    object cxDBTreeList1: TcxDBTreeList
      Left = 6
      Top = 58
      Width = 349
      Height = 481
      Align = alClient
      Bands = <
        item
          Caption.Text = 'Hesap Plan'#305
        end>
      DataController.DataSource = DtsMasrafListe
      DataController.ParentField = 'ROOTKOD'
      DataController.KeyField = 'SUBKOD'
      DefaultRowHeight = 20
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      LookAndFeel.SkinName = 'LondonLiquidSky'
      Navigator.Buttons.CustomButtons = <>
      OptionsBehavior.IncSearch = True
      OptionsData.Appending = True
      OptionsData.Inserting = True
      OptionsData.CheckHasChildren = False
      OptionsData.SmartRefresh = True
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      PopupMenu = PopupMenu1
      RootValue = -1
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 1
      OnSelectionChanged = cxDBTreeList1SelectionChanged
      object TreeListID: TcxDBTreeListColumn
        Visible = False
        DataBinding.FieldName = 'ID'
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListKOD: TcxDBTreeListColumn
        Caption.Text = 'Kod'
        DataBinding.FieldName = 'KOD'
        Width = 119
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListKOD2: TcxDBTreeListColumn
        Visible = False
        DataBinding.FieldName = 'KOD'
        Position.ColIndex = 3
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListAD: TcxDBTreeListColumn
        Caption.Text = 'Ad'
        DataBinding.FieldName = 'AD'
        Width = 227
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
  end
  object cxSplitter1: TcxSplitter
    AlignWithMargins = True
    Left = 364
    Top = 3
    Width = 8
    Height = 539
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = Panel2
  end
  object TabMasrafGelir: TFDQuery
    BeforeEdit = TabMasrafGelirBeforeEdit
    BeforePost = TabMasrafGelirBeforePost
    AfterPost = TabMasrafGelirAfterPost
    BeforeDelete = TabMasrafGelirBeforeDelete
    AfterDelete = TabMasrafGelirAfterDelete
    OnNewRecord = TabMasrafGelirNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from MASRAFGELIR where ID = :PID')
    Left = 99
    Top = 325
  end
  object DtsMasrafGelir: TDataSource
    DataSet = TabMasrafGelir
    OnStateChange = DtsMasrafGelirStateChange
    Left = 33
    Top = 343
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 64
    Top = 155
    object KasaYenileMenu: TMenuItem
      Caption = 'Sadece Bu Kasan'#305'n Toplamlar'#305'n'#305' Yenile'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object BtnKasalarnToplamlarnYenile1: TMenuItem
      Caption = 'B'#252't'#252'n Kasalar'#305'n Toplamlar'#305'n'#305' Yenile'
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object AcilisFisiGirMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir/De'#287'i'#351'tir'
      OnClick = AcilisFisiGirMenuClick
    end
    object Cizgi3: TMenuItem
      Caption = '-'
      Visible = False
    end
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala1Click
    end
    object TumunuKopyala: TMenuItem
      Tag = 4
      Caption = 'T'#252'm'#252'n'#252' Kopyala'
      Visible = False
      OnClick = TumunuKopyalaClick
    end
    object SecilileriKopyala: TMenuItem
      Tag = 5
      Caption = 'Se'#231'ili Olanlar'#305' Kopyala'
      Visible = False
      OnClick = TumunuKopyalaClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Exceldenverial1: TMenuItem
      Caption = 'Excelden Veri Al'
      OnClick = Exceldenverial1Click
    end
    object ExceleGnderMenu: TMenuItem
      Caption = 'Excel'#39'e G'#246'nder'
      OnClick = ExceleGnderMenuClick
    end
  end
  object TabButce: TFDQuery
    AfterOpen = TabButceAfterOpen
    BeforePost = TabButceBeforePost
    OnNewRecord = TabButceNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * '
      'from BUTCE '
      'where MASRAFID =:PrmMID and YIL=:PrmYil'
      'order by AY')
    Left = 50
    Top = 228
  end
  object DtsButce: TDataSource
    DataSet = TabButce
    OnStateChange = DtsButceStateChange
    Left = 103
    Top = 268
  end
  object MASRAFGELIR: TFDQuery
    Connection = Tablo.FDCnn
    Left = 229
    Top = 119
  end
  object DtsMasrafListe: TDataSource
    DataSet = MASRAFGELIR
    OnStateChange = DtsMasrafGelirStateChange
    Left = 125
    Top = 117
  end
  object TabFiyatlar: TFDQuery
    AfterOpen = TabFiyatlarAfterOpen
    BeforeEdit = TabFiyatlarBeforeEdit
    OnNewRecord = TabFiyatlarNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select * From FIYATLAR where HIZMETID = :PHId and SATIS=:PAlSat ' +
        'order by FIYATADI')
    Left = 240
    Top = 198
  end
  object DtsFiyatlar: TDataSource
    DataSet = TabFiyatlar
    OnStateChange = DtsFiyatlarStateChange
    Left = 296
    Top = 198
  end
  object PopupMenuFiyat: TPopupMenu
    Left = 224
    Top = 257
    object FiyatAdListesi1: TMenuItem
      Caption = 'Fiyat Ad Listesi'
      OnClick = FiyatAdListesi1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object YeniFiyatOlutur1: TMenuItem
      Caption = 'Yeni Fiyat Olu'#351'tur'
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object FiyatKopyala: TMenuItem
      Caption = 'Fiyat'#305'n'#305' Kopyala'
      ImageIndex = 20
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object FiyatAdiniDegistir: TMenuItem
      Caption = 'Fiyat'#305'n'#305'n Ad'#305'n'#305' De'#287'i'#351'tir'
      ImageIndex = 8
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object FiyatSil: TMenuItem
      Caption = 'Fiyat'#305'n'#305' Sil'
      ImageIndex = 2
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object MiktarArtma: TMenuItem
      Caption = 'Fiyat'#305' Miktar Art'#305'r'
      Hint = 'Artma'
    end
    object MiktarAzaltma: TMenuItem
      Caption = 'Fiyat'#305' Miktar Azalt'
      Hint = 'Azaltma'
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object YuzdeArtma: TMenuItem
      Caption = 'Fiyat'#305' % x Art'#305'r'
      Hint = 'Artma'
    end
    object YuzdeAzaltma: TMenuItem
      Caption = 'Fiyat'#305' % x Azalt'
      Hint = 'Azaltma'
    end
  end
  object pmdb: TPopupMenu
    Left = 286
    Top = 413
    object Sil1: TMenuItem
      Caption = 'Sil'
    end
  end
  object DtsCariListe: TDataSource
    DataSet = TabCariListe
    Left = 1015
    Top = 329
  end
  object TabCariListe: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select CEKID=ID,TARIH,TUR, REHBERID,  CARIKOD AS KOD, CARIUNVAN ' +
        'AS AD, ACIKLAMA=NOTLAR, HESAPID, HESAPKODU, HESAPADI,DURUM, '
      
        '   BORC = case when TUR in(33,34) then cast(TUTAR as money) else' +
        ' 0 end, '
      
        '    ALACAK= case when TUR in(23,24) then cast(TUTAR as money) el' +
        'se 0 end,KUR From CEKLER (NOLOCK) ')
    Left = 948
    Top = 329
  end
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = TabCariListe
    BCDToCurrency = False
    DataSetOptions = []
    Left = 750
    Top = 269
  end
  object PopupMenuYaz: TPopupMenu
    Left = 856
    Top = 370
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
    object MenuItem1: TMenuItem
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
      object MenuItem3: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object MenuItem4: TMenuItem
      Caption = '-'
    end
  end
  object frxMASRAFGELIR: TfrxDBDataset
    UserName = 'MASRAFGELIR'
    CloseDataSource = False
    DataSet = MASRAFGELIR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 660
    Top = 254
  end
  object PopupMenuButce: TPopupMenu
    Left = 750
    Top = 357
    object GerceklesenaylaragorebutceplanlaMenu: TMenuItem
      Caption = 'Ger'#231'ekle'#351'en aylara g'#246're b'#252't'#231'e planla'
      OnClick = GerceklesenaylaragorebutceplanlaMenuClick
    end
    object Butungerceklesenlerigetir1: TMenuItem
      Caption = 'B'#252't'#252'n ger'#231'ekle'#351'enleri getir'
      OnClick = Butungerceklesenlerigetir1Click
    end
  end
  object PopupMenuAksiyon: TPopupMenu
    OnPopup = PopupMenuAksiyonPopup
    Left = 430
    Top = 293
    object DemirbasKartiniAcMenu: TMenuItem
      Caption = 'Demirba'#351' Kart'#305'n'#305' A'#231
      OnClick = DemirbasKartiniAcMenuClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object BuKartinDemirbasOlusturMenu: TMenuItem
      Caption = 'Bu Kart '#304#231'in Demirba'#351' Olu'#351'tur'
      OnClick = BuKartinDemirbasOlusturMenuClick
    end
    object VarolanDemirbasiBuKartaBaglaMenu: TMenuItem
      Caption = 'Varolan Demirba'#351#305' Bu Karta Ba'#287'la'
      OnClick = VarolanDemirbasiBuKartaBaglaMenuClick
    end
    object DemirbasBaglantsiniKoparMenu: TMenuItem
      Caption = 'Demirba'#351' Ba'#287'lant'#305's'#305'n'#305' Kopar'
      OnClick = DemirbasBaglantsiniKoparMenuClick
    end
  end
  object TabStokMuhasebe: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT G.DEGER, SM.*,HP.HESAPKODU,HP.HESAPADI,MASRAFKODU=MG.KOD,' +
        'MASRAFADI=MG.AD,TURADI=G.ANAHTAR'
      
        'FROM MUHASEBEKOD SM LEFT OUTER JOIN dbo.GENINI G ON SM.MUHASEBEI' +
        'D=G.DEGER AND G.BOLUM=-2755'
      #9'LEFT OUTER JOIN dbo.HESAPPLANI HP ON SM.HESAPID=HP.ID'
      #9'LEFT OUTER JOIN dbo.MASRAFGELIR MG ON SM.MASRAFID=MG.ID'
      'WHERE SM.YER=58 and SM.YER_ID=:prm1')
    Left = 832
    Top = 272
  end
  object DtsStokMuhasebe: TDataSource
    DataSet = TabStokMuhasebe
    OnStateChange = DtsStokMuhasebeStateChange
    Left = 832
    Top = 320
  end
  object DtsYDil: TDataSource
    DataSet = TabYDil
    OnStateChange = DtsYDilStateChange
    Left = 605
    Top = 418
  end
  object TabYDil: TFDQuery
    BeforePost = TabYDilBeforePost
    OnNewRecord = TabYDilNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM YDIL'
      'WHERE'
      'YER=:PYER'
      'and'
      'YERID=:PYERID')
    Left = 605
    Top = 359
  end
end
