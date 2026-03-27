object MaasTabloDlg: TMaasTabloDlg
  Left = 0
  Top = 0
  Width = 1071
  Height = 600
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object GridMaas: TcxGrid
    Left = 0
    Top = 34
    Width = 1071
    Height = 311
    Align = alClient
    PopupMenu = TabloyuOlustur
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object MaasTakvimView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = MaasTakvimViewCanFocusRecord
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsPlanMTablo
      DataController.KeyFieldNames = 'ID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = '###,###,###.00'
          Kind = skSum
          FieldName = 'TOPLAMMAAS'
          Column = MaasTakvimViewTOPLAMMAAS
        end
        item
          Format = '###,###,###.00'
          Kind = skSum
          Column = MaasTakvimViewBANKA
        end
        item
          Format = '###,###,###.00'
          Kind = skSum
          Column = MaasTakvimViewKASA
        end
        item
          Kind = skCount
          FieldName = 'FIRMA'
          Column = MaasTakvimViewFIRMA
        end
        item
          Format = '###,###,###.00'
          Kind = skSum
          FieldName = 'TAHAKKUK'
          Column = MaasTakvimViewTAHAKKUK
        end
        item
          Format = '###,###,###.00'
          Kind = skSum
          FieldName = 'KESINTI'
          Column = MaasTakvimViewKESINTI
        end
        item
          Format = '###,###,###.00'
          Kind = skSum
          FieldName = 'ODEBANKA'
          Column = MaasTakvimViewODEBANKA
        end
        item
          Format = '###,###,###.00'
          Kind = skSum
          FieldName = 'ODEKASA'
          Column = MaasTakvimViewODEKASA
        end
        item
          Format = '###,###,###.00'
          Kind = skSum
          FieldName = 'AGI'
          Column = MaasTakvimViewAGI
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      Styles.ContentOdd = Tablo.cxstSecili
      object MaasTakvimViewSEC: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.FieldName = 'SEC'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        Properties.OnEditValueChanged = MaasTakvimViewSECPropertiesEditValueChanged
        Width = 31
      end
      object MaasTakvimViewFIRMA: TcxGridDBColumn
        Caption = 'Ad Soyad'
        DataBinding.FieldName = 'FIRMA'
        Options.Editing = False
        Width = 80
      end
      object MaasTakvimViewKATEGORI: TcxGridDBColumn
        Caption = 'Birimi'
        DataBinding.FieldName = 'POZISYON'
        RepositoryItem = Tablo.RepCariRoller
        Options.Editing = False
        Width = 121
      end
      object MaasTakvimViewTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        Options.Editing = False
        Width = 68
      end
      object MaasTakvimViewBANKA: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKA'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Visible = False
        Options.Editing = False
        Width = 68
      end
      object MaasTakvimViewKASA: TcxGridDBColumn
        Caption = 'Kasa'
        DataBinding.FieldName = 'KASA'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Visible = False
        Options.Editing = False
        Width = 68
      end
      object MaasTakvimViewTAHAKKUK: TcxGridDBColumn
        Caption = 'Tahakkuk'
        DataBinding.FieldName = 'TAHAKKUK'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Options.Editing = False
        Width = 70
      end
      object MaasTakvimViewKESINTI: TcxGridDBColumn
        Caption = 'Kesinti'
        DataBinding.FieldName = 'KESINTI'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Options.Editing = False
        Width = 74
      end
      object MaasTakvimViewAGI: TcxGridDBColumn
        Caption = 'Agi'
        DataBinding.FieldName = 'AGI'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Visible = False
        Options.Editing = False
        Width = 32
      end
      object MaasTakvimViewTOPLAMMAAS: TcxGridDBColumn
        Caption = 'Toplam'
        DataBinding.FieldName = 'TOPLAMMAAS'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Options.Editing = False
        Width = 68
      end
      object MaasTakvimViewKUR: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        PropertiesClassName = 'TcxComboBoxProperties'
        Properties.ImmediatePost = True
        Options.Editing = False
      end
      object MaasTakvimViewODEBANKA: TcxGridDBColumn
        Caption = #214'de.Banka'
        DataBinding.FieldName = 'ODEBANKA'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Options.Editing = False
      end
      object MaasTakvimViewODEKASA: TcxGridDBColumn
        Caption = #214'de.Kasa'
        DataBinding.FieldName = 'ODEKASA'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Options.Editing = False
      end
      object MaasTakvimViewBORCLUBNKADI: TcxGridDBColumn
        Caption = 'Kurum Banka'
        DataBinding.FieldName = 'BORCLUBANKASI'
        Options.Editing = False
        Width = 75
      end
      object MaasTakvimViewALACAKLIBNKADI: TcxGridDBColumn
        Caption = 'Personel Banka'
        DataBinding.FieldName = 'ALACAKLIBNKADI'
        Options.Editing = False
        Width = 79
      end
      object MaasTakvimViewBELGENO: TcxGridDBColumn
        Caption = 'Belge No'
        DataBinding.FieldName = 'BELGENO'
        Options.Editing = False
        Width = 64
      end
      object MaasTakvimViewEXCELISLENDI: TcxGridDBColumn
        Caption = 'Excel'
        DataBinding.FieldName = 'EXCELISLENDI'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
      end
      object MaasTakvimViewTAHAKKUKISLENDI: TcxGridDBColumn
        Caption = 'Tah.'
        DataBinding.FieldName = 'TAHAKKUKISLENDI'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
      end
      object MaasTakvimViewBANKAISLENDI: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKAISLENDI'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Width = 38
      end
      object MaasTakvimViewKASAISLENDI: TcxGridDBColumn
        Caption = 'Kasa'
        DataBinding.FieldName = 'KASAISLENDI'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
      end
      object MaasTakvimViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        Options.Editing = False
      end
      object MaasTakvimViewBORCLUBNK: TcxGridDBColumn
        DataBinding.FieldName = 'BORCLUBNK'
        PropertiesClassName = 'TcxCalcEditProperties'
        Properties.ImmediatePost = True
        Options.Editing = False
      end
      object MaasTakvimViewALACAKLIBNK: TcxGridDBColumn
        DataBinding.FieldName = 'ALACAKLIBNK'
        Options.Editing = False
      end
      object MaasTakvimViewBORCLUKASA: TcxGridDBColumn
        Caption = 'Bor'#231'lu Kasa'
        DataBinding.FieldName = 'BORCLUKASA'
        Options.Editing = False
      end
      object MaasTakvimViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        Visible = False
        Options.Editing = False
      end
      object MaasTakvimViewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
      end
    end
    object cxGridLevel3: TcxGridLevel
      GridView = MaasTakvimView
    end
  end
  object Memo1: TMemo
    Left = 93
    Top = 255
    Width = 221
    Height = 134
    Lines.Strings = (
      'AD'
      'SOYAD'
      'S'#304'C'#304'L'
      #350'UBE'
      'HESAP'
      'TUTAR'
      'MAA'#350
      'MEBLA'#286
      'M'#304'KTAR')
    TabOrder = 2
    Visible = False
  end
  object MemoUyari: TcxMemo
    Left = 0
    Top = 511
    Align = alBottom
    TabOrder = 3
    Visible = False
    Height = 89
    Width = 1071
  end
  object SQLInsert: TMemo
    Left = 94
    Top = 59
    Width = 793
    Height = 31
    Lines.Strings = (
      'insert into PLANMTABLO (REHBERID,SEC,TARIH,BANKA,KASA,'
      
        '    EXCELISLENDI,TAHAKKUKISLENDI,BANKAISLENDI,KASAISLENDI,BORCLU' +
        'BNK,ALACAKLIBNK,BORCLUKASA, BELGENO,DURUM)'
      ''
      'Select REHBERID=ID,SEC=1, TARIH,'
      'BANKA=0,KASA=0,--KUR,'
      
        '    EXCELISLENDI=0,TAHAKKUKISLENDI=0,BANKAISLENDI=0,KASAISLENDI=' +
        '0,BORCLUBNK,ALACAKLIBNK,BORCLUKASA,BELGENO,DURUMM'
      'from ('
      'select R.ID,R.KOD, R.FIRMA, R.KATEGORI,TARIH='#39'B'#304'T'#304#350'TAR'#304'H'#304#39','
      
        'BORCLUBNK = (select top 1 ID from BANKAHESAPLAR BH where BH.REHB' +
        'ERID=-1  and BH.MAASHESABI=1),'
      
        'ALACAKLIBNK=(select top 1 ID from BANKAHESAPLAR BH where BH.REHB' +
        'ERID=R.ID ),'
      'BORCLUKASA=(select top 1 ID from KASALAR K where K.KUR='#39'TL'#39'),'
      'BELGENO='#39#39','
      'DURUMM=:DRM'
      
        'from REHBER R inner join PERS_HAREKET PH on R.ID=PH.REHBERID AND' +
        ' TUR=1'
      
        'where R.DURUM = 1 AND R.GRUP = 335 AND PH.TARIH<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 2' +
        '3:59'#39'  '
      '--R.ID'
      ') AS T'
      'ORDER BY 1')
    TabOrder = 1
    Visible = False
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 345
    Width = 1071
    Height = 166
    Align = alBottom
    TabOrder = 4
    object cxPageControl1: TcxPageControl
      Left = 1
      Top = 1
      Width = 528
      Height = 164
      Align = alLeft
      TabOrder = 0
      Properties.ActivePage = cxTabSheet1
      Properties.CustomButtons.Buttons = <>
      ClientRectBottom = 160
      ClientRectLeft = 4
      ClientRectRight = 524
      ClientRectTop = 24
      object cxTabSheet1: TcxTabSheet
        Caption = 'Tahakkuk'
        ImageIndex = 0
        object GridTahakkuk: TcxGrid
          Left = 0
          Top = 0
          Width = 520
          Height = 136
          Align = alClient
          BevelEdges = []
          BevelInner = bvNone
          BevelOuter = bvNone
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridTahakkukView: TcxGridDBTableView
            PopupMenu = PopupMenuTahakkuk
            OnDblClick = TahakkukDuzenleClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsTahakkuk
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;'
                Kind = skSum
                FieldName = 'TUTAR'
                Column = GridTahakkukViewTUTAR
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.Footer = True
            OptionsView.GridLines = glNone
            OptionsView.GroupByBox = False
            OptionsView.Header = False
            Styles.ContentOdd = Tablo.cxStFaturaKontrol
            object GridTahakkukViewETIKET: TcxGridDBColumn
              Caption = 'T'#252'r'#252
              DataBinding.FieldName = 'ETIKET'
              MinWidth = 300
              Options.Editing = False
              Options.Filtering = False
              Options.Focusing = False
              Options.IgnoreTimeForFiltering = False
              Options.IncSearch = False
              Options.FilteringFilteredItemsList = False
              Options.FilteringMRUItemsList = False
              Options.FilteringPopup = False
              Options.FilteringPopupMultiSelect = False
              Options.GroupFooters = False
              Options.Grouping = False
              Options.HorzSizing = False
              Options.Moving = False
              Options.ShowCaption = False
              Options.Sorting = False
              Width = 300
            end
            object GridTahakkukViewTUTAR: TcxGridDBColumn
              Caption = 'Bilgisi'
              DataBinding.FieldName = 'TUTAR'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              MinWidth = 100
              Options.Editing = False
              Options.Filtering = False
              Options.Focusing = False
              Options.IgnoreTimeForFiltering = False
              Options.IncSearch = False
              Options.FilteringFilteredItemsList = False
              Options.FilteringMRUItemsList = False
              Options.FilteringPopup = False
              Options.FilteringPopupMultiSelect = False
              Options.GroupFooters = False
              Options.Grouping = False
              Options.HorzSizing = False
              Options.Moving = False
              Options.ShowCaption = False
              Options.Sorting = False
              Width = 100
            end
            object GridTahakkukViewKUR: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
            end
            object GridTahakkukViewSIRA: TcxGridDBColumn
              DataBinding.FieldName = 'SIRA'
              Visible = False
            end
          end
          object cxGridLevel5: TcxGridLevel
            GridView = GridTahakkukView
          end
        end
      end
    end
    object cxPageControl2: TcxPageControl
      Left = 529
      Top = 1
      Width = 541
      Height = 164
      Align = alClient
      TabOrder = 1
      Properties.ActivePage = cxTabSheet2
      Properties.CustomButtons.Buttons = <>
      ClientRectBottom = 160
      ClientRectLeft = 4
      ClientRectRight = 537
      ClientRectTop = 24
      object cxTabSheet2: TcxTabSheet
        Caption = 'Kesinti'
        ImageIndex = 0
        object GridKesinti: TcxGrid
          Left = 0
          Top = 0
          Width = 533
          Height = 136
          Align = alClient
          BevelEdges = []
          BevelInner = bvNone
          BevelOuter = bvNone
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          object GridKesintiView: TcxGridDBTableView
            PopupMenu = PopupMenuKesinti
            OnDblClick = KesintiDuzenleClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsKesinti
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;'
                Kind = skSum
                FieldName = 'TUTAR'
                Column = cxGridDBColumn2
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.Footer = True
            OptionsView.GridLines = glNone
            OptionsView.GroupByBox = False
            OptionsView.Header = False
            Styles.ContentOdd = Tablo.cxStSerinoCikilmis
            object GridKesintiViewColumn2: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Width = 30
            end
            object cxGridDBColumn1: TcxGridDBColumn
              Caption = 'T'#252'r'#252
              DataBinding.FieldName = 'ETIKET'
              MinWidth = 250
              Options.Editing = False
              Options.Filtering = False
              Options.Focusing = False
              Options.IgnoreTimeForFiltering = False
              Options.IncSearch = False
              Options.FilteringFilteredItemsList = False
              Options.FilteringMRUItemsList = False
              Options.FilteringPopup = False
              Options.FilteringPopupMultiSelect = False
              Options.GroupFooters = False
              Options.Grouping = False
              Options.HorzSizing = False
              Options.Moving = False
              Options.ShowCaption = False
              Options.Sorting = False
              Width = 250
            end
            object cxGridDBColumn2: TcxGridDBColumn
              Caption = 'Bilgisi'
              DataBinding.FieldName = 'TUTAR'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              MinWidth = 100
              Options.Editing = False
              Options.Filtering = False
              Options.Focusing = False
              Options.IgnoreTimeForFiltering = False
              Options.IncSearch = False
              Options.FilteringFilteredItemsList = False
              Options.FilteringMRUItemsList = False
              Options.FilteringPopup = False
              Options.FilteringPopupMultiSelect = False
              Options.GroupFooters = False
              Options.Grouping = False
              Options.HorzSizing = False
              Options.Moving = False
              Options.ShowCaption = False
              Options.Sorting = False
              Width = 100
            end
            object GridKesintiViewColumn1: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              Width = 20
            end
            object GridKesintiViewColumn3: TcxGridDBColumn
              DataBinding.FieldName = 'TUR'
              Width = 20
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = GridKesintiView
          end
        end
      end
    end
  end
  object SQLTahakkukInsert: TMemo
    Left = 91
    Top = 159
    Width = 793
    Height = 33
    Lines.Strings = (
      
        'insert into PLANMAAS ([YER],[YERID],[SIRA],[ETIKET],[TUTAR],[KUR' +
        '])'
      'select [YER]=:Prm1,[YERID]=T.ID, SIRA, ETIKET,TUTAR,M.KUR'
      'from PLANMAAS M'
      'inner join PLANMTABLO T on M.YERID=T.REHBERID'
      'inner join PERS_HAREKET PH on M.YERID=PH.REHBERID and PH.TUR=1'
      
        'where M.YER=:Prm2 and  T.TARIH >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH' +
        '<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23:59'#39
      '--M.YERID'
      'order by SIRA')
    TabOrder = 5
    Visible = False
  end
  object SQLUpdPlanMTablo: TMemo
    Left = 117
    Top = 198
    Width = 793
    Height = 42
    Lines.Strings = (
      'UPDATE PLANMTABLO SET'
      
        '--BANKA=ISNULL((SELECT TUTAR FROM dbo.PLANMAAS WHERE YER=51 AND ' +
        'YERID=PLANMTABLO.REHBERID),0),'
      
        '--KASA=ISNULL((SELECT sum(TUTAR) FROM PLANMAAS where YER=11 and ' +
        'YERID=PLANMTABLO.ID),0)'
      
        '--'#9'-ISNULL((SELECT TUTAR FROM dbo.PLANMAAS WHERE YER=51 AND YERI' +
        'D=PLANMTABLO.REHBERID),0),'
      
        'KUR= ISNULL((SELECT TOP 1 KUR FROM PLANMAAS WHERE YERID=PLANMTAB' +
        'LO.REHBERID),'#39#39'),'
      
        'TAHAKKUK=ISNULL((SELECT sum(TUTAR) FROM PLANMAAS where YER=11 an' +
        'd YERID=PLANMTABLO.ID),0),'
      
        'KESINTI=ISNULL((SELECT sum(TUTAR) FROM PLANMAAS where YER=21 and' +
        ' YERID=PLANMTABLO.ID ),0),'
      
        'PLANMTABLO.TOPLAMMAAS=(ISNULL((SELECT sum(TUTAR) FROM PLANMAAS W' +
        'HERE YER=11 and YERID=PLANMTABLO.ID),0)'
      
        #9'-ISNULL((SELECT sum(TUTAR) from PLANMAAS where YER=21 and YERID' +
        '=PLANMTABLO.ID ),0)'#9#9#9'),'
      
        'PLANMTABLO.ODEBANKA=(ISNULL((SELECT SUM(TUTAR) FROM dbo.PLANMAAS' +
        ' WHERE YER=51 AND YERID=PLANMTABLO.REHBERID),0)'
      
        #9'-ISNULL((SELECT SUM(TUTAR) FROM dbo.PLANMAAS WHERE YER=21 AND T' +
        'UR='#39'B'#39' AND YERID=PLANMTABLO.ID ),0)),'
      
        'PLANMTABLO.ODEKASA='#9'(select ISNULL(sum(TUTAR),0) from PLANMAAS w' +
        'here YER=11 and YERID=PLANMTABLO.ID)'
      
        #9'-ISNULL((SELECT TUTAR FROM dbo.PLANMAAS WHERE YER=51 AND YERID=' +
        'PLANMTABLO.REHBERID),0)'
      
        #9'-(SELECT ISNULL(SUM(TUTAR),0) FROM dbo.PLANMAAS WHERE YER=21  A' +
        'ND YERID=PLANMTABLO.ID ),--AND TUR='#39'K'#39
      
        'PLANMTABLO.AGI=ISNULL((SELECT SUM(TUTAR) FROM dbo.PLANMAAS WHERE' +
        ' YER=11 AND SIRA=12 AND YERID=PLANMTABLO.ID),0)'
      
        'WHERE TARIH >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and TARIH<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23:59' +
        #39' AND DURUM=:DRM'
      '--REHBERID')
    TabOrder = 6
    Visible = False
  end
  object SQLKesInsert: TMemo
    Left = 94
    Top = 96
    Width = 793
    Height = 33
    Lines.Strings = (
      ''
      
        'insert into PLANMAAS ([YER],[YERID],[TARIH],[SIRA],[ETIKET],[TUT' +
        'AR],[KUR],[DURUM],[TUR])'
      '--verilmi'#351' avanslar'#305
      
        'select  [YER],[YERID], ISLEMTARIHI, SIRA, ETIKET,TUTAR=sum(ALACA' +
        'K-BORC), KUR,DURUM,TUR'
      'from('
      
        'select [YER]=21,[YERID]=T.ID, ISLEMTARIHI, SIRA=0, ETIKET='#39'Avans' +
        #39',K.ALACAK,K.BORC, K.KUR,DURUM=196,'
      
        'TUR='#39'K'#39'--(select HESAPTURU from KASA where REHBERID=K.REHBERID a' +
        'nd GERIDONUSID=K.ID and TUR in (40,42))'
      'from KASA K'
      'inner join PLANMTABLO T on K.REHBERID=T.REHBERID'
      
        'inner join KASALAR KS on KS.KASATUR=196 and KS.KUR=T.KUR and KS.' +
        'ID=K.HESAPID'
      'where'
      'T.DURUM=1'
      '--T.REHBERID'
      
        'and T.TARIH >='#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH <= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23:' +
        '59'#39
      
        'and K.ISLEMTARIHI >=  '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39' and K.ISLEMTARIHI <= '#39'B'#304 +
        'T'#304#350'TAR'#304'H'#304' 23:59'#39
      ')as TT'
      'group by [YER],[YERID], ISLEMTARIHI, SIRA, ETIKET, KUR,DURUM,TUR'
      ''
      ''
      ''
      ''
      '')
    TabOrder = 7
    Visible = False
  end
  object MaasOdemeMemo: TMemo
    Left = 91
    Top = 307
    Width = 793
    Height = 38
    Lines.Strings = (
      'select T.REHBERID,R.KOD,R.FIRMA,R.KATEGORI,'
      'POZISYON=R.SINIF,R.OZELKOD,'
      
        'T.ID,T.SEC,T.TARIH,BANKA, KASA,TAHAKKUK,KESINTI,TOPLAMMAAS, ODEB' +
        'ANKA, ODEKASA,T.AGI,'
      'T.BELGENO, T.KUR, BORCLUBNK,'
      
        'BORCLUBANKASI=(select HESAPADI from BANKAHESAPLAR where ID=BORCL' +
        'UBNK),'
      
        'ALACAKLIBNK, BORCLUKASA, EXCELISLENDI, TAHAKKUKISLENDI, BANKAISL' +
        'ENDI, KASAISLENDI, T.DURUM'
      'from PLANMTABLO T inner join REHBER R on R.ID=T.REHBERID'
      ''
      'where T.TARIH >=:T1 and T.TARIH<=:T2  and T.DURUM=:DRM'
      '--and SEC=1'
      'Order By T.TARIH desc, 3')
    TabOrder = 8
    Visible = False
  end
  object AvansOdemeMemo: TMemo
    Left = 117
    Top = 259
    Width = 793
    Height = 36
    Lines.Strings = (
      'select T.REHBERID,R.KOD,R.FIRMA,R.KATEGORI,'
      'POZISYON=R.SINIF,R.OZELKOD,'
      'T.ID,T.SEC,'
      'T.TARIH, ODEBANKA, ODEKASA,'
      'T.BELGENO, T.KUR, BORCLUBNK,'
      
        'BORCLUBANKASI=(select HESAPADI from BANKAHESAPLAR where ID=BORCL' +
        'UBNK),'
      
        'ALACAKLIBNK, BORCLUKASA, EXCELISLENDI, TAHAKKUKISLENDI, BANKAISL' +
        'ENDI, KASAISLENDI, T.DURUM'
      'from PLANMTABLO T inner join REHBER R on R.ID=T.REHBERID'
      ''
      'WHERE T.TARIH >=:T1 AND T.TARIH<=:T2 AND T.DURUM=:PDRM'
      'Order By T.ID')
    TabOrder = 9
    Visible = False
  end
  object AvansInsert: TMemo
    Left = 211
    Top = 59
    Width = 793
    Height = 31
    Lines.Strings = (
      
        'insert into PLANMTABLO (REHBERID,SEC,TARIH,ODEBANKA,ODEKASA,KUR,' +
        'DURUM,'
      
        '    EXCELISLENDI,TAHAKKUKISLENDI,BANKAISLENDI,KASAISLENDI,BORCLU' +
        'BNK,ALACAKLIBNK,BORCLUKASA,BELGENO)'
      ''
      'Select '
      
        'REHBERID=ID,SEC=0,TARIH,ODEBANKA,ODEKASA,KUR,DURUMM,EXCELISLENDI' +
        '=0,TAHAKKUKISLENDI=0,BANKAISLENDI=0,KASAISLENDI=0,'
      'BORCLUBNK,ALACAKLIBNK,'
      'BORCLUKASA,BELGENO'
      'from ('
      'select R.ID,R.KOD, R.FIRMA, R.KATEGORI,TARIH='#39':PTRH'#39','
      
        'BORCLUBNK = (select top 1 ID from BANKAHESAPLAR BH where BH.REHB' +
        'ERID=-1  and BH.MAASHESABI=1),'
      
        'ALACAKLIBNK=(select top 1 ID from BANKAHESAPLAR BH where BH.REHB' +
        'ERID=R.ID ),'
      'BORCLUKASA=(select top 1 ID from KASALAR K where K.KUR='#39'TL'#39'),'
      'BELGENO='#39#39','
      
        'KUR=(SELECT TOP 1 KUR FROM PLANMAAS PM WHERE PM.YERID=R.ID AND P' +
        'M.YER=61),'
      
        'ODEKASA=(SELECT ISNULL(SUM(TUTAR),0) FROM dbo.PLANMAAS PM WHERE ' +
        'PM.YER=61 AND PM.YERID=R.ID AND TUR='#39'K'#39'),'
      
        'ODEBANKA=(SELECT ISNULL(SUM(TUTAR),0) FROM dbo.PLANMAAS PM WHERE' +
        ' PM.YER=61 AND PM.YERID=R.ID AND TUR='#39'B'#39'),'
      'DURUMM=0'
      'from REHBER R'
      'where R.DURUM = 1 AND R.GRUP = 335'
      ') AS T'
      'ORDER BY 1')
    TabOrder = 10
    Visible = False
  end
  object AvansMaasIsle: TMemo
    Left = 94
    Top = 351
    Width = 793
    Height = 31
    Lines.Strings = (
      
        'Insert Into KASA (TUR, ISLEMTARIHI,PLANTARIHI, REHBERID,  ACIKLA' +
        'MA, HESAPID, BORC, ALACAK,DOVIZ_TUTARI,DOVIZ_KURU,'
      
        ' KUR,YERI,YERID, HESAPTURU)--MASRAFID, DURUM,FATURAID, KREDIID,C' +
        'EKSENETID, KASA, EKLEYEN)'
      ''
      
        'select TUR, ISLEMTARIHI,PLANTARIHI, REHBERID,  ACIKLAMA, HESAPID' +
        ', BORC, ALACAK, DOVIZ_TUTARI=BORC,DOVIZ_KURU=KUR, '
      'KUR,YER,YERID,HESAPTURU from ('
      
        'select TUR=31,ISLEMTARIHI=T.TARIH,PLANTARIHI=T.TARIH, T.REHBERID' +
        ', ACIKLAMA='#39'Avans Tahakkuk'#39','
      
        'HESAPID=(select ID from KASALAR KS where KS.KASATUR=196 and KS.K' +
        'UR=T.KUR and KS.REHBERID=T.REHBERID),'
      '--E'#287'er fazla avans al'#305'nm'#305#351'sa gelecek aya devreder'
      
        'BORC=case when T.ODEKASA<0 then (select isnull(sum(TUTAR),0.0) f' +
        'rom PLANMAAS P where P.YER=21 and P.YERID=T.ID and P.DURUM=196)+' +
        'T.ODEKASA'
      
        'else (select isnull(sum(TUTAR),0.0) from PLANMAAS P where P.YER=' +
        '21 and P.YERID=T.ID and P.DURUM=196)end,'
      'ALACAK=0.0 ,KUR,'
      'YER=68,YERID=T.ID, HESAPTURU='#39'K'#39
      'from PLANMTABLO T'
      '--inner join PLANMAAS P on P.YER=21 and P.YERIDT.ID'
      'where'
      'SEC=1 and T.DURUM=1'
      
        'and T.TARIH >='#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'   and T.TARIH <= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23' +
        ':59'#39
      ')as TT'
      'where BORC>0.0'
      ''
      '')
    TabOrder = 11
    Visible = False
  end
  object SQLMesaiGetir: TMemo
    Left = 93
    Top = 388
    Width = 793
    Height = 31
    Lines.Strings = (
      '--Mesailer'
      
        'insert into PLANMAAS ([YER],[YERID],[SIRA],[ETIKET],[TUTAR],[KUR' +
        '])'
      
        'select [YER]=11,[YERID]=T.ID, RA.SIRA, ETIKET=RA.ETIKET+'#39' ('#39'+CAS' +
        'T(count(P.ID) as varchar(2))+'#39')'#39','
      'TUTAR=count(P.ID)*(select sum(TUTAR) / 30'
      'from PLANMAAS PM'
      'inner join PLANMTABLO T on PM.YERID=T.REHBERID'
      
        'inner join REHBERAYAR RA on YERI=5 and PM.SIRA=RA.SIRA and RA.VA' +
        'RSAYILAN=11'
      ''
      'where PM.YER=0 and'
      'T.TARIH >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23:59'#39
      
        '--T.TARIH >= '#39'2014-06-01 00:00'#39'  and T.TARIH<= '#39'2014-06-30 23:59' +
        #39
      'and T.REHBERID=P.REHBERID'
      '),'
      'KUR='#39'TL'#39
      'from PERS_PDKS P'
      'inner join REHBERAYAR RA on RA.VARSAYILAN=17'
      'inner join PLANMTABLO T on P.REHBERID=T.REHBERID'
      'where'
      '--P.REHBERID = 703 and'
      'P.DURUM=5 --mesai'
      
        'and  T.TARIH >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23' +
        ':59'#39
      
        '--and T.TARIH >= '#39'2014-06-01 00:00'#39'  and T.TARIH<= '#39'2014-06-30 2' +
        '3:59'#39
      
        '--and P.GIRIS >= '#39'2014-06-01 00:00'#39'  and P.GIRIS<= '#39'2014-06-30 2' +
        '3:59'#39
      
        'and  P.GIRIS >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and P.GIRIS<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23' +
        ':59'#39
      'group by T.ID,RA.SIRA, RA.ETIKET,P.REHBERID'
      ''
      ''
      ''
      '')
    TabOrder = 12
    Visible = False
  end
  object SQLDevamsizlikGetir: TMemo
    Left = 94
    Top = 412
    Width = 793
    Height = 31
    Lines.Strings = (
      '--Devams'#305'zl'#305'klar'
      
        'insert into PLANMAAS ([YER],[YERID],[SIRA],[ETIKET],[TUTAR],[KUR' +
        '])'
      
        'select [YER]=21,[YERID]=T.ID, RA.SIRA, ETIKET=RA.ETIKET+'#39' ('#39'+CAS' +
        'T(count(P.ID) as varchar(2))+'#39')'#39','
      'TUTAR=count(P.ID)*(select sum(TUTAR) / 30'
      'from PLANMAAS PM'
      'inner join PLANMTABLO T on PM.YERID=T.REHBERID'
      
        'inner join REHBERAYAR RA on YERI=5 and PM.SIRA=RA.SIRA and RA.VA' +
        'RSAYILAN=11'
      ''
      'where PM.YER=0 and'
      'T.TARIH >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23:59'#39
      
        '--T.TARIH >= '#39'2014-06-01 00:00'#39'  and T.TARIH<= '#39'2014-06-30 23:59' +
        #39
      'and T.REHBERID=P.REHBERID'
      '),'
      'KUR='#39'TL'#39
      'from PERS_PDKS P'
      'inner join REHBERAYAR RA on RA.VARSAYILAN=35'
      'inner join PLANMTABLO T on P.REHBERID=T.REHBERID'
      'where'
      '--P.REHBERID = 703 and'
      'P.DURUM=2  --gelmedi'
      
        '--and P.GIRIS >= '#39'2014-06-01 00:00'#39'  and P.GIRIS<= '#39'2014-06-30 2' +
        '3:59'#39
      
        'and  P.GIRIS >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and P.GIRIS<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23' +
        ':59'#39
      
        'and  T.TARIH >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23' +
        ':59'#39
      
        '--and T.TARIH >= '#39'2014-06-01 00:00'#39'  and T.TARIH<= '#39'2014-06-30 2' +
        '3:59'#39
      'group by T.ID,RA.SIRA, RA.ETIKET,P.REHBERID'
      ''
      ''
      ''
      '')
    TabOrder = 13
    Visible = False
  end
  object LabelMaasAralik: TcxLabel
    Left = 143
    Top = 12
    Caption = '---'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
  end
  object SQLKesDevir: TMemo
    Left = 211
    Top = 110
    Width = 793
    Height = 33
    Lines.Strings = (
      ''
      
        'insert into PLANMAAS ([YER],[YERID],[TARIH],[SIRA],[ETIKET],[TUT' +
        'AR],[KUR],[DURUM],[TUR])'
      '--verilmi'#351' avanslar'#305
      
        'select  [YER],[YERID], ISLEMTARIHI, SIRA, ETIKET,TUTAR=sum(ALACA' +
        'K-BORC), KUR,DURUM,TUR'
      'from('
      
        'select [YER]=21,[YERID]=T.ID, ISLEMTARIHI='#39'2014-11-10'#39', SIRA=0, ' +
        'ETIKET='#39'Devir'#39',K.ALACAK,K.BORC, K.KUR,DURUM=196,'
      
        'TUR='#39'K'#39'--(select HESAPTURU from KASA where REHBERID=K.REHBERID a' +
        'nd GERIDONUSID=K.ID and TUR in (40,42))'
      'from KASA K'
      'inner join PLANMTABLO T on K.REHBERID=T.REHBERID'
      
        'inner join KASALAR KS on KS.KASATUR=196 and KS.KUR=T.KUR and KS.' +
        'ID=K.HESAPID'
      'where'
      'T.DURUM=1'
      
        'and T.TARIH >='#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH <= '#39'B'#304'T'#304#350'TAR'#304'H'#304'  23' +
        ':59'#39
      
        'and K.ISLEMTARIHI >=  CAST(YEAR(GETDATE()) AS VARCHAR(4))+'#39'-01-0' +
        '1'#39'   and K.ISLEMTARIHI <= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39
      ')as TT'
      'group by [YER],[YERID], ISLEMTARIHI, SIRA, ETIKET, KUR,DURUM,TUR'
      ''
      ''
      ''
      ''
      '')
    TabOrder = 15
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1071
    Height = 34
    Align = alTop
    TabOrder = 16
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 340
      Top = 4
      Width = 727
      Height = 29
      Margins.Bottom = 0
      Align = alClient
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 94
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
      object YaziciYaz: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 16
        ImageName = 'PngImage15'
        Style = tbsTextButton
      end
      object ToolButton3: TToolButton
        Left = 94
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 17
        ImageName = 'PngImage16'
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 102
        Top = 0
        Caption = 'Aksiyonlar'
        DropdownMenu = TabloyuOlustur
        ImageIndex = 1
        ImageName = 'PngImage0'
      end
      object ToolButton4: TToolButton
        Left = 196
        Top = 0
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 2
        ImageName = 'PngImage3'
        Style = tbsSeparator
      end
      object CarsafListe: TToolButton
        Left = 204
        Top = 0
        Caption = #199'ar'#351'af Liste'
        ImageIndex = 19
        ImageName = 'PngImage19'
        OnClick = CarsafListeClick
      end
    end
    object PanelYeniIs: TJvNavPanelHeader
      Left = 1
      Top = 1
      Width = 336
      Height = 32
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = 14540253
      ColorTo = 11776947
      ImageIndex = 0
      object ComboAy: TcxComboBox
        Left = 127
        Top = 3
        Properties.DropDownListStyle = lsFixedList
        Properties.DropDownRows = 12
        Properties.Items.Strings = (
          'Ocak'
          #350'ubat'
          'Mart'
          'Nisan'
          'May'#305's'
          'Haziran'
          'Temmuz'
          'A'#287'ustos'
          'Eyl'#252'l'
          'Ekim'
          'Kas'#305'm'
          'Aral'#305'k')
        Properties.OnChange = ComboAyPropertiesChange
        TabOrder = 0
        Text = 'Ocak'
        Width = 121
      end
      object ComboYil: TcxSpinEdit
        Left = 254
        Top = 3
        Properties.LargeIncrement = 1.000000000000000000
        Properties.MaxValue = 2030.000000000000000000
        Properties.MinValue = 2010.000000000000000000
        Properties.OnChange = ComboAyPropertiesChange
        TabOrder = 1
        Value = 2010
        Width = 58
      end
      object ComboOdemeTuru: TcxComboBox
        Left = 3
        Top = 3
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          'Avans '#214'demesi'
          'Maa'#351' '#214'demesi'
          #304#351'ten '#199#305'k'#305#351)
        Properties.OnChange = OdemeTuruPropertiesChange
        TabOrder = 2
        Text = 'Maa'#351' '#214'demesi'
        Width = 118
      end
    end
  end
  object SQLUpdPlanMTablo2Adim: TMemo
    Left = 128
    Top = 211
    Width = 793
    Height = 42
    Lines.Strings = (
      'declare @SiraMaas int,@SiraPirim int'
      
        'select @SiraMaas=SIRA from REHBERAYAR where YERI=5 and VARSAYILA' +
        'N=11'
      
        'select @SiraPirim=SIRA from REHBERAYAR where YERI=5 and VARSAYIL' +
        'AN=13'
      ''
      
        'UPDATE PLANMTABLO SET TAHAKKUK=case when TAHAKKUKMAAS>TAHAKKUKPI' +
        'RIM then TAHAKKUKMAAS+TAHAKKUKDIGER else  TAHAKKUKPIRIM'
      '+TAHAKKUKDIGER end,'
      
        'TOPLAMMAAS=case when TAHAKKUKMAAS>TAHAKKUKPIRIM then TAHAKKUKMAA' +
        'S+TAHAKKUKDIGER else  TAHAKKUKPIRIM+TAHAKKUKDIGER end - KESINTI,'
      
        'ODEKASA=case when TAHAKKUKMAAS>TAHAKKUKPIRIM then TAHAKKUKMAAS+T' +
        'AHAKKUKDIGER else  TAHAKKUKPIRIM+TAHAKKUKDIGER end - KESINTI - '
      'ODEBANKA'
      'from ('#9'SELECT PLANMTABLO.ID,'
      
        #9#9#9'TAHAKKUKMAAS=sum(isnull(case when  SIRA=@SiraMaas then TUTAR ' +
        'else 0.0 end,0.0)),'
      
        #9#9#9'TAHAKKUKPIRIM=sum(isnull(case when SIRA=@SiraPirim then TUTAR' +
        ' else 0.0 end,0.0)),'
      
        #9#9#9'TAHAKKUKDIGER=sum(isnull(case when SIRA not in (@SiraMaas,@Si' +
        'raPirim) then TUTAR else 0.0 end,0.0))'
      ''
      
        #9#9'FROM PLANMTABLO inner join REHBER on REHBER.ID=PLANMTABLO.REHB' +
        'ERID inner join PLANMAAS on PLANMAAS.YER=11 and '
      'PLANMAAS.YERID=PLANMTABLO.ID'
      
        #9#9'WHERE REHBER.PERYOT=1 and PLANMTABLO.TARIH >='#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39 +
        '  and PLANMTABLO.TARIH<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23:59'#39' AND '
      'PLANMTABLO.DURUM=:DRM'
      '--REHBERID'
      ''
      #9#9'group by PLANMTABLO.ID'
      ') as X'
      'where PLANMTABLO.ID=X.ID'
      '')
    TabOrder = 17
    Visible = False
  end
  object SQLTahakkukInsert_Kopya: TMemo
    Left = 179
    Top = 149
    Width = 793
    Height = 33
    Lines.Strings = (
      
        'insert into PLANMAAS ([YER],[YERID],[SIRA],[ETIKET],[TUTAR],[KUR' +
        '])'
      'select [YER]=:Prm1,[YERID]=T.ID, SIRA, '
      
        'ETIKET=ETIKET+(case when PH.TARIH > cast('#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39' as da' +
        'tetime)'
      
        '            then '#39'('#39'+CONVERT(VARCHAR(5),CONVERT(smallint, cast('#39 +
        'B'#304'T'#304#350'TAR'#304'H'#304#39' as datetime)-PH.TARIH+1))+'#39')'#39
      '        else '#39#39' end),'
      ''
      'TUTAR=(case when PH.TARIH > cast('#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39' as datetime)'
      
        'then TUTAR*CONVERT(smallint, cast('#39'B'#304'T'#304#350'TAR'#304'H'#304#39' as datetime)-PH.' +
        'TARIH+1)/30'
      '        else TUTAR end),'
      'M.KUR'
      'from PLANMAAS M'
      'inner join PLANMTABLO T on M.YERID=T.REHBERID'
      'inner join PERS_HAREKET PH on M.YERID=PH.REHBERID and PH.TUR=1'
      
        'where M.YER=:Prm2 and  T.TARIH >= '#39'BA'#350'LANGI'#199'TAR'#304'H'#304#39'  and T.TARIH' +
        '<= '#39'B'#304'T'#304#350'TAR'#304'H'#304' 23:59'#39
      '--M.YERID'
      'order by SIRA')
    TabOrder = 18
    Visible = False
  end
  object DtsPlanMTablo: TDataSource
    DataSet = PLANMTABLO
    Left = 626
    Top = 227
  end
  object TabloyuOlustur: TPopupMenu
    OnPopup = TabloyuOlusturPopup
    Left = 231
    Top = 50
    object OlusturMenu: TMenuItem
      Caption = '1 - Tabloyu olu'#351'tur'
      object TabloOlusturMenu: TMenuItem
        Tag = 1
        Caption = #199'ar'#351'af Listeden'
        OnClick = TabloOlusturMenuClick
      end
      object ExceldenTabloyuolusturMenu: TMenuItem
        Caption = 'Excel'#39'den '
        OnClick = ExceldenTabloyuolusturMenuClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object ExceldenPrimleriTabloyaEkleMenu: TMenuItem
        Caption = 'Excel'#39'den Primleri Tabloya Ekle'
        OnClick = ExceldenPrimleriTabloyaEkleMenuClick
      end
    end
    object BankayaexceltablosuhazrlaMenu: TMenuItem
      Caption = '2 - Se'#231'ililerden '#39'Bankaya Excel'#39' tablosu haz'#305'rla'
      OnClick = BankayaexceltablosuhazrlaMenuClick
    end
    object KasayagiderolarakIsleMenu: TMenuItem
      Caption = '3 - Kasaya i'#351'lemler'
      object SeilileriTahakkukolarakile1: TMenuItem
        Caption = 'Se'#231'ilileri '#39'Tahakkuk'#39' olarak i'#351'le'
        OnClick = SeilileriTahakkukolarakile1Click
      end
      object SeilileriBankadandemeolarakile1: TMenuItem
        Caption = 'Se'#231'ilileri '#39'Bankadan '#214'deme'#39' olarak i'#351'le'
        OnClick = SeilileriBankadandemeolarakile1Click
      end
      object SeilileriKasadandemeolarakile1: TMenuItem
        Caption = 'Se'#231'ilileri '#39'Kasadan '#214'deme'#39' olarak i'#351'le'
        OnClick = SeilileriKasadandemeolarakile1Click
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object sttekinuygula1: TMenuItem
        Caption = #220'stteki '#252#231#252'n'#252' toplu uygula'
        OnClick = sttekinuygula1Click
      end
    end
    object KasayaAvansOlarakIsle: TMenuItem
      Caption = '3 - Se'#231'ilileri '#39'Avans '#214'deme'#39' olarak i'#351'le'
      OnClick = KasayaAvansOlarakIsleClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object TabloyuSilMenu: TMenuItem
      Caption = 'Tablodan se'#231'ilileri sil'
      OnClick = TabloyuSilMenuClick
    end
    object BorcluBankaAtaMenu: TMenuItem
      Caption = 'Se'#231'ililere kurum "Banka" ata'
      OnClick = BorcluBankaAtaMenuClick
    end
    object AlacaklibankaataMenu: TMenuItem
      Caption = 'Personelin "Banka" bilgisini gir'
      OnClick = AlacaklibankaataMenuClick
    end
    object SeililereborluKasaata1: TMenuItem
      Caption = 'Se'#231'ililere bor'#231'lu "Kasa" ata'
      OnClick = SeililereborluKasaata1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object HepsinisecMenu: TMenuItem
      Tag = 1
      Caption = 'Hepsini se'#231
      OnClick = HepsinisecMenuClick
    end
    object HepsinikaldirMenu: TMenuItem
      Tag = 2
      Caption = 'Hepsini kald'#305'r'
      OnClick = HepsinisecMenuClick
    end
    object SecimiterscevirMenu: TMenuItem
      Tag = 3
      Caption = 'Se'#231'imi ters '#231'evir'
      OnClick = HepsinisecMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PersonelinKartnAcMenu: TMenuItem
      Caption = 'Personelin Kart'#305'n'#305' A'#231
      OnClick = PersonelinKartnAcMenuClick
    end
    object PersonelinEkstresiniAcMenu: TMenuItem
      Caption = 'Personelin Ekstresini A'#231
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object DigerIslemlerMenu: TMenuItem
      Caption = 'Di'#287'er '#304#351'lemler'
      object ExcelAlanEslestirmesiMenu: TMenuItem
        Caption = 'Bilgi almak i'#231'in Excel <--> Alan E'#351'le'#351'tirmesi'
        OnClick = ExcelAlanEslestirmesiMenuClick
      end
    end
  end
  object PLANMTABLO: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = PLANMTABLOAfterOpen
    AfterScroll = PLANMTABLOAfterScroll
    OnCalcFields = PLANMTABLOCalcFields
    ParamData = <>
    Left = 624
    Top = 172
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'xls'
    Left = 424
    Top = 72
  end
  object PopupMenuYaz: TPopupMenu
    Left = 27
    Top = 108
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
    object MenuItem3: TMenuItem
      Caption = '-'
    end
  end
  object frxMaasTablo: TfrxDBDataset
    UserName = 'MAASTABLO'
    CloseDataSource = False
    DataSet = MaasTabloYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 783
    Top = 98
  end
  object TabTahakkuk: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select ID,ETIKET,TUTAR,KUR, SIRA  from PLANMAAS where '
      'YER=11 and YERID=:PID  order by SIRA')
    Left = 869
    Top = 164
  end
  object DtsTahakkuk: TDataSource
    DataSet = TabTahakkuk
    Left = 863
    Top = 226
  end
  object TabKesinti: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select ID,TARIH,ETIKET,TUTAR,KUR, SIRA,TUR  from PLANMAAS where '
      'YER=21 and YERID=:PID  order by TARIH')
    Left = 933
    Top = 172
  end
  object DtsKesinti: TDataSource
    DataSet = TabKesinti
    Left = 935
    Top = 226
  end
  object PopupMenuTahakkuk: TPopupMenu
    OnPopup = PopupMenuTahakkukPopup
    Left = 24
    Top = 208
    object TahakkukDuzenle: TMenuItem
      Caption = 'Tahakkuk D'#252'zenle'
      OnClick = TahakkukDuzenleClick
    end
  end
  object PopupMenuKesinti: TPopupMenu
    OnPopup = PopupMenuKesintiPopup
    Left = 48
    Top = 296
    object KesintiDuzenle: TMenuItem
      Caption = 'Kesinti D'#252'zenle'
      OnClick = KesintiDuzenleClick
    end
  end
  object frxTahakkuk: TfrxDBDataset
    UserName = 'TAHAKKUK'
    CloseDataSource = False
    DataSet = TabTahakkuk
    BCDToCurrency = False
    DataSetOptions = []
    Left = 863
    Top = 98
  end
  object frxKesinti: TfrxDBDataset
    UserName = 'KESINTI'
    CloseDataSource = False
    DataSet = TabKesintiYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 935
    Top = 98
  end
  object TabKesintiYaz: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PID1'
        Size = -1
        Value = Null
      end
      item
        Name = 'PID2'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select ID,TARIH,ETIKET,TUTAR,KUR, SIRA,TUR  from PLANMAAS '
      'where YER=21 and YERID=:PID1'
      'union all'
      
        'select ID,TARIH,ETKET='#39'Bankadan '#214'denen'#39',TUTAR=ODEBANKA,KUR,SIRA=' +
        'ID,TUR='#39'K'#39
      'from PLANMTABLO T'
      'WHERE'
      'T.ID=:PID2'
      'order by TARIH'
      '')
    Left = 933
    Top = 292
  end
  object MaasTabloYaz: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = MaasTabloYazAfterScroll
    ParamData = <>
    Left = 752
    Top = 172
  end
end

