object TakvimProje: TTakvimProje
  Left = 0
  Top = 0
  Width = 1008
  Height = 553
  HorzScrollBar.Increment = 4
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
  ExplicitWidth = 451
  ExplicitHeight = 304
  object Scheduler: TcxScheduler
    Left = 0
    Top = 33
    Width = 1008
    Height = 520
    DateNavigator.ColCount = 2
    DateNavigator.RowCount = 2
    ViewDay.TimeRulerMinutes = True
    ViewGantt.Scales.MajorUnit = suYear
    ViewWeeks.Active = True
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
    ExplicitWidth = 451
    ExplicitHeight = 271
    Selection = 245
    Splitters = {
      D1020000FB000000EF03000000010000CC02000001000000D102000007020000}
    StoredClientBounds = {0100000001000000EF03000007020000}
    object pnlControls: TPanel
      Left = 0
      Top = 0
      Width = 286
      Height = 263
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 0
      ExplicitHeight = 14
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 286
        Height = 263
        Align = alClient
        BorderStyle = bsNone
        Lines.Strings = (
          'Your '
          'controls can '
          'be placed '
          'here')
        TabOrder = 0
        ExplicitHeight = 14
      end
      object GridToplam: TcxGrid
        Left = 0
        Top = 0
        Width = 286
        Height = 263
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        ExplicitHeight = 14
        object ToplamView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
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
            Visible = False
            GroupIndex = 0
            IsCaptionAssigned = True
          end
          object ToplamViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            Width = 80
          end
          object ToplamViewTUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 75
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = ToplamView
        end
      end
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1002
    Height = 30
    Margins.Bottom = 0
    ButtonHeight = 24
    ButtonWidth = 66
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
    Images = Tablo.imgScheduler
    List = True
    ParentFont = False
    ShowCaptions = True
    AllowTextButtons = True
    TabOrder = 1
    ExplicitWidth = 445
    object ToolButton8: TToolButton
      Left = 0
      Top = 0
      Caption = 'G'#252'nl'#252'k'
      ImageIndex = 0
      Style = tbsTextButton
      OnClick = AylikTusClick
    end
    object ToolButton7: TToolButton
      Tag = 2
      Left = 64
      Top = 0
      Caption = 'Haftal'#305'k'
      ImageIndex = 2
      Style = tbsTextButton
      OnClick = AylikTusClick
    end
    object AylikTus: TToolButton
      Tag = 3
      Left = 134
      Top = 0
      Caption = 'Ayl'#305'k'
      ImageIndex = 3
      Style = tbsTextButton
      OnClick = AylikTusClick
    end
    object YillikTus: TToolButton
      Tag = 5
      Left = 188
      Top = 0
      Caption = 'Y'#305'll'#305'k'
      ImageIndex = 35
      Style = tbsTextButton
      OnClick = AylikTusClick
    end
    object CheckSorumluGrupla: TcxCheckBox
      Left = 244
      Top = 2
      Caption = 'Sorumlulara G'#246're Grupla  /  Takvim Say'#305's'#305
      Properties.ImmediatePost = True
      Properties.NullStyle = nssUnchecked
      Properties.OnEditValueChanged = CheckSorumluGruplaPropertiesEditValueChanged
      TabOrder = 0
      Transparent = True
      Width = 303
    end
    object edTakvimSayisi: TSpinEdit
      Left = 547
      Top = 0
      Width = 43
      Height = 26
      MaxValue = 20
      MinValue = 1
      TabOrder = 1
      Value = 1
      Visible = False
      OnChange = edTakvimSayisiChange
    end
  end
  object MemoPlanSQL: TMemo
    Left = 173
    Top = 150
    Width = 473
    Height = 120
    Lines.Strings = (
      'declare @KULID int'
      'declare @SUBEID int'
      'set @KULID=:prmkul'
      'set @SUBEID=:PrmSube'
      ''
      
        'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'##P' +
        'ROJE_SPID_%'#39')'
      'DROP TABLE ##Proje_SPID_'
      ''
      ''
      'CREATE TABLE ##Proje_SPID_('
      #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
      #9'[type] [smallint] NULL,'
      #9'[start] [datetime]  NULL,'
      #9'[finish] [datetime]  NULL,'
      #9'[options] [smallint] NULL,'
      #9'[caption] [nvarchar](400) NULL,'
      #9'[location] [nvarchar](10) NULL,'
      #9'[message] [nvarchar](10) NULL,'
      #9'[state] [smallint] NULL,'
      #9'[labelColor] [bigint] NULL,'
      '                [ResourceID] [int] NULL, '
      '    [DOSYA] [nvarchar](20) NULL,'
      '    [AKT_ID] [int] NULL,'
      '    [REH_ID] [int] NULL,'
      #9'[TUR] [smallint] NULL,'
      '                [TIPI] [smallint] NULL'
      ')'
      ''
      'INSERT INTO ##Proje_SPID_'
      ''
      ''
      '')
    TabOrder = 2
    Visible = False
  end
  object MemoBaslangic: TMemo
    Left = 208
    Top = 185
    Width = 589
    Height = 156
    Lines.Strings = (
      ''
      'select   '
      #9'type = 0, '
      #9'start = convert(varchar(20), BASLAMATARIHI, 120),'
      #9'finish = convert(varchar(20), BASLAMATARIHI+1, 120),  '
      '                options=3, '
      
        #9'caption = isnull(ProjeTur.ANAHTAR,'#39#39') +'#39' * '#39'+'#9'ISNULL(PROJEKODU,' +
        #39#39') +'#39' * '#39'+ISNULL(R1.FIRMA,'#39#39'),'
      #9'location='#39#39','
      #9'message='#39#39', '
      #9'state=0,   '
      #9'labelColor = 6610596,'
      #9'ResourceID = P.PRJ_SORUMLUSU_ID,'
      #9'Dosya='#39'PROJELER'#39', '
      #9'AKT_ID=P.ID,'
      #9'REH_ID=P.REHBERID,'
      #9'TUR=P.TURU,'
      '                TIPI=P.TIPI'
      'from PROJELER P '
      #9'inner join REHBER R1 on R1.ID = P.REHBERID'
      #9'inner join REHBER R2 on R2.ID = P.PRJ_SORUMLUSU_ID'
      #9'left outer join REHBER RP on RP.ID=P.ILGILI  LEFT OUTER JOIN '
      
        #9'GENINI ProjeTur on ProjeTur.DEGER = P.TURU and ProjeTur.BOLUM =' +
        '-2112 LEFT OUTER JOIN '
      
        #9'GENINI ProjeTipi ON ProjeTipi.DEGER = P.TIPI AND convert(int,'#39'-' +
        '2112'#39'+convert(varchar(5),ProjeTur.DEGER))=ProjeTipi.BOLUM '
      'where '
      '1=case '
      #9'when @KULID = P.EKLEYEN then 1 '
      #9'when @KULID = P.PRJ_SORUMLUSU_ID then 1 '
      #9'--Tam yetkili ise'
      
        #9'when 1=(select TY from KULLANICI K inner join ROLLER R on R.ID=' +
        'K.ROLID where K.REHBERID=@KULID) then 1'
      #9'--Herkesin projesini g'#246'rme yetkisi'
      
        #9'when 100=(select Y.BILGI from KULLANICI K inner join YETKIEK Y ' +
        'on K.ROLID=Y.ROLID where K.REHBERID=@KULID and MODULID=2112) the' +
        'n 1'
      #9'--Kendi '#351'ube projesini g'#246'rme yetkisi'
      
        #9'when 10=(select Y.BILGI from KULLANICI K inner join YETKIEK Y o' +
        'n K.ROLID=Y.ROLID where K.REHBERID=@KULID and MODULID=2112)and P' +
        '.SUBEID=@SUBEID then 1'
      #9'--Kendi departman projesini g'#246'rme yetkisi'
      
        #9'when 5=(select Y.BILGI from KULLANICI K inner join YETKIEK Y on' +
        ' K.ROLID=Y.ROLID where K.REHBERID=@KULID and MODULID=2112)'
      
        #9'        and (select ROL.DEPARTMAN from REHBER R left outer join' +
        ' ROLLER ROL on R.SINIF=ROL.ID where R.ID=@KULID)in'
      
        #9#9#9'    (select ROL.DEPARTMAN from REHBER R left outer join ROLLE' +
        'R ROL on R.SINIF=ROL.ID where R.ID=P.PRJ_SORUMLUSU_ID)  then 1'
      #9'--Proje a'#351'amas'#305' kendine gelmi'#351' ise'
      
        #9'when @KULID in (select REHBERID from PROJEASAMA PA where PA.PRO' +
        'JEID=P.ID and PA.AKTIF=1)then 1 '
      
        #9'when @KULID in (select REHBERID from PROJEASAMA PA where PA.PRO' +
        'JEID=P.ID and PA.ASAMA=P.ASAMA)then 1 '
      #9'else 0 end '
      ''
      ''
      ' ')
    TabOrder = 3
    Visible = False
    WordWrap = False
  end
  object MemoBitis: TMemo
    Left = 256
    Top = 219
    Width = 562
    Height = 149
    Lines.Strings = (
      'union all'
      'select   '
      #9'type = 0, '
      #9'start = convert(varchar(20), BITISTARIHI, 120),'
      #9'finish = convert(varchar(20), BITISTARIHI+1, 120),  '
      '    options=3, '
      
        #9'caption = isnull(ProjeTur.ANAHTAR,'#39#39') +'#39' * '#39'+'#9'ISNULL(PROJEKODU,' +
        #39#39') +'#39' * '#39'+isnull(R1.FIRMA,'#39#39'),'
      #9'location='#39#39','
      #9'message='#39#39', '
      #9'state=0,   '
      #9'labelColor = 8689404,'
      '    ResourceID = P.PRJ_SORUMLUSU_ID,'#9
      #9'Dosya='#39'PROJELER'#39', '
      #9'AKT_ID=P.ID,'
      #9'REH_ID=P.REHBERID,'
      #9'TUR=P.TURU,'
      '                TIPI=P.TIPI'
      'from PROJELER P '
      '                inner join REHBER R1 on R1.ID = P.REHBERID'
      
        '                inner join REHBER R2 on R2.ID = P.PRJ_SORUMLUSU_' +
        'ID '
      
        '                Left outer join REHBER RP on RP.ID=P.ILGILI  LEF' +
        'T OUTER JOIN '
      
        #9'GENINI ProjeTur on ProjeTur.DEGER = P.TURU and ProjeTur.BOLUM =' +
        '-2112 LEFT OUTER JOIN '
      
        #9'GENINI ProjeTipi ON ProjeTipi.DEGER = P.TIPI AND convert(int,'#39'-' +
        '2112'#39'+convert(varchar(5),ProjeTur.DEGER))=ProjeTipi.BOLUM '
      'where '
      '1=case '
      #9'when @KULID = P.EKLEYEN then 1 '
      #9'when @KULID = P.PRJ_SORUMLUSU_ID then 1 '
      #9'--Tam yetkili ise'
      
        #9'when 1=(select TY from KULLANICI K inner join ROLLER R on R.ID=' +
        'K.ROLID where K.REHBERID=@KULID) then 1'
      #9'--Herkesin projesini g'#246'rme yetkisi'
      
        #9'when 100=(select Y.BILGI from KULLANICI K inner join YETKIEK Y ' +
        'on K.ROLID=Y.ROLID where K.REHBERID=@KULID and MODULID=2112) the' +
        'n 1'
      #9'--Kendi '#351'ube projesini g'#246'rme yetkisi'
      
        #9'when 10=(select Y.BILGI from KULLANICI K inner join YETKIEK Y o' +
        'n K.ROLID=Y.ROLID where K.REHBERID=@KULID and MODULID=2112)and P' +
        '.SUBEID=@SUBEID then 1'
      #9'--Kendi departman projesini g'#246'rme yetkisi'
      
        #9'when 5=(select Y.BILGI from KULLANICI K inner join YETKIEK Y on' +
        ' K.ROLID=Y.ROLID where K.REHBERID=@KULID and MODULID=2112)'
      
        #9'        and (select ROL.DEPARTMAN from REHBER R left outer join' +
        ' ROLLER ROL on R.SINIF=ROL.ID where R.ID=@KULID)in'
      
        #9#9#9'    (select ROL.DEPARTMAN from REHBER R left outer join ROLLE' +
        'R ROL on R.SINIF=ROL.ID where R.ID=P.PRJ_SORUMLUSU_ID)  then 1'
      #9'--Proje a'#351'amas'#305' kendine gelmi'#351' ise'
      
        #9'when @KULID in (select REHBERID from PROJEASAMA PA where PA.PRO' +
        'JEID=P.ID and PA.AKTIF=1)then 1 '
      
        #9'when @KULID in (select REHBERID from PROJEASAMA PA where PA.PRO' +
        'JEID=P.ID and PA.ASAMA=P.ASAMA)then 1 '
      #9'else 0 end '
      ''
      '')
    TabOrder = 4
    Visible = False
    WordWrap = False
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
        FieldName = 'AKT_ID'
      end
      item
        FieldName = 'REH_ID'
      end
      item
        FieldName = 'TUR'
      end>
    DataSource = SchedulerDataSource
    FieldNames.ActualFinish = 'Finish'
    FieldNames.ActualStart = 'Start'
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
    Left = 200
    Top = 80
  end
  object SchedulerDataSource: TDataSource
    DataSet = AraQuery1
    Left = 322
    Top = 81
  end
  object AraQuery1: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      '')
    Left = 427
    Top = 86
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    Left = 104
    Top = 128
    object BilgileriDegisMenu: TMenuItem
      Caption = 'bilgilerini g'#246'r / de'#287'i'#351'tir'
      ImageIndex = 22
      OnClick = BilgileriDegisMenuClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object ButariheProjeekle: TMenuItem
      Caption = 'Bu tarihe Proje ekle'
      ImageIndex = 21
      OnClick = ButariheProjeekleClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ProjeyiSil1: TMenuItem
      Caption = 'Projeyi Sil'
      ImageIndex = 1
      OnClick = ProjeyiSil1Click
    end
  end
  object Query1: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 484
    Top = 90
  end
  object DtsToplam: TDataSource
    DataSet = TabToplam
    Left = 760
    Top = 224
  end
  object TabToplam: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'Tar1'
        DataType = ftWideString
        Size = 10
        Value = '2010-01-01'
      end
      item
        Name = 'Tar2'
        DataType = ftWideString
        Size = 10
        Value = '2010-01-01'
      end>
    SQL.Strings = (
      ''
      'select '
      ' YON=case '
      #9'when TUR in (23,24,61,62) then '#39'Tahsilat'#39' '
      #9'when TUR in (33,34,35,71,72,73,111) then '#39#214'deme'#39' '
      ' end, '
      ' SIRA=case '
      #9'when TUR in (61,71) then 1 '
      #9'when TUR in (23,24,33,34) then 3'
      #9'when TUR=35 then 5 '
      #9'when TUR=72 then 7 '
      #9'when TUR=73 then 9 '
      #9'when TUR=111 then 11 '
      #9
      ' end,  '
      ' TUR=case '
      #9'when TUR in (61, 71) then '#39'A'#231#305'k Hesap'#39' '
      #9'when TUR = 35 then '#39'Kredi Kart'#305#39' '
      #9'when TUR = 72 then '#39'D'#252'zenli '#214'deme'#39' '
      #9'when TUR in (23,24,33,34) then '#39#199'ek Senet'#39' '
      #9'when TUR = 73 then '#39'Personel'#39' '
      #9'when TUR = 111 then '#39'Kredi'#39' '
      ' end, '
      ' TUTAR=SUM(TUTAR) '
      'from #TAKVIM_SPID_ '
      'where '
      'start between :Tar1 and :Tar2'
      'and '
      'TUTAR >0'
      'group by TUR'
      'order by 1 desc, 2'
      ''
      '')
    Left = 816
    Top = 226
  end
  object dtsTakvimKaynaklari: TDataSource
    DataSet = tabTakvimKaynaklari
    Left = 117
    Top = 276
  end
  object tabTakvimKaynaklari: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select TOP 1 ID, FIRMA AS PERSONEL FROM REHBER')
    Left = 107
    Top = 216
  end
end

