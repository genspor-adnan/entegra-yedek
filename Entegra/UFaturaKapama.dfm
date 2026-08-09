object FaturaKapamaDlg: TFaturaKapamaDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Bor'#231'/Alacak Kapama'
  ClientHeight = 461
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 39
    Width = 1000
    Height = 422
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 1049
    ExplicitHeight = 397
    object GridBASol: TcxGrid
      Left = 1
      Top = 1
      Width = 494
      Height = 420
      Align = alLeft
      PopupMenu = PopupBorc
      TabOrder = 0
      object GridBASolDBTableViewBorc: TcxGridDBTableView
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
        OnCanFocusRecord = GridBASolDBTableViewBorcCanFocusRecord
        DataController.DataSource = DtsBorc
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Column = GridBASolDBTableViewBorcTUTAR
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Column = GridBASolDBTableViewBorcKAPANAN
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Column = GridBASolDBTableViewBorcKALAN
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnCycle = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideSelection = True
        OptionsSelection.InvertSelect = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        Styles.OnGetContentStyle = GridBASolDBTableViewBorcStylesGetContentStyle
        object GridBASolDBTableViewBorcTARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
          Width = 62
        end
        object GridBASolDBTableViewBorcVADE: TcxGridDBColumn
          Caption = 'Vade'
          DataBinding.FieldName = 'VADE'
          Width = 61
        end
        object GridBASolDBTableViewBorcANAHTAR: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ANAHTAR'
          Width = 95
        end
        object GridBASolDBTableViewBorcBELGENO: TcxGridDBColumn
          Caption = 'Belge No'
          DataBinding.FieldName = 'BELGENO'
        end
        object GridBASolDBTableViewBorcTUTAR: TcxGridDBColumn
          Caption = 'Bor'#231
          DataBinding.FieldName = 'TUTAR'
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 73
        end
        object GridBASolDBTableViewBorcKAPANAN: TcxGridDBColumn
          Caption = 'Kapanan'
          DataBinding.FieldName = 'KAPANAN'
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 72
        end
        object GridBASolDBTableViewBorcKALAN: TcxGridDBColumn
          Caption = 'Kalan'
          DataBinding.FieldName = 'KALAN'
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 77
        end
        object GridBASolDBTableViewBorcKUR: TcxGridDBColumn
          Caption = 'Kur'
          DataBinding.FieldName = 'KUR'
          Width = 26
        end
        object GridBASolDBTableViewBorcTUR: TcxGridDBColumn
          DataBinding.FieldName = 'TUR'
          Visible = False
        end
        object GridBASolDBTableViewBorcID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
      end
      object GridBASolLevel1: TcxGridLevel
        GridView = GridBASolDBTableViewBorc
      end
    end
    object GridBASag: TcxGrid
      Left = 503
      Top = 1
      Width = 496
      Height = 420
      Align = alClient
      PopupMenu = PopupAlacak
      TabOrder = 1
      ExplicitLeft = 512
      ExplicitWidth = 487
      object GridBASagDBTableViewAlacak: TcxGridDBTableView
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
        OnCanFocusRecord = GridBASagDBTableViewAlacakCanFocusRecord
        OnCellClick = GridBASagDBTableViewAlacakCellDblClick
        DataController.DataSource = DtsAlacak
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Column = GridBASagDBTableViewAlacakTUTAR
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Column = GridBASagDBTableViewAlacakKAPANAN
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Column = GridBASagDBTableViewAlacakKALAN
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnCycle = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideSelection = True
        OptionsSelection.InvertSelect = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        Styles.OnGetContentStyle = GridBASagDBTableViewAlacakStylesGetContentStyle
        object GridBASagDBTableViewAlacakTARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
          Width = 59
        end
        object GridBASagDBTableViewAlacakVADE: TcxGridDBColumn
          Caption = 'Vade'
          DataBinding.FieldName = 'VADE'
          Width = 58
        end
        object GridBASagDBTableViewAlacakANAHTAR: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ANAHTAR'
          Width = 110
        end
        object GridBASagDBTableViewAlacakBELGENO: TcxGridDBColumn
          Caption = 'Belge No'
          DataBinding.FieldName = 'BELGENO'
        end
        object GridBASagDBTableViewAlacakTUTAR: TcxGridDBColumn
          Caption = 'Alacak'
          DataBinding.FieldName = 'TUTAR'
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 77
        end
        object GridBASagDBTableViewAlacakKAPANAN: TcxGridDBColumn
          Caption = 'Kapanan'
          DataBinding.FieldName = 'KAPANAN'
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 76
        end
        object GridBASagDBTableViewAlacakKALAN: TcxGridDBColumn
          Caption = 'Kalan'
          DataBinding.FieldName = 'KALAN'
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 71
        end
        object GridBASagDBTableViewAlacakKUR: TcxGridDBColumn
          Caption = 'Kur'
          DataBinding.FieldName = 'KUR'
          Width = 23
        end
        object GridBASagDBTableViewAlacakTUR: TcxGridDBColumn
          DataBinding.FieldName = 'TUR'
          Visible = False
        end
        object GridBASagDBTableViewAlacakID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
      end
      object GridBASagLevel1: TcxGridLevel
        GridView = GridBASagDBTableViewAlacak
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 495
      Top = 1
      Width = 8
      Height = 420
      HotZoneClassName = 'TcxSimpleStyle'
      Control = GridBASol
      ShowHint = False
      ParentShowHint = False
      ExplicitLeft = 488
      ExplicitTop = -7
    end
    object MemoAlacakSQL: TMemo
      Left = 49
      Top = 92
      Width = 889
      Height = 31
      Lines.Strings = (
        '--Fatura Kapatma ALACAK'
        ' DECLARE @RehID integer'
        ' DECLARE @DIL integer'
        'DECLARE @Kur nvarchar(5)'
        'set @RehID = :PRehID'
        'set @Kur =  :PKur'
        'set @DIL = -1'
        ''
        ''
        
          'select ASD.TUR,ASD.ID,ASD.TARIH,ASD.BELGENO,ASD.VADE,ASD.ANAHTAR' +
          ',ASD.TUTAR,ASD.KUR,'
        'KAPANAN=SUM(isnull(BK.TUTAR,0.0)),'
        'KALAN=ASD.TUTAR-SUM(isnull(BK.TUTAR,0.0))'
        'from ('
        '                --ALACAK --Fatura Giri'#351'i'
        
          '                SELECT TUR=F.TUR,F.ID,G.ANAHTAR,TARIH=F.FATURATA' +
          'RIH,BELGENO=F.FATURANO,VADE=F.FATURATARIH+ISNULL(F.VADE,0.0),'
        
          '                           --TUTAR=isnull(F.DOVIZ_TUTARI,F.FATUR' +
          'A_TUTARI),'
        
          '                           TUTAR=case when EKSTREDEKULLAN=1 then' +
          ' DOVIZ_TUTARI else FATURA_TUTARI end,'
        
          '                           KUR = case when EKSTREDEKULLAN=1 then' +
          ' F.DOVIZ_CINSI else F.KUR end'
        
          '                FROM FATBASLIK F inner join GENINI G on F.TUR=G.' +
          'DEGER and G.BOLUM=-1005 and G.DIL=@DIL'
        '                WHERE  isnull(F.DURUM,0)<>6'
        
          '                              --and isnull(F.DOVIZ_CINSI,F.KUR)=' +
          '@Kur'
        
          '                              and case when EKSTREDEKULLAN=1 the' +
          'n F.DOVIZ_CINSI else F.KUR end = @Kur'
        '                              and F.REHBERID = @RehID'
        '                              and F.TUR in (8,11,12,13)'
        ''
        '                UNION ALL --ALACAK --Kasa '#304#351'lemi'
        ''
        
          '                SELECT TUR=K.TUR,K.ID,G.ANAHTAR,TARIH=K.ISLEMTAR' +
          'IHI,K.BELGENO,VADE=K.ISLEMTARIHI,'
        
          '                           --TUTAR=isnull(K.DOVIZ_TUTARI,ALACAK)' +
          ','
        
          '                           Tutar=case when EKSTREDEKULLAN=1 AND ' +
          'ALACAK>0 then K.DOVIZ_TUTARI else K.ALACAK end,'
        '                           --KUR=isnull(K.DOVIZ_KURU,KUR)'
        
          '                                           KUR = case when EKSTR' +
          'EDEKULLAN=1 then K.DOVIZ_KURU else K.KUR end'
        
          '                FROM KASA K inner join GENINI G on K.TUR=G.DEGER' +
          ' and G.BOLUM=-1005 and G.DIL=@DIL'
        '                WHERE'
        
          '                                        --isnull(K.DOVIZ_KURU,K.' +
          'KUR)=@Kur'
        
          '                                        case when EKSTREDEKULLAN' +
          '=1 then K.DOVIZ_KURU else K.KUR end = @Kur'
        '                                  and K.REHBERID = @RehID'
        
          '                                  and K.TUR NOT IN (2,61,63,65,7' +
          '1,73,75)'
        '                                  and ALACAK>0'
        ''
        '                UNION ALL--ALACAK --'#199'ekle Tahsilat'
        ''
        
          '                SELECT TUR=23,CH.ID,'#39'Al'#305'nan '#199'ek '#39'+G.ANAHTAR,TARI' +
          'H=CH.TARIH,BELGENO=C.MAKBUZNO,VADE=C.VADE,'
        '                           --TUTAR=isnull(C.DOVIZ_TUTARI,TUTAR),'
        
          '                           Tutar=case when C.EKSTREDEKULLAN=1 th' +
          'en C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end,'
        '                           --KUR=isnull(C.DOVIZ_KURU,KUR)'
        
          '                                           KUR = case when C.EKS' +
          'TREDEKULLAN=1 then C.DOVIZ_KURU else C.KUR end'
        
          '                FROM CEKLER C inner join CEKHAREKET CH on C.ID=C' +
          'H.CEKSENETLERID inner join GENINI G on CH.ISLEM=G.DEGER and G.BO' +
          'LUM=-1005 and G.DIL=@DIL'
        '                WHERE'
        
          '                                  --isnull(C.DOVIZ_KURU,KUR)=@Ku' +
          'r'
        
          '                                        case when C.EKSTREDEKULL' +
          'AN=1 then C.DOVIZ_KURU else C.KUR end = @Kur'
        '                                  and CH.REHBERID = @RehID'
        '                                  and CH.ISLEM in (130,141)'
        ''
        ''
        ''
        
          ' ) as ASD left outer join BORCKAPATMA BK on ASD.TUR=BK.ALACAKTUR' +
          ' and ASD.ID=BK.ALACAKID'
        '--KOSUL'
        
          'group by ASD.TUR,ASD.ID,ASD.TARIH,ASD.BELGENO,ASD.VADE,ASD.ANAHT' +
          'AR,ASD.TUTAR,ASD.KUR'
        '')
      TabOrder = 3
      Visible = False
      WordWrap = False
    end
  end
  object JvNavPanelHeader4: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 1000
    Height = 39
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = 14540253
    ColorTo = 11776947
    ImageIndex = 0
    object Label1: TcxLabel
      Left = 3
      Top = 8
      Caption = 'Para Birimi : '
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label2: TcxLabel
      Left = 219
      Top = 9
      Caption = 'Mod :'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object RadioModIzle: TcxRadioButton
      Left = 264
      Top = 10
      Width = 68
      Height = 22
      Caption = #304'zleme'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = RadioModIzleClick
    end
    object RadioModEsle: TcxRadioButton
      Left = 335
      Top = 9
      Width = 66
      Height = 22
      Caption = 'E'#351'leme'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = RadioModIzleClick
    end
    object cxComboBox1: TcxComboBox
      Left = 89
      Top = 6
      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
      ParentFont = False
      Properties.OnEditValueChanged = cxComboBox1PropertiesEditValueChanged
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Arial'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 4
      Width = 73
    end
    object BtnEslestir: TcxButton
      Left = 407
      Top = 6
      Width = 88
      Height = 27
      Caption = 'E'#351'le'#351'tir'
      TabOrder = 5
      Visible = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnEslestirClick
    end
    object LabelAyrim: TcxLabel
      Left = 675
      Top = 11
      Caption = 'Ayr'#305'm :'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object RadioRenk: TcxRadioButton
      Left = 728
      Top = 11
      Width = 68
      Height = 22
      Caption = 'Renk'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      TabStop = True
      OnClick = RadioRenkClick
      GroupIndex = 1
    end
    object RadioSuzme: TcxRadioButton
      Left = 799
      Top = 11
      Width = 66
      Height = 22
      Caption = 'S'#252'zme'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 8
      OnClick = RadioRenkClick
      GroupIndex = 1
    end
  end
  object PopupBorc: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 176
    Top = 208
    object Busatrnbalantlarnsil2: TMenuItem
      Caption = 'Bu sat'#305'r'#305'n ba'#287'lant'#305'lar'#305'n'#305' sil'
      ImageIndex = 1
      OnClick = Busatrnbalantlarnsil2Click
    end
  end
  object TabBorc: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabBorcAfterScroll
    ParamData = <>
    SQL.Strings = (
      ''
      '--Fatura Kapatma BOR'#199
      'DECLARE @RehID integer'
      'DECLARE @DIL integer'
      'DECLARE @Kur nvarchar(5)'
      'set @RehID = :PRehID'
      'set @Kur = :PKur'
      'set @DIL = -1'
      ''
      '--bor'#231' sat'#305'rlar'#305' ve kapat'#305'lan k'#305's'#305'mlar'#305'..'
      
        'select ASD.TUR,ASD.ID,ASD.TARIH,ASD.BELGENO,ASD.VADE,ASD.ANAHTAR' +
        ',ASD.TUTAR,ASD.KUR,'
      'KAPANAN=SUM(isnull(BK.TUTAR,0.0)),'
      'KALAN=ASD.TUTAR-SUM(isnull(BK.TUTAR,0.0))'
      'from ('
      '                --BORC --Fatura Giri'#351'i'
      
        '                SELECT TUR=F.TUR,F.ID,G.ANAHTAR,TARIH=F.FATURATA' +
        'RIH,BELGENO=F.FATURANO,VADE=F.FATURATARIH+ISNULL(F.VADE,0.0),'
      
        '                           --TUTAR=isnull(F.DOVIZ_TUTARI,F.FATUR' +
        'A_TUTARI),'
      
        '                           TUTAR=case when EKSTREDEKULLAN=1 then' +
        ' DOVIZ_TUTARI else FATURA_TUTARI end,'
      '                           --KUR=isnull(F.DOVIZ_CINSI,F.KUR)'
      
        '                                           KUR = case when EKSTR' +
        'EDEKULLAN=1 then F.DOVIZ_CINSI else F.KUR end'
      
        '                FROM FATBASLIK F inner join GENINI G on F.TUR=G.' +
        'DEGER and G.BOLUM=-1005 and G.DIL=@DIL'
      '                WHERE'
      '                                        isnull(F.DURUM,0)<>6'
      
        '                                  --and isnull(F.DOVIZ_CINSI,F.K' +
        'UR)=@Kur'
      
        '                                  and case when EKSTREDEKULLAN=1' +
        ' then F.DOVIZ_CINSI else F.KUR end = @Kur'
      '                                  and F.REHBERID = @RehID'
      '                                  and F.TUR in (15,16,17)'
      ''
      '                UNION ALL --BORC --Kasa '#304#351'lemi'
      ''
      
        '                SELECT TUR=K.TUR,K.ID,G.ANAHTAR,TARIH=K.ISLEMTAR' +
        'IHI,K.BELGENO,VADE=K.ISLEMTARIHI,'
      '                           --TUTAR=isnull(K.DOVIZ_TUTARI,BORC),'
      
        '                           TUTAR=case when EKSTREDEKULLAN=1 AND ' +
        'K.BORC>0 then K.DOVIZ_TUTARI else K.BORC end,'
      '                           --KUR=isnull(K.DOVIZ_KURU,KUR)'
      
        '                                           KUR = case when EKSTR' +
        'EDEKULLAN=1 then K.DOVIZ_KURU else K.KUR end'
      
        '                FROM KASA K inner join GENINI G on K.TUR=G.DEGER' +
        ' and G.BOLUM=-1005 and G.DIL=@DIL'
      '                WHERE'
      
        '                                        --isnull(K.DOVIZ_KURU,K.' +
        'KUR)=@Kur'
      
        '                                        case when EKSTREDEKULLAN' +
        '=1 then K.DOVIZ_KURU else K.KUR end = @Kur'
      '                                  and K.REHBERID = @RehID'
      
        '                                  and K.TUR NOT IN (2,61,63,65,7' +
        '1,73,75)'
      '                                  and BORC>0'
      ''
      '                UNION ALL --BORC --'#199'ekle '#214'deme'
      ''
      
        '                SELECT TUR=33,CH.ID,'#39'Verilen '#199'ek '#39'+G.ANAHTAR,TAR' +
        'IH=CH.TARIH,BELGENO=C.MAKBUZNO,VADE=C.VADE,'
      '                           --TUTAR=isnull(C.DOVIZ_TUTARI,TUTAR),'
      
        '                           TUTAR=case when C.EKSTREDEKULLAN=1 th' +
        'en C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end,'
      '                           --KUR=isnull(C.DOVIZ_KURU,KUR)'
      
        '                                           KUR = case when C.EKS' +
        'TREDEKULLAN=1 then C.DOVIZ_KURU else C.KUR end'
      
        '                FROM CEKLER C inner join CEKHAREKET CH on C.ID=C' +
        'H.CEKSENETLERID inner join GENINI G on CH.ISLEM=G.DEGER and G.BO' +
        'LUM=-1005 and G.DIL=@DIL'
      '                WHERE'
      
        '                                        --isnull(C.DOVIZ_KURU,KU' +
        'R)=@Kur'
      
        '                                        case when C.EKSTREDEKULL' +
        'AN=1 then C.DOVIZ_KURU else C.KUR end = @Kur'
      '                                  and CH.REHBERID = @RehID'
      
        '                                  and CH.ISLEM in (140,131,132,1' +
        '33,134,137)'
      ''
      
        ') as ASD left outer join BORCKAPATMA BK on ASD.TUR=BK.BORCTUR an' +
        'd ASD.ID=BK.BORCID'
      
        'group by ASD.TUR,ASD.ID,ASD.TARIH,ASD.BELGENO,ASD.VADE,ASD.ANAHT' +
        'AR,ASD.TUTAR,ASD.KUR'
      '')
    Left = 48
    Top = 192
  end
  object DtsBorc: TDataSource
    DataSet = TabBorc
    Left = 48
    Top = 248
  end
  object TabAlacak: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      '')
    Left = 624
    Top = 120
  end
  object PopupAlacak: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 704
    Top = 128
    object Busatrnbalantlarnsil1: TMenuItem
      Caption = 'Bu sat'#305'r'#305'n ba'#287'lant'#305'lar'#305'n'#305' sil'
      ImageIndex = 1
      OnClick = Busatrnbalantlarnsil1Click
    end
  end
  object DtsAlacak: TDataSource
    DataSet = TabAlacak
    Left = 624
    Top = 176
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 440
    Top = 80
    PixelsPerInch = 96
    object cxStyleSeciliHucre: TcxStyle
      AssignedValues = [svColor]
      Color = clYellow
    end
    object cxStyle1: TcxStyle
    end
  end
  object TabCapraz: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabCaprazAfterOpen
    ParamData = <>
    Left = 424
    Top = 240
  end
end
