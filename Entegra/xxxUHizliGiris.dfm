object HizliGirisDlg: THizliGirisDlg
  Left = 49
  Top = 55
  BorderStyle = bsNone
  Caption = 'H'#305'zl'#305' Giri'#351
  ClientHeight = 847
  ClientWidth = 1289
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poDesigned
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 1289
    Height = 37
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clGray
    ColorTo = clBlack
    ImageIndex = 0
    DesignSize = (
      1289
      37)
    object KapatTus: TJvNavPanelButton
      Left = 1209
      Top = 0
      Width = 80
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = KapatTusClick
      ExplicitLeft = 1202
    end
    object KaydetTus: TJvNavPanelButton
      Left = 1122
      Top = 0
      Width = 87
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Kaydet'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Visible = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = KaydetTusClick
      ExplicitLeft = 1001
      ExplicitTop = -1
    end
    object YaziciYaz: TJvNavPanelButton
      Left = 986
      Top = 0
      Width = 136
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Yazd'#305'r'
      DropDownMenu = PopupMenuYaz
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 16
      ExplicitLeft = 865
    end
    object AksiyonTus: TJvNavPanelButton
      Left = 906
      Top = 0
      Width = 80
      Height = 37
      Align = alRight
      Alignment = taCenter
      AllowAllUp = True
      Caption = 'Aksiyon'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Visible = False
      WordWrap = True
      Colors.ButtonColorFrom = clRed
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = AksiyonTusClick
      ExplicitLeft = 621
      ExplicitTop = -5
    end
    object cxLabel9: TcxLabel
      Left = 6
      Top = 2
      Caption = 'Gentegre'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -24
      Style.Font.Name = 'Magneto'
      Style.Font.Style = [fsBold, fsItalic]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Transparent = True
    end
    object cxLabel10: TcxLabel
      Left = 132
      Top = 1
      Caption = 'ERP'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWhite
      Style.Font.Height = -24
      Style.Font.Name = 'Maiandra GD'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Transparent = True
    end
    object EditRehAd: TcxLabel
      Left = 333
      Top = 6
      AutoSize = False
      Caption = '---'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clSilver
      Style.Font.Height = -16
      Style.Font.Name = 'Arial Narrow'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Properties.Alignment.Horz = taRightJustify
      Transparent = True
      OnMouseUp = EditRehAdMouseUp
      Height = 24
      Width = 340
      AnchorX = 673
    end
    object lbKullanici: TcxLabel
      Left = 190
      Top = 8
      Align = alCustom
      Caption = 'lbKullanici'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clSilver
      Style.Font.Height = -13
      Style.Font.Name = 'Arial'
      Style.Font.Style = [fsBold, fsItalic]
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      Properties.Alignment.Horz = taRightJustify
      Properties.WordWrap = True
      Transparent = True
      OnClick = lbKullaniciDblClick
      Width = 137
      AnchorX = 327
    end
    object EditRehID: TcxTextEdit
      AlignWithMargins = True
      Left = 191
      Top = 12
      Anchors = [akRight, akBottom]
      AutoSize = False
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Properties.ClearKey = 8238
      Style.Color = clInfoBk
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      StyleDisabled.Color = clInfoBk
      TabOrder = 9
      Visible = False
      OnKeyUp = StokAraKeyUp
      Height = 19
      Width = 12
    end
    object EditRehKod: TcxTextEdit
      AlignWithMargins = True
      Left = 224
      Top = 12
      Anchors = [akRight, akBottom]
      AutoSize = False
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Properties.ClearKey = 8238
      Style.Color = clInfoBk
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      StyleDisabled.Color = clInfoBk
      TabOrder = 4
      Visible = False
      OnKeyUp = StokAraKeyUp
      Height = 19
      Width = 16
    end
    object LabelMasa: TcxLabel
      Left = 707
      Top = 5
      Caption = 'Masa'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clSilver
      Style.Font.Height = -16
      Style.Font.Name = 'Arial Narrow'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Properties.Alignment.Horz = taLeftJustify
      Transparent = True
      Visible = False
    end
    object EditMasa: TcxLabel
      Left = 749
      Top = 6
      Caption = '---'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clSilver
      Style.Font.Height = -16
      Style.Font.Name = 'Arial Narrow'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Properties.Alignment.Horz = taLeftJustify
      Transparent = True
      Visible = False
    end
    object LabelKisi: TcxLabel
      Left = 796
      Top = 6
      Caption = 'Ki'#351'i'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clSilver
      Style.Font.Height = -16
      Style.Font.Name = 'Arial Narrow'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Properties.Alignment.Horz = taLeftJustify
      Transparent = True
      Visible = False
    end
    object EditKisi: TcxLabel
      Left = 838
      Top = 6
      Caption = '---'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clSilver
      Style.Font.Height = -16
      Style.Font.Name = 'Arial Narrow'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Properties.Alignment.Horz = taLeftJustify
      Transparent = True
      Visible = False
      OnClick = EditKisiClick
    end
    object cxLabel1: TcxLabel
      Left = 672
      Top = 6
      Caption = '---'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clSilver
      Style.Font.Height = -16
      Style.Font.Name = 'Arial Narrow'
      Style.Font.Style = [fsBold]
      Style.LookAndFeel.Kind = lfOffice11
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.Kind = lfOffice11
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfOffice11
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfOffice11
      StyleHot.LookAndFeel.NativeStyle = True
      Properties.Alignment.Horz = taLeftJustify
      Transparent = True
      OnMouseUp = cxLabel1MouseUp
    end
  end
  object PanelSol: TPanel
    Left = 0
    Top = 37
    Width = 387
    Height = 791
    Align = alLeft
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object cxGridFatura: TcxGrid
      Left = 0
      Top = 0
      Width = 387
      Height = 477
      Align = alClient
      TabOrder = 0
      TabStop = False
      DragOpening = False
      object cxGridFaturaDBCardView1: TcxGridDBCardView
        OnDblClick = cxGridFaturaDBCardView1DblClick
        OnKeyDown = FormKeyDown
        Navigator.Buttons.CustomButtons = <>
        FilterBox.CustomizeDialog = False
        OnCustomDrawCell = cxGridFaturaDBCardView1CustomDrawCell
        DataController.DataSource = DtsDetay
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        Filtering.MRUItemsList = False
        Filtering.RowMRUItemsList = False
        LayoutDirection = ldVertical
        OptionsBehavior.DragHighlighting = False
        OptionsBehavior.DragOpening = False
        OptionsBehavior.DragScrolling = False
        OptionsBehavior.ExpandRowOnDblClick = False
        OptionsCustomize.CardSizing = False
        OptionsCustomize.RowExpanding = False
        OptionsCustomize.RowFiltering = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.InvertSelect = False
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.CellEndEllipsis = True
        OptionsView.ScrollBars = ssVertical
        OptionsView.CardBorderWidth = 1
        OptionsView.CardIndent = 7
        OptionsView.CardWidth = 380
        OptionsView.CategorySeparatorWidth = 0
        OptionsView.CellAutoHeight = True
        OptionsView.SeparatorColor = clActiveCaption
        OptionsView.SeparatorWidth = 0
        RowLayout = rlVertical
        object cxGridFaturaDBCardView1IMAJ: TcxGridDBCardViewRow
          DataBinding.FieldName = 'RESIM'
          PropertiesClassName = 'TcxImageProperties'
          Properties.GraphicClassName = 'TJPEGImage'
          Options.Editing = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.LineCount = 3
          Position.Width = 75
        end
        object cxGridFaturaDBCardView1AD: TcxGridDBCardViewRow
          Caption = #220'r'#252'n Ad'#305
          DataBinding.FieldName = 'AD'
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.Width = 225
        end
        object cxGridFaturaDBCardView1ACIKLAMA: TcxGridDBCardViewRow
          DataBinding.FieldName = 'ACIKLAMA'
          Options.ShowCaption = False
          Position.BeginsLayer = False
          IsCaptionAssigned = True
        end
        object cxGridFaturaDBCardView1TUTAR: TcxGridDBCardViewRow
          Caption = 'Tutar'
          DataBinding.FieldName = 'TUTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(,0.00)'
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.Width = 100
        end
        object cxGridFaturaDBCardView1KUR: TcxGridDBCardViewRow
          DataBinding.FieldName = 'KUR'
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.Width = 50
        end
        object cxGridFaturaDBCardView1DURUM: TcxGridDBCardViewRow
          DataBinding.FieldName = 'DURUM'
          Visible = False
          Position.BeginsLayer = False
        end
      end
      object cxGridFaturaLevel1: TcxGridLevel
        Caption = 'Sat'#305#351'taki '#220'r'#252'nler'
        GridView = cxGridFaturaDBCardView1
      end
    end
    object MemoStoklarANABIRIM: TMemo
      Left = 11
      Top = 103
      Width = 677
      Height = 39
      Lines.Strings = (
        'declare @Adet Float'
        'declare @SIskonto Float'
        ''
        ''
        ''
        'set @Adet=:PAdet'
        'set @SIskonto=:PSIskonto'
        ''
        ''
        ''
        'select '
        #9'S.ID,'
        #9'S.KOD,'
        #9'AD=S.STOKADI,'
        'S.KATEGORI,'
        #9'TUR=1,'
        #9'ADET=@Adet,'
        #9'BIRIM,'
        #9'MIKTAR=@Adet,'
        'DOVIZKURUDEGERI=case when F.KUR='#39'TL'#39' then 1 else '
        
          '  (select top 1 isnull((&Kur),1) from DOVIZ where CINSI=F.KUR an' +
          'd TARIH<GETDATE() order by TARIH desc )end,'
        'BIRIMFIYAT=case when F.KUR='#39'TL'#39' then round(F.FIYAT,2) else '
        
          '  round(F.FIYAT*(select top 1 isnull((&Kur),1) from DOVIZ where ' +
          'CINSI=F.KUR and TARIH<GETDATE() order by TARIH desc ),2)end,'
        
          'TUTAR=case when F.KUR='#39'TL'#39' then round((@Adet*F.FIYAT)*((100-@SIs' +
          'konto)/100),2) else '
        
          '  round((@Adet*F.FIYAT)*((100-@SIskonto)/100)*(select top 1 isnu' +
          'll((&Kur),1) from DOVIZ where CINSI=F.KUR and TARIH<GETDATE() or' +
          'der by TARIH desc),2)end, '
        'KUR='#39'TL'#39', '
        #9'S.OZELKOD,'
        #9'DOVIZ_TUTARI=(@Adet*F.FIYAT)*((100-@SIskonto)/100),'
        #9'DOVIZ_KURU=isnull(F.KUR,'#39'TL'#39'),'
        #9'ISKONTO=@SIskonto,'
        #9'ISKONTO2=0,'
        #9'KDV=isnull(KDV,0),'
        #9'DEPO=0,'
        #9'URETICIID,'
        '                URUNKDVDURUM = F.KDVDURUM'
        ''
        'from '
        #9'STOKLAR S left outer join '
        #9#9'STOKFIYAT F on S.ID=F.STOKID and'
        #9#9'F.BIRIM=S.ANABIRIM and'
        #9#9'F.FIYATADI=:PFiyatAdi and'
        #9#9'PAKETID= :PPaketID'
        ''
        ''
        '')
      TabOrder = 3
      Visible = False
      WordWrap = False
    end
    object MemoHizmetler: TMemo
      Left = 200
      Top = 41
      Width = 678
      Height = 39
      Lines.Strings = (
        'declare @Adet Float'
        'declare @SIskonto Float'
        ''
        ''
        'set @Adet=:PAdet'
        'set @SIskonto=:PSIskonto'
        ''
        ''
        ''
        'select '
        #9'M.ID,'
        #9'M.KOD,'
        #9'M.AD,'
        'KATEGORI=NULL,'
        #9'TUR=0,'
        #9'ADET=@Adet,'
        #9'BIRIM=0,'
        #9'BIRIMADI='#39#39','
        #9'MIKTAR=@Adet,'
        'DOVIZKURUDEGERI=case when F.KUR='#39'TL'#39' then 1 else '
        
          '(select top 1 isnull((&Kur),1) from DOVIZ where CINSI=F.KUR and ' +
          'TARIH<GETDATE() order by TARIH desc )end,'
        'BIRIMFIYAT=case when F.KUR='#39'TL'#39' then round(F.FIYAT,2) else '
        
          'round(F.FIYAT*(select top 1 isnull((&Kur),1) from DOVIZ where CI' +
          'NSI=F.KUR and TARIH<GETDATE() order by TARIH desc ),2)end,'
        
          'TUTAR=case when F.KUR='#39'TL'#39' then round((@Adet*F.FIYAT)*((100-@SIs' +
          'konto)/100),2) else '
        
          'round((@Adet*F.FIYAT)*((100-@SIskonto)/100)*(select top 1 isnull' +
          '((&Kur),1) from DOVIZ where CINSI=F.KUR and TARIH<GETDATE() orde' +
          'r by TARIH desc),2)end, '
        'KUR='#39'TL'#39', '
        #9'M.OZELKOD,'
        #9'DOVIZ_TUTARI=(@Adet*F.FIYAT)*((100-@SIskonto)/100),'
        #9'DOVIZ_KURU=isnull(F.KUR,'#39'TL'#39'),'
        #9'ISKONTO=@SIskonto,'
        #9'ISKONTO2=0,'
        #9'KDV=isnull(KDV,0),'
        #9'DEPO=0, URETICIID=null,'
        #9'BARKOD='#39#39','
        #9'URUNKDVDURUM = F.KDVDURUM,'
        #9'RESIM  '#9
        'from '
        #9'MASRAFGELIR M left outer join '
        #9'FIYATLAR F on M.ID=F.HIZMETID and'
        #9'F.FIYATADI=:PFiyatAdi '
        '')
      TabOrder = 1
      Visible = False
      WordWrap = False
    end
    object MemoPaketBul: TMemo
      Left = 26
      Top = 64
      Width = 676
      Height = 38
      Lines.Strings = (
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
        #9'select URUNID=@YerID,STOK=@Stok,ADET=1,PAKETID=0'
        'else'
        
          #9'select URUNID,STOK,ADET,PAKETID from PAKETDETAY where PAKETID=@' +
          'YerID')
      TabOrder = 2
      Visible = False
      WordWrap = False
    end
    object PanelSolAlt: TPanel
      Left = 0
      Top = 477
      Width = 387
      Height = 314
      Align = alBottom
      TabOrder = 5
      object PanelButtomRight: TPanel
        Left = 203
        Top = 51
        Width = 183
        Height = 262
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Align = alRight
        BevelOuter = bvNone
        Color = 14740459
        ParentBackground = False
        TabOrder = 2
        object PanelSiparisSablonlar: TPanel
          Left = 0
          Top = 48
          Width = 183
          Height = 48
          Align = alTop
          Caption = 'PanelSiparisSablonlar'
          TabOrder = 0
          object BtnSiparisler: TJvNavPanelButton
            Left = 171
            Top = 1
            Width = 11
            Height = 46
            Align = alClient
            AllowAllUp = True
            Caption = 'Sipari'#351'ler'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 22
            Images = Tablo.cxImageList1
            OnClick = BtnSiparislerClick
            ExplicitLeft = 103
            ExplicitTop = 3
            ExplicitWidth = 80
          end
          object BtnSiparisTablosu: TJvNavPanelButton
            Left = 86
            Top = 1
            Width = 85
            Height = 46
            Align = alLeft
            AllowAllUp = True
            Caption = 'Sipari'#351' Tablosu'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 22
            Images = Tablo.cxImageList1
            OnClick = BtnSiparisTablosuClick
            ExplicitLeft = 62
            ExplicitTop = 25
          end
          object BtnTeklifler: TJvNavPanelButton
            Left = 1
            Top = 1
            Width = 85
            Height = 46
            Align = alLeft
            AllowAllUp = True
            Caption = 'Teklifler'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 22
            Images = Tablo.cxImageList1
            OnClick = BtnTekliflerClick
            ExplicitLeft = 9
            ExplicitTop = 2
          end
          object Button2: TButton
            Left = 64
            Top = 24
            Width = 75
            Height = 25
            Caption = 'travala'
            TabOrder = 0
          end
        end
        object PanelSil: TPanel
          Left = 0
          Top = 192
          Width = 183
          Height = 48
          Align = alTop
          Caption = 'Panel1'
          TabOrder = 2
          object BtnSecimiSil: TJvNavPanelButton
            Left = 1
            Top = 1
            Width = 80
            Height = 46
            Align = alLeft
            AllowAllUp = True
            Caption = 'Sil'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -13
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 2
            Images = Tablo.cxImageList1
            OnClick = BtnSecimiSilClick
            ExplicitTop = 0
          end
          object BtnTSil: TJvNavPanelButton
            Left = 81
            Top = 1
            Width = 101
            Height = 46
            Align = alClient
            AllowAllUp = True
            Caption = 'T'#252'm'#252' Sil'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 2
            Images = Tablo.cxImageList1
            OnClick = BtnTSilClick
            ExplicitLeft = 78
            ExplicitTop = -3
          end
        end
        object PanelIskonto: TPanel
          Left = 0
          Top = 144
          Width = 183
          Height = 48
          Align = alTop
          Caption = 'Panel1'
          TabOrder = 1
          object BtnSecimeIskonto: TJvNavPanelButton
            Left = 1
            Top = 1
            Width = 85
            Height = 46
            Align = alLeft
            AllowAllUp = True
            Caption = #304'sk.'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -13
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 11
            Images = Tablo.cxImageList1
            OnClick = BtnSecimeIskontoClick
            ExplicitLeft = 2
            ExplicitTop = -2
          end
          object BtnTumuneIskonto: TJvNavPanelButton
            Left = 86
            Top = 1
            Width = 96
            Height = 46
            Align = alClient
            AllowAllUp = True
            Caption = 'T'#252'm'#252' '#304'sk'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 11
            Images = Tablo.cxImageList1
            OnClick = BtnSecimeIskontoClick
            ExplicitLeft = 136
            ExplicitTop = 0
            ExplicitWidth = 46
          end
        end
        object PanelTerazi: TPanel
          Left = 0
          Top = 288
          Width = 183
          Height = 48
          Align = alTop
          Caption = 'Panel1'
          TabOrder = 4
          object BtnTerazi: TJvNavPanelButton
            Left = 1
            Top = 1
            Width = 96
            Height = 46
            Align = alLeft
            AllowAllUp = True
            Caption = 'Terazi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 22
            Images = Tablo.cxImageList1
            OnClick = BtnTeraziClick
            ExplicitLeft = 2
          end
          object BtnNakliye: TJvNavPanelButton
            Left = 97
            Top = 1
            Width = 85
            Height = 46
            Align = alClient
            AllowAllUp = True
            Caption = 'Nakliye'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 22
            OnClick = BtnNakliyeClick
            ExplicitLeft = 98
            ExplicitWidth = 84
          end
        end
        object Panel_Sip_Hesap: TPanel
          Left = 0
          Top = 240
          Width = 183
          Height = 48
          Align = alTop
          Caption = 'Panel_Sip_Hesap'
          TabOrder = 3
          object BtnHesapYaz: TJvNavPanelButton
            Left = 88
            Top = 1
            Width = 94
            Height = 46
            Align = alClient
            AllowAllUp = True
            Caption = 'Hesap Yazd'#305'r'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 9
            Images = Tablo.cxImageList1
            OnClick = BtnHesapYazClick
            OnMouseUp = BtnSiparisYazMouseUp
            ExplicitLeft = 1
            ExplicitWidth = 80
          end
          object BtnSiparisYaz: TJvNavPanelButton
            Left = 1
            Top = 1
            Width = 87
            Height = 46
            Align = alLeft
            AllowAllUp = True
            Caption = 'Sipari'#351' G'#246'nder'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 23
            Images = Tablo.cxImageList1
            OnClick = BtnSiparisYazClick
            OnMouseUp = BtnSiparisYazMouseUp
          end
        end
        object PanelIkramMesaj: TPanel
          Left = 0
          Top = 96
          Width = 183
          Height = 48
          Align = alTop
          Caption = 'PanelIkramMesaj'
          TabOrder = 5
          object BtnMesaj: TJvNavPanelButton
            Left = 89
            Top = 1
            Width = 93
            Height = 46
            Align = alClient
            AllowAllUp = True
            Caption = 'Mesaj'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -11
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 13
            Images = Tablo.cxImageList1
            OnClick = BtnMesajClick
            ExplicitLeft = 73
            ExplicitTop = 33
          end
          object BtnIkram: TJvNavPanelButton
            Left = 1
            Top = 1
            Width = 88
            Height = 46
            Align = alLeft
            AllowAllUp = True
            Caption = #304'kram'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            GroupIndex = 2
            HotTrack = False
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -13
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            WordWrap = True
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            Colors.ButtonHotColorFrom = 14256961
            Colors.ButtonHotColorTo = 11694645
            Colors.ButtonSelectedColorFrom = 14256961
            Colors.ButtonSelectedColorTo = 11694645
            ParentStyleManager = False
            ImageIndex = 37
            Images = Tablo.cxImageList1
            OnClick = BtnIkramClick
            ExplicitLeft = 77
            ExplicitTop = -23
          end
        end
        object PanelTahsilatBelge: TPanel
          Left = 0
          Top = 0
          Width = 183
          Height = 48
          Align = alTop
          Caption = 'Panel1'
          TabOrder = 6
          ExplicitLeft = 16
          ExplicitTop = 39
        end
      end
      object PanelNumPad: TPanel
        Left = 1
        Top = 51
        Width = 202
        Height = 262
        Align = alClient
        BevelOuter = bvNone
        Color = 14740459
        ParentBackground = False
        TabOrder = 1
        object BtnNum1: TJvNavPanelButton
          Left = 4
          Top = 96
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '1'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum8: TJvNavPanelButton
          Left = 53
          Top = -1
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '8'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum7: TJvNavPanelButton
          Left = 4
          Top = -1
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '7'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum6: TJvNavPanelButton
          Left = 102
          Top = 48
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '6'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum4: TJvNavPanelButton
          Left = 4
          Top = 48
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '4'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum5: TJvNavPanelButton
          Left = 53
          Top = 48
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '5'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum2: TJvNavPanelButton
          Left = 53
          Top = 96
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '2'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum3: TJvNavPanelButton
          Left = 102
          Top = 96
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '3'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum9: TJvNavPanelButton
          Left = 102
          Top = -1
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '9'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNum0: TJvNavPanelButton
          Left = 4
          Top = 144
          Width = 97
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '0'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -16
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNumComma: TJvNavPanelButton
          Left = 102
          Top = 144
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = ','
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -19
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -19
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNumx: TJvNavPanelButton
          Left = 151
          Top = 51
          Width = 48
          Height = 93
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = '*'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -19
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -19
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnNumBspc: TJvNavPanelButton
          Tag = 55
          Left = 151
          Top = -1
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          AllowAllUp = True
          Caption = #8592
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -19
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -19
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnNum0Click
        end
        object BtnAdet: TJvNavPanelButton
          Left = 152
          Top = 144
          Width = 48
          Height = 48
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alCustom
          Alignment = taCenter
          AllowAllUp = True
          Caption = 'Miktar'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 2
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -13
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          WordWrap = True
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 19
          OnClick = BtnAdetClick
        end
        object PanelBeklet: TPanel
          Left = 0
          Top = 193
          Width = 200
          Height = 48
          Align = alCustom
          Caption = 'Panel1'
          TabOrder = 0
          object BtnParkEt: TJvNavPanelButton
            Left = 1
            Top = 1
            Width = 83
            Height = 46
            Align = alLeft
            Alignment = taCenter
            Caption = 'Beklet'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clRed
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -13
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            ImageIndex = 3
            OnClick = BtnParkEtClick
            ExplicitTop = 9
          end
          object BtnParktanAl: TJvNavPanelButton
            Left = 84
            Top = 1
            Width = 115
            Height = 46
            Align = alClient
            Alignment = taCenter
            Caption = 'Geri Al'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clGreen
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            HotTrackFont.Charset = TURKISH_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -13
            HotTrackFont.Name = 'Trebuchet MS'
            HotTrackFont.Style = [fsBold]
            ParentFont = False
            Colors.ButtonColorFrom = 15395562
            Colors.ButtonColorTo = 12566463
            ImageIndex = 4
            OnClick = BtnParktanAlClick
            ExplicitTop = 2
          end
        end
        object Button3: TButton
          Left = 64
          Top = 120
          Width = 75
          Height = 25
          Caption = 'tretora'
          TabOrder = 1
        end
      end
      object Panel4: TPanel
        Left = 1
        Top = 1
        Width = 385
        Height = 50
        Align = alTop
        BevelOuter = bvNone
        Color = 14740459
        ParentBackground = False
        TabOrder = 0
        ExplicitLeft = -3
        ExplicitTop = -4
        object lbUrunMiktar: TcxLabel
          Left = 93
          Top = 5
          Align = alCustom
          Caption = '0'
          ParentFont = False
          Style.Edges = [bLeft, bTop]
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.TextStyle = []
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          Transparent = True
        end
        object lbUrunSayisi: TcxLabel
          Left = 19
          Top = 5
          Align = alCustom
          Caption = '0'
          ParentFont = False
          Style.Edges = [bLeft, bTop]
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.TextStyle = []
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LabelMatrah: TcxLabel
          Left = 203
          Top = 25
          Caption = 'Matrah'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.TextStyle = []
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LabelKDV: TcxLabel
          Left = 299
          Top = 25
          Caption = 'KDV'
          ParentFont = False
          Style.Edges = [bLeft, bTop]
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.TextStyle = []
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          Transparent = True
        end
        object EditToplamTutar: TcxCurrencyEdit
          Left = 203
          Top = 1
          TabStop = False
          AutoSize = False
          EditValue = 0.000000000000000000
          ParentFont = False
          Properties.Alignment.Horz = taRightJustify
          Properties.ClearKey = 46
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.Nullable = False
          Properties.Nullstring = '0'
          Properties.ReadOnly = True
          Properties.UseDisplayFormatWhenEditing = True
          Properties.UseThousandSeparator = True
          Style.Color = 14740459
          Style.Edges = [bRight]
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -19
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.TextColor = clBlack
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          StyleDisabled.BorderColor = clBtnText
          StyleDisabled.Color = clMoneyGreen
          StyleDisabled.TextColor = clBackground
          TabOrder = 0
          Height = 26
          Width = 173
        end
        object LabelTahsilat: TcxLabel
          Left = 19
          Top = 27
          Align = alCustom
          Caption = '-'
          ParentFont = False
          Style.Edges = [bLeft, bTop]
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.TextStyle = []
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          Transparent = True
        end
      end
      object Button4: TButton
        Left = 160
        Top = 144
        Width = 75
        Height = 25
        Caption = 'trewsew'
        TabOrder = 3
      end
    end
    object MemoAdisyonSatir: TMemo
      Left = 11
      Top = 181
      Width = 678
      Height = 39
      Lines.Strings = (
        'truncate table TABLOADI'
        
          'insert into TABLOADI (FID,REHBERID,DURUM,URUNID,TUR,KOD,AD,KATEG' +
          'ORI,ADET,MF,BIRIM,BIRIMAD,MIKTAR,BIRIMFIYAT,'
        
          'TUTAR,DOVIZ_TUTARI,KUR,DOVIZ_KURU,ISKONTO,ISKONTO2,KDV,IADEADET,' +
          'IZLEME,YERID,URETICIID,BARKOD,ACIKLAMA,RESIM)'
        'select'
        'ID, REHBERID,DURUM=0,URUNID,TUR,'
        
          'KOD=(case when TUR=0 then (select KOD from MASRAFGELIR MG where ' +
          'MG.ID=F.URUNID) else (select KOD from STOKLAR S where S.ID=F.URU' +
          'NID) end),'
        
          'AD=(case when TUR=0 then (select AD from MASRAFGELIR MG where MG' +
          '.ID=F.URUNID) else (select S.STOKADI from STOKLAR S where S.ID=F' +
          '.URUNID) end),'
        
          'KATEGORI=(case when TUR=0 then 0 else (select KATEGORI from STOK' +
          'LAR S where S.ID=F.URUNID) end),'
        
          'ADET,isnull(MF,0.0),BIRIM,BIRIMAD=(select TOP 1 ANAHTAR from GEN' +
          'INI where BOLUM = -2702 and DIL=-1 and DEGER=F.BIRIM),MIKTAR,BIR' +
          'IMFIYAT,TUTAR,DOVIZ_TUTARI,KUR,DOVIZ_KURU,ISKONTO,ISKONTO2,'
        
          'KDV,IADEADET,IZLEME,YERID,URETICIID=0,BARKOD=(case when TUR=0 th' +
          'en 0 else (select KATEGORI from STOKLAR S where S.ID=F.URUNID) e' +
          'nd),'
        
          'ACIKLAMA=(case when ADET>1.0 then cast(ADET as nvarchar(10))+'#39' '#39 +
          '+'
        
          '(select TOP 1 ANAHTAR from GENINI where BOLUM = -2702 and DIL=-1' +
          ')+'#39' Birim Fiyat'#305' :'#39'+(SELECT convert(nvarchar(20), cast(BIRIMFIYA' +
          'T as money), 1)) else '#39' '#39' end)+'
        
          ' CHAR(13)+CHAR(10)+(case when ISKONTO>0.0 then '#39'%'#39'+cast(ISKONTO ' +
          'as nvarchar(10))+'#39' '#304'skonto'#39' else '#39' '#39' end)+'
        
          ' CHAR(13)+CHAR(10)+(case when ISKONTO2>0.0 then '#39'%'#39'+cast(ISKONTO' +
          '2 as nvarchar(10))+'#39' '#304'skonto2'#39
        
          ' when ADET=0.0 then '#39'**'#304'PTAL** '#39'+cast(IADEADET as nvarchar(10))+' +
          #39' Adet'#39' else '#39' '#39' end),'
        
          'RESIM=(case when TUR=0 then (select RESIM from MASRAFGELIR MG wh' +
          'ere MG.ID=F.URUNID) else (select RESIM from STOKLAR S where S.ID' +
          '=F.URUNID) end)'
        ' from FATURA F'
        'where '
        'ADET>0'
        'and FATBASID= :SID'
        'order by F.ID'
        '')
      TabOrder = 4
      Visible = False
      WordWrap = False
    end
    object MemoTeklifDetaySQL: TMemo
      Left = -123
      Top = 242
      Width = 678
      Height = 39
      Lines.Strings = (
        
          'insert into TABLOADI (REHBERID,DURUM,URUNID,TUR,KOD,AD,KATEGORI,' +
          'ADET,BIRIM,BIRIMAD,MIKTAR,BIRIMFIYAT,'
        
          'TUTAR,DOVIZ_TUTARI,KUR,DOVIZ_KURU,ISKONTO,ISKONTO2,KDV,IZLEME,YE' +
          'RID,URETICIID,BARKOD,ACIKLAMA,RESIM)'
        'select REHBERID,DURUM=0,URUNID,TUR,'
        
          'KOD=(case when TUR=0 then (select KOD from MASRAFGELIR MG where ' +
          'MG.ID=TD.URUNID) else (select KOD from STOKLAR S where S.ID=TD.U' +
          'RUNID) end),'
        
          'AD=(case when TUR=0 then (select AD from MASRAFGELIR MG where MG' +
          '.ID=TD.URUNID) else (select S.STOKADI from STOKLAR S where S.ID=' +
          'TD.URUNID) end),'
        
          'KATEGORI=(case when TUR=0 then 0 else (select KATEGORI from STOK' +
          'LAR S where S.ID=TD.URUNID) end),'
        
          'ADET,BIRIM,BIRIMAD=(select TOP 1 ANAHTAR from GENINI where BOLUM' +
          ' = -2702 and DIL=-1 and DEGER=TD.BIRIM),MIKTAR,BIRIMFIYAT,TUTAR,' +
          'DOVIZ_TUTARI,KUR,DOVIZ_KURU,ISKONTO,ISKONTO2,'
        
          'KDV,IZLEME,YERID,URETICIID=0,BARKOD=(case when TUR=0 then 0 else' +
          ' (select KATEGORI from STOKLAR S where S.ID=TD.URUNID) end),'
        
          'ACIKLAMA=(case when ADET>1.0 then cast(ADET as nvarchar(10))+'#39' '#39 +
          '+'
        
          '(select TOP 1 ANAHTAR from GENINI where BOLUM = -2702 and DIL=-1' +
          ')+'#39' Birim Fiyat'#305' :'#39'+(SELECT convert(nvarchar(20), cast(BIRIMFIYA' +
          'T as money), 1)) else '#39' '#39' end)+'
        
          ' CHAR(13)+CHAR(10)+(case when ISKONTO>0.0 then '#39'%'#39'+cast(ISKONTO ' +
          'as nvarchar(10))+'#39' '#304'skonto'#39' else '#39' '#39' end)+'
        
          ' CHAR(13)+CHAR(10)+(case when ISKONTO2>0.0 then '#39'%'#39'+cast(ISKONTO' +
          '2 as nvarchar(10))+'#39' '#304'skonto2'#39' else '#39' '#39' end),'
        
          'RESIM=(case when TUR=0 then (select RESIM from MASRAFGELIR MG wh' +
          'ere MG.ID=TD.URUNID) else (select RESIM from STOKLAR S where S.I' +
          'D=TD.URUNID) end)'
        ' from TEKLIFDETAY TD '
        'where TEKLIFID= :ESID'
        'order by TD.ID')
      TabOrder = 6
      Visible = False
      WordWrap = False
    end
    object MemoSiparisDetay: TMemo
      Left = -267
      Top = 287
      Width = 678
      Height = 39
      Lines.Strings = (
        
          'insert into TABLOADI (REHBERID,DURUM,URUNID,TUR,KOD,AD,KATEGORI,' +
          'ADET,BIRIM,BIRIMAD,MIKTAR,BIRIMFIYAT,'
        
          'TUTAR,DOVIZ_TUTARI,KUR,DOVIZ_KURU,ISKONTO,ISKONTO2,KDV,IZLEME,YE' +
          'RID,URETICIID,BARKOD,ACIKLAMA,RESIM)'
        'select'
        'REHBERID,DURUM=0,URUNID,TUR,'
        
          'KOD=(case when TUR=0 then (select KOD from MASRAFGELIR MG where ' +
          'MG.ID=SD.URUNID) else (select KOD from STOKLAR S where S.ID=SD.U' +
          'RUNID) end),'
        
          'AD=(case when TUR=0 then (select AD from MASRAFGELIR MG where MG' +
          '.ID=SD.URUNID) else (select S.STOKADI from STOKLAR S where S.ID=' +
          'SD.URUNID) end),'
        
          'KATEGORI=(case when TUR=0 then 0 else (select KATEGORI from STOK' +
          'LAR S where S.ID=SD.URUNID) end),'
        
          'ADET,BIRIM,BIRIMAD=(select TOP 1 ANAHTAR from GENINI where BOLUM' +
          ' = -2702 and DIL=-1),MIKTAR,BIRIMFIYAT,TUTAR,DOVIZ_TUTARI,KUR,DO' +
          'VIZ_KURU,ISKONTO,ISKONTO2,'
        
          'KDV,IZLEME,YERID,URETICIID=0,BARKOD=(case when TUR=0 then 0 else' +
          ' (select KATEGORI from STOKLAR S where S.ID=SD.URUNID) end),'
        
          'ACIKLAMA=(case when ADET>1.0 then cast(ADET as nvarchar(10))+'#39' '#39 +
          '+'
        
          '(select TOP 1 ANAHTAR from GENINI where BOLUM = -2702 and DIL=-1' +
          ')+'#39' Birim Fiyat'#305' :'#39'+(SELECT convert(nvarchar(20), cast(BIRIMFIYA' +
          'T as money), 1)) else '#39' '#39' end)+'
        
          ' CHAR(13)+CHAR(10)+(case when ISKONTO>0.0 then '#39'%'#39'+cast(ISKONTO ' +
          'as nvarchar(10))+'#39' '#304'skonto'#39' else '#39' '#39' end)+'
        
          ' CHAR(13)+CHAR(10)+(case when ISKONTO2>0.0 then '#39'%'#39'+cast(ISKONTO' +
          '2 as nvarchar(10))+'#39' '#304'skonto2'#39' else '#39' '#39' end),'
        
          'RESIM=(case when TUR=0 then (select RESIM from MASRAFGELIR MG wh' +
          'ere MG.ID=SD.URUNID) else (select RESIM from STOKLAR S where S.I' +
          'D=SD.URUNID) end)'
        ' from SIPARISDETAY SD'
        'where SIPARISID= :ESID'
        'order by SD.ID'
        ''
        '')
      TabOrder = 7
      Visible = False
      WordWrap = False
    end
  end
  object PanelAltGenel: TPanel
    Left = 387
    Top = 37
    Width = 902
    Height = 791
    Align = alClient
    Caption = 'PanelAltGenel'
    TabOrder = 2
    object PanelKategori: TPanel
      Left = 1
      Top = 1
      Width = 900
      Height = 41
      Align = alTop
      TabOrder = 0
      DesignSize = (
        900
        41)
      object EvTus: TJvNavPanelButton
        Left = 1
        Top = 1
        Width = 42
        Height = 39
        Hint = '150'
        Align = alLeft
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -11
        HotTrackFont.Name = 'Tahoma'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Colors.ButtonColorFrom = 15395562
        Colors.ButtonColorTo = 12566463
        ImageIndex = 35
        Images = Tablo.cxImageList1
        OnClick = EvTusClick
        ExplicitLeft = 738
        ExplicitTop = 3
      end
      object MercekTus: TJvNavPanelButton
        Left = 604
        Top = 5
        Width = 42
        Height = 33
        Hint = '150'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alCustom
        Anchors = [akRight, akBottom]
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -11
        HotTrackFont.Name = 'Tahoma'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        Colors.ButtonColorFrom = clBtnFace
        Colors.ButtonColorTo = clBtnFace
        ImageIndex = 20
        Images = Tablo.cxImageList1
        OnClick = MercekTusClick
        ExplicitLeft = 598
      end
      object BtnBarkodGiris: TJvNavPanelButton
        Left = 803
        Top = 5
        Width = 39
        Height = 31
        Align = alCustom
        AllowAllUp = True
        Anchors = [akRight, akBottom]
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        WordWrap = True
        Colors.ButtonColorFrom = 15395562
        Colors.ButtonColorTo = 12566463
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 17
        Images = Tablo.cxImageList1
        OnClick = BtnBarkodGirisClick
        ExplicitLeft = 797
      end
      object JvNavPanelButton1: TJvNavPanelButton
        Left = 860
        Top = 1
        Width = 37
        Height = 40
        Anchors = [akRight, akBottom]
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
        Colors.ButtonColorFrom = clBtnFace
        Colors.ButtonColorTo = clBtnFace
        Colors.ButtonHotColorFrom = clSilver
        Colors.ButtonHotColorTo = clSilver
        Colors.ButtonSelectedColorFrom = clSilver
        Colors.ButtonSelectedColorTo = clSilver
        Colors.SplitterColorFrom = clSilver
        Colors.SplitterColorTo = clSilver
        Colors.DividerColorFrom = clSilver
        Colors.DividerColorTo = clSilver
        Colors.HeaderColorFrom = clSilver
        Colors.HeaderColorTo = clSilver
        Colors.FrameColor = clSilver
        Colors.ToolPanelHeaderColorTo = clSilver
        ImageIndex = 36
        Images = Tablo.cxImageList1
        OnClick = JvNavPanelButton1Click
        ExplicitLeft = 798
      end
      object StokAra: TcxTextEdit
        AlignWithMargins = True
        Left = 649
        Top = 6
        Anchors = [akRight, akBottom]
        AutoSize = False
        ParentFont = False
        Properties.Alignment.Horz = taCenter
        Properties.ClearKey = 8238
        Style.Color = clInfoBk
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        StyleDisabled.Color = clInfoBk
        TabOrder = 0
        OnKeyUp = StokAraKeyUp
        Height = 31
        Width = 155
      end
    end
    object cxGridKategori: TcxGrid
      Left = 1
      Top = 42
      Width = 900
      Height = 239
      Align = alTop
      TabOrder = 1
      TabStop = False
      DragOpening = False
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      LookAndFeel.SkinName = 'LondonLiquidSky'
      object cxGridDBCardViewKategori: TcxGridDBCardView
        Navigator.Buttons.CustomButtons = <>
        FilterBox.CustomizeDialog = False
        OnCellClick = cxGridDBCardViewKategoriCellClick
        DataController.DataSource = DtsKategori
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        Filtering.MRUItemsList = False
        Filtering.RowMRUItemsList = False
        LayoutDirection = ldVertical
        OptionsBehavior.DragHighlighting = False
        OptionsBehavior.DragOpening = False
        OptionsBehavior.DragScrolling = False
        OptionsBehavior.ExpandRowOnDblClick = False
        OptionsCustomize.CardSizing = False
        OptionsCustomize.RowExpanding = False
        OptionsCustomize.RowFiltering = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.InvertSelect = False
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.CellEndEllipsis = True
        OptionsView.ScrollBars = ssVertical
        OptionsView.CardIndent = 4
        OptionsView.CardWidth = 150
        OptionsView.CategorySeparatorWidth = 0
        OptionsView.CellTextMaxLineCount = 3
        OptionsView.SeparatorWidth = 0
        RowLayout = rlVertical
        object cxGridDBCardViewResim: TcxGridDBCardViewRow
          Caption = #220'r'#252'n Ad'#305
          DataBinding.FieldName = 'RESIM'
          PropertiesClassName = 'TcxImageProperties'
          Properties.GraphicClassName = 'TJPEGImage'
          Properties.PopupMenuLayout.MenuItems = []
          Properties.ReadOnly = True
          Properties.Stretch = True
          Options.Editing = False
          Options.Filtering = False
          Options.Moving = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.LineCount = 8
          Position.Width = 180
        end
        object cxGridDBCardViewRow2: TcxGridDBCardViewRow
          DataBinding.FieldName = 'AD'
          Options.ShowCaption = False
          Position.BeginsLayer = False
          IsCaptionAssigned = True
        end
        object cxGridDBCardViewKategoriRow1: TcxGridDBCardViewRow
          DataBinding.FieldName = 'KOD'
          Visible = False
          Position.BeginsLayer = False
        end
      end
      object cxGridLevel1: TcxGridLevel
        Caption = 'Sat'#305#351'taki '#220'r'#252'nler'
        GridView = cxGridDBCardViewKategori
      end
    end
    object cxGridKartlar: TcxGrid
      Left = 1
      Top = 281
      Width = 900
      Height = 509
      Align = alClient
      TabOrder = 2
      TabStop = False
      DragOpening = False
      object cxGridDBCardViewKartlar: TcxGridDBCardView
        Navigator.Buttons.CustomButtons = <>
        FilterBox.CustomizeDialog = False
        OnCellClick = cxGridDBCardViewKartlarCellClick
        DataController.DataSource = DtsKartlar
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        Filtering.MRUItemsList = False
        Filtering.RowMRUItemsList = False
        LayoutDirection = ldVertical
        OptionsBehavior.DragHighlighting = False
        OptionsBehavior.DragOpening = False
        OptionsBehavior.DragScrolling = False
        OptionsBehavior.ExpandRowOnDblClick = False
        OptionsCustomize.CardSizing = False
        OptionsCustomize.RowExpanding = False
        OptionsCustomize.RowFiltering = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.InvertSelect = False
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.ScrollBars = ssVertical
        OptionsView.CardBorderWidth = 1
        OptionsView.CardIndent = 4
        OptionsView.CardWidth = 150
        OptionsView.CategorySeparatorWidth = 0
        OptionsView.CellTextMaxLineCount = 3
        OptionsView.SeparatorWidth = 0
        RowLayout = rlVertical
        object cxGridDBCardViewKartlarRESIM: TcxGridDBCardViewRow
          DataBinding.FieldName = 'RESIM'
          PropertiesClassName = 'TcxImageProperties'
          Properties.GraphicClassName = 'TJPEGImage'
          Properties.PopupMenuLayout.MenuItems = []
          Properties.ReadOnly = True
          CaptionAlignmentHorz = taRightJustify
          Options.Editing = False
          Options.Filtering = False
          Options.FilteringFilteredItemsList = False
          Options.FilteringMRUItemsList = False
          Options.FilteringPopup = False
          Options.FilteringPopupMultiSelect = False
          Options.IgnoreTimeForFiltering = False
          Options.IncSearch = False
          Options.Expanding = False
          Options.Moving = False
          Options.ShowCaption = False
          Position.BeginsLayer = True
          Position.LineCount = 8
          Position.Width = 180
          VisibleForCustomization = False
          IsCaptionAssigned = True
        end
        object cxGridDBCardViewKartlarSTOKADI: TcxGridDBCardViewRow
          DataBinding.FieldName = 'STOKADI'
          PropertiesClassName = 'TcxMemoProperties'
          Options.ShowCaption = False
          Position.BeginsLayer = False
          IsCaptionAssigned = True
        end
        object cxGridDBCardViewKartlarID: TcxGridDBCardViewRow
          DataBinding.FieldName = 'ID'
          Visible = False
          Position.BeginsLayer = False
        end
        object cxGridDBCardViewKartlarADET: TcxGridDBCardViewRow
          DataBinding.FieldName = 'ADET'
          Visible = False
          Position.BeginsLayer = False
        end
        object cxGridDBCardViewKartlarBARKOD: TcxGridDBCardViewRow
          DataBinding.FieldName = 'BARKOD'
          Options.Editing = False
          Options.Filtering = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
        end
        object cxGridDBCardViewKartlarRowOZELKOD: TcxGridDBCardViewRow
          Caption = #214'zel Kod'
          DataBinding.FieldName = 'OZELKOD'
          RepositoryItem = Tablo.cxEditRepository1Label1
          Options.Editing = False
          Options.ShowCaption = False
          Position.BeginsLayer = False
        end
      end
      object cxGridLevel2: TcxGridLevel
        Caption = 'Sat'#305#351'taki '#220'r'#252'nler'
        GridView = cxGridDBCardViewKartlar
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 828
    Width = 1289
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 150
      end>
    Touch.ParentTabletOptions = False
    Touch.TabletOptions = [toPressAndHold]
  end
  object Button1: TButton
    Left = 20
    Top = 20
    Width = 75
    Height = 25
    Caption = 'trefghghg'
    TabOrder = 4
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabDetayAfterOpen
    BeforePost = TabDetayBeforePost
    AfterPost = TabDetayAfterPost
    AfterDelete = TabDetayAfterDelete
    ParamData = <>
    SQL.Strings = (
      ''
      'select top 100 * from FATURA  ')
    Left = 25
    Top = 176
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 73
    Top = 175
  end
  object TabKartlar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PAdet'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end
      item
        Name = 'PSIskonto'
        DataType = ftWideString
        Size = 1
        Value = '0'
      end
      item
        Name = 'PMIskonto'
        DataType = ftWideString
        Size = 1
        Value = '0'
      end
      item
        Name = 'PDovizKuru1'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end
      item
        Name = 'PDovizKuru2'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end
      item
        Name = 'PFiyatAdi'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
    SQL.Strings = (
      'declare @Adet int'
      'declare @SIskonto Float'
      'declare @MIskonto float'
      'declare @DovizKuru1 float'
      'declare @DovizKuru2 float'
      'set @Adet=:PAdet'
      'set @SIskonto=:PSIskonto'
      'set @MIskonto=:PMIskonto'
      'set @DovizKuru1=:PDovizKuru1'
      'set @DovizKuru2=:PDovizKuru2'
      ''
      'select '
      #9'S.ID,'
      #9'S.KOD,'
      #9'AD=S.STOKADI,'
      #9'TUR=1,'
      #9'ADET=@Adet,'
      #9'BIRIM,'
      #9'MIKTAR=@Adet,'
      #9'BIRIMFIYAT=case when isnull(F.KUR,'#39'TL'#39')='#39'TL'#39' then F.FIYAT'
      #9#9'when F.KUR = '#39'$'#39' then  F.FIYAT*@DovizKuru1 '
      #9#9'else F.FIYAT*@DovizKuru2 end,'
      
        #9'TUTAR=case when isnull(F.KUR,'#39'TL'#39')='#39'TL'#39' then (@Adet*F.FIYAT)*((' +
        '100-@SIskonto)/100)'
      
        #9#9'when F.KUR = '#39'$'#39' then (@Adet*F.FIYAT)*((100-@SIskonto)/100)*@D' +
        'ovizKuru1 '
      #9#9'else (@Adet*F.FIYAT)*((100-@SIskonto)/100)*@DovizKuru2 end,'
      #9'KUR='#39'TL'#39','
      #9'DOVIZ_TUTARI=(@Adet*F.FIYAT)*((100-@SIskonto)/100),'
      #9'DOVIZ_KURU=isnull(F.KUR,'#39'TL'#39'),'
      #9'ISKONTO=@SIskonto,'
      #9'ISKONTO2=0,'
      #9'KDV=isnull(KDV,0),'
      #9'DEPO=0,'
      #9'S.RESIM'
      #9'--BARKOD=S.BARKOD'#9
      'from '
      #9'STOKLAR S left outer join '
      #9'STOKFIYAT F on S.ID=F.STOKID and'
      #9'F.BIRIM=S.ANABIRIM and'
      #9'F.FIYATADI=:PFiyatAdi ')
    Left = 472
    Top = 365
  end
  object DtsKartlar: TDataSource
    DataSet = TabKartlar
    Left = 605
    Top = 402
  end
  object PopupBekletilenler: TPopupMenu
    Left = 375
    Top = 156
  end
  object PopupKisaYollar: TPopupMenu
    Left = 373
    Top = 112
    object StokEkle1: TMenuItem
      Caption = 'Stok Ekle '
    end
    object SeiliStouksayolmensndenkaldr1: TMenuItem
      Caption = 'Stok Kald'#305'r'
      OnClick = SeiliStouksayolmensndenkaldr1Click
    end
  end
  object DtsTahDetay: TDataSource
    DataSet = TabTahDetay
    Left = 98
    Top = 118
  end
  object TabFatBasDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      '')
    Left = 18
    Top = 250
  end
  object DtsFatBasDetay: TDataSource
    DataSet = TabFatBasDetay
    Left = 98
    Top = 253
  end
  object TabTahDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'select top 100 * from KASA')
    Left = 27
    Top = 112
  end
  object TabKategori: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'Prm1'
        Attributes = [paNullable]
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 20
        Value = '0'
      end
      item
        Name = 'Prm2'
        Attributes = [paNullable]
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 20
        Value = '0'
      end>
    SQL.Strings = (
      'select KOD, AD, RESIM, ID from KATEGORI'
      ' where '
      'DURUM=1 '
      'and KOD like :Prm1'
      'and KOD not like :Prm2'
      'order by 2')
    Left = 470
    Top = 315
  end
  object DtsKategori: TDataSource
    DataSet = TabKategori
    Left = 546
    Top = 303
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <>
    StorageName = 'cxPropertiesStore1'
    Left = 93
    Top = 47
  end
  object PopupSablonMenu: TPopupMenu
    Left = 470
    Top = 219
    object SablonSiparistenGetirMenu: TMenuItem
      Caption = #350'ablondan Getir'
      OnClick = SablonSiparistenGetirMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object YeniSablonSiparisOlusturMenu: TMenuItem
      Caption = 'Yeni '#350'ablon Olu'#351'tur'
      OnClick = YeniSablonSiparisOlusturMenuClick
    end
    object SablonSiparisDegistirMenu: TMenuItem
      Caption = #350'ablon De'#287'i'#351'tir'
    end
  end
  object PopupMenuYaz: TPopupMenu
    Left = 1064
    Top = 45
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
      object MenuItem2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxDetay: TfrxDBDataset
    UserName = 'frxDetay'
    CloseDataSource = False
    DataSource = DtsDetay
    BCDToCurrency = False
    Left = 656
    Top = 192
  end
  object frxFatBasDetay: TfrxDBDataset
    UserName = 'frxFatBasDetay'
    CloseDataSource = False
    DataSource = DtsFatBasDetay
    BCDToCurrency = False
    Left = 663
    Top = 257
  end
  object TabCokKullanilan: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      '   ')
    Left = 478
    Top = 457
  end
  object TabDetayYaz: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 561
    Top = 200
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Interval = 700
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 176
    Top = 144
  end
  object JvThreadTimer1: TJvThreadTimer
    Left = 208
    Top = 272
  end
  object TabHazirlayanDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
    Prepared = True
    SQL.Strings = (
      'Declare @IletisimID integer, @RehberID integer'
      'set @RehberID = :PRehID'
      
        'select top 1 @IletisimID = ID from REHBERILETISIM where REHBERID' +
        '=@RehberID  order by VARSAYILAN desc'
      '    select'
      
        '    '#9'KOD,FIRMA,GRUP,KATEGORI,DURUM,OZELKOD,NOTLAR,' +
        'YETKIKODU,'
      
        '    '#9'KATEGORIADI=(select top 1 ANAHTAR from GENINI where BOLUM=-' +
        '2204 and DEGER=KATEGORI and DIL=-1),'
      
        '    '#9'GOREVADI=(select top 1 ANAHTAR from GENINI where BOLUM=-220' +
        '5 and DEGER=KATEGORI),'
      
        '    '#9'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=40),'
      
        '    '#9'CEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '2),'
      
        '    '#9'FAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '3),'
      
        '    '#9'ADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=2),'
      
        '    '#9'ILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=' +
        '6),'
      
        '    '#9'IL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=8)' +
        ','
      
        '    '#9'PK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4)' +
        ','
      
        '    '#9'VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILA' +
        'N=20),'
      
        '    '#9'VERGINO=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN' +
        '=22),'
      
        '    '#9'WEB=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '8),'
      
        '    '#9'EMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=46),'
      
        '    '#9'FATURABASLIK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (noloc' +
        'k) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB' +
        '.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSA' +
        'YILAN=10),'
      
        '    '#9'LOGO= (SELECT  TOP 1 BELGE FROM IMAJ I WHERE VARSAYILAN=1 A' +
        'ND YERI=11 AND YER_ID=@RehberID ),'
      
        '    '#9'VERGIDAI_KODU=(select TOP 1  VDKODU FROM VDLISTE VD WHERE V' +
        'D.VD =(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA' +
        '.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=20)),'
      
        '      VERGI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=' +
        '20)+'#39' / '#39'+(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=22' +
        ')'
      '      from'
      '      '#9'REHBER R'
      '      WHERE ID = @RehberID')
    Left = 490
    Top = 105
  end
  object frxHazirlayanDetay: TfrxDBDataset
    UserName = 'HazirlayanDetay'
    CloseDataSource = False
    DataSet = TabHazirlayanDetay
    BCDToCurrency = False
    Left = 485
    Top = 151
  end
  object mem: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 680
    Top = 104
    object memId: TSmallintField
      AutoGenerateValue = arAutoInc
      FieldName = 'ID'
    end
    object memREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object memTUR: TSmallintField
      FieldName = 'TUR'
    end
    object memDURUM: TSmallintField
      FieldName = 'DURUM'
    end
    object memURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object memKOD: TStringField
      FieldName = 'KOD'
      Size = 25
    end
    object memAD: TStringField
      FieldName = 'AD'
      Size = 200
    end
    object memKATEGORI: TSmallintField
      FieldName = 'KATEGORI'
    end
    object memADET: TFloatField
      FieldName = 'ADET'
    end
    object memBIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object memBIRIMAD: TStringField
      FieldName = 'BIRIMAD'
      Size = 10
    end
    object memMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object memBIRIMFIYAT: TFloatField
      FieldName = 'BIRIMFIYAT'
    end
    object memTUTAR: TCurrencyField
      FieldName = 'TUTAR'
    end
    object memKUR: TStringField
      FieldName = 'KUR'
      Size = 5
    end
    object memOZELKOD: TStringField
      FieldName = 'OZELKOD'
      Size = 50
    end
    object memDOVIZ_TUTARI: TCurrencyField
      FieldName = 'DOVIZ_TUTARI'
    end
    object memDOVIZ_KURU: TStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object memISKONTO: TFloatField
      FieldName = 'ISKONTO '
    end
    object memISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object memKDV: TSmallintField
      FieldName = 'KDV'
    end
    object memIADEADET: TFloatField
      FieldName = 'IADEADET'
    end
    object memRESIM: TFloatField
      FieldName = 'RESIM'
    end
    object memBARKOD: TStringField
      FieldName = 'BARKOD'
      Size = 50
    end
    object memACIKLAMA: TStringField
      FieldName = 'ACIKLAMA '
      Size = 400
    end
    object memSUBEID: TSmallintField
      FieldName = 'SUBEID '
    end
    object memIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object memIZLEMEYERI: TIntegerField
      FieldName = 'IZLEMEYERI'
    end
    object memIZLEMEYERID: TIntegerField
      FieldName = 'IZLEMEYERID'
    end
    object memACIKLAMA2: TStringField
      FieldName = 'ACIKLAMA2'
      Size = 200
    end
    object memYERID: TIntegerField
      FieldName = 'YERID '
    end
    object memURETICIID: TIntegerField
      FieldName = 'URETICIID'
    end
  end
  object memFATBAS: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 824
    Top = 120
    object SmallintField1: TSmallintField
      AutoGenerateValue = arAutoInc
      FieldName = 'ID'
    end
    object memFATBASTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object SmallintField2: TSmallintField
      FieldName = 'TUR'
    end
    object memFATBASTIPI: TSmallintField
      FieldName = 'TIPI'
    end
    object IntegerField1: TIntegerField
      FieldName = 'REHBERID'
    end
    object memFATBASFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object memFATBASKOCANNO: TIntegerField
      FieldName = 'KOCANNO'
    end
    object memFATBASFATURASERI: TStringField
      FieldName = 'FATURASERI'
      Size = 5
    end
    object memFATBASFATURANO: TStringField
      FieldName = 'FATURANO'
    end
    object memFATBASCIKISDEPO: TSmallintField
      FieldName = 'CIKISDEPO'
    end
    object memFATBASBASLIK: TStringField
      FieldName = 'BASLIK'
      Size = 200
    end
    object memFATBASADRES: TStringField
      FieldName = 'ADRES'
      Size = 200
    end
    object memFATBASILCE: TStringField
      FieldName = 'ILCE'
      Size = 50
    end
    object memFATBASIL: TStringField
      FieldName = 'IL'
      Size = 50
    end
    object memFATBASVD: TStringField
      FieldName = 'VD'
      Size = 30
    end
    object memFATBASVNO: TStringField
      FieldName = 'VNO'
    end
    object StringField5: TStringField
      FieldName = 'OZELKOD'
      Size = 50
    end
    object memFATBASKDVDURUM: TStringField
      FieldName = 'KDVDURUM'
      Size = 5
    end
    object memFATBASLOTNO: TStringField
      FieldName = 'LOTNO'
      Size = 8
    end
    object memFATBASACIK_KAPALI: TSmallintField
      FieldName = 'ACIK_KAPALI'
    end
    object memFATBASFATURA_MATRAHI: TCurrencyField
      FieldName = 'FATURA_MATRAHI'
    end
    object memFATBASKDV_TUTARI: TCurrencyField
      FieldName = 'KDV_TUTARI'
    end
    object memFATBASEKVERGI: TCurrencyField
      FieldName = 'EKVERGI'
    end
    object memFATBASFATURA_TUTARI: TCurrencyField
      FieldName = 'FATURA_TUTARI'
    end
    object memFATBASKUR: TStringField
      FieldName = 'KUR'
      Size = 5
    end
    object memFATBASMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object memFATBASACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object memFATBASSATICIKODU: TIntegerField
      FieldName = 'SATICIKODU'
    end
    object memFATBASFIYAT_LISTESI: TSmallintField
      FieldName = 'FIYAT_LISTESI'
    end
    object memFATBASODEME: TSmallintField
      FieldName = 'ODEME'
    end
    object memFATBASSTOKISK: TFloatField
      FieldName = 'STOKISK'
    end
    object memFATBASHIZMETISK: TFloatField
      FieldName = 'HIZMETISK'
    end
    object memFATBASKASATAKIPID: TIntegerField
      FieldName = 'KASATAKIPID'
    end
    object memFATBASDETAYBOLUMU: TStringField
      FieldName = 'DETAYBOLUMU'
    end
    object memFATBASDOVIZ_TUTARI: TCurrencyField
      FieldName = 'DOVIZ_TUTARI'
    end
    object memFATBASDOVIZ_CINSI: TStringField
      FieldName = 'DOVIZ_CINSI'
      Size = 5
    end
    object memFATBASDOVIZKUR: TCurrencyField
      FieldName = 'DOVIZKUR'
    end
    object memFATBASREHBERILETID: TIntegerField
      FieldName = 'REHBERILETID'
    end
    object memFATBASSUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
  end
  object memKAS: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 736
    Top = 200
    object memKASID: TIntegerField
      FieldName = 'ID'
    end
    object memKASTUR: TSmallintField
      FieldName = 'TUR'
    end
    object memKASHESAPID: TIntegerField
      FieldName = 'HESAPID'
    end
    object memKASMUSTERIHESAPID: TIntegerField
      FieldName = 'MUSTERIHESAPID'
    end
    object memKASTUTAR: TCurrencyField
      FieldName = 'TUTAR'
    end
    object memKASKUR: TStringField
      FieldName = 'KUR'
      Size = 5
    end
    object memKASTAHSILAD: TStringField
      FieldName = 'TAHSILAD'
      Size = 25
    end
    object memKASCEKSENETID: TIntegerField
      FieldName = 'CEKSENETID'
    end
  end
end

