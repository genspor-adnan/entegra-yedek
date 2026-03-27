object StokDurumDetayDlg: TStokDurumDetayDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Stok Bilgileri'
  ClientHeight = 521
  ClientWidth = 959
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 959
    Height = 42
    Align = alTop
    TabOrder = 0
    DesignSize = (
      959
      42)
    object cxImageComboBox1: TcxImageComboBox
      Left = 790
      Top = 13
      RepositoryItem = Tablo.RepStokTumDepolar
      Anchors = [akRight, akBottom]
      Properties.Items = <>
      Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
      TabOrder = 0
      Width = 160
    end
    object LabelAd: TcxLabel
      Left = 16
      Top = 13
      Caption = '--'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 42
    Width = 690
    Height = 479
    Align = alClient
    TabOrder = 1
    object GridResim: TcxGrid
      Left = 1
      Top = 412
      Width = 688
      Height = 66
      Align = alBottom
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      TabOrder = 0
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridResimView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsResim
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Appending = True
        OptionsData.DeletingConfirmation = False
        OptionsSelection.CellSelect = False
        OptionsView.ScrollBars = ssVertical
        OptionsView.DataRowHeight = 70
        OptionsView.GridLines = glNone
        OptionsView.GroupByBox = False
        OptionsView.Header = False
        object cxGridDBColumn1: TcxGridDBColumn
          Caption = 'T'#252'r'#252
          DataBinding.FieldName = 'BELGE'
          PropertiesClassName = 'TcxImageProperties'
          Properties.GraphicClassName = 'TJPEGImage'
          Properties.Proportional = False
          Properties.Stretch = True
          MinWidth = 50
          Options.Editing = False
          Options.Filtering = False
          Options.FilteringFilteredItemsList = False
          Options.FilteringMRUItemsList = False
          Options.FilteringPopup = False
          Options.FilteringPopupMultiSelect = False
          Options.IgnoreTimeForFiltering = False
          Options.IncSearch = False
          Options.ShowEditButtons = isebAlways
          Options.GroupFooters = False
          Options.Grouping = False
          Options.ShowCaption = False
          Options.Sorting = False
          Width = 100
        end
      end
      object GridFirIlet: TcxGridLevel
        GridView = GridResimView
      end
    end
    object LogoResim: TcxImage
      Left = 1
      Top = 1
      Align = alClient
      Enabled = False
      Properties.GraphicClassName = 'TJPEGImage'
      Style.Color = 11776947
      TabOrder = 1
      Height = 411
      Width = 688
    end
    object MemoBoyutCik: TMemo
      Left = 16
      Top = 289
      Width = 401
      Height = 41
      Color = clOlive
      Lines.Strings = (
        '--Boyut @izlemtur=4'
        ''
        ''
        'select '
        
          #9'DURUM=isnull((select SUM(SI.MIKTAR) from STOKIZLEME SI where SI' +
          '.DURUM=1 and SI.STOKID=@StokID and SI.GIRISDEPO=@DepoID and SI.I' +
          'ZLEMID=SBK.ID),0.0)'
        
          #9#9'-isnull((select SUM(SI.MIKTAR) from STOKIZLEME SI where SI.DUR' +
          'UM=1 and SI.STOKID=@StokID and SI.CIKISDEPO=@DepoID and SI.IZLEM' +
          'ID=SBK.ID),0.0),'
        
          #9'ACIKLAMA=isnull(G1.ANAHTAR,'#39#39')+'#39' '#39'+isnull(G2.ANAHTAR,'#39#39')+'#39' '#39'+is' +
          'null(G3.ANAHTAR,'#39#39')'
        'from '
        #9'STOKLAR S inner join '
        #9'STOKBOYUTKOMBINASYON SBK on S.ID=SBK.STOKID inner join'
        #9'STOKBOYUTGRUPLARI SBG on SBG.ID=SBK.SBGID left outer join'
        
          #9'GENINI G1 on G1.BOLUM=SBK.BOLUM1 and G1.DEGER=SBK.DEGER1 and G1' +
          '.DIL=-1 left outer join'
        
          #9'GENINI G2 on G2.BOLUM=SBK.BOLUM2 and G2.DEGER=SBK.DEGER2 and G2' +
          '.DIL=-1 left outer join'
        
          #9'GENINI G3 on G3.BOLUM=SBK.BOLUM3 and G3.DEGER=SBK.DEGER3 and G3' +
          '.DIL=-1 '
        'where '
        #9'S.ID=@StokID ')
      TabOrder = 2
      Visible = False
      WordWrap = False
    end
    object MemoSKTCik: TMemo
      Left = 16
      Top = 250
      Width = 401
      Height = 41
      Color = clAqua
      Lines.Strings = (
        '--SKT  @izlemtur=2'
        'select '
        
          'DURUM=isnull((select SUM(SI2.MIKTAR)from STOKIZLEME SI2 where SI' +
          '2.DURUM=1 and SI2.GIRISDEPO=@DepoID and SI2.STOKID=@StokID and S' +
          'I2.IZLEMTUR=2 and SI1.SKT=SI2.SKT and isnull(SI2.ACIKLAMA,'#39#39')=is' +
          'null(SI1.ACIKLAMA,'#39#39')),0.0)'
        
          #9'-isnull((select SUM(SI2.MIKTAR)from STOKIZLEME SI2 where SI2.DU' +
          'RUM=1 and SI2.CIKISDEPO=@DepoID and SI2.STOKID=@StokID and SI2.I' +
          'ZLEMTUR=2 and SI1.SKT=SI2.SKT and isnull(SI2.ACIKLAMA,'#39#39')=isnull' +
          '(SI1.ACIKLAMA,'#39#39')),0.0),'
        'ACIKLAMA = convert(varchar(10),SKT,105)+'#39' '#39'+SI1.ACIKLAMA'
        'from '
        'STOKIZLEME SI1 '
        'where '
        'SI1.IZLEMTUR=2 and'
        'SI1.DURUM=1 and'
        'SI1.STOKID=@StokID'
        'group by '
        'SI1.STOKID,SI1.ACIKLAMA,SI1.SKT'
        
          'having isnull((select SUM(SI2.MIKTAR)from STOKIZLEME SI2 where S' +
          'I2.DURUM=1 and SI2.GIRISDEPO=@DepoID and SI2.STOKID=@StokID and ' +
          'SI2.IZLEMTUR=2 and SI1.SKT=SI2.SKT and isnull(SI2.ACIKLAMA,'#39#39')=i' +
          'snull(SI1.ACIKLAMA,'#39#39')),0.0)'
        
          #9' > isnull((select SUM(SI2.MIKTAR)from STOKIZLEME SI2 where SI2.' +
          'DURUM=1 and SI2.CIKISDEPO=@DepoID and SI2.STOKID=@StokID and SI2' +
          '.IZLEMTUR=2 and SI1.SKT=SI2.SKT and isnull(SI2.ACIKLAMA,'#39#39')=isnu' +
          'll(SI1.ACIKLAMA,'#39#39')),0.0)'
        '')
      TabOrder = 3
      Visible = False
      WordWrap = False
    end
    object MemoSerinoCik: TMemo
      Left = 16
      Top = 336
      Width = 401
      Height = 41
      Color = clFuchsia
      Lines.Strings = (
        '--Serino - Karekod  @izlemtur= 1,3'
        ''
        'select distinct'
        #9'DURUM=1,'
        #9'ACIKLAMA=SI.IZLEM'
        'from '
        #9'STOKIZLEME SI'
        'where '
        #9'SI.DURUM=1 and'
        #9'SI.IZLEMTUR in (1,3) and'
        #9'SI.STOKID=@StokID and '
        #9'SI.GIRISDEPO=@DepoID and'
        
          #9'(select count(*) from STOKIZLEME SI2 where SI2.DURUM=1 and SI2.' +
          'STOKID=SI.STOKID and SI2.IZLEMTUR=SI.IZLEMTUR and SI2.GIRISDEPO=' +
          '@DepoID and SI2.IZLEM=SI.IZLEM)'
        
          #9'>(select count(*) from STOKIZLEME SI2 where SI2.DURUM=1 and SI2' +
          '.STOKID=SI.STOKID and SI2.IZLEMTUR=SI.IZLEMTUR and SI2.CIKISDEPO' +
          '=@DepoID and SI2.IZLEM=SI.IZLEM)'
        '')
      TabOrder = 4
      Visible = False
      WordWrap = False
    end
  end
  object Panel3: TPanel
    Left = 690
    Top = 42
    Width = 269
    Height = 479
    Align = alRight
    Caption = 'Panel3'
    TabOrder = 2
    object cxGrid1: TcxGrid
      Left = 1
      Top = 1
      Width = 267
      Height = 275
      Align = alClient
      TabOrder = 0
      LevelTabs.CaptionAlignment = taLeftJustify
      RootLevelOptions.DetailTabsPosition = dtpTop
      object cxGrid1DBTableViewDurum: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsStokDurumDetay
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
        object cxGrid1DBTableViewDurumTIP: TcxGridDBColumn
          Caption = 'Tip'
          DataBinding.FieldName = 'TIP'
          Width = 104
        end
        object cxGrid1DBTableViewDurumADET: TcxGridDBColumn
          Caption = 'Miktar'
          DataBinding.FieldName = 'ADET'
          RepositoryItem = Tablo.RepCurrencyAdetGenel
          Width = 69
        end
        object cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'BIRIM'
          RepositoryItem = Tablo.repStokAnaBirim
          Width = 71
        end
      end
      object cxGrid1DBTableViewIzlem: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
      end
      object cxGrid1DBTableViewDonusum: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsStokCevrimleri
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
        object cxGrid1DBTableViewDonusumADET1: TcxGridDBColumn
          Caption = 'Adet 1'
          DataBinding.FieldName = 'ADET1'
          Width = 59
        end
        object cxGrid1DBTableViewDonusumBIRIM1: TcxGridDBColumn
          Caption = 'Birim 1'
          DataBinding.FieldName = 'BIRIM1'
          RepositoryItem = Tablo.repStokAnaBirim
        end
        object cxGrid1DBTableViewDonusumADET2: TcxGridDBColumn
          Caption = 'Adet 2'
          DataBinding.FieldName = 'ADET2'
          Width = 63
        end
        object cxGrid1DBTableViewDonusumBIRIM2: TcxGridDBColumn
          Caption = 'Birim 2'
          DataBinding.FieldName = 'BIRIM2'
          RepositoryItem = Tablo.repStokAnaBirim
        end
      end
      object cxGrid1LevelDepoDurumu: TcxGridLevel
        Caption = 'Depo Durumu'
        GridView = cxGrid1DBTableViewDurum
      end
      object cxGrid1LevelIzlem: TcxGridLevel
        Caption = #304'zleme'
        GridView = cxGrid1DBTableViewIzlem
      end
      object cxGrid1LevelDonusum: TcxGridLevel
        Caption = 'D'#246'n'#252#351#252'm'
        GridView = cxGrid1DBTableViewDonusum
      end
    end
    object Panel4: TPanel
      Left = 1
      Top = 276
      Width = 267
      Height = 202
      Align = alBottom
      TabOrder = 1
      object EditFiyat: TcxCurrencyEdit
        Left = 32
        Top = 106
        ParentFont = False
        Style.Color = clBtnFace
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 0
        Width = 137
      end
      object cxLabel1: TcxLabel
        Left = 56
        Top = 73
        Caption = 'Sat'#305#351' Fiyat'#305
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
      end
    end
  end
  object TabStokDurumDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from fn_StokDurumDetay(:PStokID,:PDepoID)')
    Left = 201
    Top = 136
  end
  object DtsStokDurumDetay: TDataSource
    DataSet = TabStokDurumDetay
    Left = 201
    Top = 183
  end
  object TabResim: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabResimAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select * from IMAJ '
      'where YERI=71 and YER_ID=:YID order by 2')
    Left = 191
    Top = 65
  end
  object DtsResim: TDataSource
    DataSet = TabResim
    Left = 264
    Top = 64
  end
  object TabDepoIzlemDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from fn_StokDurumDetay(:PStokID,:PDepoID)')
    Left = 313
    Top = 144
  end
  object DtsDepoIzlemDetay: TDataSource
    DataSet = TabDepoIzlemDetay
    Left = 313
    Top = 191
  end
  object TabStokCevrimleri: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from STOKCEVRIM where STOKID=:PStokID')
    Left = 417
    Top = 152
  end
  object DtsStokCevrimleri: TDataSource
    DataSet = TabStokCevrimleri
    Left = 417
    Top = 199
  end
end
