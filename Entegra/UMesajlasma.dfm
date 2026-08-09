object MesajlasmaDlg: TMesajlasmaDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Mesajla'#351'ma Ekran'#305
  ClientHeight = 572
  ClientWidth = 1398
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMesajlasma: TPanel
    Left = 0
    Top = 0
    Width = 1398
    Height = 572
    Align = alClient
    Color = clGradientInactiveCaption
    ParentBackground = False
    TabOrder = 0
    object Panel18: TPanel
      Left = 1
      Top = 1
      Width = 1396
      Height = 24
      Align = alTop
      Color = clSkyBlue
      ParentBackground = False
      TabOrder = 0
      object Label12: TLabel
        Left = 6
        Top = 3
        Width = 70
        Height = 18
        Caption = 'Mesajla'#351'ma'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object MesajLED: TJvLED
        Left = 83
        Top = 4
        Status = False
      end
      object Label2: TLabel
        Left = 123
        Top = -3
        Width = 35
        Height = 29
        Caption = '+   '
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -24
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label3: TLabel
        Left = 234
        Top = -3
        Width = 35
        Height = 29
        Caption = '+   '
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -24
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LabelYeniGrup: TLabel
        Left = 250
        Top = 3
        Width = 62
        Height = 18
        Caption = 'Yeni Grup'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = LabelYeniGrupClick
      end
      object LabelYeniKisi: TLabel
        Left = 135
        Top = 3
        Width = 56
        Height = 18
        Caption = ' Yeni ki'#351'i'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = LabelYeniKisiClick
      end
    end
    object ScrollBox2: TScrollBox
      Left = 1
      Top = 25
      Width = 408
      Height = 546
      Align = alLeft
      TabOrder = 1
      object GridPersonel: TcxGrid
        Left = 0
        Top = 31
        Width = 404
        Height = 511
        Align = alClient
        PopupMenu = MesajMenu
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridPersonelDBTableViewKisiler: TcxGridDBTableView
          PopupMenu = MesajMenu
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsMesajKisiler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          Images = Tablo.PNGImageList2
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.DataRowHeight = 40
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Header = False
          OptionsView.IndicatorWidth = 0
          object GridPersonelDBTableViewKisilerColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'FIRMA'
            PropertiesClassName = 'TcxTextEditProperties'
            Options.ShowCaption = False
            Width = 180
            IsCaptionAssigned = True
          end
          object GridPersonelDBTableViewKisilerColumn2: TcxGridDBColumn
            DataBinding.FieldName = 'OKUNMAMIS'
            Width = 20
          end
          object GridPersonelDBTableViewKisilerColumn3: TcxGridDBColumn
            DataBinding.FieldName = 'MESAJ'
          end
          object GridPersonelDBTableViewKisilerColumn4: TcxGridDBColumn
            DataBinding.FieldName = 'ZAMAN'
          end
        end
        object GridPersonelCardView1: TcxGridCardView
          Navigator.Buttons.CustomButtons = <>
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.CardIndent = 7
          object GridPersonelCardView1Row1: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
          object GridPersonelCardView1Row2: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
          object GridPersonelCardView1Row3: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
          object GridPersonelCardView1Row4: TcxGridCardViewRow
            Position.BeginsLayer = True
          end
        end
        object GridPersonelDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          OnCellClick = GridPersonelDBCardView1CellClick
          OnCellDblClick = GridPersonelDBCardView1CellDblClick
          DataController.DataSource = DtsMesajKisiler
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.CellSelect = False
          OptionsView.CaptionSeparator = #0
          OptionsView.CardIndent = 7
          OptionsView.CardWidth = 372
          Styles.Background = Tablo.cxStSelected
          object GridPersonelDBCardView1Row5: TcxGridDBCardViewRow
            DataBinding.FieldName = 'RESIM '
            PropertiesClassName = 'TcxImageProperties'
            Position.BeginsLayer = True
            Position.LineCount = 2
            Position.Width = 20
            IsCaptionAssigned = True
          end
          object GridPersonelDBCardView1Row1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'FIRMA'
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 70
          end
          object GridPersonelDBCardView1Row4: TcxGridDBCardViewRow
            DataBinding.FieldName = 'ZAMAN'
            PropertiesClassName = 'TcxTextEditProperties'
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 60
          end
          object GridPersonelDBCardView1Row3: TcxGridDBCardViewRow
            DataBinding.FieldName = 'OKUNMAMIS'
            PropertiesClassName = 'TcxTextEditProperties'
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 15
          end
          object GridPersonelDBCardView1Row2: TcxGridDBCardViewRow
            DataBinding.FieldName = 'MESAJ'
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
        end
        object GridPersonelLevel1: TcxGridLevel
          GridView = GridPersonelDBCardView1
        end
      end
      object Panel10: TPanel
        Left = 0
        Top = 0
        Width = 404
        Height = 31
        Align = alTop
        TabOrder = 0
        Visible = False
        object MesajPersonAra: TcxButtonEdit
          AlignWithMargins = True
          Left = 7
          Top = 4
          Hint = 'Personel ara'
          ParentShowHint = False
          Properties.Buttons = <>
          ShowHint = True
          TabOrder = 0
          TextHint = 'Ara'
          Visible = False
          Width = 257
        end
      end
    end
    object PanelChat: TPanel
      Left = 409
      Top = 25
      Width = 988
      Height = 546
      Align = alClient
      TabOrder = 2
      object Panel4: TPanel
        Left = 1
        Top = 504
        Width = 986
        Height = 41
        Align = alBottom
        TabOrder = 0
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 0
          OnKeyUp = MemoChatKeyUp
          Height = 39
          Width = 838
        end
        object BtnMesajGonder: TcxButton
          Left = 839
          Top = 1
          Width = 85
          Height = 39
          Align = alRight
          OptionsImage.ImageIndex = 39
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 1
          OnClick = BtnMesajGonderClick
        end
        object BtnDosyaGonder: TcxButton
          Left = 924
          Top = 1
          Width = 61
          Height = 39
          Align = alRight
          Kind = cxbkDropDown
          OptionsImage.ImageIndex = 38
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 2
        end
      end
      object GridMesaj: TcxGrid
        Left = 1
        Top = 1
        Width = 986
        Height = 503
        Align = alClient
        PopupMenu = MesajMenu
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object cxGridDBTableView1: TcxGridDBTableView
          PopupMenu = MesajMenu
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsMesajKisiler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          Images = Tablo.PNGImageList2
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.DataRowHeight = 40
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Header = False
        end
        object GridMesajDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsMesajlar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsData.Deleting = False
          OptionsSelection.CellSelect = False
          OptionsView.ScrollBars = ssVertical
          OptionsView.CaptionSeparator = #0
          OptionsView.CardIndent = 7
          OptionsView.CardWidth = 845
          OptionsView.CellAutoHeight = True
          Styles.Background = Tablo.cxStyle10
          Styles.CardBorder = Tablo.cxStyle10
          object GridMesajDBCardView1Row4: TcxGridDBCardViewRow
            DataBinding.FieldName = 'KIMDEN'
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 100
          end
          object GridMesajDBCardView1Row2: TcxGridDBCardViewRow
            DataBinding.FieldName = 'ZAMAN'
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            CaptionAlignmentHorz = taRightJustify
            Options.Editing = False
            Position.BeginsLayer = False
            Styles.Content = Tablo.cxStyle10
            IsCaptionAssigned = True
          end
          object GridMesajDBCardView1Row1: TcxGridDBCardViewRow
            DataBinding.FieldName = 'GIDENMESAJ'
            Options.Editing = False
            Position.BeginsLayer = True
            Position.Width = 400
            Styles.Content = Tablo.cxStyle10
            IsCaptionAssigned = True
          end
          object GridMesajDBCardView1Row3: TcxGridDBCardViewRow
            DataBinding.FieldName = 'GELENMESAJ'
            Options.Editing = False
            Position.BeginsLayer = False
            Styles.Content = Tablo.cxStyle10
            IsCaptionAssigned = True
          end
        end
        object GridMesajLevel1: TcxGridLevel
          GridView = GridMesajDBCardView1
        end
      end
    end
  end
  object MesajMenu: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 477
    Top = 203
    object KonusmaGecmisiMenu: TMenuItem
      Caption = 'Konu'#351'ma Ge'#231'mi'#351'ini G'#246'ster'
      ImageIndex = 19
    end
  end
  object DtsMesajKisiler: TDataSource
    DataSet = TabMesajKisiler
    Left = 115
    Top = 302
  end
  object TabMesajKisiler: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      
        '-- Kullan'#305'c'#305'ya ki'#351'ilerden gelen/giden ve gruptan gelen/giden mes' +
        'aj olabilir.'
      'Declare @KULID int'
      'Declare @Bugun datetime'
      ''
      'set @KULID=:PRID'
      'set @Bugun = GETDATE()'
      ''
      ''
      
        'select SERVERID=0,MESAJID,M.TARIH, Liste.REHBERID, R.FIRMA, R.G' +
        'RUP,'
      
        'OKUNMAMIS=(case when (select count(*) from MESAJLOG M inner join' +
        ' MESAJLOGKULLANICI K on M.ID=K.MESAJLOGID '
      
        '                      where M.GONDERENID=Liste.REHBERID and K.OK' +
        'UNMATARIHI is null)>0 then'
      
        '                  (convert(varchar(5), (select count(*) from MES' +
        'AJLOG M inner join MESAJLOGKULLANICI K on M.ID=K.MESAJLOGID '
      
        '                     where M.GONDERENID=Liste.REHBERID and K.OKU' +
        'NMATARIHI is null)))'
      #9#9#9#9'else '#39#39' end),'
      
        'ZAMAN=dbo.fn_prg_iki_tarih_farki_Yazi(M.TARIH,@Bugun), M.MESAJ,R' +
        '.RESIM'
      'from ('
      'select '
      
        #9'MESAJID=max(M.ID), REHBERID=(case when ALANID=@KULID then M.GON' +
        'DERENID else ALANID end)  '
      'from  '
      #9'MESAJLOG M '
      #9'--inner join MESAJLOGKULLANICI L on M.ID=L.MESAJLOGID'
      'where'
      '-- Ki'#351'i Giden mesaj'
      #9'1=case '
      
        #9'    when M.GRUP=0 and (M.GONDERENID=@KULID or M.ALANID=@KULID) ' +
        'then 1 '
      
        #9'    --when M.GRUP=1 and @KULID in (select K.ALICIID from MESAJL' +
        'OGKULLANICI K where M.ID=K.MESAJLOGID) then 1 '
      
        #9#9'when M.GRUP=1 and @KULID in (select ALICILAR=DEGER from GENINI' +
        ' where BOLUM=99 and DIL=M.ALANID) then 1 '
      #9#9'else 0 '
      #9'end'
      ''
      '-- Ki'#351'i Gelen mesaj'
      #9
      
        'group by (case when ALANID=@KULID then M.GONDERENID else ALANID ' +
        'end)  '
      ''
      ')as Liste '
      'inner join MESAJLOG M on M.ID=Liste.MESAJID'
      'inner join REHBER R on R.ID=Liste.REHBERID'
      'left join KULLANICI K on R.ID=K.REHBERID'
      'order by 2 desc')
    Left = 119
    Top = 240
  end
  object TabMesajlar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'Declare @KULID int'
      'Declare @KARSIID int'
      'Declare @Bugun datetime'
      ''
      'set @KULID=:PKULID'
      'set @KARSIID= :PKARSIID'
      'set @Bugun = GETDATE()'
      ''
      'SET LANGUAGE turkish;  '
      ''
      'select distinct'
      'TARIH,'#9
      'ZAMAN=dbo.fn_prg_iki_tarih_farki_Yazi(TARIH,@Bugun),'#9
      #9
      #9'KIMDEN=RG.FIRMA,'
      
        #9'GELENMESAJ = case when M.GONDERENID = @KULID then MESAJ else '#39#39 +
        ' end,'
      
        #9'GIDENMESAJ = case when M.GONDERENID <> @KULID then MESAJ else '#39 +
        #39' end'
      'from '
      #9'MESAJLOG M  '
      #9'inner join REHBER RG on RG.ID=M.GONDERENID'
      'where '
      #9'1=case '
      
        #9'    when M.GRUP=0 and ((M.GONDERENID=@KARSIID and M.ALANID=@KUL' +
        'ID) or (M.GONDERENID=@KULID and M.ALANID=@KARSIID)) then 1 '
      #9#9'when M.GRUP=1 and M.ALANID=@KARSIID then 1 '
      #9#9'else 0 '
      #9'end'
      'order by 1'
      ''
      'SET LANGUAGE us_english;  '
      ''
      ''
      ''
      '')
    Left = 855
    Top = 184
  end
  object DtsMesajlar: TDataSource
    DataSet = TabMesajlar
    Left = 739
    Top = 174
  end
end

