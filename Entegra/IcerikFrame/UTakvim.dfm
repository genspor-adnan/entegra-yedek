object TakvimDlg: TTakvimDlg
  Left = 0
  Top = 0
  Width = 1154
  Height = 506
  HorzScrollBar.Increment = 4
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object PageControl: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 33
    Width = 1154
    Height = 473
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = TabSheetTakvim
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlChange
    ClientRectBottom = 469
    ClientRectLeft = 4
    ClientRectRight = 1150
    ClientRectTop = 24
    object TabSheetTakvim: TcxTabSheet
      Tag = 1
      Caption = 'Takvim'
      ImageIndex = 21
      object Scheduler: TcxScheduler
        Left = 0
        Top = 0
        Width = 1146
        Height = 445
        DateNavigator.ColCount = 2
        DateNavigator.RowCount = 2
        DateNavigator.OnSelectionChanged = SchedulerDateNavigatorSelectionChanged
        ViewDay.Active = True
        ViewDay.TimeRulerMinutes = True
        Align = alClient
        ContentPopupMenu.PopupMenu = PopupMenu1
        ContentPopupMenu.UseBuiltInPopupMenu = False
        ContentPopupMenu.Items = []
        ControlBox.Control = pnlControls
        EventOperations.Creating = False
        EventOperations.Deleting = False
        EventOperations.DialogEditing = False
        EventOperations.DialogShowing = False
        EventOperations.InplaceEditing = False
        EventPopupMenu.PopupMenu = PopupMenu1
        EventPopupMenu.UseBuiltInPopupMenu = False
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        LookAndFeel.Kind = lfOffice11
        OptionsBehavior.SelectOnRightClick = True
        OptionsView.WorkFinish = 0.375000000000000000
        PopupMenu = PopupMenu1
        Storage = SchedulerDBStorage
        TabOrder = 0
        OnDblClick = SchedulerDblClick
        Splitters = {
          5B030000FB000000790400000001000056030000010000005B030000BC010000}
        StoredClientBounds = {010000000100000079040000BC010000}
        object pnlControls: TPanel
          Left = 0
          Top = 0
          Width = 286
          Height = 188
          Align = alClient
          BevelOuter = bvNone
          Color = clWindow
          TabOrder = 0
          object Memo1: TMemo
            Left = 0
            Top = 0
            Width = 286
            Height = 188
            Align = alClient
            BorderStyle = bsNone
            Lines.Strings = (
              'Your '
              'controls can '
              'be placed '
              'here')
            TabOrder = 1
          end
          object GridToplam: TcxGrid
            Left = 0
            Top = 0
            Width = 286
            Height = 188
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfStandard
            LookAndFeel.NativeStyle = True
            object ToplamView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsToplam
              DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
              DataController.Summary.DefaultGroupSummaryItems = <
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Position = spFooter
                  Column = ToplamViewTUTAR
                end>
              DataController.Summary.FooterSummaryItems = <
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  FieldName = 'TUTAR'
                  Column = ToplamViewTUTAR
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              OptionsView.GroupFooters = gfAlwaysVisible
              OptionsView.Header = False
              object ToplamViewYON: TcxGridDBColumn
                DataBinding.FieldName = 'YON'
                DataBinding.IsNullValueType = True
                Visible = False
                GroupIndex = 0
                Options.Sorting = False
                IsCaptionAssigned = True
              end
              object ToplamViewTUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                Options.Sorting = False
                SortIndex = 0
                SortOrder = soAscending
                Width = 80
              end
              object ToplamViewTUTAR: TcxGridDBColumn
                Caption = 'Tutar'
                DataBinding.FieldName = 'TUTAR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
                Options.Sorting = False
                Width = 75
              end
            end
            object cxGridLevel2: TcxGridLevel
              GridView = ToplamView
            end
          end
        end
      end
      object MemoFatura: TMemo
        Left = 149
        Top = 93
        Width = 641
        Height = 39
        Lines.Strings = (
          ''
          'select  type = 0, '
          
            '       start = convert(datetime, convert(varchar(10), TARIH, 120' +
            ')+'#39' 00:00'#39', 120) ,'
          
            '       finish = convert(datetime, convert(varchar(10), TARIH+1, ' +
            '120)+'#39' 00:00'#39',120),   options=3,  '
          
            '       caption = (select ANAHTAR from GENINI where BOLUM=-1005 a' +
            'nd DIL=-1 and DEGER=F.TUR)+'#39' '#39
          
            '       +convert(varchar(20),isnull(FATURA_TUTARI,0))+isnull(KUR,' +
            #39#39')+'#39' '#39
          '       +isnull(BASLIK,'#39#39')+'#39' '#39'+isnull(ACIKLAMA,'#39#39'),'
          #9'location = F.BASLIK,'
          #9'message= F.ACIKLAMA,'
          'state=0,   '
          '   labelColor =  case  '
          '   when TUR between 8 and 13 then 8689404  '
          '   when TUR between 14 and 19 then 6610596  '
          '   end,'
          '   Dosya='#39'FATBASLIK'#39', '
          '   ID2=ID,'
          '   REHBERID,'
          '   TUR, TURAD='#39#39','
          '   '#9'TUTAR=case'
          #9#9'when TUR between 8 and 13 then isnull(FATURA_TUTARI,0)'
          #9#9'when TUR between 14 and 19 then -1*isnull(FATURA_TUTARI,0)'
          #9' end,'
          '        KUR,'
          #9'YON=case '
          #9#9'when TUR between 8 and 13 then '#39'Gelen'#39' '
          #9#9'when TUR between 14 and 19 then '#39'Giden'#39' '
          #9' end,'#9
          #9'SIRA=1, ACIKLAMA= '#39'Fatura'#39' '
          '    from  FATBASLIK F'#9
          'where '
          'TARIH >= '#39'2010-01-01 00:00'#39' '
          'and TARIH <= '#39'2020-01-01 23:59'#39
          'and TUR not in (1,2)'#9
          '')
        TabOrder = 1
        Visible = False
        WordWrap = False
      end
      object MemoOdeme: TMemo
        Left = 103
        Top = 138
        Width = 639
        Height = 55
        Lines.Strings = (
          ''
          '--kasa gurupsuz hareketler'
          'select '
          #9'type = 0,'
          
            #9'start=convert(datetime,convert(varchar(10),ISLEMTARIHI,120)+'#39' 0' +
            '0:00'#39',120),'
          
            #9'finish=convert(datetime,convert(varchar(10),ISLEMTARIHI+1,120)+' +
            #39' 00:00'#39',120), '
          #9'options=3, '
          
            #9'caption = (select ANAHTAR from GENINI where BOLUM=-1005 and DIL' +
            '=-1 and DEGER=K.TUR)+'#39' '#39
          
            #9#9#9'+convert(varchar(20),case when K.TUR IN(31,32,33,34,35,36,37,' +
            '38,39,53,54,57,58,73) then BORC'
          
            #9#9'when K.TUR IN(21,22,23,24,25,26,27,28,29,51,52,59,63,91,95,121' +
            ',122) then ALACAK end)'
          #9#9#9'+isnull(K.KUR,'#39'TL'#39')+'#39' '#39
          #9#9#9'+isnull(R.FIRMA,'#39#39'),'#9
          #9'location = isnull(RTRIM(CONVERT(varchar(25),R.FIRMA)),'#39#39'), '
          #9'message= RTRIM(isnull(K.ACIKLAMA,'#39#39')), '
          #9'state=0, '
          
            #9'labelColor =case when K.TUR IN(31,32,33,34,35,36,37,38,39,53,54' +
            ',57,58,73) then 8689404'
          
            #9#9'when K.TUR IN(21,22,23,24,25,26,27,28,29,51,52,59,63,91,95,121' +
            ',122) then 6610596 end,'#9
          #9'Dosya='#39'KASA'#39', '
          #9'ID2=K.ID,'
          '               REHBERID=K.REHBERID,'
          #9'K.TUR, TURAD=T.AD,'
          
            #9'TUTAR =case when K.TUR IN(31,32,33,34,35,36,37,38,39,53,54,57,5' +
            '8,73) then -1*BORC'
          
            #9#9'when K.TUR IN(21,22,23,24,25,26,27,28,29,51,52,59,63,91,95,121' +
            ',122) then ALACAK end,'
          #9'K.KUR,'
          
            #9'YON= case when K.TUR IN(31,32,33,34,35,36,37,38,39,53,54,57,58,' +
            '73) then '#39#214'deme'#39
          
            #9#9'when K.TUR IN(21,22,23,24,25,26,27,28,29,51,52,59,63,91,95,121' +
            ',122) then '#39'Tahsilat'#39' end,'
          #9'SIRA=1,'
          #9'ACIKLAMA=K.ACIKLAMA'
          'from'
          #9'KASA K'
          '        inner join ISLEMTURLERI T on K.TUR=T.TUR'
          '        left outer join KASALAR K2 on K.HESAPID=K2.ID'
          '        left outer join BANKAHESAPLAR BH on K.HESAPID=BH.ID'
          '        left outer join REHBER R on R.ID=K.REHBERID'
          'where '
          #9'ISLEMTARIHI between '#39'2010-01-01 00:00'#39' and '#39'2020-01-01 23:59'#39
          
            #9'and K.TUR not in(1,2,40,41,42,43,44,45,46,47,48,49,61,62,63,65,' +
            '67,68,71,72,73,75)'
          ''
          ''
          ''
          '')
        TabOrder = 2
        Visible = False
        WordWrap = False
      end
      object MemoPlanButce: TMemo
        Left = 109
        Top = 449
        Width = 647
        Height = 29
        Lines.Strings = (
          '---'#214'nceki  B'#252't'#231'e B'#246'l'#252'm'#252' '
          ''
          'select   '
          #9'type = 0, '
          
            '    start = convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONV' +
            'ERT(Varchar(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'),120' +
            ') ,'
          
            '    finish = convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CON' +
            'VERT(Varchar(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'),12' +
            '0),   '
          '    options=3,  '
          
            '    caption = '#39'B'#252't'#231'e '#39'+convert(varchar(20),B.PLANLANAN,1)+  isnu' +
            'll( KUR,'#39'TL'#39')+'#39' '#39'+isnull(M.KOD,'#39#39')+'#39' '#39'+isnull(RTRIM(M.AD),'#39#39'),'
          #9'location=isnull(RTRIM(M.AD),'#39#39'),'
          #9'message='#39'B'#252't'#231'e '#39'+convert(varchar(20),B.PLANLANAN,1), '
          #9'state=0,   '
          
            #9'labelColor = case when M.GELIRMI=1 then 6610596 when M.GELIRMI=' +
            '0 then 8689404 end,'
          '    Dosya='#39'B'#252't'#231'e'#39', '
          '    ID2=B.ID,'
          '    REHBERID=-1,'
          
            '    TUR= case when M.GELIRMI=1 then 301 when M.GELIRMI=0 then 31' +
            '1 end,'
          '    TUTAR=B.PLANLANAN,KUR,'
          
            #9'YON=case when M.GELIRMI=1 then '#39'Gelir B'#252't'#231'esi'#39' when M.GELIRMI=0' +
            ' then '#39'Masraf B'#252't'#231'esi'#39' end, '
          #9'SIRA=7,'
          #9'AIKLAMA='#39'B'#252't'#231'e'#39' '#9' '
          'from '
          #9'BUTCE B inner join '
          #9'MASRAFGELIR M on M.ID=B.MASRAFID'
          'where B.GOR=1 '
          
            'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
            'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>='#39'2010-01-' +
            '01 00:00'#39' '
          
            'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
            'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))<='#39'2012-01-' +
            '01 00:00'#39
          
            'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
            'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>GETDATE()'#9 +
            ' '
          '')
        TabOrder = 3
        Visible = False
        WordWrap = False
      end
      object MemoPlanKredi: TMemo
        Left = 111
        Top = 398
        Width = 655
        Height = 25
        Lines.Strings = (
          '---- Kredi B'#246'l'#252'm'#252' Takvim'
          ''
          'select   '
          #9'type = 0, '
          
            #9'start = convert(datetime, convert(varchar(10), TARIH, 120)+'#39' 00' +
            ':00'#39', 120) ,'
          
            #9'finish = convert(datetime, convert(varchar(10), TARIH+1, 120)+'#39 +
            ' 00:00'#39',120),   options=3,  '
          #9'caption = convert(varchar(20),KO.TAKSIT,1)+   K.KUR+'#39' Kredi '#39'+'
          
            #9'isnull(RTRIM(KREDIKODU),'#39#39')+ '#39' '#39'+isnull(RTRIM(K.ADI),'#39#39')+'#39' '#39'+is' +
            'null(RTRIM(KO.ACIKLAMA),'#39#39'),'
          #9'location=isnull(RTRIM(K.ADI),'#39#39'),'
          #9'message=isnull(RTRIM(KO.ACIKLAMA),'#39#39'),'
          #9'state=0,'
          #9'labelColor = 8689404,'
          #9'Dosya='#39'PLANKREDI'#39','
          #9'ID2=KO.ID,'
          #9'REHBERID=-99,'
          #9'TUR=58,TURAD=T.AD,'
          #9'TUTAR=KO.TAKSIT, KO.KUR,'
          #9'YON='#39#214'deme'#39', SIRA=4, ACIKLAMA= '#39'Kredi'#39
          
            'from KREDILER K inner join PLANKREDI KO on K.ID =KO.KREDIID inne' +
            'r join ISLEMTURLERI T on T.TUR=58 '
          'where '
          #9'TARIH >= '#39'2010-01-01 00:00'#39' and  '
          #9'TARIH <= '#39'2020-01-01 23:59'#39' and '
          #9'ODENMIS=0 ')
        TabOrder = 4
        Visible = False
        WordWrap = False
      end
      object MemoPlanMaas: TMemo
        Left = 111
        Top = 419
        Width = 645
        Height = 24
        Lines.Strings = (
          '---- Personel Maa'#351' B'#246'l'#252'm'#252' Takvim'
          ''
          'select   '
          #9'type = 0, '
          
            #9'start = convert(datetime, convert(varchar(10), TARIH, 120)+'#39' 00' +
            ':00'#39', 120) ,'
          
            #9'finish = convert(datetime, convert(varchar(10), TARIH+1, 120)+'#39 +
            ' 00:00'#39',120),   '
          #9'options=3,  '
          
            'caption = convert(varchar(20),sum(TUTAR),1)+ KUR+'#39' '#39'+(select ANA' +
            'HTAR from GENINI where BOLUM=-1005 and DIL=-1 and DEGER=73),'
          #9'location='#39#39','
          
            #9'message=(select ANAHTAR from GENINI where BOLUM=-1005 and DIL=-' +
            '1 and DEGER=73), '
          #9'state=0,   '
          #9'labelColor = 8689404,'
          #9'Dosya='#39'PLANMAAS'#39', '
          #9'ID2=0,'
          #9'REHBERID=-99,'
          #9'TUR=73, TURAD=T.AD,'
          #9'TUTAR=-1*sum(TUTAR),KUR,'
          #9'YON='#39#214'deme'#39', SIRA=3, ACIKLAMA='#39'Personel'#39
          'from PLANMAAS PM'
          '        inner join ISLEMTURLERI T on T.TUR=73'
          'where '
          #9'TARIH >= '#39'2010-01-01 00:00'#39' '
          'and TARIH <= '#39'2020-01-01 23:59'#39
          
            'and (select count(*) from REHBERAYAR RA where RA.ETIKET=PM.ETIKE' +
            'T and RA.VARSAYILAN=36)>0'#9
          'group by TARIH, KUR, T.AD'
          'having sum(TUTAR)>0'
          '')
        TabOrder = 5
        Visible = False
        WordWrap = False
      end
      object MemoTakvimCekKendi: TMemo
        Left = 111
        Top = 321
        Width = 623
        Height = 21
        Lines.Strings = (
          
            '--Kendi '#199'ekimiz Takvim    (C.TUR=33 or (isnull(CIROLU,0)=1 and C' +
            '.TUR=23))'
          ''
          ''
          'select   '
          #9'type = 0, '
          
            '    start = convert(datetime, convert(varchar(10), VADE, 120)+'#39' ' +
            '00:00'#39', 120) ,'
          
            '    finish = convert(datetime, convert(varchar(10), VADE+1, 120)' +
            '+'#39' 00:00'#39',120),'
          '    options=3,'
          
            '    caption =convert(varchar(20),C.TUTAR,1)+isnull(C.KUR,'#39'TL'#39')+'#39 +
            ' '#199'ek '#214'demesi  '#39'+'
          #9#9#9'+substring(R.FIRMA,1, CHARINDEX('#39' '#39', R.FIRMA)) +'#39' '#39
          #9#9#9'+isnull(convert(varchar(20),B.BANKAADI),'#39#39'),'
          #9'location=isnull(RTRIM(CONVERT(varchar(25),R.FIRMA)),'#39#39'),'
          
            #9'message=isnull(convert(varchar(20),B.BANKAADI),'#39#39')+'#39' '#39'+isnull(C' +
            '.HESAPNO,'#39#39') +'#39' Seri No:'#39'+convert(varchar(20),C.SERINO,1), '
          #9'state=0,   '
          #9'labelColor = 8689404 ,'
          '    Dosya='#39'CEKLER'#39', '
          '    ID2=C.ID,'
          '               REHBERID=R.ID,'
          '    C.TUR, TURAD=T.AD,'
          '    -1*C.TUTAR,C.KUR,'
          #9' YON='#39#214'deme'#39', '
          #9' SIRA=2,'
          #9' AIKLAMA= '#39#199'ek'#39
          'from CEKLER C'
          
            '        inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID and C.' +
            'TUR=CH.ISLEM'
          '        inner join ISLEMTURLERI T on CH.ISLEM=T.TUR'
          '        inner join REHBER R on R.ID=C.REHBERID'
          
            '        left outer join BANKASUBELER BS on BS.ID=C.BANKASUBELERI' +
            'D'
          '        left outer join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
          'where'
          '  VADE >= '#39'2010-01-01 00:00'#39' and VADE <= '#39'2020-01-01 23:59'#39
          
            '  and (C.TUR between 140 and 149 or (isnull(CIROLU,0)=1 and C.TU' +
            'R between 130 and 139)) '
          '  and CEKSENET=103 ')
        TabOrder = 6
        Visible = False
        WordWrap = False
      end
      object MemoTakvimCekMusteri: TMemo
        Left = 111
        Top = 296
        Width = 631
        Height = 19
        Lines.Strings = (
          '--M'#252#351'teri '#199'eki B'#246'l'#252'm'#252' Takvim 130'
          ''
          'select'
          #9'type = 0,'
          
            '    start = convert(datetime, convert(varchar(10), VADE, 120)+'#39' ' +
            '00:00'#39', 120) ,'
          
            '    finish = convert(datetime, convert(varchar(10), VADE+1, 120)' +
            '+'#39' 00:00'#39',120),'
          '    options=3,'
          
            '  caption =convert(varchar(20),C.TUTAR,1)+isnull(C.KUR,'#39'TL'#39')+'#39' M' +
            #252#351'teri '#199'eki '#39'+'
          #9#9#9'+substring(R.FIRMA,1, CHARINDEX('#39' '#39', R.FIRMA)) +'#39' '#39
          #9#9#9'+isnull(convert(varchar(20),B.BANKAADI),'#39#39'),'
          #9'location=isnull(RTRIM(CONVERT(varchar(25),R.FIRMA)),'#39#39'),'
          
            #9'message=isnull(convert(varchar(20),B.BANKAADI),'#39#39')+'#39' '#39'+isnull(C' +
            '.HESAPNO,'#39#39') +'#39' Seri No:'#39'+convert(varchar(20),C.SERINO,1),'
          #9'state=0,   '
          #9'labelColor = 6610596,'
          '    Dosya='#39'CEKLER'#39', '
          '    ID2=C.ID,'
          '               REHBERID=R.ID,'
          '    C.TUR, TURAD=T.AD,'
          '    C.TUTAR,C.KUR,'
          #9' YON='#39'Tahsilat'#39', '
          #9' SIRA=2,'
          #9' AIKLAMA= '#39#199'ek'#39' '
          'from CEKLER C'
          
            '        inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID and C.' +
            'TUR=CH.ISLEM'
          '        inner join ISLEMTURLERI T on CH.ISLEM=T.TUR'
          #9'inner join REHBER R on R.ID=C.REHBERID'
          
            '        left outer join BANKASUBELER BS on BS.ID=C.BANKASUBELERI' +
            'D'
          '        left outer join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
          'where'
          #9'VADE >= '#39'2010-01-01 00:00'#39' and VADE <= '#39'2020-01-01 23:59'#39
          #9'and C.TUR between 130 and 139 '
          #9'and CEKSENET=101'
          ' '#9
          ''
          '')
        TabOrder = 7
        Visible = False
        WordWrap = False
      end
      object MemoTakvimOdemePlan: TMemo
        Left = 95
        Top = 242
        Width = 647
        Height = 20
        Lines.Strings = (
          '  --'#214'deme plan'#305' Takvim 71'
          ''
          '  select '
          #9'type = 0,'
          
            #9'start = convert(datetime, convert(varchar(10), PLANTARIHI, 120)' +
            '+'#39' 00:00'#39', 120) ,'
          
            #9'finish = convert(datetime, convert(varchar(10), PLANTARIHI+1, 1' +
            '20)+'#39' 00:00'#39',120), '
          #9'options = 3, '
          #9'caption = convert(varchar(20),ALACAK,1)'
          #9#9'+isnull(KUR,'#39'TL'#39')+'#39' '#214'.P.'#39
          #9#9'+substring(R.FIRMA,1, CHARINDEX('#39' '#39', R.FIRMA)) +'#39' '#39
          #9#9
          #9#9'+RTRIM(isnull(K.ACIKLAMA,'#39#39')),'
          #9'location = isnull(RTRIM(CONVERT(varchar(25),R.FIRMA)),'#39#39'), '
          #9'message=RTRIM(isnull(K.ACIKLAMA,'#39#39')), '
          #9'state=0, '
          #9'labelColor = 8689404,'
          #9'Dosya='#39'KASA'#39', '
          #9'ID2=K.ID,'
          '               REHBERID=R.ID,--select * from SIPARISDETAY'
          #9'K.TUR,TURAD=T.AD,'
          #9'TUTAR = -1*ALACAK ,'
          #9'KUR=isnull(K.KUR,'#39'TL'#39'),'
          #9' YON='#39#214'deme'#39','
          #9' SIRA=5,'
          #9' ACIKLAMA='#39'D'#252'zenli '#214'deme'#39
          'from'
          #9'KASA K'
          '        inner join ISLEMTURLERI T on K.TUR=T.TUR'
          '        left outer join REHBER R on R.ID = K.REHBERID'
          'where '
          #9'PLANTARIHI between '
          #39'2010-01-01 00:00'#39' and '#39'2020-01-01 23:59'#39' and '
          '  K.TUR in(71,72,73,75)')
        TabOrder = 8
        Visible = False
        WordWrap = False
      end
      object MemoTakvimPlanKK: TMemo
        Left = 95
        Top = 268
        Width = 647
        Height = 22
        Lines.Strings = (
          ' ---- Kredi Kart'#305' B'#246'l'#252'm'#252' Takvim'
          ''
          'select '
          #9'type = 0,'
          
            #9'start = convert(datetime, convert(varchar(10), SOT, 120)+'#39' 00:0' +
            '0'#39', 120) ,'
          
            #9'finish = convert(datetime, convert(varchar(10), SOT+1, 120)+'#39' 0' +
            '0:00'#39',120), '
          #9'options=3, '
          
            #9'caption = isnull((select ANAHTAR from GENINI where BOLUM=-1005 ' +
            'and DIL=-1 and DEGER=57),'#39'Kredi Kart'#305#39')+'#39' '#39'+isnull(convert(varch' +
            'ar(20), SUM(PLKK.TUTAR),1),'#39'0'#39')+'#39' '#39'+isnull(KK.ADI,'#39#39'),'
          #9'location=KK.ADI, '
          
            #9'message=(select ANAHTAR from GENINI where BOLUM=-1005 and DIL=-' +
            '1 and DEGER=57), '
          #9'state=0, '
          #9'labelColor =8689404,'
          #9'Dosya='#39'KREDIKARTI'#39', '
          
            #9'ID2=case when LEN(convert(varchar(2),MONTH(GETDATE()))) = 1 the' +
            'n '
          
            #9'convert(int,'#39'0'#39'+convert(varchar(2),MONTH(SOT))+convert(varchar(' +
            '4),YEAR(SOT))+convert(varchar(5),kk.ID))'
          
            #9'else convert(int,convert(varchar(2),MONTH(SOT))+convert(varchar' +
            '(4),YEAR(SOT))+convert(varchar(5),kk.ID))end ,'
          #9'REHBERID=-99,'
          #9'TUR=57, TURAD=T.AD,'
          #9'TUTAR=-1*SUM(PLKK.TUTAR),isnull(PLKK.KUR,'#39'TL'#39') ,'
          #9'YON='#39#214'deme'#39','
          #9'SIRA=5,'
          #9'ACIKLAMA='#39'KK '#214'demesi'#39
          'from'
          #9'PLANKREDIKARTI PLKK'
          '        inner join ISLEMTURLERI T on T.TUR=57'
          '        inner join KREDIKARTI KK  on KK.ID = PLKK.KKID'
          'where'
          #9'SOT between '#39'2010-01-01 00:00'#39
          'and '#39'2020-01-01 23:59'#39
          'group by KK.ID,KK.ADI, SOT,PLKK.KUR,T.AD')
        TabOrder = 9
        Visible = False
        WordWrap = False
      end
      object MemoTakvimTahsilatPlan: TMemo
        Left = 95
        Top = 209
        Width = 647
        Height = 19
        Lines.Strings = (
          '----Tahsilat plan'#305' Takvim 61'
          ''
          'select '
          #9'type = 0,'
          
            #9'start = convert(datetime, convert(varchar(10), PLANTARIHI, 120)' +
            '+'#39' 00:00'#39', 120) ,'
          
            #9'finish = convert(datetime, convert(varchar(10), PLANTARIHI+1, 1' +
            '20)+'#39' 00:00'#39',120), '
          #9'options = 3, '
          #9'caption =convert(varchar(20),BORC,1)'
          #9#9'+isnull(KUR,'#39'TL'#39')+'#39' T.P. '#39
          #9#9'+isnull(R.KOD,'#39#39')+'#39' '#39
          #9#9'+substring(R.FIRMA,1, CHARINDEX('#39' '#39', R.FIRMA)) +'#39' '#39
          #9#9'+RTRIM(isnull(K.ACIKLAMA,'#39#39')),'
          #9'location = isnull(RTRIM(CONVERT(varchar(25),R.FIRMA)),'#39#39'), '
          #9'message= RTRIM(isnull(K.ACIKLAMA,'#39#39')), '
          #9'state=0, '
          #9'labelColor =6610596,'
          #9'Dosya='#39'KASA'#39', '
          #9'ID2=K.ID,'
          '               REHBERID=R.ID,--select * from SIPARISDETAY'
          #9'K.TUR,TURAD=T.AD,'
          #9'TUTAR = BORC,'
          #9'KUR=isnull(K.KUR,'#39'TL'#39'),'
          #9' YON='#39'Tahsilat'#39' ,'
          #9' SIRA=1,'
          #9' ACIKLAMA='#39'A'#231#305'k Hesap'#39
          'from'
          #9'KASA K'
          '        inner join ISLEMTURLERI T on K.TUR=T.TUR'
          '        left outer join REHBER R on R.ID = K.REHBERID'
          'where '
          #9'PLANTARIHI between '
          #39'2010-01-01 00:00'#39' and '#39'2020-01-01 23:59'#39' and '
          '  K.TUR in(61,62,63,65)'
          '')
        TabOrder = 10
        Visible = False
        WordWrap = False
      end
      object MemoTakvimSenetMusteri: TMemo
        Left = 111
        Top = 348
        Width = 647
        Height = 22
        Lines.Strings = (
          '--M'#252#351'teri Seneti B'#246'l'#252'm'#252' Takvim 24'
          ''
          'select   '
          #9'type = 0, '
          
            '    start = convert(datetime, convert(varchar(10), VADE, 120)+'#39' ' +
            '00:00'#39', 120) ,'
          
            '    finish = convert(datetime, convert(varchar(10), VADE+1, 120)' +
            '+'#39' 00:00'#39',120),   options=3,  '
          
            '    caption = convert(varchar(20),TUTAR,1)+  isnull( KUR,'#39'TL'#39')+'#39 +
            'M'#252#351'teri Seneti '#39
          
            #9#9#9'   +isnull(R.KOD,'#39#39')+'#39' '#39'+substring(R.FIRMA,1, CHARINDEX('#39' '#39', ' +
            'R.FIRMA)),'
          #9'location='#39#39','
          #9'message='#39'M'#252#351'teri Seneti'#39', '
          #9'state=0,   '
          #9'labelColor =6610596,'
          '    Dosya='#39'CEKLER'#39', '
          '    ID2=C.ID,'
          '               REHBERID=R.ID,'
          '    C.TUR, TURAD=T.AD,'
          '    TUTAR,KUR,'
          #9' YON='#39'Tahsilat'#39' , '
          #9' SIRA=2,'
          #9' AIKLAMA='#39'Senet'#39' '
          #9' '
          'from CEKLER C'
          'inner join ISLEMTURLERI T on C.TUR=T.TUR'
          'inner join REHBER R on R.ID=C.REHBERID'
          'where '
          #9'VADE >= '#39'2010-01-01 00:00'#39' '
          'and VADE <= '#39'2020-01-01 23:59'#39
          #9#9'AND C.TUR'#9'IN (130,133,138)'
          #9#9'AND CEKSENET=121')
        TabOrder = 11
        Visible = False
        WordWrap = False
      end
      object MemoTakvimSenetKendi: TMemo
        Left = 111
        Top = 370
        Width = 647
        Height = 22
        Lines.Strings = (
          '--Kendi Senetimiz B'#246'l'#252'm'#252' Takvim 34'
          ''
          'select   '
          #9'type = 0, '
          
            '    start = convert(datetime, convert(varchar(10), VADE, 120)+'#39' ' +
            '00:00'#39', 120) ,'
          
            '    finish = convert(datetime, convert(varchar(10), VADE+1, 120)' +
            '+'#39' 00:00'#39',120),   options=3,  '
          
            '     caption = convert(varchar(20),TUTAR,1)+  isnull( KUR,'#39'TL'#39')+' +
            #39' Kendi Senetimiz '#39
          
            #9#9#9'+isnull(R.KOD,'#39#39')+substring(R.FIRMA,1, CHARINDEX('#39' '#39', R.FIRMA' +
            ')),'
          #9'location='#39#39','
          #9'message='#39'Kendi Senetimiz '#39', '
          #9'state=0,   '
          #9'labelColor = 8689404,'
          '    Dosya='#39'CEKLER'#39', '
          '    ID2=C.ID,'
          '               REHBERID=R.ID,'
          '    C.TUR, TURAD=T.AD,'
          '    -1*TUTAR,KUR,'
          #9' YON='#39#214'deme'#39', '
          #9' SIRA=2,'
          #9' AIKLAMA='#39'Senet'#39' '
          #9' '
          'from CEKLER C'
          'inner join ISLEMTURLERI T on C.TUR=T.TUR'
          'inner join REHBER R on R.ID=C.REHBERID'
          'where '
          #9'VADE >= '#39'2010-01-01 00:00'#39' '
          'and VADE <= '#39'2020-01-01 23:59'#39
          #9'and '#9'C.TUR between 140 and 149  '
          #9'and CEKSENET=321')
        TabOrder = 12
        Visible = False
        WordWrap = False
      end
      object MemoTakvimGider: TMemo
        Left = 117
        Top = 480
        Width = 649
        Height = 17
        Lines.Strings = (
          '--- Gider B'#246'l'#252'm'#252' Takvim 0'
          ''
          'select   '
          #9'type = 0, '
          
            '    start = convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONV' +
            'ERT(Varchar(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'),120' +
            ') ,'
          
            '    finish = convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CON' +
            'VERT(Varchar(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'),12' +
            '0),   '
          '    options=3,  '
          
            '    caption = convert(varchar(20),B.PLANLANAN,1)+  isnull( KUR,'#39 +
            'TL'#39')+'#39' Gider B'#252't'#231'e '#39'+isnull(M.KOD,'#39#39')+'#39' '#39'+isnull(RTRIM(M.AD),'#39#39')' +
            ','
          #9'location=isnull(RTRIM(M.AD),'#39#39'),'
          #9'message='#39'Gider B'#252't'#231'e '#39'+convert(varchar(20),B.PLANLANAN,1), '
          #9'state=0,   '
          #9'labelColor =8689404 ,'
          '    Dosya='#39'B'#252't'#231'e'#39', '
          '    ID2=B.ID,'
          '    REHBERID=-1,'
          '    TUR= 311,TURAD=T.AD,'
          '    TUTAR=B.PLANLANAN,KUR,'
          #9'YON='#39'Masraf B'#252't'#231'esi'#39', '
          #9'SIRA=7,'
          #9'AIKLAMA='#39'Gider B'#252't'#231'e'#39' '#9' '
          'from '
          #9'BUTCE B inner join '
          
            #9'MASRAFGELIR M on M.ID=B.MASRAFID  inner join ISLEMTURLERI T on ' +
            'T.TUR=311'
          'where'
          ' B.GOR=1 and M.GELIRMI=0'
          
            ' and CONVERT(DATETIME, cast(YIL as varchar(4))+'#39'-'#39'+cast(AY as va' +
            'rchar(2))+'#39'-'#39'+cast(GUN as varchar(2)), 102) '
          ' between '#39'2010-01-01 00:00'#39' and '#39'2020-01-01 23:59'#39)
        TabOrder = 13
        Visible = False
        WordWrap = False
      end
      object MemoTakvimGelir: TMemo
        Left = 117
        Top = 498
        Width = 647
        Height = 19
        Lines.Strings = (
          '--- Gelir B'#246'l'#252'm'#252' Takvim 1'
          ''
          'select   '
          #9'type = 0, '
          
            '    start = convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONV' +
            'ERT(Varchar(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'),120' +
            ') ,'
          
            '    finish = convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CON' +
            'VERT(Varchar(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'),12' +
            '0),   '
          '    options=3,  '
          
            '    caption = convert(varchar(20),B.PLANLANAN,1)+  isnull( KUR,'#39 +
            'TL'#39')+'#39' Gelir B'#252't'#231'e '#39'+isnull(M.KOD,'#39#39')+'#39' '#39'+isnull(RTRIM(M.AD),'#39#39')' +
            ','
          #9'location=isnull(RTRIM(M.AD),'#39#39'),'
          #9'message='#39'Gelir B'#252't'#231'e '#39'+convert(varchar(20),B.PLANLANAN,1), '
          #9'state=0,   '
          #9'labelColor = 6610596 ,'
          '    Dosya='#39'B'#252't'#231'e'#39', '
          '    ID2=B.ID,'
          '    REHBERID=-1,'
          '    TUR= 301 ,TURAD=T.AD,'
          '    TUTAR=B.PLANLANAN,KUR,'
          #9'YON='#39'Gelir B'#252't'#231'esi'#39', '
          #9'SIRA=7,'
          #9'AIKLAMA='#39'Gelir B'#252't'#231'e'#39' '#9' '
          'from '
          #9'BUTCE B inner join '
          
            #9'MASRAFGELIR M on M.ID=B.MASRAFID inner join ISLEMTURLERI T on T' +
            '.TUR=311'
          'where B.GOR=1 and M.GELIRMI=1'
          
            ' and CONVERT(DATETIME, cast(YIL as varchar(4))+'#39'-'#39'+cast(AY as va' +
            'rchar(2))+'#39'-'#39'+cast(GUN as varchar(2)), 102) '
          ' between '#39'2010-01-01 00:00'#39' and '#39'2020-01-01 23:59'#39)
        TabOrder = 14
        Visible = False
        WordWrap = False
      end
      object MemoTakvimPOS: TMemo
        Left = 111
        Top = 523
        Width = 647
        Height = 19
        Lines.Strings = (
          '----POS Takvim 61'
          ''
          'select '
          #9'type = 0,'
          
            #9'start = convert(datetime, convert(varchar(10), PLANTARIHI, 120)' +
            '+'#39' 00:00'#39', 120) ,'
          
            #9'finish = convert(datetime, convert(varchar(10), PLANTARIHI+1, 1' +
            '20)+'#39' 00:00'#39',120), '
          #9'options = 3, '
          #9'caption = convert(varchar(20),ALACAK,1)'
          
            #9#9'+isnull(KUR,'#39'TL'#39')+'#39' '#39' + (select ANAHTAR from GENINI where BOLU' +
            'M=-1005 and DIL=-1 and DEGER=K.TUR)+'#39' '#39
          #9#9'+isnull(R.KOD,'#39#39')+'#39' '#39
          #9#9'+isnull(RTRIM(CONVERT(varchar(25),R.FIRMA)),'#39#39')+ '#39' '#39
          #9#9'+RTRIM(isnull(K.ACIKLAMA,'#39#39')),'
          #9'location = isnull(RTRIM(CONVERT(varchar(25),R.FIRMA)),'#39#39'), '
          #9'message= RTRIM(isnull(K.ACIKLAMA,'#39#39')), '
          #9'state=0, '
          #9'labelColor =6610596,'
          #9'Dosya='#39'KASA'#39', '
          #9'ID2=K.ID,'
          '               REHBERID=R.ID,--select * from SIPARISDETAY'
          #9'K.TUR,TURAD=T.AD,'
          #9'TUTAR =ALACAK,'
          #9'KUR=isnull(K.KUR,'#39'TL'#39'),'
          #9' YON='#39'Tahsilat'#39' , '
          #9' SIRA=1,  '
          #9' ACIKLAMA='#39'A'#231#305'k Hesap'#39#9' '#9
          'from '
          
            #9'KASA K  inner join ISLEMTURLERI T on T.TUR=K.TUR left outer joi' +
            'n '
          'REHBER R on R.ID = K.REHBERID'
          'where '
          #9'PLANTARIHI between '
          #39'2010-01-01 00:00'#39' and '#39'2020-01-01 23:59'#39' and '
          '  K.TUR in(25) and HESAPTURU='#39'P'#39)
        TabOrder = 15
        Visible = False
        WordWrap = False
      end
      object MemoBaslangic: TMemo
        Left = 61
        Top = 32
        Width = 641
        Height = 39
        Lines.Strings = (
          
            'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'##T' +
            'AKVIM_SPID_%'#39')'
          'DROP TABLE ##TAKVIM_SPID_'
          ''
          'CREATE TABLE ##TAKVIM_SPID_('
          #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
          #9'[type] [smallint] NULL,'
          #9'[start] [datetime]  NULL,'
          #9'[finish] [datetime]  NULL,'
          #9'[options] [smallint] NULL,'
          #9'[caption] [nvarchar](600) NULL,'
          #9'[location] [nvarchar](150) NULL,'
          #9'[message] [nvarchar](350) NULL,'
          #9'[state] [smallint] NULL,'
          #9'[labelColor] [bigint] NULL,'
          '    [DOSYA] [nvarchar](20) NULL,'
          '    [ID2] [int] NULL,'
          '    [REHBERID] [int] NULL,'
          #9'[TUR] [smallint] NULL,'
          '    [TURAD] [nvarchar](40) NULL,'
          #9'[TUTAR] [money] NULL,'
          '    [KUR] [nvarchar](5) NULL,'
          '    [YON] [nvarchar](20) NULL,'
          '    [SIRA] [smallint] NULL,'
          '    [ACIKLAMA] [nvarchar](300) NULL'
          ')'
          ''
          'INSERT INTO ##TAKVIM_SPID_')
        TabOrder = 16
        Visible = False
        WordWrap = False
      end
    end
    object TabSheetPivot: TcxTabSheet
      Tag = 2
      Caption = 'Pivot'
      ImageIndex = 19
      object Label1: TLabel
        Left = 184
        Top = 48
        Width = 31
        Height = 13
        Caption = 'TARIH'
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 1146
        Height = 41
        Align = alTop
        TabOrder = 0
        object LabelBittar: TJvDateTimePicker
          Left = 9
          Top = 2
          Width = 184
          Height = 33
          Date = 41640.000000000000000000
          Time = 0.577444641203328500
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnChange = LabelBittarChange
          DropDownDate = 41430.000000000000000000
          NullDate = 36526.000000000000000000
        end
        object cxImageComboBox1: TcxImageComboBox
          Left = 207
          Top = 2
          RepositoryItem = Tablo.RepStokKaynakUretimYeri
          ParentFont = False
          Properties.Items = <>
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -21
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 1
          Visible = False
          Width = 225
        end
      end
      object Memo2: TMemo
        Left = 9
        Top = 314
        Width = 630
        Height = 47
        Color = clHighlight
        TabOrder = 1
        Visible = False
      end
      object pivot: TcxDBPivotGrid
        AlignWithMargins = True
        Left = 3
        Top = 44
        Width = 1140
        Height = 398
        Customization.FormStyle = cfsAdvanced
        Align = alClient
        DataSource = DtsPivot
        Groups = <>
        OptionsDataField.IsCaptionAssigned = True
        OptionsDataField.Caption = 'Veri'
        OptionsSelection.MultiSelect = True
        OptionsView.ColumnGrandTotalText = 'Genel Toplam'
        OptionsView.RowGrandTotalText = 'Genel Toplam'
        PopupMenu = pmPivot
        TabOrder = 2
        object pivotGRUP: TcxDBPivotGridField
          Area = faRow
          AreaIndex = 0
          DataBinding.FieldName = 'GRUP'
          Visible = True
          UniqueName = 'GRUP'
        end
        object pivotTUR: TcxDBPivotGridField
          Area = faRow
          AreaIndex = 1
          DataBinding.FieldName = 'TUR'
          Visible = True
          UniqueName = 'TUR'
        end
        object pivotTARIH: TcxDBPivotGridField
          Area = faColumn
          AreaIndex = 0
          DataBinding.FieldName = 'TARIH'
          Visible = True
          UniqueName = 'TARIH'
        end
        object pivotTUTAR: TcxDBPivotGridField
          Area = faData
          AreaIndex = 0
          DataBinding.FieldName = 'TUTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Visible = True
          UniqueName = 'TUTAR'
        end
      end
      object FGrid: TcxGrid
        AlignWithMargins = True
        Left = 1385
        Top = 1237
        Width = 443
        Height = 128
        Align = alCustom
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        Visible = False
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object FGridTableView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsPivot
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
            end
            item
              Format = ',0.00;(,0.00)'
            end
            item
              Format = ',0.00;(,0.00)'
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.ContentEven = AnaForm.cxStyle1
          Styles.GroupByBox = AnaForm.cxStyle1
          Styles.Header = AnaForm.cxStyle1
          object FGridTableViewGRUP: TcxGridDBColumn
            DataBinding.FieldName = 'GRUP'
          end
          object FGridTableViewTUR: TcxGridDBColumn
            DataBinding.FieldName = 'TUR'
          end
          object FGridTableViewTARIH: TcxGridDBColumn
            DataBinding.FieldName = 'TARIH'
          end
          object FGridTableViewTUTAR: TcxGridDBColumn
            DataBinding.FieldName = 'TUTAR'
          end
        end
        object FGridDBTableView1: TcxGridDBTableView
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
          object FGridDBTableView1DURUM: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object FGridDBTableView1VADE: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 130
          end
          object FGridDBTableView1SERINO: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object FGridDBTableView1HESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 354
          end
          object FGridDBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
          end
        end
        object FGridLevel1: TcxGridLevel
          GridView = FGridTableView
        end
      end
    end
    object TabSheetGrafik: TcxTabSheet
      Tag = 3
      Caption = 'Grafik'
      ImageIndex = 19
      object GridGrafik: TcxGrid
        Left = 0
        Top = 0
        Width = 1146
        Height = 445
        Align = alClient
        TabOrder = 0
        object GridGrafikDBChartView: TcxGridDBChartView
          Categories.DataBinding.FieldName = 'AY'
          DataController.DataSource = DsTabGrafik
          DiagramColumn.Active = True
          DiagramColumn.Values.CaptionPosition = cdvcpOutsideEnd
          ToolBox.Border = tbNone
          ToolBox.DiagramSelector = True
          object GridGrafikDBChartViewGUN: TcxGridDBChartSeries
            DataBinding.FieldName = 'GUN'
            DisplayText = ' '
          end
          object GridGrafikDBChartViewAYADI: TcxGridDBChartSeries
            DataBinding.FieldName = 'AY'
            DisplayText = ' '
          end
          object GridGrafikDBChartViewBAKIYE: TcxGridDBChartSeries
            DataBinding.FieldName = 'BAKIYE'
            DisplayText = ' '
          end
        end
        object GridGrafikLevel1: TcxGridLevel
          GridView = GridGrafikDBChartView
        end
      end
      object SqlMemoGrafik: TMemo
        Left = 321
        Top = 525
        Width = 647
        Height = 27
        Lines.Strings = (
          '--- Grafik B'#246'l'#252'm'#252' '
          ''
          'SET LANGUAGE Turkish'
          'Declare @BasTarih smalldatetime'
          'Declare @BitTarih smalldatetime'
          ''
          'set @BasTarih=:BasTar'
          'set @BitTarih=:BitTar'
          ''
          '--////////////////////////////'
          'IF EXISTS(SELECT * FROM sysobjects'
          'WHERE ID = (OBJECT_ID('#39'GRAFIKPLAN_SPID'#39')) AND xtype = '#39'U'#39')'
          'DROP TABLE GRAFIKPLAN_SPID'
          'CREATE TABLE GRAFIKPLAN_SPID'
          '(TARIH DATETIME,'
          'GUN nvarchar(2),'
          'AY nvarchar(15),'
          'YIL nvarchar(4),'
          'TUTAR Money,'
          'BAKIYE Money);'
          ''
          ''
          'WITH numbers AS'
          '('
          'SELECT 1 AS num'
          'UNION ALL'
          'SELECT num + 1 FROM numbers'
          'WHERE num <= (SELECT DATEDIFF(dd, @BasTarih, @BitTarih))'
          ')'
          ''
          'INSERT INTO GRAFIKPLAN_SPID (TARIH,GUN,AY,YIL,TUTAR)'
          'SELECT'
          'num+@BasTarih-1,'
          
            'CASE WHEN LEN(DAY(num+@BasTarih-1))=1 THEN '#39'0'#39'+CONVERT(VARCHAR(2' +
            '),DAY(num+@BasTarih-1)) ELSE CONVERT(VARCHAR(2),DAY(num+@BasTari' +
            'h-1)) END ,'
          'DATENAME(MONTH,num+@BasTarih-1),'
          
            '--CASE WHEN LEN(MONTH(num+@BasTarih-1))=1 THEN '#39'0'#39'+CONVERT(VARCH' +
            'AR(2),MONTH(num+@BasTarih-1)) ELSE CONVERT(VARCHAR(2),MONTH(num+' +
            '@BasTarih-1)) END ,'
          'YEAR(num+@BasTarih-1),0 FROM numbers'
          'OPTION (MAXRECURSION 0)'
          ''
          'SET LANGUAGE us_english'
          ''
          '--------////////////////-------------------------------'
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '
          #39'##PLANLAR_SPID_%'#39')'
          'DROP TABLE ##PLANLAR_SPID_'
          ''
          'CREATE TABLE ##PLANLAR_SPID_('
          #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
          #9'PLANTARIH [SmallDateTime]  NULL,'
          #9'TUTAR [money] NULL)'
          ''
          'INSERT INTO ##PLANLAR_SPID_ (PLANTARIH,TUTAR)'
          'Select TARIH,Tutar=Sum(Tutar) from ( '
          
            'Select TARIH='#39'1900-01-01'#39',Tutar=0,KUR='#39'TL'#39' Where 0=1      -- Uni' +
            'on All Koymak i'#231'in select yazd'#305'm '
          ' _SQLMEMO_  ) as s'
          'Group by TARIH'
          'Order by 1'
          ''
          '-----'
          'declare @KasaBakiye money, @Tutar money,@Tarih DateTime'
          
            'DECLARE PlanTable CURSOR FOR '#9'SELECT TARIH FROM GRAFIKPLAN_SPID ' +
            'ORDER BY TARIH ASC'
          'Set @KasaBakiye=0'
          'Set @Tutar=0'
          '----  Toplam Bakiyeyi Yaz  Kasa  ve BankaHesaplar'#305' Bakiye'
          ''
          ' Select @KasaBakiye=Sum(KasaBakiye) from'#9
          
            '              (SELECT top 1     KasaBakiye=(select sum(de) from ' +
            '('
          ''
          #9#9'Select case When K.KUR='#39'TL'#39' then K.BAKIYE else'
          #9#9#9'K.BAKIYE*('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=K.KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end as de'
          ''
          #9#9'from KASALAR K WHERE K.GUNLUKAKSIYONDAGOSTER=1 ) as ff)'
          #9#9'FROM KASALAR K1 (NOLOCK)  '
          #9#9'WHERE GUNLUKAKSIYONDAGOSTER=1 '
          #9#9'Union All'
          #9#9'SELECT top 1'
          #9'    KasaBakiye=(select sum(de) from ('
          ''
          #9#9'Select case When B.KUR='#39'TL'#39' then B.BAKIYE else'
          #9#9#9'B.BAKIYE*('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=B.KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end as de'
          #9#9'from BANKAHESAPLAR B WHERE B.REHBERID=-1 ) as ff)'
          #9#9'FROM BANKAHESAPLAR B1 (NOLOCK)  '
          #9#9'WHERE REHBERID=-1 ) as AA'
          '--///////'
          '  OPEN PlanTable'
          '  FETCH NEXT FROM PlanTable INTO @Tarih'
          #9'WHILE @@FETCH_STATUS=0'
          #9#9'BEGIN'
          #9#9'Set @Tutar=0'
          
            #9#9'select @Tutar=PS.TUTAR from ##PLANLAR_SPID_ PS  Where PS.PLANT' +
            'ARIH=@Tarih'
          ''
          #9#9'Update GRAFIKPLAN_SPID set '
          #9#9'BAKIYE=@KasaBakiye+@Tutar,'
          #9#9'TUTAR=@Tutar Where TARIH=@Tarih'
          ''
          #9'    set @KasaBakiye=@KasaBakiye+@Tutar'#9
          #9#9'FETCH NEXT FROM PlanTable INTO @Tarih'
          #9#9'END'
          ''
          '  CLOSE PlanTable'
          '  DEALLOCATE PlanTable'
          ''
          
            '--Select * from GRAFIKPLAN_SPID Where datename(dw,TARIH)='#39'Sunday' +
            #39' order by TARIH'
          ''
          '')
        TabOrder = 1
        Visible = False
        WordWrap = False
      end
      object SqlGrafikPOS: TMemo
        Left = 336
        Top = 502
        Width = 649
        Height = 17
        Lines.Strings = (
          '--Pos Grafik'
          ''
          
            ' Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(P' +
            'LANTARIHI,'#39'1900-01-01'#39'),20)),'
          'Tutar= Case When KUR='#39'TL'#39' then isnull(Sum(ALACAK),0) else'
          #9#9#9'isnull(Sum(ALACAK),0)*('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end'
          
            ',KUR from KASA Where TUR = 25 and HESAPTURU='#39'P'#39' and PLANTARIHI >' +
            '=@BasTarih  and PLANTARIHI <= @BitTarih'
          'Group by PLANTARIHI,KUR'
          ''
          ''
          '--'#214'nceki POS olay'#305
          
            '--Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(' +
            'ALINISTARIHI,'#39'1900-01-01'#39'),20)),'
          '--Tutar = '
          '--case When KUR='#39'TL'#39' then isnull(SUM(BAKIYE),0) else'
          '--'#9#9#9'isnull(SUM(BAKIYE),0)*('
          '--'#9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          '--'#9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          '--'#9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          '--'#9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          '--'#9#9#9#9#9') '
          
            '--'#9#9#9#9#9'end,KUR from POS  Where ALINISTARIHI >=@BasTarih  and ALI' +
            'NISTARIHI <= @BitTarih'
          '--Group by ALINISTARIHI,K')
        TabOrder = 2
        Visible = False
        WordWrap = False
      end
      object SqlGrafikMaas: TMemo
        Left = 338
        Top = 483
        Width = 647
        Height = 18
        Lines.Strings = (
          '--Maas Grafik'
          ''
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(TA' +
            'RIH,'#39'1900-01-01'#39'),20)),'
          'Tutar=case When KUR='#39'TL'#39' then (-1*isnull(SUM(TUTAR),0))  else'
          #9#9#9'(-1*isnull(SUM(TUTAR),0)) *('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end,KUR '
          #9#9#9#9#9'from PLANMAAS PM Where '
          #9'TARIH >= @BasTarih'
          'and TARIH <= @BitTarih'
          
            'and (select count(*) from REHBERAYAR RA where RA.ETIKET=PM.ETIKE' +
            'T and RA.VARSAYILAN=36)>0'#9
          'group by TARIH, KUR'
          'having sum(TUTAR)>0')
        TabOrder = 3
        Visible = False
        WordWrap = False
      end
      object SqlGrafikKK: TMemo
        Left = 338
        Top = 467
        Width = 647
        Height = 18
        Lines.Strings = (
          '--Kredi Kart'#305' Grafik'
          ''
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(TA' +
            'RIH,'#39'1900-01-01'#39'),20)),'
          'Tutar='
          ''
          'case When KUR='#39'TL'#39' then (-1*isnull(SUM(TUTAR),0))  else'
          #9#9#9'(-1*isnull(SUM(TUTAR),0)) *('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9#9#9#9#9') '
          
            #9#9#9#9#9'end,KUR from PLANKREDIKARTI  Where SOT >=@BasTarih  and SOT' +
            ' <= @BitTarih'
          'Group by TARIH,KUR')
        TabOrder = 4
        Visible = False
        WordWrap = False
      end
      object SqlGrafikKredi: TMemo
        Left = 338
        Top = 450
        Width = 647
        Height = 18
        Lines.Strings = (
          '--Kredi Grafik'
          ''
          
            'select  TARIH=Convert(smalldatetime,convert(varchar(10),isnull(T' +
            'ARIH,'#39'1900-01-01'#39'),20)), '
          
            #9'TUTAR=case When KO.KUR='#39'TL'#39' then (-1*isnull(SUM(KO.TAKSIT),0)) ' +
            ' else'
          #9#9#9'(-1*isnull(SUM(KO.TAKSIT),0)) *('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KO.KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end'
          #9
          #9', KO.KUR'
          'from KREDILER K inner join PLANKREDI KO on K.ID =KO.KREDIID'
          'where '
          #9'TARIH >= @BasTarih and  '
          #9'TARIH <= @BitTarih and '
          #9'ODENMIS=0 '
          ''
          'group by TARIH, KO.KUR')
        TabOrder = 5
        Visible = False
        WordWrap = False
      end
      object SqlGrafikGider: TMemo
        Left = 336
        Top = 420
        Width = 649
        Height = 17
        Lines.Strings = (
          '--Gider Grafik'
          ''
          
            'Select TARIH=convert(smalldatetime, convert(char(10),+(convert(c' +
            'har(2),AY)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(char(4),YIL))),1' +
            '20),'
          'Tutar =('
          'case When KUR='#39'TL'#39' then (-1*isnull(SUM(PLANLANAN),0))  else '
          
            '                (-1*isnull(SUM(PLANLANAN),0))*(Select SATIS from' +
            ' DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=B.KUR'
          #9#9#9#9#9')'
          #9#9#9#9#9'end)'
          #9#9#9#9#9
          
            #9#9#9#9#9',KUR from BUTCE B left outer Join MASRAFGELIR M on B.MASRAF' +
            'ID=M.ID'
          
            #9#9#9#9#9'Where GELIRMI=0 and convert(smalldatetime, convert(char(10)' +
            ',+(convert(char(2),AY)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(char' +
            '(4),YIL))),120) >=@BasTarih  and '
          
            #9#9#9#9#9'convert(smalldatetime, convert(char(10),+(convert(char(2),A' +
            'Y)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(char(4),YIL))),120) <= @' +
            'BitTarih'
          
            'Group by convert(smalldatetime, convert(char(10),+(convert(char(' +
            '2),AY)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(char(4),YIL))),120),' +
            'KUR,GELIRMI'
          '')
        TabOrder = 6
        Visible = False
        WordWrap = False
      end
      object SqlGrafikGelir: TMemo
        Left = 338
        Top = 402
        Width = 647
        Height = 19
        Lines.Strings = (
          '--Gelir Grafik'
          ''
          
            'Select TARIH=convert(smalldatetime, convert(char(10),+(convert(c' +
            'har(2),AY)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(char(4),YIL))),1' +
            '20),'
          'Tutar =('
          'case When KUR='#39'TL'#39' then (isnull(SUM(PLANLANAN),0))  else '
          
            '                (isnull(SUM(PLANLANAN),0))*(Select SATIS from DO' +
            'VIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=B.KUR'
          #9#9#9#9#9')'
          #9#9#9#9#9'end)'
          #9#9#9#9#9
          
            #9#9#9#9#9',KUR from BUTCE B left outer Join MASRAFGELIR M on B.MASRAF' +
            'ID=M.ID'
          
            #9#9#9#9#9'Where GELIRMI=1 and  convert(smalldatetime, convert(char(10' +
            '),+(convert(char(2),AY)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(cha' +
            'r(4),YIL))),120) >=@BasTarih  and '
          
            #9#9#9#9#9'convert(smalldatetime, convert(char(10),+(convert(char(2),A' +
            'Y)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(char(4),YIL))),120) <= @' +
            'BitTarih'
          
            'Group by convert(smalldatetime, convert(char(10),+(convert(char(' +
            '2),AY)+'#39'-'#39'+convert(char(2),GUN)+'#39'-'#39'+convert(char(4),YIL))),120),' +
            'KUR,GELIRMI')
        TabOrder = 7
        Visible = False
        WordWrap = False
      end
      object SqlGrafikSenetMusteri: TMemo
        Left = 336
        Top = 381
        Width = 649
        Height = 17
        Lines.Strings = (
          '--Kendi Senetimiz Grafik 34'
          'select TARIH,TUTAR=-1*sum(TUTAR),KUR from('
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
            'DE ,'#39'1900-01-01'#39'),20)),'
          'Tutar = case When KUR='#39'TL'#39' then TUTAR'
          #9'else TUTAR*(Select SATIS from DOVIZ D Where  '
          #9'Year(D.TARIH) =YEAR(GETDATE()) and MONTH(D.TARIH)='
          
            #9'MONTH(GETDATE()) and DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KU' +
            'R) '
          #9'end'
          ',KUR '
          'from CEKLER C '
          'Where '
          'TUR between 140 and 149  '
          'and CEKSENET=321'
          'and VADE >=@BasTarih  and VADE <= @BitTarih '
          ')as CEKLER'
          'Group by TARIH,KUR'
          '')
        TabOrder = 8
        Visible = False
        WordWrap = False
      end
      object SqlGrafikSenetKendi: TMemo
        Left = 338
        Top = 366
        Width = 647
        Height = 18
        Lines.Strings = (
          '--M'#252#351'teri Senet Grafik 24'
          'select TARIH,TUTAR=sum(TUTAR),KUR from('
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
            'DE ,'#39'1900-01-01'#39'),20)),'
          'Tutar = case When KUR='#39'TL'#39' then TUTAR'
          'else TUTAR*(Select SATIS from DOVIZ D Where  '
          #9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9') '
          'end'
          ',KUR '
          'from CEKLER C '
          'Where '
          'TUR between 130 and 139 '
          'and CEKSENET=121'
          'and  VADE >=@BasTarih  and VADE <= @BitTarih'
          ')as CEKLER'
          'Group by TARIH,KUR'
          '')
        TabOrder = 9
        Visible = False
        WordWrap = False
      end
      object SqlGrafikCekKendi: TMemo
        Left = 336
        Top = 346
        Width = 649
        Height = 17
        Lines.Strings = (
          '--Kendi '#231'ekimiz Grafik'
          ''
          ''
          'select TARIH,TUTAR=-1*sum(TUTAR),KUR from('
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
            'DE ,'#39'1900-01-01'#39'),20)),'
          'Tutar = case When KUR='#39'TL'#39' then TUTAR'
          #9'else TUTAR*(Select SATIS from DOVIZ D Where  '
          #9'Year(D.TARIH) =YEAR(GETDATE()) and MONTH(D.TARIH)='
          
            #9'MONTH(GETDATE()) and DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KU' +
            'R) '
          #9'end'
          ',KUR '
          'from CEKLER C '
          'Where '
          
            '(TUR between 140 and 149 or (isnull(CIROLU,0)=1 and TUR between ' +
            '130 and 139)) '
          'and CEKSENET=103'
          'and VADE >=@BasTarih  and VADE <= @BitTarih '
          ')as CEKLER'
          'Group by TARIH,KUR'
          '')
        TabOrder = 10
        Visible = False
        WordWrap = False
      end
      object SqlGrafikCekMusteri: TMemo
        Left = 330
        Top = 330
        Width = 655
        Height = 18
        Lines.Strings = (
          '--M'#252#351'teri '#199'eki Grafik'
          'select TARIH,TUTAR=sum(TUTAR),KUR from('
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
            'DE ,'#39'1900-01-01'#39'),20)),'
          'Tutar = case When KUR='#39'TL'#39' then TUTAR'
          'else TUTAR*(Select SATIS from DOVIZ D Where  '
          #9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9') '
          'end'
          ',KUR '
          'from CEKLER C '
          'Where '
          'TUR between 130 and 139 '
          'and CEKSENET=101'
          'and  VADE >=@BasTarih  and VADE <= @BitTarih'
          ')as CEKLER'
          'Group by TARIH,KUR'
          '')
        TabOrder = 11
        Visible = False
        WordWrap = False
      end
      object SqlGrafikOdemePlan: TMemo
        Left = 321
        Top = 284
        Width = 647
        Height = 17
        Lines.Strings = (
          '--Odeme Plan'#305' Grafik'
          ''
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(PL' +
            'ANTARIHI,'#39'1900-01-01'#39'),20)),'
          'Tutar= Case When KUR='#39'TL'#39' then (-1*isnull(Sum(ALACAK),0)) else'
          #9#9#9'(-1*isnull(Sum(ALACAK),0))*('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end'
          
            ',KUR from KASA Where TUR = 71 and PLANTARIHI >=@BasTarih  and PL' +
            'ANTARIHI <= @BitTarih'
          'Group by PLANTARIHI,KUR')
        TabOrder = 12
        Visible = False
        WordWrap = False
      end
      object SqlGrafikTahsilatPlan: TMemo
        Left = 335
        Top = 307
        Width = 647
        Height = 17
        Lines.Strings = (
          '--Tahsilat Plan'#305' Grafik'
          ' '
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(PL' +
            'ANTARIHI,'#39'1900-01-01'#39'),20)),'
          'Tutar= Case When KUR='#39'TL'#39' then isnull(Sum(BORC),0) else'
          #9#9#9'isnull(Sum(BORC),0)*('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end'
          
            ',KUR from KASA Where TUR = 61 and PLANTARIHI >=@BasTarih  and PL' +
            'ANTARIHI <= @BitTarih'
          'Group by PLANTARIHI,KUR')
        TabOrder = 13
        Visible = False
        WordWrap = False
      end
      object Memo3: TMemo
        Left = 440
        Top = 217
        Width = 649
        Height = 17
        Lines.Strings = (
          '--Kendi '#231'ekimiz Grafik'
          ''
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
            'DE ,'#39'1900-01-01'#39'),20)),'
          'Tutar='
          'case When KUR='#39'TL'#39' then '
          
            '(-1*(Select isnull(SUM(CA.TUTAR),0) from CEKLER CA Where TUR=33 ' +
            'or (isnull(CIROLU,0)=1 and TUR=23) and CA.VADE=C.VADE ))'
          ' else'
          
            '(-1*(Select isnull(SUM(CA.TUTAR),0) from CEKLER CA Where TUR=33 ' +
            'or (isnull(CIROLU,0)=1 and TUR=23) and CA.VADE=C.VADE ))*('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
          #9#9#9#9#9') '
          #9#9#9#9#9'end'
          
            ',KUR from CEKLER C Where TUR=33 or (isnull(CIROLU,0)=1 and TUR=2' +
            '3) and VADE >=@BasTarih  and VADE <= @BitTarih '
          'Group by KUR,VADE')
        TabOrder = 14
        Visible = False
        WordWrap = False
      end
      object Memo4: TMemo
        Left = 394
        Top = 240
        Width = 647
        Height = 18
        Lines.Strings = (
          '--M'#252#351'teri Senet Grafik 24'
          ''
          
            'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
            'DE,'#39'1900-01-01'#39'),20)),'
          'Tutar='
          'case When KUR='#39'TL'#39' then ('
          
            'Select isnull(SUM(SB.TUTAR),0) from SENETLER SB Where SB.TUR = 2' +
            '4 and  SB.VADE=S.VADE) else'
          #9#9#9'('
          
            'Select isnull(SUM(SB.TUTAR),0) from SENETLER SB Where SB.TUR = 2' +
            '4 and  SB.VADE=S.VADE )*('
          #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
          #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
          #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
          #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=S.KUR'
          #9#9#9#9#9') '
          
            #9#9#9#9#9'end,KUR from SENETLER S Where  VADE >=@BasTarih  and VADE <' +
            '= @BitTarih'
          'Group by KUR,VADE')
        TabOrder = 15
        Visible = False
        WordWrap = False
      end
    end
    object TabSheetListe: TcxTabSheet
      Tag = 4
      Caption = 'Liste'
      ImageIndex = 32
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 1146
        Height = 41
        Align = alTop
        TabOrder = 0
        object DateTimeListeBitis: TJvDateTimePicker
          Left = 9
          Top = 2
          Width = 184
          Height = 33
          Date = 41640.000000000000000000
          Time = 0.577444641203328500
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnChange = DateTimeListeBitisChange
          DropDownDate = 41430.000000000000000000
          NullDate = 36526.000000000000000000
        end
        object CheckTahsilat: TcxCheckBox
          Left = 251
          Top = 8
          Caption = 'Tahsilat'
          ParentFont = False
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          TabOrder = 1
          Transparent = True
          OnClick = DateTimeListeBitisChange
        end
        object CheckOdeme: TcxCheckBox
          Left = 347
          Top = 8
          Caption = #214'deme'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          TabOrder = 2
          Transparent = True
          OnClick = DateTimeListeBitisChange
        end
      end
      object GridListe: TcxGrid
        Left = 0
        Top = 41
        Width = 1146
        Height = 404
        Align = alClient
        PopupMenu = PopupMenuListe
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridListeView: TcxGridDBTableView
          OnDblClick = MenuListeDuzenleClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridListeViewCanFocusRecord
          DataController.DataSource = DtsListe
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skCount
              FieldName = 'FIRMA'
              Column = GridListeViewFIRMA
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
              Column = GridListeViewBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'TAHSILAT'
              Column = GridListeViewTAHSILAT
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ODEME'
              Column = GridListeViewODEME
            end>
          DataController.Summary.SummaryGroups = <>
          FilterRow.ApplyChanges = fracImmediately
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsSelection.HideFocusRectOnExit = False
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.Footer = True
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object GridListeViewTIPI: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TIPI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
          end
          object GridListeViewPLANTARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'PLANTARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.DisplayFormat = 'dd/mm/yyyy'
            Width = 86
          end
          object GridListeViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 77
          end
          object GridListeViewFIRMA: TcxGridDBColumn
            Caption = 'Cari '#220'nvan'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 171
          end
          object GridListeViewISTEL: TcxGridDBColumn
            Caption = #304#351' Telefonu'
            DataBinding.FieldName = 'ISTEL'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 88
          end
          object GridListeViewBORC: TcxGridDBColumn
            Caption = 'Bakiye'
            DataBinding.FieldName = 'BORC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 81
          end
          object GridListeViewKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
          object GridListeViewTAHSILAT: TcxGridDBColumn
            Caption = 'Plan Tahsilat'
            DataBinding.FieldName = 'TAHSILAT'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 74
          end
          object GridListeViewODEME: TcxGridDBColumn
            Caption = 'Plan '#214'deme'
            DataBinding.FieldName = 'ODEME'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Properties.ReadOnly = True
          end
          object GridListeViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 276
          end
        end
        object GridListeLevel1: TcxGridLevel
          GridView = GridListeView
        end
      end
      object SQLListe: TMemo
        Left = 103
        Top = 217
        Width = 647
        Height = 40
        Lines.Strings = (
          'select K.ID,K.TUR,PLANTARIHI,K.REHBERID,R.KOD,R.FIRMA,'
          
            'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
            'N REHBERAYAR RA (nolock) ON RA.YERI=1'
          
            'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
            'D RA.VARSAYILAN=40),'
          'TIPI = case when  TUR=61 then '#39'Tahsilat'#39' else '#39#214'deme'#39' end,'
          ''
          
            'BORC=(SELECT BORC-ALACAK from [dbo].[fn_CARIHESAPOZETI] (K.REHBE' +
            'RID,K.KUR,0)) ,'
          'TAHSILAT=(BORC), ODEME=(ALACAK), KUR, K.ACIKLAMA'
          'from KASA K inner join REHBER R on K.REHBERID=R.ID'
          
            'left outer join REHBERILETISIM RI on RI.REHBERID=R.ID and VARSAY' +
            'ILAN=1'
          'where')
        TabOrder = 2
        Visible = False
        WordWrap = False
      end
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1148
    Height = 30
    Margins.Bottom = 0
    ButtonHeight = 30
    ButtonWidth = 73
    Caption = 'AletCubugu'
    DockSite = True
    DrawingStyle = dsGradient
    EdgeInner = esNone
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    Images = Tablo.PNGImageList1
    List = True
    ParentFont = False
    ShowCaptions = True
    AllowTextButtons = True
    TabOrder = 0
    object AylikTus: TToolButton
      Tag = 3
      Left = 0
      Top = 0
      Caption = 'Ayl'#305'k'
      Grouped = True
      ImageIndex = 11
      ImageName = 'PngImage10'
      Style = tbsTextButton
      OnClick = AylikTusClick
    end
    object ToolButton7: TToolButton
      Tag = 2
      Left = 62
      Top = 0
      Caption = 'Haftal'#305'k'
      Grouped = True
      ImageIndex = 11
      ImageName = 'PngImage10'
      Style = tbsTextButton
      OnClick = AylikTusClick
    end
    object ToolButton8: TToolButton
      Left = 136
      Top = 0
      Caption = 'G'#252'nl'#252'k'
      Grouped = True
      ImageIndex = 11
      ImageName = 'PngImage10'
      Style = tbsTextButton
      OnClick = AylikTusClick
    end
    object ToolButton3: TToolButton
      Left = 208
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 216
      Top = 0
      Caption = 'Varl'#305'klar'
      ImageIndex = 22
      ImageName = 'PngImage22'
      Style = tbsTextButton
      OnClick = ToolButton2Click
    end
    object ToolButton1: TToolButton
      Left = 293
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 12
      ImageName = 'PngImage11'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 301
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
      Style = tbsTextButton
    end
  end
  object SchedulerDBStorage: TcxSchedulerDBStorage
    UseActualTimeRange = True
    Resources.Items = <>
    Resources.ResourceID = 'ResourceID'
    Resources.ResourceName = 'ResourceName'
    CustomFields = <
      item
        FieldName = 'SyncIDField'
      end
      item
        FieldName = 'Dosya'
      end
      item
        FieldName = 'ID2'
      end
      item
        FieldName = 'REHBERID'
      end
      item
        FieldName = 'TUR'
      end
      item
        FieldName = 'TUTAR'
      end
      item
        FieldName = 'KUR'
      end>
    DataSource = SchedulerDataSource
    FieldNames.ActualFinish = 'ActualFinish'
    FieldNames.ActualStart = 'ActualStart'
    FieldNames.Caption = 'Caption'
    FieldNames.EventType = 'Type'
    FieldNames.Finish = 'Finish'
    FieldNames.ID = 'ID'
    FieldNames.LabelColor = 'LabelColor'
    FieldNames.Location = 'Location'
    FieldNames.Message = 'Message'
    FieldNames.Options = 'Options'
    FieldNames.ParentID = 'ParentID'
    FieldNames.RecurrenceIndex = 'RecurrenceIndex'
    FieldNames.RecurrenceInfo = 'RecurrenceInfo'
    FieldNames.ReminderDate = 'ReminderDate'
    FieldNames.ReminderMinutesBeforeStart = 'ReminderMinutes'
    FieldNames.ResourceID = 'ResourceID'
    FieldNames.Start = 'Start'
    FieldNames.State = 'State'
    Left = 280
    Top = 120
  end
  object SchedulerDataSource: TDataSource
    DataSet = TabTakvim
    Left = 338
    Top = 73
  end
  object TabTakvim: TFDQuery
    Connection = Tablo.FDCnn
    Left = 437
    Top = 73
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OnPopup = PopupMenu1Popup
    Left = 623
    Top = 80
    object Gizle1: TMenuItem
      Caption = 'Gizle'
      ImageIndex = 14
      Visible = False
      OnClick = Gizle1Click
    end
    object BilgileriDegisMenu: TMenuItem
      Caption = 'bilgilerini g'#246'r / de'#287'i'#351'tir'
      ImageIndex = 22
      OnClick = BilgileriDegisMenuClick
    end
    object SilMenu: TMenuItem
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = SilMenuClick
    end
    object TahsilMenu: TMenuItem
      Caption = 'Tahsil Et'
      ImageIndex = 34
      object Nakit1: TMenuItem
        Tag = 21
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object HavaleEFT1: TMenuItem
        Tag = 22
        Caption = 'Havale/EFT'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object POS1: TMenuItem
        Tag = 23
        Caption = 'POS'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object ek1: TMenuItem
        Tag = 24
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object Senet1: TMenuItem
        Tag = 25
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
    end
    object OdemeMenu: TMenuItem
      Caption = #214'deme yap'
      ImageIndex = 34
      object NakitOdemeMenu: TMenuItem
        Tag = 31
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object HavaleEFTOdemeMenu: TMenuItem
        Tag = 32
        Caption = 'Havale/EFT'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object KrediKart1: TMenuItem
        Tag = 33
        Caption = 'Kredi Kart'#305
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object CekOdemeMenu: TMenuItem
        Tag = 34
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
      object SenetOdemeMenu: TMenuItem
        Tag = 35
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = NakitOdemeMenuClick
      end
    end
    object GenelMenu: TMenuItem
      Caption = 'Genel'
      ImageIndex = 15
      OnClick = NakitOdemeMenuClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Butariheplanekle1: TMenuItem
      Caption = 'Bu tarihe plan ekle'
      ImageIndex = 21
      object TahsilatPlanMenu: TMenuItem
        Tag = 61
        Caption = 'Tahsilat'
        ImageIndex = 34
        OnClick = OdemePlanMenuClick
      end
      object OdemePlanMenu: TMenuItem
        Tag = 71
        Caption = #214'deme'
        ImageIndex = 34
        OnClick = OdemePlanMenuClick
      end
    end
    object Butarihefaturaekle1: TMenuItem
      Caption = 'Bu tarihe fatura ekle'
      ImageIndex = 21
      Visible = False
      object GelenFaturaMenu: TMenuItem
        Caption = 'Gelen Fatura'
        ImageIndex = 19
      end
      object GidenFaturaMenu: TMenuItem
        Caption = 'Giden Fatura'
        ImageIndex = 19
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object BuguneaksiyonekleMenu: TMenuItem
      Caption = 'Bu tarihe aksiyon ekle'
      ImageIndex = 21
      OnClick = BuguneaksiyonekleMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object GunlukMenu: TMenuItem
      Caption = 'G'#252'nl'#252'k gelir-gider '#231'izelgesini a'#231
      ImageIndex = 34
      OnClick = GunlukMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object AksiyonMenu: TMenuItem
      Caption = 'G'#252'nl'#252'k aksiyon sayfas'#305'n'#305' a'#231
      ImageIndex = 19
      OnClick = AksiyonMenuClick
    end
  end
  object DtsToplam: TDataSource
    DataSet = TabToplam
    Left = 447
    Top = 212
  end
  object TabToplam: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select '
      
        ' YON=case when asda.TUR in(8,9,10,11,12,13,21,22,23,24,25,26,27,' +
        '28,29,51,52,59,61,62,63,91,95,121,122,301) then '#39'Giren'#39
      
        #9#9'when asda.TUR in(14,15,16,17,18,19,31,32,33,34,35,36,37,38,39,' +
        '53,54,57,58,71,72,73) then '#39#199#305'kan'#39' '
      #9#9'else '#39'Transfer'#39'  end,'
      ' SIRA=asda.TUR,'
      
        ' TUR=(select ANAHTAR from GENINI where BOLUM=-1005 and DIL= -1 a' +
        'nd DEGER=asda.TUR),'
      ' TUTAR=SUM(TUTAR),KUR  '
      'from '
      ''
      ' ##TAKVIM_SPID_  asda   '
      'where '
      'start between :Tar1 and :Tar2'
      'and '
      'TUTAR <>0'
      'group by TUR, KUR'
      'order by 1'
      ''
      ''
      ''
      '')
    Left = 507
    Top = 215
    ParamData = <
      item
        Name = 'Tar1'
        DataType = ftDateTime
        Precision = 23
        NumericScale = 3
        Size = 16
        Value = 40179d
      end
      item
        Name = 'Tar2'
        DataType = ftDateTime
        Precision = 23
        NumericScale = 3
        Size = 16
        Value = 40179d
      end>
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 243
    Top = 191
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
  object frxTAKVIM: TfrxDBDataset
    UserName = 'TAKVIM'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 369
    Top = 182
  end
  object TAKVIM: TFDQuery
    Connection = Tablo.FDCnn
    Left = 530
    Top = 72
  end
  object TabGrafik: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SET LANGUAGE Turkish'
      ''
      'Declare @BasTarih smalldatetime'
      'Declare @BitTarih smalldatetime'
      ''
      'set @BasTarih=:BasTar'
      'set @BitTarih=:BitTar'
      ''
      '--////////////////////////////'
      'IF EXISTS(SELECT * FROM sysobjects'
      'WHERE ID = (OBJECT_ID('#39'GRAFIKPLAN_SPID'#39')) AND xtype = '#39'U'#39')'
      'DROP TABLE GRAFIKPLAN_SPID'
      'CREATE TABLE GRAFIKPLAN_SPID'
      '(TARIH DATETIME,'
      'GUN nvarchar(2),'
      'AY nvarchar(15),'
      'YIL nvarchar(4),'
      'TUTAR Money,'
      'BAKIYE Money);'
      ''
      'WITH numbers AS'
      '('
      'SELECT 1 AS num'
      'UNION ALL'
      'SELECT num + 1 FROM numbers'
      'WHERE num <= (SELECT DATEDIFF(dd, @BasTarih, @BitTarih))'
      ')'
      'INSERT INTO GRAFIKPLAN_SPID (TARIH,GUN,AY,YIL,TUTAR)'
      'SELECT'
      'num+@BasTarih-1,'
      
        'CASE WHEN LEN(DAY(num+@BasTarih-1))=1 THEN '#39'0'#39'+CONVERT(VARCHAR(2' +
        '),DAY(num+@BasTarih-1)) ELSE CONVERT(VARCHAR(2),DAY(num+@BasTari' +
        'h-1)) END ,'
      'DATENAME(MONTH,num+@BasTarih-1),'
      
        '--CASE WHEN LEN(MONTH(num+@BasTarih-1))=1 THEN '#39'0'#39'+CONVERT(VARCH' +
        'AR(2),MONTH(num+@BasTarih-1)) ELSE CONVERT(VARCHAR(2),MONTH(num+' +
        '@BasTarih-1)) END ,'
      'YEAR(num+@BasTarih-1),0 FROM numbers'
      'OPTION (MAXRECURSION 0)'
      ''
      '--------////////////////-------------------------------'
      'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '
      #39'##PLANLAR_SPID_%'#39')'
      'DROP TABLE ##PLANLAR_SPID_'
      ''
      'CREATE TABLE ##PLANLAR_SPID_('
      #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
      #9'PLANTARIH [SmallDateTime]  NULL,'
      #9'TUTAR [money] NULL)'
      ''
      'INSERT INTO ##PLANLAR_SPID_ (PLANTARIH,TUTAR)'
      'Select TARIH,Tutar=Sum(Tutar) from ('
      ''
      'Select TARIH=PLANTARIHI,'
      
        'Tutar=(isnull(Sum(BORC),0)-isnull(Sum(ALACAK),0)),KUR from KASA ' +
        'Where TUR in (61,71) and PLANTARIHI >=@BasTarih  and PLANTARIHI ' +
        '<= @BitTarih'
      'Group by PLANTARIHI,KUR'
      ''
      'union All'
      ''
      'Select TARIH,Tutar=('
      
        '((Select isnull(SUM(CB.TUTAR),0) from CEKLER CB Where CB.TUR = 2' +
        '3 and isnull(CB.CIROLU,0)=0 and CB.TARIH=C.TARIH  )'
      '-'
      
        '(Select isnull(SUM(CA.TUTAR),0) from CEKLER CA Where CA.TUR=33 a' +
        'nd (isnull(CA.CIROLU,0)=1 and CA.TUR=23) and CA.TARIH=C.TARIH ))'
      ')'
      ',KUR from CEKLER C Where VADE >=@BasTarih  and VADE <= @BitTarih'
      'Group by TARIH,KUR'
      ''
      'union All'
      ''
      'Select TARIH,Tutar=('
      
        '((Select isnull(SUM(SB.TUTAR),0) from SENETLER SB Where SB.TUR =' +
        ' 24 and SB.TARIH=S.TARIH  )'
      '-'
      
        '(Select isnull(SUM(SA.TUTAR),0) from SENETLER SA Where SA.TUR=34' +
        '  and SA.TARIH=S.TARIH ))'
      ')'
      
        ',KUR from SENETLER S Where VADE >=@BasTarih  and VADE <= @BitTar' +
        'ih'
      'Group by TARIH,KUR'
      ''
      'Union all'
      
        'Select TARIH,Tutar=(-1*isnull(SUM(TUTAR),0)),KUR from PLANKREDIK' +
        'ARTI  Where SOT >=@BasTarih  and SOT <= @BitTarih'
      'Group by TARIH,KUR'
      'Union all'
      
        'Select TARIH=ALINISTARIHI,Tutar = isnull(SUM(BAKIYE),0),KUR from' +
        ' POS  Where ALINISTARIHI >=@BasTarih  and ALINISTARIHI <= @BitTa' +
        'rih'
      'Group by ALINISTARIHI,KUR'
      ') as s'
      'Group by TARIH'
      'Order by 1'
      ''
      ''
      '-----'
      'declare @KasaBakiye money, @Tutar money,@Tarih DateTime'
      
        'DECLARE PlanTable CURSOR FOR '#9'SELECT TARIH FROM GRAFIKPLAN_SPID ' +
        'ORDER BY TARIH ASC'
      'Set @KasaBakiye=0'
      'Set @Tutar=0'
      '--Toplam Bakiyeyi Yaz'
      #9#9'SELECT top 1'
      #9'    @KasaBakiye=(select sum(de) from ('
      ''
      #9#9'Select case When K.KUR='#39'TL'#39' then K.BAKIYE else'
      #9#9#9'K.BAKIYE*('
      #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
      #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
      #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
      #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=K.KUR'
      #9#9#9#9#9') '
      #9#9#9#9#9'end as de'
      ''
      #9#9'from KASALAR K WHERE K.GUNLUKAKSIYONDAGOSTER=1 ) as ff)'
      #9#9'FROM KASALAR K1 (NOLOCK)  '
      #9#9'WHERE GUNLUKAKSIYONDAGOSTER=1 '
      '  OPEN PlanTable'
      '  FETCH NEXT FROM PlanTable INTO @Tarih'
      #9'WHILE @@FETCH_STATUS=0'
      #9#9'BEGIN'
      #9#9'Set @Tutar=0'
      
        #9#9'select @Tutar=PS.TUTAR from ##PLANLAR_SPID_ PS  Where PS.PLANT' +
        'ARIH=@Tarih'
      ''
      #9#9'Update GRAFIKPLAN_SPID set '
      #9#9'BAKIYE=@KasaBakiye+@Tutar,'
      #9#9'TUTAR=@Tutar Where TARIH=@Tarih'
      ''
      #9'    set @KasaBakiye=@KasaBakiye+@Tutar'#9
      #9#9'FETCH NEXT FROM PlanTable INTO @Tarih'
      #9#9'END'
      ''
      '  CLOSE PlanTable'
      '  DEALLOCATE PlanTable'
      ''
      '  '#9#9'--Update GRAFIKPLAN_SPID set '#9'BAKIYE=0,TUTAR=0 '
      #9#9
      'select * from GRAFIKPLAN_SPID'
      'SET LANGUAGE us_english'
      ''
      '----////////////////////////'
      '--select * from ##PLANLAR_SPID_ PS ')
    Left = 242
    Top = 248
    ParamData = <
      item
        Name = 'BasTar'
        Size = -1
        Value = Null
      end
      item
        Name = 'BitTar'
        Size = -1
        Value = Null
      end>
  end
  object DsTabGrafik: TDataSource
    DataSet = TabGrafik
    Left = 312
    Top = 240
  end
  object TabPivot: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from [dbo].[fn_NakitAkisiPivot](:PSonTarih)')
    Left = 608
    Top = 157
    ParamData = <
      item
        Name = 'PSonTarih'
        DataType = ftDateTime
        Size = -1
        Value = Null
      end>
    object TabPivotGRUP: TWideStringField
      FieldName = 'GRUP'
      ReadOnly = True
      Size = 6
    end
    object TabPivotTUR: TWideStringField
      FieldName = 'TUR'
      ReadOnly = True
      Size = 221
    end
    object TabPivotTARIH: TSQLTimeStampField
      FieldName = 'TARIH'
      ReadOnly = True
    end
    object TabPivotTUTAR: TFloatField
      FieldName = 'TUTAR'
      ReadOnly = True
    end
  end
  object DtsPivot: TDataSource
    DataSet = TabPivot
    Left = 683
    Top = 156
  end
  object pmPivot: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 176
    Top = 160
    object ExcelPivot1: TMenuItem
      Caption = 'Excel Pivot...'
      ImageIndex = 32
      OnClick = ExcelPivot1Click
    end
  end
  object DtsListe: TDataSource
    DataSet = LISTE
    Left = 217
    Top = 379
  end
  object LISTE: TFDQuery
    Connection = Tablo.FDCnn
    Left = 116
    Top = 378
  end
  object PopupMenuListe: TPopupMenu
    Images = Tablo.PNGImageList1
    Left = 64
    Top = 200
    object MenuListeDuzenle: TMenuItem
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      OnClick = MenuListeDuzenleClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object MenuListeSil: TMenuItem
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = MenuListeSilClick
    end
  end
end
