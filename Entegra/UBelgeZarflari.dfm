object BelgeZarflariDlg: TBelgeZarflariDlg
  Left = 0
  Top = 0
  Caption = 'Belge Zarflari'
  ClientHeight = 621
  ClientWidth = 1086
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = JvSplitter1Moved
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object JvSplitter1: TJvSplitter
    Left = 326
    Top = 0
    Width = 8
    Height = 621
    Beveled = True
    OnMoved = JvSplitter1Moved
    ExplicitLeft = -4
    ExplicitTop = -16
  end
  object PanelZarfSecimi: TPanel
    Left = 0
    Top = 0
    Width = 326
    Height = 621
    Align = alLeft
    TabOrder = 0
    object GridZarflar: TcxGrid
      Left = 1
      Top = 110
      Width = 324
      Height = 510
      Align = alClient
      TabOrder = 0
      object GridZarflarDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        Navigator.Buttons.First.Visible = True
        Navigator.Buttons.PriorPage.Visible = True
        Navigator.Buttons.Prior.Visible = True
        Navigator.Buttons.Next.Visible = True
        Navigator.Buttons.NextPage.Visible = True
        Navigator.Buttons.Last.Visible = True
        Navigator.Buttons.Insert.Visible = True
        Navigator.Buttons.Append.Visible = False
        Navigator.Buttons.Delete.Visible = True
        Navigator.Buttons.Edit.Visible = True
        Navigator.Buttons.Post.Visible = True
        Navigator.Buttons.Cancel.Visible = True
        Navigator.Buttons.Refresh.Visible = True
        Navigator.Buttons.SaveBookmark.Visible = True
        Navigator.Buttons.GotoBookmark.Visible = True
        Navigator.Buttons.Filter.Visible = True
        OnCellDblClick = GridZarflarDBTableView1CellDblClick
        DataController.DataSource = DtsZarflar
        DataController.Filter.Options = [fcoCaseInsensitive, fcoIgnoreNull]
        DataController.Filter.Active = True
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        FilterRow.ApplyChanges = fracDelayed
        FilterRow.ApplyInputDelay = 600
        OptionsBehavior.FocusCellOnCycle = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.CellAutoHeight = True
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        object GridZarflarDBTableView1AD: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'AD'
          Width = 84
        end
        object GridZarflarDBTableView1ACIKLAMA: TcxGridDBColumn
          DataBinding.FieldName = 'ACIKLAMA'
          Width = 158
        end
      end
      object GridZarflarLevel1: TcxGridLevel
        GridView = GridZarflarDBTableView1
      end
    end
    object ToolBar1: TToolBar
      Left = 1
      Top = 64
      Width = 324
      Height = 24
      Margins.Bottom = 0
      ButtonWidth = 106
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
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'Yeni    '
        ImageIndex = 0
        OnClick = ToolButton1Click
      end
      object ToolButton2: TToolButton
        Left = 64
        Top = 0
        AutoSize = True
        Caption = 'Sil       '
        ImageIndex = 1
        OnClick = ToolButton2Click
      end
      object TumunuHesaplaBtn: TToolButton
        Left = 126
        Top = 0
        AutoSize = True
        Caption = 'T'#252'm'#252'n'#252' Hesapla'
        ImageIndex = 9
        OnClick = TumunuHesaplaBtnClick
      end
    end
    object JvPanel1: TJvPanel
      Left = 1
      Top = 1
      Width = 324
      Height = 63
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      FlatBorder = True
      Align = alTop
      BorderWidth = 1
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object Label2: TLabel
        Left = 9
        Top = 39
        Width = 168
        Height = 13
        Caption = #304#351'lem Yap'#305'lacak Zarf'#305' Se'#231'iniz.'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object Label3: TLabel
        Left = 9
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Zarflar'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object JvNavPanelButton2: TJvNavPanelButton
        Left = 603
        Top = 11
        Width = 43
        Height = 40
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -12
        HotTrackFont.Name = 'Segoe UI'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        ImageIndex = 0
      end
    end
    object Panel1: TPanel
      Left = 1
      Top = 88
      Width = 324
      Height = 22
      Align = alTop
      TabOrder = 3
      object EditAd: TcxTextEdit
        Left = 20
        Top = 0
        Properties.OnEditValueChanged = EditAdPropertiesEditValueChanged
        TabOrder = 0
        OnKeyUp = EditAciklamaKeyUp
        Width = 121
      end
      object EditAciklama: TcxTextEdit
        Left = 191
        Top = 0
        Properties.OnEditValueChanged = EditAdPropertiesEditValueChanged
        TabOrder = 1
        OnKeyUp = EditAciklamaKeyUp
        Width = 121
      end
      object cxLabel1: TcxLabel
        Left = 5
        Top = 1
        Caption = 'Ad'
      end
      object cxLabel2: TcxLabel
        Left = 147
        Top = 1
        Caption = 'A'#231#305'klama'
      end
    end
  end
  object Panel2: TPanel
    Left = 334
    Top = 0
    Width = 752
    Height = 621
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 731
    object JvSplitter2: TJvSplitter
      Left = 1
      Top = 312
      Width = 750
      Height = 6
      Cursor = crVSplit
      Align = alTop
      ExplicitWidth = 726
    end
    object ToolBar5: TToolBar
      Left = 1
      Top = 64
      Width = 750
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 59
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
      TabOrder = 0
      Transparent = True
      ExplicitWidth = 729
      object BelgeEkleTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Ekle'
        ImageIndex = 4
        OnClick = BelgeEkleTusClick
      end
      object BelgeSilTus: TToolButton
        Left = 59
        Top = 0
        Caption = #199#305'kart'
        ImageIndex = 5
        OnClick = BelgeSilTusClick
      end
      object YaziciYaz: TToolButton
        Left = 118
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 8
      end
    end
    object GridFatBasliklar: TcxGrid
      Left = 1
      Top = 88
      Width = 750
      Height = 224
      Align = alTop
      TabOrder = 1
      ExplicitWidth = 729
      object GridFatBasliklarDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        Navigator.Buttons.First.Visible = True
        Navigator.Buttons.PriorPage.Visible = True
        Navigator.Buttons.Prior.Visible = True
        Navigator.Buttons.Next.Visible = True
        Navigator.Buttons.NextPage.Visible = True
        Navigator.Buttons.Last.Visible = True
        Navigator.Buttons.Insert.Visible = True
        Navigator.Buttons.Append.Visible = False
        Navigator.Buttons.Delete.Visible = True
        Navigator.Buttons.Edit.Visible = True
        Navigator.Buttons.Post.Visible = True
        Navigator.Buttons.Cancel.Visible = True
        Navigator.Buttons.Refresh.Visible = True
        Navigator.Buttons.SaveBookmark.Visible = True
        Navigator.Buttons.GotoBookmark.Visible = True
        Navigator.Buttons.Filter.Visible = True
        DataController.DataSource = DtsZarfFatBaslik
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnCycle = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.CellAutoHeight = True
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        object GridFatBasliklarDBTableView1TUR: TcxGridDBColumn
          Caption = 'T'#252'r'
          DataBinding.FieldName = 'TUR'
          RepositoryItem = Tablo.RepKasaTurleri
          Width = 85
        end
        object GridFatBasliklarDBTableView1FIRMA: TcxGridDBColumn
          Caption = 'Firma'
          DataBinding.FieldName = 'FIRMA'
          Width = 164
        end
        object GridFatBasliklarDBTableView1FATURATARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'FATURATARIH'
          Width = 123
        end
        object GridFatBasliklarDBTableView1FATURASERI: TcxGridDBColumn
          Caption = 'Seri'
          DataBinding.FieldName = 'FATURASERI'
          Width = 23
        end
        object GridFatBasliklarDBTableView1FATURANO: TcxGridDBColumn
          Caption = 'Belge No'
          DataBinding.FieldName = 'FATURANO'
          Width = 140
        end
        object GridFatBasliklarDBTableView1FATURA_TUTARI: TcxGridDBColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'FATURA_TUTARI'
          Width = 114
        end
        object GridFatBasliklarDBTableView1KUR: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'KUR'
          Width = 42
        end
        object GridFatBasliklarDBTableView1OZELKOD: TcxGridDBColumn
          Caption = #214'zel Kod'
          DataBinding.FieldName = 'OZELKOD'
          Width = 45
        end
      end
      object GridFatBasliklarLevel1: TcxGridLevel
        GridView = GridFatBasliklarDBTableView1
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 318
      Width = 750
      Height = 302
      Align = alClient
      TabOrder = 2
      ExplicitWidth = 729
      object ToolBar2: TToolBar
        Left = 1
        Top = 1
        Width = 748
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 65
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
        TabOrder = 0
        Transparent = True
        ExplicitWidth = 727
        object HesaplaTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Hesapla'
          ImageIndex = 9
          OnClick = HesaplaTusClick
        end
      end
      object GridHizmetler: TcxGrid
        Left = 385
        Top = 25
        Width = 364
        Height = 276
        Align = alClient
        TabOrder = 1
        ExplicitWidth = 343
        object GridHizmetlerDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = True
          Navigator.Buttons.PriorPage.Visible = True
          Navigator.Buttons.Prior.Visible = True
          Navigator.Buttons.Next.Visible = True
          Navigator.Buttons.NextPage.Visible = True
          Navigator.Buttons.Last.Visible = True
          Navigator.Buttons.Insert.Visible = True
          Navigator.Buttons.Append.Visible = False
          Navigator.Buttons.Delete.Visible = True
          Navigator.Buttons.Edit.Visible = True
          Navigator.Buttons.Post.Visible = True
          Navigator.Buttons.Cancel.Visible = True
          Navigator.Buttons.Refresh.Visible = True
          Navigator.Buttons.SaveBookmark.Visible = True
          Navigator.Buttons.GotoBookmark.Visible = True
          Navigator.Buttons.Filter.Visible = True
          OnCustomDrawCell = GridStoklarDBTableView2CustomDrawCell
          DataController.DataSource = DtsZarfHizmetler
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skSum
              Column = GridHizmetlerDBTableView1TUTAR
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
          OptionsView.CellAutoHeight = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object GridHizmetlerDBTableView1FATBASID: TcxGridDBColumn
            DataBinding.FieldName = 'FATBASID'
            Visible = False
          end
          object GridHizmetlerDBTableView1KOD: TcxGridDBColumn
            Caption = 'Hizmet Kod'
            DataBinding.FieldName = 'KOD'
            Width = 62
          end
          object GridHizmetlerDBTableView1AD: TcxGridDBColumn
            Caption = 'Hizmet Ad'#305
            DataBinding.FieldName = 'AD'
            Width = 111
          end
          object GridHizmetlerDBTableView1MIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 36
          end
          object GridHizmetlerDBTableView1TUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 66
          end
          object GridHizmetlerDBTableView1KUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            Width = 23
          end
          object GridHizmetlerDBTableView1ZARFMALIYETDURUMU: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'ZARFMALIYETDURUMU'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 36
          end
        end
        object GridHizmetlerLevel1: TcxGridLevel
          GridView = GridHizmetlerDBTableView1
        end
      end
      object GridStoklar: TcxGrid
        Left = 1
        Top = 25
        Width = 384
        Height = 276
        Align = alLeft
        TabOrder = 2
        object GridStoklarDBTableView2: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = True
          Navigator.Buttons.PriorPage.Visible = True
          Navigator.Buttons.Prior.Visible = True
          Navigator.Buttons.Next.Visible = True
          Navigator.Buttons.NextPage.Visible = True
          Navigator.Buttons.Last.Visible = True
          Navigator.Buttons.Insert.Visible = True
          Navigator.Buttons.Append.Visible = False
          Navigator.Buttons.Delete.Visible = True
          Navigator.Buttons.Edit.Visible = True
          Navigator.Buttons.Post.Visible = True
          Navigator.Buttons.Cancel.Visible = True
          Navigator.Buttons.Refresh.Visible = True
          Navigator.Buttons.SaveBookmark.Visible = True
          Navigator.Buttons.GotoBookmark.Visible = True
          Navigator.Buttons.Filter.Visible = True
          OnCustomDrawCell = GridStoklarDBTableView2CustomDrawCell
          DataController.DataSource = DtsZarfStoklar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skSum
              Column = GridStoklarDBTableView2TUTAR
            end
            item
              Kind = skSum
              Column = GridStoklarDBTableView2EKMALIYET
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
          OptionsView.CellAutoHeight = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object GridStoklarDBTableView2FATBASID: TcxGridDBColumn
            DataBinding.FieldName = 'FATBASID'
            Visible = False
          end
          object GridStoklarDBTableView2KOD: TcxGridDBColumn
            Caption = 'Stok Kod'
            DataBinding.FieldName = 'KOD'
          end
          object GridStoklarDBTableView2STOKADI: TcxGridDBColumn
            Caption = 'Stok Ad'#305
            DataBinding.FieldName = 'STOKADI'
            Width = 160
          end
          object GridStoklarDBTableView2MIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 38
          end
          object GridStoklarDBTableView2TUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 75
          end
          object GridStoklarDBTableView2EKMALIYET: TcxGridDBColumn
            Caption = 'Ek Maliyet'
            DataBinding.FieldName = 'EKMALIYET'
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 74
          end
          object GridStoklarDBTableView2BIRIMMALIYET: TcxGridDBColumn
            Caption = 'Birim Maliyet'
            DataBinding.FieldName = 'BIRIMMALIYET'
            RepositoryItem = Tablo.RepCurrencyGenel
          end
          object GridStoklarDBTableView2KUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            Width = 23
          end
        end
        object GridStoklarLevel2: TcxGridLevel
          GridView = GridStoklarDBTableView2
        end
      end
    end
    object UstPanel: TJvPanel
      Left = 1
      Top = 1
      Width = 750
      Height = 63
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      FlatBorder = True
      Align = alTop
      BorderWidth = 1
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      ExplicitWidth = 729
      object Label1: TLabel
        Left = 9
        Top = 39
        Width = 191
        Height = 13
        Caption = 'Zarf '#304#231'eri'#287'indeki Fatura ve Fi'#351'ler.'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object BaslikLabel: TLabel
        Left = 9
        Top = 8
        Width = 92
        Height = 25
        Caption = 'Belgeler'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object TabZarfFatBaslik: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabZarfFatBaslikAfterScroll
    AfterScroll = TabZarfFatBaslikAfterScroll
    ParamData = <>
    SQL.Strings = (
      
        'select FB.*,R.FIRMA,TURADI=(select ANAHTAR from GENINI where BOL' +
        'UM=-1005 and DIL=-1 and DEGER=FB.TUR) from FATBASLIK FB inner jo' +
        'in REHBER R on FB.REHBERID=R.ID where ZARFID=:PID')
    Left = 472
    Top = 99
  end
  object DtsZarfFatBaslik: TDataSource
    DataSet = TabZarfFatBaslik
    Left = 472
    Top = 151
  end
  object TabZarflar: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabZarflarAfterScroll
    AfterScroll = TabZarflarAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select BZ.* from BELGEZARFI BZ '
      '')
    Left = 400
    Top = 98
  end
  object DtsZarflar: TDataSource
    DataSet = TabZarflar
    Left = 399
    Top = 151
  end
  object TabZarfStoklar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select F.* ,S.KOD,S.STOKADI,BIRIMMALIYET=(F.TUTAR+F.EKMALIYET)/F' +
        '.MIKTAR'
      
        'from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID inner ' +
        'join STOKLAR S on S.ID=F.URUNID'
      'where FB.ZARFID=:PZarfID and F.TUR=1')
    Left = 576
    Top = 115
  end
  object DtsZarfStoklar: TDataSource
    DataSet = TabZarfStoklar
    Left = 576
    Top = 167
  end
  object TabZarfHizmetler: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select F.* ,M.KOD,M.AD,M.ZARFMALIYETDURUMU'
      
        'from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID inner ' +
        'join MASRAFGELIR M on M.ID=F.URUNID'
      'where FB.ZARFID=:PZarfID and F.TUR<>1')
    Left = 656
    Top = 115
  end
  object DtsZarfHizmetler: TDataSource
    DataSet = TabZarfHizmetler
    Left = 656
    Top = 167
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 745
    Top = 136
  end
  object PopupMenuYaz: TPopupMenu
    Left = 829
    Top = 138
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YaziciyaYazdirMenu: TMenuItem
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
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxZarflar: TfrxDBDataset
    Description = 'Zarflar'
    UserName = 'Zarflar'
    CloseDataSource = False
    DataSet = TabZarflar
    BCDToCurrency = False
    Left = 400
    Top = 208
  end
  object frxZarfFatBaslik: TfrxDBDataset
    Description = 'ZarfFatBaslik'
    UserName = 'ZarfFatBaslik'
    CloseDataSource = False
    DataSet = TabZarfFatBaslik
    BCDToCurrency = False
    Left = 472
    Top = 208
  end
  object frxZarfStoklar: TfrxDBDataset
    Description = 'ZarfStoklar'
    UserName = 'ZarfStoklar'
    CloseDataSource = False
    DataSet = TabZarfStoklar
    BCDToCurrency = False
    Left = 576
    Top = 216
  end
  object frxZarfHizmetler: TfrxDBDataset
    Description = 'ZarfHizmetler'
    UserName = 'ZarfHizmetler'
    CloseDataSource = False
    DataSet = TabZarfHizmetler
    BCDToCurrency = False
    Left = 656
    Top = 216
  end
end
