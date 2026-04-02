object AnaGirisSayfasiFrame: TAnaGirisSayfasiFrame
  Left = 0
  Top = 0
  Width = 1184
  Height = 604
  Align = alClient
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object anaPanel: TPanel
    Left = 0
    Top = 0
    Width = 1184
    Height = 604
    Align = alClient
    TabOrder = 0
    object PanelOrta: TPanel
      Left = 231
      Top = 1
      Width = 952
      Height = 602
      Align = alClient
      Color = clGray
      ParentBackground = False
      TabOrder = 1
      object PageControlOrta: TcxPageControl
        Left = 1
        Top = 1
        Width = 950
        Height = 600
        Align = alClient
        Color = clCream
        ParentBackground = False
        ParentColor = False
        TabOrder = 0
        Properties.ActivePage = SheetNakitAkisi
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 596
        ClientRectLeft = 4
        ClientRectRight = 946
        ClientRectTop = 27
        object SheetGiris: TcxTabSheet
          Caption = 'SheetGiris'
          ImageIndex = 13
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object pnlGenel: TJvPanel
            Left = 0
            Top = 0
            Width = 942
            Height = 569
            Align = alClient
            BevelOuter = bvNone
            Color = 16753828
            ParentBackground = False
            TabOrder = 0
            object Label5: TLabel
              Left = 42
              Top = 33
              Width = 120
              Height = 29
              Caption = 'GENTEGRE'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -24
              Font.Name = 'Trebuchet MS'
              Font.Style = [fsBold]
              ParentFont = False
              Transparent = True
            end
            object Label6: TLabel
              Left = 42
              Top = 74
              Width = 462
              Height = 22
              Caption = 
                'Sol taraftaki gezinme panelini kullanarak i'#351'lemleri ger'#231'ekle'#351'tir' +
                'in.'
              Font.Charset = TURKISH_CHARSET
              Font.Color = 16744448
              Font.Height = -16
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object Shape1: TShape
              Left = 42
              Top = 66
              Width = 379
              Height = 1
            end
          end
        end
        object SheetArama: TcxTabSheet
          Caption = 'SheetArama'
          ImageIndex = 0
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object pnlHaberler: TPanel
            Left = 0
            Top = 0
            Width = 942
            Height = 569
            Align = alClient
            Color = clGradientInactiveCaption
            ParentBackground = False
            TabOrder = 0
            object Panel8: TPanel
              Left = 1
              Top = 1
              Width = 940
              Height = 24
              Align = alTop
              Color = clSkyBlue
              ParentBackground = False
              TabOrder = 0
              object Label8: TLabel
                Left = 6
                Top = 1
                Width = 21
                Height = 18
                Caption = 'Ara'
                Font.Charset = TURKISH_CHARSET
                Font.Color = clNavy
                Font.Height = -13
                Font.Name = 'Trebuchet MS'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object EditAra: TcxTextEdit
                Left = 71
                Top = 1
                TabOrder = 0
                OnKeyUp = EditAraKeyUp
                Width = 193
              end
              object AraTus: TcxButton
                Left = 265
                Top = 1
                Width = 29
                Height = 23
                OptionsImage.Glyph.SourceDPI = 96
                OptionsImage.Glyph.Data = {
                  424D760600000000000036000000280000001400000014000000010020000000
                  000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00F4F4F4FFE4DFE0FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00E1E1E1FF687180FF817BA0FFD4BBC2FFFFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D8E5
                  EDFF48A2F0FF4C75C1FF857EA4FFD8BDC1FFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00F4FAFFFF74C7FFFF45A5FAFF4C75C1FF857E
                  A4FFD8BDC1FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00F4FAFFFF74C7FFFF45A5FAFF4C75C1FF857EA4FFD8BDC1FFFFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F4FAFFFF74C7FFFF45A5
                  FAFF4C75C1FF8780A4FFF2E2DFFFEDD2C8FFDEB5A7FFDEAF9DFFE1B8A9FFEDD2
                  C8FFF8EDE8FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00F4FAFFFF74C7FFFF4FA9F8FFA09497FFD8B0A2FFD8AE
                  9BFFE0BD9FFFEDDDBDFFEDDBBEFFDBB6A7FFDDB3A6FFF3E2DCFFFFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F4FA
                  FFFFD8DCE2FFD2AA9CFFE4B599FFFFF0C0FFFFFFD1FFFFFFD8FFFFFFE0FFFFFF
                  EEFFECDDD0FFDCB3A4FFF8EDE8FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EBCFC5FFDDAD9BFFFFF3C6FFFFE8
                  B6FFF2E6B7FFC5742DFFFFFFF8FFFFFFFEFFFFFFFDFFD9B7A2FFE7CABFFFFFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00E1B7A8FFF1D3B2FFFFECB9FFF2CD9BFFF1D09EFFC5742DFFEADCCDFFEADC
                  CDFFFFFFE7FFF4E8C4FFDBB0A1FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DEAE9DFFFEF1BFFFFFE1AEFFCC67
                  01FFC5742DFFC5742DFFC5742DFFC5742DFFFFFFDAFFFEFDD1FFDDAD9BFFFFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00DFB4A6FFF6E4B9FFFFEBBEFFF4D191FFF4D191FFC5742DFFF4DDA9FFFAEE
                  BFFFFFFFCEFFF9E7BEFFDAAB9AFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E8C9C0FFE4C1A7FFFFFDE5FFFFEE
                  D8FFF4D191FFC5742DFFFFF9C7FFFFF2C0FFFFF8C6FFE2BBA0FFDFBDB3FFFFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00F8EDE8FFD9AB9AFFF6EADEFFFFFFFF00FFEBC9FFFFE8B8FFFFE2AFFFFFF1
                  BEFFFADAACFFD9AB9BFFF8EDE8FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F1DED7FFDAAE9FFFEACE
                  BBFFF9E9C5FFFEF0BEFFF9E5B8FFEBC4A3FFDCAE9DFFF0DDD6FFFFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00F8EDE8FFDEBBB1FFDAAB9AFFDDAD9BFFDAAE9EFFE0BB
                  B1FFF4E7E2FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                SpeedButtonOptions.Flat = True
                TabOrder = 1
                OnClick = AraTusClick
              end
            end
            object cxGrid1: TcxGrid
              Left = 1
              Top = 25
              Width = 940
              Height = 543
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object GridAraView: TcxGridDBTableView
                OnDblClick = GridAraViewDblClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsArama
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsView.GroupByBox = False
                OptionsView.Header = False
                object GridAraViewID: TcxGridDBColumn
                  Caption = 'S'#305'ra'
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Width = 28
                end
                object GridAraViewModul: TcxGridDBColumn
                  DataBinding.FieldName = 'Modul'
                  DataBinding.IsNullValueType = True
                  Visible = False
                  GroupIndex = 0
                  Width = 77
                end
                object GridAraViewArananId: TcxGridDBColumn
                  DataBinding.FieldName = 'ArananId'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridAraViewKod: TcxGridDBColumn
                  DataBinding.FieldName = 'Kod'
                  DataBinding.IsNullValueType = True
                  Visible = False
                  Width = 68
                end
                object GridAraViewAd: TcxGridDBColumn
                  DataBinding.FieldName = 'Ad'
                  DataBinding.IsNullValueType = True
                  Width = 250
                end
                object GridAraViewAranan: TcxGridDBColumn
                  DataBinding.FieldName = 'Aranan'
                  DataBinding.IsNullValueType = True
                  Width = 250
                end
              end
              object GridAra: TcxGridLevel
                GridView = GridAraView
              end
            end
            object SQLMemoAra: TcxMemo
              Left = 24
              Top = 79
              Lines.Strings = (
                'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name '
                'LIKE '
                #39'##ARAMA_SPID_%'#39')'
                'DROP TABLE ##ARAMA_SPID_'
                ''
                'CREATE TABLE ##ARAMA_SPID_('
                #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
                #9'[Modul] [nvarchar](20) NULL,'
                '                [SQLID] [int]  NULL,'
                #9'[ArananId] [int]  NULL,'
                #9'[Kod] [nvarchar](20)  NULL,'
                #9'[Ad] [nvarchar](100) NULL,'
                #9'[Aranan] [nvarchar](600) NULL)')
              TabOrder = 2
              Visible = False
              Height = 46
              Width = 331
            end
          end
        end
        object SheetDuyurular: TcxTabSheet
          Caption = 'SheetDuyurular'
          ImageIndex = 10
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 942
            Height = 30
            Align = alTop
            Color = clSkyBlue
            ParentBackground = False
            TabOrder = 0
            object Label2: TLabel
              Left = 88
              Top = 6
              Width = 21
              Height = 18
              Caption = 'Ara'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clNavy
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object EditDuyuruArama: TcxTextEdit
              Left = 115
              Top = 4
              TabOrder = 0
              OnKeyUp = EditDuyuruAramaKeyUp
              Width = 193
            end
            object DuyuruYenileTus: TcxButton
              Left = 7
              Top = 4
              Width = 59
              Height = 23
              OptionsImage.ImageIndex = 8
              OptionsImage.Images = Tablo.imgScheduler
              SpeedButtonOptions.Flat = True
              TabOrder = 1
              OnClick = DuyuruYenileTusClick
            end
          end
          object GridDuyuru: TcxGrid
            Left = 0
            Top = 30
            Width = 942
            Height = 539
            Align = alClient
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            object GridDuyuruDBCardView: TcxGridDBCardView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCellClick = GridDuyuruDBCardViewCellClick
              OnCustomDrawCell = GridDuyuruDBCardViewCustomDrawCell
              DataController.DataSource = DtsDuyuruListe
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              LayoutDirection = ldVertical
              OptionsView.CaptionSeparator = #0
              OptionsView.CardIndent = 7
              Styles.Content = Tablo.cxStyleDuyPasif
              Styles.OnGetContentStyle = GridDuyuruDBCardViewStylesGetContentStyle
              object GridDuyuruDBCardViewDUYURUAD: TcxGridDBCardViewRow
                DataBinding.FieldName = 'DUYURUAD'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Options.Editing = False
                Options.ShowCaption = False
                Position.BeginsLayer = True
                Position.Width = 15
              end
              object GridDuyuruDBCardViewID: TcxGridDBCardViewRow
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
                Position.BeginsLayer = False
              end
              object GridDuyuruDBCardViewRED: TcxGridDBCardViewRow
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Caption = 'X'
                    Default = True
                    ImageIndex = 24
                    Kind = bkGlyph
                  end>
                Properties.Images = Tablo.PNGImageList2
                Properties.OnButtonClick = GridDuyuruDBCardViewRow7PropertiesButtonClick
                CaptionAlignmentHorz = taRightJustify
                Options.ShowCaption = False
                Options.ShowEditButtons = isebAlways
                Position.BeginsLayer = False
                Position.Width = 3
                IsCaptionAssigned = True
              end
              object GridDuyuruDBCardViewKONU: TcxGridDBCardViewRow
                DataBinding.FieldName = 'KONU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.Alignment.Horz = taCenter
                Options.Editing = False
                Options.ShowCaption = False
                Options.ShowEditButtons = isebAlways
                Position.BeginsLayer = True
                IsCaptionAssigned = True
              end
              object GridDuyuruDBCardViewKATEGORI: TcxGridDBCardViewRow
                DataBinding.FieldName = 'KATEGORI'
                DataBinding.IsNullValueType = True
                Visible = False
                Position.BeginsLayer = False
                IsCaptionAssigned = True
              end
              object GridDuyuruDBCardViewZAMAN: TcxGridDBCardViewRow
                DataBinding.FieldName = 'ZAMAN'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Options.Editing = False
                Options.ShowCaption = False
                Position.BeginsLayer = True
                Position.Width = 15
              end
              object GridDuyuruDBCardViewONAY: TcxGridDBCardViewRow
                Tag = 9
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Caption = 'i'
                    Default = True
                    ImageIndex = 23
                    Kind = bkGlyph
                  end>
                Properties.Images = Tablo.PNGImageList2
                Properties.OnButtonClick = GridDuyuruDBCardViewONAYPropertiesButtonClick
                Options.ShowCaption = False
                Options.ShowEditButtons = isebAlways
                Position.BeginsLayer = False
                Position.Width = 3
                Styles.Content = Tablo.cxStyle11
              end
              object GridDuyuruDBCardViewGUN: TcxGridDBCardViewRow
                DataBinding.FieldName = 'GUN'
                DataBinding.IsNullValueType = True
                Visible = False
                Position.BeginsLayer = True
              end
              object GridDuyuruDBCardViewYER: TcxGridDBCardViewRow
                DataBinding.FieldName = 'YER'
                DataBinding.IsNullValueType = True
                Visible = False
                Position.BeginsLayer = True
              end
            end
            object GridDuyuruLevel1: TcxGridLevel
              GridView = GridDuyuruDBCardView
            end
          end
          object duyuruMemo: TcxMemo
            Left = 24
            Top = 290
            Lines.Strings = (
              'declare @Bugun datetime'
              'declare @RehberId Int, @GunSay Int'
              'declare @Konu varchar(50)'
              ''
              
                'set @Bugun=convert(datetime,convert(varchar(10), getdate(), 120)' +
                ')'
              'set @RehberId=:Kul'
              'set @Konu=:KONU'
              'set @GunSay=-1 * :Gun'
              ''
              'select distinct ID,TUR,KATEGORI,DUYURUAD,KONU,OLAYZAMANI, '
              'ZAMAN=(select case '
              
                'when convert(float,OLAYZAMANI-@Bugun)<-1 then   cast(abs(convert' +
                '(int,OLAYZAMANI-@Bugun)) as varchar'
              '(8))+'#39' g'#252'n '#246'nce'#39
              'when convert(float,OLAYZAMANI-@Bugun)=-1 then '#39'D'#252'n'#39
              
                'when convert(float,OLAYZAMANI-@Bugun) between 0.0 and 0.9999  th' +
                'en '#39'Bug'#252'n'#39
              'when convert(float,OLAYZAMANI-@Bugun)=1 then '#39'Yar'#305'n'#39
              
                'when convert(float,OLAYZAMANI-@Bugun)>1 then cast(convert(int,OL' +
                'AYZAMANI-@Bugun) as varchar(8))+'#39' '
              'g'#252'n sonra'#39
              'else'
              #39#39
              'end) ,'
              
                'GUN=  convert(smallint,OLAYZAMANI-@Bugun),REHBERID,EKLEYEN, YER=' +
                'isnull(YER,0), YER_ID=isnull'
              '(YER_ID,0)'
              '--Data kayna'#287#305' buras'#305
              'from ( '
              
                'select   D.ID,D.TUR,KATEGORI,DUYURUAD=U.ACIKLAMA,D.KONU,OLAYZAMA' +
                'NI, '
              'REHBERID=null,D.EKLEYEN, D.YER, D.YER_ID '
              'from DUYURU D '
              #9' left join UYARIAYAR U on D.SABLONID=U.SABLONDUYURUID'
              
                #9' left join DUYURUKULLANICI DK on DK.TUR=0 and D.TUR=2  and DK.D' +
                'UYURUID=D.ID'
              ''
              'where'
              'OKUNMATARIHI is null'
              'and DK.ALICIID= @RehberId '
              '--and (D.KONU like @Konu or U.ACIKLAMA like @Konu)'
              '--and D.GECERLILIKTARIHI < getdate()  '
              '--and OLAYZAMANI-@Bugun>-10'
              ''
              ''
              ''
              'UNION ALL'
              ''
              
                'select   ID,TUR=-1,KATEGORI=LISTEID,DUYURUAD='#39'G'#246'rev'#39',KONU=KONUSU' +
                ',OLAYZAMANI=BITISTARIHI, '
              'REHBERID,EKLEYEN, YER=33, YER_ID=ID'
              'FROM [dbo].[fn_prg_IsListesiBanaAtananlar] (@RehberId,0,9999)'
              ''
              '--UNION ALL'
              ''
              '--select   ID,TUR=-10,KATEGORI=T.ID,DUYURUAD='#39'Teklif Onay'#39','
              '--KONU=(SELECT FIRMA FROM REHBER R WHERE R.ID=T.REHBERID),'
              '--OLAYZAMANI=DURUMTARIHI, '
              '--REHBERID,EKLEYEN'
              '--FROM TEKLIF T'
              '--WHERE isnull(T.ONAYLAYAN,0)=0'
              '--and T.ONAYLAYACAK=@RehberId'
              ''
              '--UNION ALL'
              ''
              '--select ID,TUR=-10,KATEGORI=T.ID,DUYURUAD='#39'Teklif SKT'#39','
              '--'#9'Konu='#39'Bu teklifin ge'#231'erlili'#287'i '#39'+ '
              
                '--'#9'Convert(varchar(10),ABS(case when ISNULL(T.GECERLILIK_SURESI,' +
                '0)=0 then 0 else DATEDIFF'
              '--(day,GETDATE(),T.TARIH+GECERLILIK_SURESI) end))+'
              '--'#9#39' g'#252'n '#246'nce sona erdi. Durumunu de'#287'i'#351'tirin!'#39','
              '--'#9'OLAYZAMANI=T.TARIH+GECERLILIK_SURESI,'
              '--'#9'REHBERID,EKLEYEN'
              ''
              '--from TEKLIF T'
              
                '--where T.EKLEYEN=@RehberId and T.DURUM=(Select min(DEGER) from ' +
                'GENINI where BOLUM=-2902) and'
              
                '--'#9'0>case when ISNULL(T.GECERLILIK_SURESI,0)=0 then 0  else DATE' +
                'DIFF(day,GETDATE(),T.TARIH'
              '--+GECERLILIK_SURESI) end'
              ''
              'UNION ALL'
              ''
              
                'select   S.ID,TUR=-20,KATEGORI=S.ID,DUYURUAD='#39'Servis - '#39'+(select' +
                ' ANAHTAR from GENINI where BOLUM=-'
              '3007 '
              'and DEGER=S.DURUM),'
              
                'KONU=S.KONUSU+'#39' - '#39'+(SELECT FIRMA FROM REHBER R WHERE R.ID=S.REH' +
                'BERID),'
              'OLAYZAMANI=S.EKLEMETARIHI, '
              'REHBERID,S.EKLEYEN, YER=83, YER_ID=S.ID'
              'FROM '
              #9'SERVIS S inner join '
              #9'(select * from ('
              
                #9#9'select * ,SIRANO=Row_Number() over(partition by SH.SERVISID or' +
                'der by SH.ID desc)'
              #9#9'from SERVISHAREKET SH )as AA'
              #9'where SIRANO=1) as BB on S.ID=BB.SERVISID'
              'WHERE BB.PERSONEL=@RehberId and S.ACKAPA=0'
              ''
              '--UNION ALL'
              ''
              
                '--select   S.ID,TUR=-20,KATEGORI=S.ID,DUYURUAD='#39'Servis - '#39'+(sele' +
                'ct ANAHTAR from GENINI where BOLUM=-'
              '--  3007 and DEGER=S.DURUM),'
              
                '--KONU=S.KONUSU+'#39' - '#39'+(SELECT FIRMA FROM REHBER R WHERE R.ID=S.R' +
                'EHBERID),'
              '--OLAYZAMANI=S.EKLEMETARIHI, '
              '--REHBERID,S.EKLEYEN,YER=83, YER_ID=S.ID'
              '--FROM '
              '--'#9'SERVIS S inner join  SERVISHAREKET SH  on S.ID=SH.SERVISID'
              
                '--WHERE SH.PERSONEL=@RehberId and S.ACKAPA=0 and SH.BITIS is nul' +
                'l'
              ''
              ') as Liste'
              ''
              'where'
              '   convert(smallint,OLAYZAMANI-@Bugun) > @GunSay'
              ' --Kategori'
              ''
              'ORDER BY convert(smallint,OLAYZAMANI-@Bugun)'
              '')
            TabOrder = 2
            Visible = False
            Height = 89
            Width = 553
          end
        end
        object SheetMesajlasma: TcxTabSheet
          Caption = 'SheetMesajlasma'
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object pnlMesajlasma: TPanel
            Left = 0
            Top = 0
            Width = 942
            Height = 569
            Align = alClient
            Color = clGradientInactiveCaption
            ParentBackground = False
            TabOrder = 0
            object Panel18: TPanel
              Left = 1
              Top = 1
              Width = 940
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
            end
            object ScrollBox2: TScrollBox
              Left = 1
              Top = 25
              Width = 211
              Height = 543
              Align = alLeft
              TabOrder = 1
              object cxGrid4: TcxGrid
                Left = 0
                Top = 31
                Width = 207
                Height = 508
                Align = alClient
                PopupMenu = MesajMenu
                TabOrder = 1
                LookAndFeel.Kind = lfOffice11
                LookAndFeel.NativeStyle = False
                object cxGrid4DBTableViewKisiler: TcxGridDBTableView
                  PopupMenu = MesajMenu
                  Navigator.Buttons.CustomButtons = <>
                  ScrollbarAnnotations.CustomAnnotations = <>
                  OnCellClick = cxGrid4DBTableViewKisilerCellClick
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
                  object cxGrid4DBTableViewKisilerColumn1: TcxGridDBColumn
                    DataBinding.FieldName = 'ID'
                    DataBinding.IsNullValueType = True
                    RepositoryItem = Tablo.repOnlinePersonel
                    Options.ShowCaption = False
                    Width = 200
                    IsCaptionAssigned = True
                  end
                end
                object cxGridLevel1: TcxGridLevel
                  GridView = cxGrid4DBTableViewKisiler
                end
              end
              object Panel10: TPanel
                Left = 0
                Top = 0
                Width = 207
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
                  Width = 162
                end
              end
            end
            object PanelChat: TPanel
              Left = 212
              Top = 25
              Width = 729
              Height = 543
              Align = alClient
              TabOrder = 2
              object PageControlChat: TcxPageControl
                Left = 1
                Top = 1
                Width = 727
                Height = 500
                Align = alClient
                PopupMenu = MesajMenu
                TabOrder = 0
                Properties.CustomButtons.Buttons = <>
                LookAndFeel.NativeStyle = False
                OnCanClose = PageControlChatCanClose
                OnPageChanging = PageControlChatPageChanging
                ClientRectBottom = 498
                ClientRectLeft = 2
                ClientRectRight = 725
                ClientRectTop = 2
              end
              object Panel4: TPanel
                Left = 1
                Top = 501
                Width = 727
                Height = 41
                Align = alBottom
                TabOrder = 1
                object BtnMesajGonder: TcxButton
                  Left = 628
                  Top = 1
                  Width = 59
                  Height = 39
                  Align = alRight
                  Caption = 'G'#246'nder'
                  Enabled = False
                  TabOrder = 0
                  OnClick = BtnMesajGonderClick
                end
                object MemoChat: TcxRichEdit
                  Left = 1
                  Top = 1
                  Align = alClient
                  Enabled = False
                  Properties.ScrollBars = ssVertical
                  TabOrder = 2
                  OnKeyUp = MemoChatKeyUp
                  Height = 39
                  Width = 627
                end
                object BtnDosyaGonder: TcxButton
                  Left = 687
                  Top = 1
                  Width = 39
                  Height = 39
                  Align = alRight
                  Enabled = False
                  OptionsImage.Glyph.SourceDPI = 96
                  OptionsImage.Glyph.Data = {
                    424D361000000000000036000000280000002000000020000000010020000000
                    000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E2DA
                    D5FFA59081FF7E604AFF69452AFF643E22FF6A472CFF836954FFAD9D92FFF0ED
                    E9FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F0ECEAFF927B67FF6740
                    24FF774929FF83522CFF88552EFF87542EFF804F2CFF7A4D29FF714726FF6642
                    28FFAFA093FFFDFDFDFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E5DDD8FF855F40FF9C6134FFB872
                    3EFFC87D43FFD18346FFD88748FFDC8849FFD48648FFBE7640FF9B5F34FF7E4E
                    2AFF6E4424FF8A7666FFFBFAFAFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00F1EBE6FFA6724AFFC87D43FFDA8949FFDA88
                    49FFDA8F59FFF3C199FFFDD9BDFFFFE5CDFFFFDEBBFFFFCD94FFFFA75BFFD282
                    46FF8A572EFF6E4626FF9D8F82FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00F6F2F0FFB17D57FFDF8B4AFFE4904CFFC67D43FFD5B3
                    98FFFDFBF8FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF8EAFFFFC6
                    84FFED9550FF8B562EFF654023FFDCD8D5FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FCFBFAFFB38A68FFDD8A4AFFE9934EFFBD7741FFD1BEAEFFFFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFD
                    F7FFFFC97DFFE48B4CFF764A28FF958478FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FDFDFDFFC0997DFFD9874AFFED9350FFC77C42FFC6AE9CFFFFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFF1CEFFFFB662FFA46436FF6A503DFFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00CEAD94FFD88648FFEF9651FFD08245FFBFA38DFFFFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFBF3FFFFC56AFFD38246FF563821FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6BC
                    A9FFD28247FFF39850FFD58448FFB5967FFFFEFEFEFFF0E9E3FFDAC5B5FFDBC5
                    B5FFF1E8E2FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFAF4FFFFC46BFFE9914EFF583B24FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DFCDBEFFCC80
                    46FFF59952FFDE8B4AFFAB8971FFF3EFEEFFB38E72FF83532EFF7E502AFF7F4F
                    2CFF82522DFFAD8B71FFF7F5F3FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFF0D7FFFFC369FFE58E4CFF725946FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7DBD1FFC68049FFF89A
                    54FFE4904CFFAC8568FFF3F1EEFFCA9669FFD28346FFD18346FFC87C43FFB270
                    3BFF8F5A2FFF774A28FF93745EFFFEFEFEFFFFFFFF00FFFFFF00FFFFFF00FEFE
                    FEFFFFD28EFFFFBC65FFC27740FFA19387FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFE7E1FFC58251FFFA9B53FFEC94
                    4FFFAD815DFFEEEBEAFFD29F75FFF69952FFF59853FFD18449FFF0B487FFFFC3
                    8FFFFA9E56FFA66738FF714625FFD8D0CAFFFFFFFF00FFFFFF00FFFFFF00FFDA
                    AEFFFFB863FFFFA75AFF865533FFECE9E7FFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00F5EFECFFC4875AFFFB9C55FFF49851FFAF7B
                    56FFEDEAE8FFD9A982FFF59952FFFC9C55FFBB7843FFD8CCC2FFFFFFFF00FFFF
                    FF00FFE8BAFFFBA357FF82502BFFBAADA2FFFFFFFF00FFFEFEFFFFD4A5FFFFA8
                    5AFFFFAA5BFFC47A41FFB3A498FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00F9F7F5FFC69168FFFC9D54FFFA9D55FFB57C4FFFE7E5
                    E2FFDAAC8BFFF79A52FFFF9F56FFBD7841FFCBBDB2FFFFFFFF00FFFFFF00FEF9
                    F5FFFFBF82FFFFB662FF925A31FFBEB7B2FFFDFCFBFFF8C796FFFFAA5DFFFFA1
                    58FFD08146FFAF9681FFFEFEFEFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FDFDFCFFCC987AFFFD9D54FFFFA157FFB97A4AFFE2DDD9FFDCB2
                    93FFF89B54FFFFA357FFC27B42FFCDBDB2FFFFFFFF00FFFFFF00FEF8F4FFEFA9
                    73FFFFA659FFFCA055FF7A573DFFF2F0EDFFFFC18EFFFFAA5BFFFFA358FFBF78
                    42FFB9A595FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00D5AA8DFFFC9D56FFFFA659FFC17E4AFFDBD5D1FFE0BBA0FFFA9D
                    54FFFFA659FFC87E44FFCDBCAFFFFFFFFF00FFFFFF00FEF8F4FFF5AD75FFFFA8
                    5AFFFC9D56FF9E6A40FFCEC7C2FFFFC188FFFFAE5DFFFFA258FFB57441FFC8B8
                    ADFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00E1BEA4FFFA9D55FFFFAB5BFFCA8147FFD3CAC2FFE5C6ADFFF99D55FFFFA9
                    5BFFCF8146FFCFBCAFFFFFFFFF00FFFFFF00FDF4EFFFF9AD74FFFFAA5BFFFC9E
                    55FF996842FFD7CDC7FFFFBE7EFFFFAF5EFFFFA158FFAF7141FFD1C7BFFFFFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E8CD
                    B9FFF59A53FFFFAF5FFFD68649FFCDC0B7FFE8CCB7FFF89C56FFFFAD5CFFD284
                    47FFCEBDAEFFFFFFFF00FFFFFF00FEF7F0FFFDAE74FFFFAD5DFFFA9E55FF9667
                    44FFDFD4CCFFFFBB78FFFFB160FFFE9F57FFA97046FFDDD6D1FFFFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E8D6C9FFF39C
                    57FFFFB561FFE48E4EFFC5B5A8FFEAD2BFFFF9A059FFFFB05EFFDB894AFFD0BC
                    ADFFFFFFFF00FFFFFF00FEF6EFFFFFB174FFFFB060FFFA9E55FF936A4BFFE3D7
                    CDFFFFB871FFFFB461FFFA9D55FFA5744FFFE6E2DEFFFFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E99C5FFFFFB9
                    63FFF29852FFBCA898FFEFDBCBFFFAA45BFFFFB461FFE18D4BFFC6B0A1FFFFFF
                    FF00FFFFFF00FFF4ECFFFFAF70FFFFB461FFF89D54FF916B50FFEAD9CCFFFFB8
                    6EFFFFB662FFF89A54FFA57B5AFFEFEDEBFFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFE4B5FFFFA6
                    59FFB89D8AFFF4E3D6FFF8A55DFFFFB863FFE8914EFFC4AB99FFFFFFFF00FFFF
                    FF00FFF5EDFFFFB472FFFFB663FFF89B54FF8E6D54FFEFDACBFFFFBA6AFFFFB7
                    63FFF09651FFA68569FFF6F5F4FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FAF4
                    EFFFF4E6DCFFF9A762FFFFBF67FFEF9752FFC5AB99FFFFFFFF00FFFFFF00FFF3
                    E8FFFFB875FFFFBA64FFF59A53FF91725EFFF2DAC6FFFFBD6AFFFFB963FFE991
                    4DFFAE937AFFFBFAFAFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7EA
                    E0FFFAAE69FFFFC369FFF59B55FFC8AB98FFFFFFFF00FFFFFF00FFF4EBFFFFB9
                    71FFFFBE66FFF29952FF927764FFF6DBC2FFFFBE69FFFFBA64FFDE894AFFB8A0
                    8FFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FEFAF7FFFFB5
                    72FFFFC76CFFFAA057FFC9AC96FFFFFFFF00FFFFFF00FFF3E9FFFFBD75FFFFC1
                    68FFF09752FF998071FFF9D8B9FFFFC169FFFFBA65FFD28146FFC3B1A4FFFFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFE3C9FFFFCA
                    6DFFFBA558FFC3A691FFFFFFFF00FFFFFF00FFF7EBFFFFBF72FFFFC56AFFED95
                    51FF9C887AFFFDD9B4FFFFC66AFFFFBA64FFC87F49FFCFC3B9FFFFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFE8CAFFFFBB
                    66FF774727FFBC9D87FFFCF9F6FFFFFFFF00FFF9E0FFFFCC6DFFE6914FFFA492
                    86FFFFD6AAFFFFCA6DFFFFB964FFC17E4CFFD9CFCAFFFFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFBF5FFFFC0
                    73FFBA723DFFB5723DFFBF8253FFE2CDB9FFFFFEFEFFFCDFBFFFBAABA2FFFFD9
                    A4FFFFCF6FFFFFB763FFB87C4FFFE4DDDAFFFFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF5
                    E3FFFFB875FFF89B54FFD18246FFB5753EFFB68E65FFE5BE9FFFFFCE8CFFFFD1
                    71FFFFB562FFB37F59FFECE9E6FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFDFCFFFFDDBBFFFFAA65FFE4904DFFDE8A4AFFFFC269FFFFD472FFFFB1
                    5FFFB08565FFF3F3F2FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FEF9F4FFF5C8A6FFF0A268FFE79753FFDF9C64FFC7AB
                    96FFF9F9F9FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                    FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                  TabOrder = 1
                  OnClick = BtnDosyaGonderClick
                end
              end
            end
          end
        end
        object SheetYonetimFinans: TcxTabSheet
          Caption = 'SheetYonetimFinans'
          ImageIndex = 9
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object pageFinans: TcxPageControl
            Left = 0
            Top = 0
            Width = 942
            Height = 569
            Align = alClient
            PopupMenu = PopupMenuGrafik
            TabOrder = 0
            Properties.CustomButtons.Buttons = <>
            Properties.Style = 10
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            OnChange = pageFinansChange
            ClientRectBottom = 569
            ClientRectRight = 942
            ClientRectTop = 0
          end
        end
        object SheetYonetimCRM: TcxTabSheet
          Caption = 'SheetYonetimCRM'
          ImageIndex = 10
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PageCRM: TcxPageControl
            Left = 0
            Top = 0
            Width = 942
            Height = 569
            Align = alClient
            PopupMenu = PopupMenuGrafik
            TabOrder = 0
            Properties.CustomButtons.Buttons = <>
            Properties.Style = 10
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            OnChange = PageCRMChange
            ClientRectBottom = 569
            ClientRectRight = 942
            ClientRectTop = 0
          end
        end
        object SheetYonetimTeklif: TcxTabSheet
          Caption = 'SheetYonetimTeklif'
          ImageIndex = 11
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PageTeklif: TcxPageControl
            Left = 0
            Top = 0
            Width = 942
            Height = 569
            Align = alClient
            PopupMenu = PopupMenuGrafik
            TabOrder = 0
            Properties.CustomButtons.Buttons = <>
            Properties.Style = 10
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            OnChange = PageTeklifChange
            ClientRectBottom = 569
            ClientRectRight = 942
            ClientRectTop = 0
          end
        end
        object SheetYonetimServis: TcxTabSheet
          Caption = 'SheetYonetimServis'
          ImageIndex = 12
          PopupMenu = PopupMenuGrafik
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object ScrollBoxYoneticiSag: TScrollBox
            Left = 757
            Top = 24
            Width = 185
            Height = 545
            Align = alRight
            TabOrder = 0
            Visible = False
            object Panel1: TPanel
              Left = 0
              Top = 0
              Width = 181
              Height = 24
              Align = alTop
              Color = clSkyBlue
              ParentBackground = False
              TabOrder = 0
              object Label1: TLabel
                Left = 6
                Top = 4
                Width = 50
                Height = 18
                Caption = 'Ko'#351'ullar'
                Font.Charset = TURKISH_CHARSET
                Font.Color = clNavy
                Font.Height = -13
                Font.Name = 'Trebuchet MS'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object SpeedButton1: TSpeedButton
                Left = 157
                Top = 1
                Width = 23
                Height = 22
                Hint = 'mnDovizKurlari'
                Align = alRight
                Caption = 'X'
                Flat = True
                OnClick = SpeedButton1Click
                ExplicitTop = 0
              end
              object cxButton1: TcxButton
                Left = 216
                Top = 0
                Width = 29
                Height = 23
                OptionsImage.Glyph.SourceDPI = 96
                OptionsImage.Glyph.Data = {
                  424D360400000000000036000000280000001000000010000000010020000000
                  000000000000C40E0000C40E0000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  000000000000000000001C0C0025763701A8C26413F2C96913FA904205C7491D
                  006B000000000000000000000000000000000000000000000000000000000000
                  00000000000036190042C76F1BF3FFAE4FFFFFAD48FFFFA73DFFFF972AFFEB7F
                  19FE6B2D00900000000000000000000000000000000000000000AE5F11CE9D57
                  0DB220100029C56E1CF5FFB763FFFFB259FFD1741DF8682F008B3D1800535824
                  007CA64501E8411B005A00000000000000000000000000000000CD8133F6FDC2
                  85FFB56303EEFFC98EFFFFBE74FFD37B23F83017003B00000000000000000000
                  00001608001C5B24007A00000000000000000000000000000000AC6820D5FFE0
                  BDFFFFCF9EFFFFCC96FFECA660FF592B00700000000000000000000000000000
                  00000000000000000000000000000000000000000000000000008B4F08B3FFE9
                  D1FFFFD2A4FFFFCF9FFFCF822AFD592B00750F08001200000000000000000000
                  00000000000001000001040100070000000000000000000000006E390091FFF3
                  E5FFFFE2C5FFFFDCB7FFFFD4A1FFFFC37EFF713C0091250F00317C3A049E9E51
                  17C7B6682BE0C18043F8BF743AF737150052000000000000000042220055DA9A
                  44F8DB9D4CF9CF862CE3B46A17CA945003B0291600316A310094FFD9A0FFFFE5
                  BCFFFFE4C0FFFFE2BCFFFFE4BAFF571D008F0000000000000000000000000905
                  00090201000200000000000000000000000000000000110700145120007ACC7E
                  39FEFFD3A0FFFFD1A2FFFFE0B1FF743004B10000000000000000000000000000
                  000000000000000000000000000000000000000000000000000054250072F8B7
                  76FFFFCC94FFFFCF98FFFFDFB0FF974D17D30000000000000000000000000000
                  0000753B0090190E00190000000000000000000000003219003BD9822BF6FFBE
                  75FFFFCA88FFA14800EFFECC9BFFBD6B2BF30000000000000000000000000000
                  00004E29005EC47002E7673A00774324004F713B0089DC8223F6FFB057FFFFC1
                  79FFC46D1EF31E0B002995490EB7A14C10C50000000000000000000000000000
                  00000000000085490195F78F1BFEFC952AFFFFA13AFFFFA743FFFFBF75FFCA70
                  1CF4492100620000000000000000000000000000000000000000000000000000
                  00000000000000000000572E006FAC6610CBD47E20FDCA7822F7884604B93618
                  004B000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  00000000000000000000000000000000000000000000}
                TabOrder = 0
              end
            end
            object cxGrid3: TcxGrid
              Left = 0
              Top = 24
              Width = 181
              Height = 493
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object cxGrid3DBCardView1: TcxGridDBCardView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsKosul
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.RowMoving = True
                OptionsView.ScrollBars = ssVertical
                OptionsView.CardIndent = 7
                object cxGrid3DBCardView1Row1: TcxGridDBCardViewRow
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Options.ShowCaption = False
                  Position.BeginsLayer = True
                end
                object cxGrid3DBCardView1Row2: TcxGridDBCardViewRow
                  Caption = 'De'#287'er'
                  DataBinding.FieldName = 'DEGER'
                  DataBinding.IsNullValueType = True
                  OnGetPropertiesForEdit = cxGridDBColumn2GetPropertiesForEdit
                  Options.ShowCaption = False
                  Position.BeginsLayer = True
                end
              end
              object cxGridLevel5: TcxGridLevel
                GridView = cxGrid3DBCardView1
              end
            end
            object Panel3: TPanel
              Left = 0
              Top = 517
              Width = 181
              Height = 24
              Align = alBottom
              Caption = 'Yenile'
              Color = clSkyBlue
              ParentBackground = False
              TabOrder = 2
              OnClick = YenileMenuClick
              object cxButton2: TcxButton
                Left = 216
                Top = 0
                Width = 29
                Height = 23
                OptionsImage.Glyph.SourceDPI = 96
                OptionsImage.Glyph.Data = {
                  424D360400000000000036000000280000001000000010000000010020000000
                  000000000000C40E0000C40E0000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  000000000000000000001C0C0025763701A8C26413F2C96913FA904205C7491D
                  006B000000000000000000000000000000000000000000000000000000000000
                  00000000000036190042C76F1BF3FFAE4FFFFFAD48FFFFA73DFFFF972AFFEB7F
                  19FE6B2D00900000000000000000000000000000000000000000AE5F11CE9D57
                  0DB220100029C56E1CF5FFB763FFFFB259FFD1741DF8682F008B3D1800535824
                  007CA64501E8411B005A00000000000000000000000000000000CD8133F6FDC2
                  85FFB56303EEFFC98EFFFFBE74FFD37B23F83017003B00000000000000000000
                  00001608001C5B24007A00000000000000000000000000000000AC6820D5FFE0
                  BDFFFFCF9EFFFFCC96FFECA660FF592B00700000000000000000000000000000
                  00000000000000000000000000000000000000000000000000008B4F08B3FFE9
                  D1FFFFD2A4FFFFCF9FFFCF822AFD592B00750F08001200000000000000000000
                  00000000000001000001040100070000000000000000000000006E390091FFF3
                  E5FFFFE2C5FFFFDCB7FFFFD4A1FFFFC37EFF713C0091250F00317C3A049E9E51
                  17C7B6682BE0C18043F8BF743AF737150052000000000000000042220055DA9A
                  44F8DB9D4CF9CF862CE3B46A17CA945003B0291600316A310094FFD9A0FFFFE5
                  BCFFFFE4C0FFFFE2BCFFFFE4BAFF571D008F0000000000000000000000000905
                  00090201000200000000000000000000000000000000110700145120007ACC7E
                  39FEFFD3A0FFFFD1A2FFFFE0B1FF743004B10000000000000000000000000000
                  000000000000000000000000000000000000000000000000000054250072F8B7
                  76FFFFCC94FFFFCF98FFFFDFB0FF974D17D30000000000000000000000000000
                  0000753B0090190E00190000000000000000000000003219003BD9822BF6FFBE
                  75FFFFCA88FFA14800EFFECC9BFFBD6B2BF30000000000000000000000000000
                  00004E29005EC47002E7673A00774324004F713B0089DC8223F6FFB057FFFFC1
                  79FFC46D1EF31E0B002995490EB7A14C10C50000000000000000000000000000
                  00000000000085490195F78F1BFEFC952AFFFFA13AFFFFA743FFFFBF75FFCA70
                  1CF4492100620000000000000000000000000000000000000000000000000000
                  00000000000000000000572E006FAC6610CBD47E20FDCA7822F7884604B93618
                  004B000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  00000000000000000000000000000000000000000000}
                TabOrder = 0
              end
            end
          end
          object PageServis: TcxPageControl
            Left = 0
            Top = 24
            Width = 757
            Height = 545
            Align = alClient
            PopupMenu = PopupMenuGrafik
            TabOrder = 1
            Properties.CustomButtons.Buttons = <>
            Properties.Style = 10
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            OnChange = PageServisChange
            ClientRectBottom = 545
            ClientRectRight = 757
            ClientRectTop = 0
          end
          object PanelYoneticiUst: TPanel
            Left = 0
            Top = 0
            Width = 942
            Height = 24
            Align = alTop
            Color = clSkyBlue
            ParentBackground = False
            TabOrder = 2
            object Label11: TLabel
              Left = 6
              Top = 4
              Width = 103
              Height = 18
              Caption = 'Y'#246'netici Konsolu'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clNavy
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object KosulButon: TSpeedButton
              Left = 823
              Top = 1
              Width = 118
              Height = 22
              Hint = 'mnYoneticiKonsolu'
              Align = alRight
              Caption = 'Ko'#351'ullar'
              Flat = True
              OnClick = KosullarMenuClick
              ExplicitLeft = 557
            end
          end
        end
        object SheetKDR: TcxTabSheet
          Caption = 'Karar Destek Raporlar'#305
          ImageIndex = 8
          object dxTileControl1: TdxTileControl
            Left = 0
            Top = 0
            Width = 441
            Height = 569
            Align = alLeft
            OptionsView.GroupIndent = 10
            OptionsView.GroupMaxRowCount = 8
            OptionsView.IndentHorz = 5
            OptionsView.IndentVert = 5
            OptionsView.ItemHeight = 75
            OptionsView.ItemIndent = 5
            OptionsView.ItemWidth = 100
            TabOrder = 0
            object dxTileControl1Group1: TdxTileControlGroup
              Index = 0
            end
            object dxTileControl1Group2: TdxTileControlGroup
              Index = 1
            end
            object KDR_BORCLULAR: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.AlignWithText = itaLeft
              Glyph.ImageIndex = 2
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 0
              IndexInGroup = 0
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'BOR'#199'LULAR'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_ALINAN_CEK: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 6
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 0
              IndexInGroup = 3
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'ALINAN '#199'EK'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_ALACAKLILAR: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 2
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 1
              IndexInGroup = 0
              Size = tcisLarge
              Style.GradientBeginColor = 232
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'ALACAKLILAR'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_STOK: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 29
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFill
              Glyph.Images = Tablo.PNGImageList1
              GroupIndex = 0
              IndexInGroup = 6
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'STOK'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_KASA: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 3
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 0
              IndexInGroup = 5
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'KASA'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_ALINAN_SENET: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 6
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 0
              IndexInGroup = 4
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'ALINAN SENET'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_BANKA: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 0
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 0
              IndexInGroup = 1
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'BANKA'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_KREDILER: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 0
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 1
              IndexInGroup = 1
              Size = tcisLarge
              Style.GradientBeginColor = 232
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'KRED'#304'LER'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_KREDI_KARTI: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 1
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 1
              IndexInGroup = 2
              Size = tcisLarge
              Style.GradientBeginColor = 232
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'KRED'#304' KARTI'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_VERILEN_CEK: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 6
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 1
              IndexInGroup = 3
              Size = tcisLarge
              Style.GradientBeginColor = 232
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'VER'#304'LEN '#199'EK'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_VERILEN_SENET: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 6
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 1
              IndexInGroup = 4
              Size = tcisLarge
              Style.GradientBeginColor = 232
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'VER'#304'LEN SENET'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_POS: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 1
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 0
              IndexInGroup = 2
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'POS'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object dxTileControl1Item5: TdxTileControlItem
              GroupIndex = 1
              IndexInGroup = 5
              Size = tcisSmall
              Style.GradientBeginColor = clSilver
              Style.GradientEndColor = clSilver
              Text1.AssignedValues = []
              Text2.AssignedValues = []
              Text3.AssignedValues = []
              Text4.AssignedValues = []
            end
            object KDR_SONUC: TdxTileControlItem
              Glyph.Align = oaMiddleLeft
              Glyph.AlignWithText = itaTop
              Glyph.ImageIndex = 3
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.PngImageListTicari
              GroupIndex = 1
              IndexInGroup = 6
              Size = tcisLarge
              Style.GradientBeginColor = clGreen
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'SONU'#199
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.IndentHorz = 0
              Text4.IndentVert = 0
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
          end
          object PanelKDR_Sag: TPanel
            Left = 441
            Top = 0
            Width = 501
            Height = 569
            Align = alClient
            TabOrder = 1
            object GridKDR: TcxGrid
              Left = 1
              Top = 42
              Width = 499
              Height = 526
              Align = alClient
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              LookAndFeel.ScrollbarMode = sbmClassic
              LookAndFeel.ScrollMode = scmDefault
              object GridKDRView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCanFocusRecord = GridKDRViewCanFocusRecord
                DataController.DataSource = DtsKDR
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <
                  item
                    Kind = skSum
                    Position = spFooter
                    Sorted = True
                  end>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Kind = skCount
                    Column = GridKDRViewColumn1
                  end
                  item
                    Kind = skSum
                    FieldName = 'TUTAR'
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.ColumnHeaderHints = False
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsCustomize.ColumnsQuickCustomizationSorted = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsView.Footer = True
                OptionsView.FooterMultiSummaries = True
                OptionsView.Indicator = True
                object GridKDRViewColumn1: TcxGridDBColumn
                  DataBinding.IsNullValueType = True
                end
                object GridKDRViewTUR: TcxGridDBColumn
                  DataBinding.FieldName = 'TUR'
                  DataBinding.IsNullValueType = True
                  Width = 119
                end
                object GridKDRViewTUTAR: TcxGridDBColumn
                  DataBinding.FieldName = 'TUTAR'
                  DataBinding.IsNullValueType = True
                  Width = 119
                end
                object GridKDRViewAD: TcxGridDBColumn
                  DataBinding.FieldName = 'AD'
                  DataBinding.IsNullValueType = True
                end
              end
              object GridKDRLevel1: TcxGridLevel
                GridView = GridKDRView
              end
            end
            object Panel11: TPanel
              Left = 1
              Top = 1
              Width = 499
              Height = 41
              Align = alTop
              TabOrder = 1
              object cxLabel4: TcxLabel
                Left = 3
                Top = 8
                Caption = 'D'#246'nem Ba'#351#305' :'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
                OnClick = cxLabel2Click
              end
              object DateKDRDonemBas: TcxDateEdit
                Left = 92
                Top = 7
                Enabled = False
                ParentFont = False
                Properties.ImmediatePost = True
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 1
                Width = 121
              end
              object cxLabel5: TcxLabel
                Left = 219
                Top = 9
                Caption = 'D'#246'nem Sonu :'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object DateKDRDonemSon: TcxDateEdit
                Left = 310
                Top = 8
                ParentFont = False
                Properties.ImmediatePost = True
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 3
                Width = 121
              end
              object cxButton3: TcxButton
                Left = 441
                Top = 9
                Width = 59
                Height = 23
                OptionsImage.ImageIndex = 8
                OptionsImage.Images = Tablo.imgScheduler
                SpeedButtonOptions.Flat = True
                TabOrder = 4
                OnClick = cxButton3Click
              end
            end
          end
        end
        object SheetNakitAkisi: TcxTabSheet
          Caption = 'Nakit Ak'#305#351#305
          ImageIndex = 9
          object PageControl: TcxPageControl
            Left = 0
            Top = 33
            Width = 942
            Height = 536
            Align = alClient
            TabOrder = 0
            Properties.ActivePage = TabSheetListe
            Properties.CustomButtons.Buttons = <>
            OnChange = PageControlChange
            ClientRectBottom = 532
            ClientRectLeft = 4
            ClientRectRight = 938
            ClientRectTop = 27
            object TabSheetTakvim: TcxTabSheet
              Caption = 'Takvim'
              ImageIndex = 0
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object Scheduler: TcxScheduler
                Left = 0
                Top = 0
                Width = 934
                Height = 505
                DateNavigator.ColCount = 2
                DateNavigator.RowCount = 2
                DateNavigator.OnSelectionChanged = SchedulerDateNavigatorSelectionChanged
                ViewDay.TimeRulerMinutes = True
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
                Selection = 119
                Splitters = {
                  87020000FB000000A503000000010000820200000100000087020000F8010000}
                StoredClientBounds = {0100000001000000A5030000F8010000}
                object pnlControls: TPanel
                  Left = 0
                  Top = 0
                  Width = 286
                  Height = 248
                  Align = alClient
                  BevelOuter = bvNone
                  Color = clWindow
                  TabOrder = 0
                  object Memo1: TMemo
                    Left = 0
                    Top = 0
                    Width = 286
                    Height = 248
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
                    Height = 248
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
                  #9'VADE >= '#39'2010-01-01 00:00'#39' and VADE <= '#39'2020-01-01 23:59'#39
                  #9'and CH.ISLEM = 140 and CH.GERIDONUSID is null')
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
                  #9'and CH.ISLEM = 130 and CH.GERIDONUSID is null'
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
                    'ar(10), SUM(PLKK.TUTAR),1),'#39'0'#39')+'#39' '#39'+isnull(KK.ADI,'#39#39'),'
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
                  '    Dosya='#39'SENETLER'#39', '
                  '    ID2=C.ID,'
                  '               REHBERID=R.ID,'
                  '    C.TUR, TURAD=T.AD,'
                  '    TUTAR,KUR,'
                  #9' YON='#39'Tahsilat'#39' , '
                  #9' SIRA=2,'
                  #9' AIKLAMA='#39'Senet'#39' '
                  #9' '
                  'from SENETLER C'
                  'inner join ISLEMTURLERI T on C.TUR=T.TUR'
                  'inner join REHBER R on R.ID=C.REHBERID'
                  'where '
                  #9'VADE >= '#39'2010-01-01 00:00'#39' '
                  'and VADE <= '#39'2020-01-01 23:59'#39
                  #9'and C.TUR in (24)')
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
                  '    Dosya='#39'SENETLER'#39', '
                  '    ID2=C.ID,'
                  '               REHBERID=R.ID,'
                  '    C.TUR, TURAD=T.AD,'
                  '    -1*TUTAR,KUR,'
                  #9' YON='#39#214'deme'#39', '
                  #9' SIRA=2,'
                  #9' AIKLAMA='#39'Senet'#39' '
                  #9' '
                  'from SENETLER C'
                  'inner join ISLEMTURLERI T on C.TUR=T.TUR'
                  'inner join REHBER R on R.ID=C.REHBERID'
                  'where '
                  #9'VADE >= '#39'2010-01-01 00:00'#39' '
                  'and VADE <= '#39'2020-01-01 23:59'#39
                  #9'and C.TUR in (34)')
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
                  'where B.GOR=1 and M.GELIRMI=0'
                  
                    'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
                    'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>='#39'2010-01-' +
                    '01 00:00'#39' '
                  
                    'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
                    'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))<='#39'2012-01-' +
                    '01 00:00'#39
                  
                    'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
                    'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>GETDATE()'#9 +
                    ' ')
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
                  
                    'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
                    'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>='#39'2010-01-' +
                    '01 00:00'#39' '
                  
                    'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
                    'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))<='#39'2012-01-' +
                    '01 00:00'#39
                  
                    'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
                    'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>GETDATE()'#9 +
                    ' ')
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
              Caption = 'Pivot'
              ImageIndex = 2
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object Label3: TLabel
                Left = 184
                Top = 48
                Width = 28
                Height = 16
                Caption = 'TARIH'
              end
              object Panel5: TPanel
                Left = 0
                Top = 0
                Width = 934
                Height = 41
                Align = alTop
                TabOrder = 0
                object LabelBittar: TJvDateTimePicker
                  Left = 4
                  Top = 4
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
                Width = 928
                Height = 458
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
                Left = 2048
                Top = 1900
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
                ExplicitLeft = 2042
                ExplicitTop = 1894
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
              Caption = 'Grafik'
              ImageIndex = 1
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object GridGrafik: TcxGrid
                Left = 0
                Top = 0
                Width = 934
                Height = 505
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
                  ''
                  
                    'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
                    'DE,'#39'1900-01-01'#39'),20)),'
                  'Tutar='
                  'case When KUR='#39'TL'#39' then ('
                  
                    'Select (-1*isnull(SUM(SB.TUTAR),0)) from SENETLER SB Where TUR =' +
                    ' 34 and SB.VADE=S.VADE) else'
                  #9#9#9'('
                  
                    'Select (-1*isnull(SUM(SB.TUTAR),0)) from SENETLER SB Where TUR =' +
                    ' 34 and SB.VADE=S.VADE )*('
                  #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
                  #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
                  #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
                  #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
                  #9#9#9#9#9') '
                  
                    #9#9#9#9#9'end,KUR from SENETLER S Where VADE >=@BasTarih  and VADE <=' +
                    ' @BitTarih'
                  'Group by KUR,VADE')
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
                  ''
                  
                    'Select TARIH=Convert(smalldatetime,convert(varchar(10),isnull(VA' +
                    'DE ,'#39'1900-01-01'#39'),20)),'
                  'Tutar='
                  'case When KUR='#39'TL'#39' then '
                  
                    '(Select isnull(SUM(CB.TUTAR),0) from CEKLER CB Where TUR = 23 an' +
                    'd isnull(CIROLU,0)=0 and CB.VADE=C.VADE  )'
                  ' else'
                  
                    '(Select isnull(SUM(CB.TUTAR),0) from CEKLER CB Where TUR = 23 an' +
                    'd isnull(CIROLU,0)=0 and CB.VADE=C.VADE  )*('
                  #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
                  #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
                  #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
                  #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
                  #9#9#9#9#9') '
                  #9#9#9#9#9'end'
                  
                    ',KUR from CEKLER C Where TUR = 23 and isnull(CIROLU,0)=0 and VAD' +
                    'E >=@BasTarih  and VADE <= @BitTarih'
                  'Group by KUR,VADE')
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
            end
            object TabSheetListe: TcxTabSheet
              Caption = 'Liste'
              ImageIndex = 3
              object Panel6: TPanel
                Left = 0
                Top = 0
                Width = 934
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
                  OnClick = DateTimeListeBitisChange
                end
              end
              object GridListe: TcxGrid
                Left = 0
                Top = 41
                Width = 934
                Height = 464
                Align = alClient
                PopupMenu = PopupMenuListe
                TabOrder = 1
                LookAndFeel.Kind = lfOffice11
                LookAndFeel.NativeStyle = False
                object GridListeView: TcxGridDBTableView
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
            Width = 936
            Height = 30
            Margins.Bottom = 0
            ButtonHeight = 30
            ButtonWidth = 70
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
            TabOrder = 1
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
            object YaziciYaz: TToolButton
              Left = 216
              Top = 0
              Caption = 'Yazd'#305'r'
              DropdownMenu = PopupMenuYaz
              ImageIndex = 16
              ImageName = 'PngImage15'
              Style = tbsTextButton
            end
            object ToolButton1: TToolButton
              Left = 286
              Top = 0
              Caption = 'Yenile'
              ImageIndex = 17
              ImageName = 'PngImage16'
              Style = tbsTextButton
              OnClick = ToolButton1Click
            end
          end
        end
        object SheetStok: TcxTabSheet
          Caption = 'SheetStok'
          ImageIndex = 10
          object dxTileControl2: TdxTileControl
            Left = 0
            Top = 41
            Width = 441
            Height = 528
            Align = alLeft
            OptionsView.GroupIndent = 10
            OptionsView.GroupMaxRowCount = 8
            OptionsView.IndentHorz = 5
            OptionsView.IndentVert = 5
            OptionsView.ItemHeight = 75
            OptionsView.ItemIndent = 5
            OptionsView.ItemWidth = 100
            TabOrder = 0
            object dxTileControlGroup1: TdxTileControlGroup
              Index = 0
            end
            object dxTileControlGroup2: TdxTileControlGroup
              Index = 1
            end
            object KDR_DONEM_BASI: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.AlignWithText = itaLeft
              Glyph.ImageIndex = 29
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.cxImageList1
              GroupIndex = 0
              IndexInGroup = 0
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'D'#246'nem Ba'#351#305' Envanter'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_DONEM_BASIClick
            end
            object KDR_DONEM_SONU: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 28
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.cxImageList1
              GroupIndex = 1
              IndexInGroup = 0
              Size = tcisLarge
              Style.GradientBeginColor = 232
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'D'#246'nem Sonu Envanter'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_DONEM_BASIClick
            end
            object KDR_STMM: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 14
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.cxImageList1
              GroupIndex = 0
              IndexInGroup = 3
              Size = tcisLarge
              Style.GradientBeginColor = clNavy
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'STMM'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_DONEM_BASIClick
            end
            object dxTileControlItem5: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 5
              Glyph.Mode = ifmFit
              GroupIndex = 0
              IndexInGroup = 2
              Size = tcisSmall
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_BORCLULARClick
            end
            object KDR_ALIS_FATURA_TUTAR: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 12
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.cxImageList1
              GroupIndex = 0
              IndexInGroup = 1
              Size = tcisLarge
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'Al'#305#351
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_DONEM_BASIClick
            end
            object KDR_SATIS_FATURA_TUTAR: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.ImageIndex = 9
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.cxImageList1
              GroupIndex = 1
              IndexInGroup = 1
              Size = tcisLarge
              Style.GradientBeginColor = 232
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'Sat'#305#351
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.Value = '0'
              OnClick = KDR_DONEM_BASIClick
            end
            object dxTileControlItem13: TdxTileControlItem
              GroupIndex = 1
              IndexInGroup = 2
              Size = tcisSmall
              Style.GradientBeginColor = clSilver
              Style.GradientEndColor = clSilver
              Text1.AssignedValues = []
              Text2.AssignedValues = []
              Text3.AssignedValues = []
              Text4.AssignedValues = []
            end
            object KDR_BRUT_KAR_ZARAR: TdxTileControlItem
              Glyph.Align = oaTopLeft
              Glyph.AlignWithText = itaTop
              Glyph.ImageIndex = 10
              Glyph.IndentHorz = 0
              Glyph.IndentVert = 0
              Glyph.Mode = ifmFit
              Glyph.Images = Tablo.cxImageList1
              GroupIndex = 1
              IndexInGroup = 3
              Size = tcisLarge
              Style.GradientBeginColor = clGreen
              Text1.AssignedValues = []
              Text2.AssignedValues = [avFont]
              Text2.Font.Charset = DEFAULT_CHARSET
              Text2.Font.Color = clDefault
              Text2.Font.Height = -12
              Text2.Font.Name = 'Segoe UI'
              Text2.Font.Style = [fsBold]
              Text2.Value = 'Br'#252't Kar / Zarar'
              Text3.AssignedValues = []
              Text4.AssignedValues = [avFont]
              Text4.Font.Charset = DEFAULT_CHARSET
              Text4.Font.Color = clDefault
              Text4.Font.Height = -19
              Text4.Font.Name = 'Segoe UI'
              Text4.Font.Style = [fsBold]
              Text4.IndentHorz = 0
              Text4.IndentVert = 0
              Text4.Value = '0'
              OnClick = KDR_DONEM_BASIClick
            end
          end
          object Panel7: TPanel
            Left = 0
            Top = 0
            Width = 942
            Height = 41
            Align = alTop
            TabOrder = 1
            object cxLabel2: TcxLabel
              Left = 3
              Top = 8
              Caption = 'D'#246'nem Ba'#351#305' :'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              OnClick = cxLabel2Click
            end
            object CalendarDonemBas: TcxDateEdit
              Left = 92
              Top = 7
              ParentFont = False
              Properties.ImmediatePost = True
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 1
              Width = 121
            end
            object cxLabel3: TcxLabel
              Left = 219
              Top = 9
              Caption = 'D'#246'nem Sonu :'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object CalendarDonemSon: TcxDateEdit
              Left = 310
              Top = 8
              ParentFont = False
              Properties.ImmediatePost = True
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 3
              Width = 121
            end
            object ButtonDonemStokYenile: TcxButton
              Left = 441
              Top = 9
              Width = 59
              Height = 23
              OptionsImage.ImageIndex = 8
              OptionsImage.Images = Tablo.imgScheduler
              SpeedButtonOptions.Flat = True
              TabOrder = 4
              OnClick = ButtonDonemStokYenileClick
            end
          end
          object GridStok: TcxGrid
            Left = 441
            Top = 41
            Width = 501
            Height = 528
            Align = alClient
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
            LookAndFeel.Kind = lfStandard
            object GridStokView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridStokViewCanFocusRecord
              DataController.DataSource = DtsKDRStok
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <
                item
                  Kind = skCount
                  Column = cxGridDBColumn1
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.ColumnHeaderHints = False
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.Footer = True
              OptionsView.FooterMultiSummaries = True
              OptionsView.Indicator = True
              object cxGridDBColumn1: TcxGridDBColumn
                DataBinding.IsNullValueType = True
              end
            end
            object cxGridLevel3: TcxGridLevel
              GridView = GridStokView
            end
          end
        end
      end
    end
    object Panel9: TPanel
      Left = 1
      Top = 1
      Width = 230
      Height = 602
      Align = alLeft
      TabOrder = 0
      object btnArama: TJvNavPanelButton
        Left = 1
        Top = 95
        Width = 228
        Height = 52
        Hint = 'Girilmi'#351' t'#252'm bilgilerden genel arama yap'
        Align = alTop
        AllowAllUp = True
        Caption = 'Genel Arama'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 1
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -12
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        WordWrap = True
        Colors.ButtonColorFrom = 13080400
        Colors.ButtonColorTo = 13080400
        Colors.ButtonHotColorFrom = 3187534
        Colors.ButtonHotColorTo = 3113284
        Colors.ButtonSelectedColorFrom = clSilver
        Colors.ButtonSelectedColorTo = clSilver
        ParentStyleManager = False
        ImageIndex = 9
        Images = PNGImageList1
        OnClick = btnAramaClick
        ExplicitLeft = 10
        ExplicitTop = -4
        ExplicitWidth = 183
      end
      object PanelAktiviteGorev: TPanel
        Left = 1
        Top = 251
        Width = 228
        Height = 52
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 2
        object btnGorev: TJvNavPanelButton
          Left = 124
          Top = 1
          Width = 103
          Height = 50
          Hint = 'Sorumlusu oldu'#287'um veya verdi'#287'im g'#246'revler'
          Align = alClient
          AllowAllUp = True
          Caption = #304#351' Listesi'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 1
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -12
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          WordWrap = True
          Colors.ButtonColorFrom = 3113284
          Colors.ButtonColorTo = 3113284
          Colors.ButtonHotColorFrom = 3187534
          Colors.ButtonHotColorTo = 3113284
          Colors.ButtonSelectedColorFrom = clSilver
          Colors.ButtonSelectedColorTo = clSilver
          Colors.ButtonSeparatorColor = clSilver
          ParentStyleManager = False
          ImageIndex = 7
          Images = PNGImageList1
          OnClick = btnAramaClick
          ExplicitTop = -3
        end
        object btnAktivite: TJvNavPanelButton
          Left = 1
          Top = 1
          Width = 123
          Height = 50
          Hint = 'Sorumlusu oldu'#287'um aktivitelerim'
          Align = alLeft
          AllowAllUp = True
          Caption = 'Aktivitem'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 1
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -12
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          Visible = False
          WordWrap = True
          Colors.ButtonColorFrom = 3113284
          Colors.ButtonColorTo = 3113284
          Colors.ButtonHotColorFrom = 3187534
          Colors.ButtonHotColorTo = 3113284
          Colors.ButtonSelectedColorFrom = clSilver
          Colors.ButtonSelectedColorTo = clSilver
          Colors.ButtonSeparatorColor = clSilver
          ParentStyleManager = False
          ImageIndex = 5
          Images = PNGImageList1
          OnClick = btnAramaClick
          ExplicitLeft = -5
          ExplicitTop = -3
          ExplicitWidth = 100
        end
      end
      object PanelMesajDuyuru: TPanel
        Left = 1
        Top = 147
        Width = 228
        Height = 52
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 1
        object BtnDuyuru: TJvNavPanelButton
          Left = 112
          Top = 1
          Width = 115
          Height = 50
          Hint = 'Duyuru yay'#305'nla veya gelen yorumlar'#305' oku ve yorumla'
          Align = alRight
          AllowAllUp = True
          Caption = 'Duyuru'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 1
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -12
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          WordWrap = True
          Colors.ButtonColorFrom = 33023
          Colors.ButtonColorTo = 33023
          Colors.ButtonHotColorFrom = 3187534
          Colors.ButtonHotColorTo = 3113284
          Colors.ButtonSelectedColorFrom = clSilver
          Colors.ButtonSelectedColorTo = clSilver
          Colors.ButtonSeparatorColor = clSilver
          ParentStyleManager = False
          ImageIndex = 4
          Images = PNGImageList1
          OnClick = btnAramaClick
        end
        object BtnMesaj: TJvNavPanelButton
          Left = 1
          Top = 1
          Width = 111
          Height = 50
          Hint = 'Ba'#351'kas'#305'na mesaj yaz veya oku'
          Align = alClient
          AllowAllUp = True
          Caption = 'Mesaj'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 1
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -12
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          WordWrap = True
          Colors.ButtonColorFrom = 33023
          Colors.ButtonColorTo = 33023
          Colors.ButtonHotColorFrom = 3187534
          Colors.ButtonHotColorTo = 3113284
          Colors.ButtonSelectedColorFrom = clSilver
          Colors.ButtonSelectedColorTo = clSilver
          Colors.ButtonSeparatorColor = clSilver
          ParentStyleManager = False
          ImageIndex = 1
          Images = PNGImageList1
          OnClick = btnAramaClick
          ExplicitTop = 3
          ExplicitWidth = 100
        end
      end
      object PanelHaberPiyasa: TPanel
        Left = 1
        Top = 303
        Width = 228
        Height = 52
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 3
        object BtnKDR: TJvNavPanelButton
          Tag = 1
          Left = 1
          Top = 1
          Width = 226
          Height = 50
          Hint = 'G'#252'nl'#252'k haberler'
          Align = alClient
          AllowAllUp = True
          Caption = 'Karar Destek Raporlar'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 1
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -12
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          WordWrap = True
          Colors.ButtonColorFrom = 12743304
          Colors.ButtonColorTo = 12743304
          Colors.ButtonHotColorFrom = 3187534
          Colors.ButtonHotColorTo = 3113284
          Colors.ButtonSelectedColorFrom = clSilver
          Colors.ButtonSelectedColorTo = clSilver
          Colors.ButtonSeparatorColor = clSilver
          ParentStyleManager = False
          ImageIndex = 8
          Images = PNGImageList1
          OnClick = btnAramaClick
          ExplicitLeft = -1
          ExplicitTop = 16
          ExplicitWidth = 100
        end
      end
      object Panel20: TPanel
        Left = 1
        Top = 1
        Width = 228
        Height = 94
        Align = alTop
        ParentShowHint = False
        PopupMenu = PopHavaDurumu
        ShowHint = True
        TabOrder = 0
        OnDblClick = Panel20DblClick
        object pnlImage: TJvPanel
          Left = 98
          Top = 1
          Width = 129
          Height = 92
          Transparent = True
          OnPaint = pnlImagePaint
          Align = alClient
          ParentShowHint = False
          ShowHint = False
          TabOrder = 0
          OnDblClick = pnlImageDblClick
          object lblKullanici: TcxLabel
            Left = 2
            Top = 47
            AutoSize = False
            Caption = '........................................'
            ParentColor = False
            ParentFont = False
            Style.BorderColor = clWindowFrame
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            Height = 24
            Width = 96
          end
          object cxLabel1: TcxLabel
            Left = 3
            Top = 23
            Caption = 'Merhaba'
            ParentColor = False
            ParentFont = False
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
        end
        object ProfilResim: TcxImage
          AlignWithMargins = True
          Left = 4
          Top = 4
          Align = alLeft
          Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
          Properties.FitMode = ifmProportionalStretch
          Properties.GraphicClassName = 'TdxSmartImage'
          Properties.PopupMenuLayout.MenuItems = []
          Style.BorderColor = clBtnFace
          Style.Color = clBtnFace
          Style.Edges = []
          Style.LookAndFeel.Kind = lfFlat
          Style.LookAndFeel.NativeStyle = False
          Style.TransparentBorder = False
          StyleDisabled.BorderStyle = ebsNone
          StyleDisabled.LookAndFeel.Kind = lfFlat
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.BorderStyle = ebsNone
          StyleFocused.LookAndFeel.Kind = lfFlat
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.Kind = lfFlat
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.Kind = lfFlat
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 1
          Transparent = True
          OnClick = ProfilResimClick
          Height = 86
          Width = 91
        end
      end
      object KDRListe: TCategoryButtons
        Left = 1
        Top = 355
        Width = 228
        Height = 246
        Align = alClient
        ButtonFlow = cbfVertical
        ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boUsePlusMinus]
        Categories = <
          item
            Caption = 'Finans'
            Color = clWhite
            Collapsed = False
            GradientColor = clGray
            Items = <
              item
                Caption = 'Varl'#305'klar'
                Hint = '0'
                ImageIndex = 0
                OnClick = KDRListeCategories0Items0Click
              end
              item
                Caption = 'Nakit Ak'#305#351#305
                Hint = '1'
                OnClick = KDRListeCategories0Items1Click
              end
              item
                Caption = 'Grafikler'
                Hint = '2'
                OnClick = KDRListeCategories0Items2Click
              end>
          end
          item
            Caption = 'CRM'
            Color = 16053492
            Collapsed = False
            Items = <
              item
                Caption = 'Grafikler'
                OnClick = KDRListeCategories1Items0Click
              end>
          end
          item
            Caption = 'Teklif'
            Color = 16053492
            Collapsed = False
            Items = <
              item
                Caption = 'Grafikler'
                OnClick = KDRListeCategories2Items0Click
              end>
          end
          item
            Caption = 'Servis'
            Color = 15395839
            Collapsed = False
            Items = <
              item
                Caption = 'Grafikler'
                OnClick = KDRListeCategories3Items0Click
              end>
          end
          item
            Caption = 'Stok'
            Color = 15466474
            Collapsed = False
            Items = <
              item
                Caption = 'SMM / Br'#252't Kar'
                OnClick = KDRListeCategories4Items0Click
              end>
          end>
        HotButtonColor = 14525318
        RegularButtonColor = clSilver
        SelectedButtonColor = 12303291
        TabOrder = 4
        Visible = False
      end
      object PanelProje: TPanel
        Left = 1
        Top = 199
        Width = 228
        Height = 52
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 5
        object btnServis: TJvNavPanelButton
          Left = 118
          Top = 1
          Width = 109
          Height = 50
          Hint = 'Sorumlusu oldu'#287'um veya a'#351'amas'#305'nda bulundu'#287'um projeler'
          Align = alRight
          AllowAllUp = True
          Caption = 'Servisler'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 1
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -12
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          WordWrap = True
          Colors.ButtonColorFrom = 3113284
          Colors.ButtonColorTo = 3113284
          Colors.ButtonHotColorFrom = 3187534
          Colors.ButtonHotColorTo = 3113284
          Colors.ButtonSelectedColorFrom = clSilver
          Colors.ButtonSelectedColorTo = clSilver
          Colors.ButtonSeparatorColor = clSilver
          ParentStyleManager = False
          ImageIndex = 10
          Images = PNGImageList1
          OnClick = btnAramaClick
          ExplicitTop = 5
        end
        object BtnProje: TJvNavPanelButton
          Left = 1
          Top = 1
          Width = 123
          Height = 50
          Hint = 'Sorumlusu oldu'#287'um aktivitelerim'
          Align = alLeft
          AllowAllUp = True
          Caption = 'Projeler'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          GroupIndex = 1
          HotTrack = False
          HotTrackFont.Charset = TURKISH_CHARSET
          HotTrackFont.Color = clWindowText
          HotTrackFont.Height = -12
          HotTrackFont.Name = 'Trebuchet MS'
          HotTrackFont.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          WordWrap = True
          Colors.ButtonColorFrom = 3113284
          Colors.ButtonColorTo = 3113284
          Colors.ButtonHotColorFrom = 3187534
          Colors.ButtonHotColorTo = 3113284
          Colors.ButtonSelectedColorFrom = clSilver
          Colors.ButtonSelectedColorTo = clSilver
          Colors.ButtonSeparatorColor = clSilver
          ParentStyleManager = False
          ImageIndex = 6
          Images = PNGImageList1
          OnClick = btnAramaClick
          ExplicitLeft = -5
          ExplicitTop = -3
        end
      end
    end
  end
  object TabMesajKisiler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select R.ID,R.FIRMA'
      ' from REHBER R inner join KULLANICI K on R.ID=K.REHBERID'
      ''
      ' where GRUP=335 and R.DURUM=1 and K.DURUM=1 '
      ' and R.ID<>:PRID'
      ' order by  2'
      '')
    Left = 407
    Top = 400
  end
  object DtsMesajKisiler: TDataSource
    DataSet = TabMesajKisiler
    Left = 299
    Top = 414
  end
  object TabSK: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ' select top 10 M.MODULID,M.MODULADI from KULLANICI_ISLEM '
      'K inner join MODUL M on K.ISLEMID=M.MODULID'
      'where KULID=:PID order by SAY desc ')
    Left = 512
    Top = 160
  end
  object DtsSK: TDataSource
    DataSet = TabSK
    Left = 610
    Top = 148
  end
  object PmSagClick: TPopupMenu
    Left = 604
    Top = 55
  end
  object TabKosul: TFDQuery
    OnNewRecord = TabKosulNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM KOSULLAR '
      'WHERE DOKUMID = :DID ORDER BY ID')
    Left = 148
    Top = 472
  end
  object TabDokum: TFDQuery
    BeforePost = TabDokumBeforePost
    AfterScroll = TabDokumAfterScroll
    OnNewRecord = TabDokumNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM DOKUMLER D WHERE MODUL LIKE :M '
      ''
      'ORDER BY GRUBU,RAPORADI')
    Left = 76
    Top = 346
  end
  object DtsKosul: TDataSource
    DataSet = TabKosul
    Left = 199
    Top = 428
  end
  object TabArama: TFDQuery
    Connection = Tablo.FDCnn
    Left = 734
    Top = 123
  end
  object DtsArama: TDataSource
    DataSet = TabArama
    Left = 720
    Top = 181
  end
  object ChatTimer: TTimer
    Enabled = False
    OnTimer = ChatTimerTimer
    Left = 819
    Top = 123
  end
  object MesajMenu: TPopupMenu
    Left = 593
    Top = 269
    object KonusmaGecmisiMenu: TMenuItem
      Caption = 'Konu'#351'ma Ge'#231'mi'#351'ini G'#246'ster'
      OnClick = KonusmaGecmisiMenuClick
    end
  end
  object PopupMenuGrafik: TPopupMenu
    Left = 585
    Top = 337
    object KosullarMenu: TMenuItem
      Caption = 'Ko'#351'ullar'
      OnClick = KosullarMenuClick
    end
    object YenileMenu: TMenuItem
      Caption = 'Yenile'
      OnClick = YenileMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object DokumAyarlarMenu: TMenuItem
      Caption = 'Dokum Ayarlar'#305
      OnClick = DokumAyarlarMenuClick
    end
    object YeniDokumMenu: TMenuItem
      Caption = 'Yeni D'#246'k'#252'm'
      OnClick = DokumAyarlarMenuClick
    end
    object DokumuKopyalaMenu: TMenuItem
      Caption = 'D'#246'k'#252'm'#252' Kopyala'
      OnClick = DokumuKopyalaMenuClick
    end
    object DokumSilMenu: TMenuItem
      Caption = 'D'#246'k'#252'm Sil'
      OnClick = DokumSilMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object DokumKaydetMenu: TMenuItem
      Caption = 'D'#246'k'#252'm'#252' Kaydet'
      OnClick = DokumKaydetMenuClick
    end
  end
  object PNGImageList1: TPngImageList
    Height = 32
    Width = 32
    PngImages = <
      item
        Background = clWindow
        Name = 'PngImage0'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D6500446F20313820417567
          20323030352032323A33343A3036202B303130301AAFDF580000000774494D45
          07D303041428219AA79CFE000000097048597300000AF000000AF00142AC3498
          00000A8C4944415478DAC597797014551EC7BF3D3D3309B9333107B9869C2421
          1C22B2721B08B280802C8AC812757577D9B04164D7A082D6E205150849981C84
          432840310854A9B82BA5965A28A880C10592C931C924906420E498642699BB7B
          7FAF7B26C1B26AFFB5A94937EFF5FBBDCFFBDDCDE137BE38F667DFBEFDDBDD6E
          5781CBE5B1793CA25D1439070DD31D7640413FCE41E336362E8AA25D10381A13
          E8CE3B140AE97D9BDBCD49CF6C3DC729E9EEA6FF7376974BA079B55DA974389C
          4EDE26087E7685C2E6B05A794775F5867E0940A7ABDA356FDE9CC24993B2E170
          B8402070BB9D703ADD10040146633BEEBB2F92C63CD218C1D2DD038F47406F6F
          1F785E299DC537EF9B1B1C1C8442A1A2670FC91421B804B869DCE1726368C836
          505CBC3E4C02282DD5ED993F3FE71F0C80F683280AF46353220950A0A9C900AD
          36091CC7E644698E81711C8F5BB7DA111111057F7F3F695336C7DE61EB5A5A0C
          888F4F04AF504209356A2D5FC031A0C014CD0C14951E35EFDDBB215C02282BAB
          28CBC97978D3C48913A453D07AEF4618119498384E3A25DB588614094081CECE
          9B080B8B804AE5EF05C70880D1D88AB163E3E1C707E0A2F9DFB810B213179B1A
          F1CCDD2AD45DE8339757BC2003141757942F5C9853909D9D45006EAF109F209E
          009A4803C9B4B1F82BB8F67659032A95DA0B20CF31B8B6362362C72620441582
          B7DB9EC6E7BD9FC264B162A7EB387EFCD6683E78E8551960CF1EDDBEDCDCDCBF
          6567674A3664974F10CFF3686E6A467ACA7828E96D32251CE41FE46C04C0A1E3
          663BA2A2A2C013001B93CD80110DA4C667E1AC65378E76ED81A1DB86670DAF62
          D694B9F8EC8B5A7379F9261960D7AECAFD8B17E7FE3533335D3201B335533347
          0F0A3AC9AD66136A033FC697B74F63BE231FB9594BA0F4E3A12280CBFA36DCB1
          28303733042A75305CB49EAD65009DC62E74692EA3F2F666187A2DD882FD9816
          37136191E164F6F7CD3A5D810FA0FCF0F4E90FFC2931315E723CE65C4C808A1C
          C75FED8F72E356D4E22C2283C271B1760087E3CF20397B1C86EC2E3C71C686FA
          9B0358A769C2E65593101C16492238F821103FF57D8643C30568E8E9C5F3E26E
          2C495A8580B040D29087F63C6AAEA8D828031415551E993BF7A1671900D30013
          10C807E372DF5728EA7801CDC31DE81DF420664C2862229448EE9F8BD26987F0
          55A705EB8E74C1333884708D12FB160E226B7C06E056E3C2F0697CA9DC8F2E6B
          1FE60C3C8745014F224013208524D36C4DCD376402AF06DE79A7FCBD152B96FC
          31232D191CA98F10B0B361238EB51D40A7C509AD3D0D45B13AA883049C0E2A84
          71B0076B35AFA3BBAF00DBDEBD8028A709E6B11998A3F5C317CFA5E1BDEE4A34
          069FC20F8DADF06BCEC4F6D40A246424C0E972498ECC7C67F7EE7B34B06347E5
          FB8F2D5FBA36245E896F4C6751D5B60306F32D0C0C03DBE37663866736A6CD7E
          104A8A88EB033F60AF691DD9DD0C7353359AFFA3C6D75B34C83914003E4A89D5
          2BDE41ABF33C5A2809DDED75E2CDE16ACCFEDD3C444446D3E9DD5E07E529F28E
          9AABAABC61F8D65BE5A7D6AC7CFCF15DDC528A59250EFC78090F60162A261C44
          724232DA3A5BA11D478988FEF9717E38DF7F1A27FB5F4697C501EDF71B51F9DC
          CB38D1F921CE0E6F45AFB31F766B101EEDC987AA230493A74D414A3A45905245
          A7F778B33F479177DC5C59E9D5C0DB6F579E5AF5E8F2C7D7DF7C044D4E3D7E6F
          7D1EEB429FC1430B66432083D4D7D7219D84B038575254D476F8E3DDCE3D088C
          DD8F615B00FC9CD1D0DBAFA0C76EC5ADFA3F20DABC139FE605A2B7BB1DF1DA14
          A8E9501C399E92E760B73BC0FBF96367D1B1518037DED07DFCD49A55CB05CAD1
          FF35FE8C18FF28C427252292E29BA5D686867A024883E0E1304625A0E80711C5
          A76F6341CE16A4CFBA83C60E13BE6D3061A7A6189F5C9983CFEE7A303B750C74
          33FB11119F860EAB0237CD1E149FEFC5CFADFD289B3908FD65BDB96ADF261F40
          F9270B16CC5916171B05B3D942EAA228080A963C9685637373135252D2A0A077
          EB7B399C6A0FC4899AEFF0CDFA50149AF271DBD58FBF980B31EBFE19C8189F8C
          096FDE40EA8414D45E3522332B1126B30DDD2633C22382D0DFE7C0BA483D5477
          0CFD478EBDA1F102549E9B3F7FC6A28888702944E42C28FEA2A8A424A720808A
          5E557D108E7DDF8327C20CD8B02C1BD7AED653B1E1E11FEA8FD8B87804AA9538
          48F3470D41B8ABEF009C16A4C7283039CE0FBCCD0497C3868559FEB8F4D39DEE
          C387B7464B00AFBFAE3BB766CD638B6249032C95FA3221BB944AA5E403591999
          B8DA65C789261EEFD67C8FFAADB188D68E97B4131D3D167E645729C669CDF060
          1FCA3EAEC3B0A91E8BA6C660E2E407111C1A01BBC309F30095685E85C347CE75
          5755FD5D0678EDB58AAFD6AE5D96C372BA9488462EB9183534E831353B033B2E
          DA71E6A73E3C12D08E97574FA2741C48DA69A68A47259757788B106552F0B00D
          0DA04E5F8FD4D44C048784925CC15B413929179496BEDF5D5DBD5106D8B64DF7
          F5534FAD7C382A4A2369E0DE4B41B5BCA5F9063CA12978CFA0C6FE939770ED9F
          51884A48928A8FD1D882D8D838A9F160512217324E026270F1F15A2665A454B3
          43B1F992920FBA0F1EF402BCF28AEEBBA79F5E354BA309F7C6AAEF4540ADE4D1
          6EA8C3DEA61834F688988236FC6B7506044580642AA3D1401A4890AAA6BCF968
          1937189A9090A0954AB3AFC433B9EC575A7AB2FBC08151800B7979AB66464484
          C99D8E57104FEA0CA2AA9777E226ACEA707CFED1559CCA1BC2BCDCA552EBC604
          CBA76426507901E4AE88A5DBE6E6466A64922418760992637192E64A4B4F8C6A
          60CB16DDA5BCBC950F86840451AC9323B184C38BE8F484E2F80D272A3FD21333
          8FD0DE0694AF103071EA2CC939650003E2E212A44DD806BE968DA3A2D2DADAFA
          AB3906C0208F1FFF9A000A6480C2C28A2B3939F73F1011E24F2AA74E6688FA37
          672C3EB8DC0FC395368CF3EFC0626D2FD2A3796893D2282DA78E342B6D6D2DA4
          817112902FCDB28B35AACC3CCC07D8B3BCB98260641FA9AC3C33AA0102F87953
          FE93932BAE38F1B97E0041E1A138FFE32DC4723D7873710895E101644E9A4E6A
          F720282890750C724FCFC96A6676963B63EA7C05F984A33E304E0265BE2587B6
          DCEC96949CA43CE0037849777DC5EAE5D9CB3EB4414576BF7BFD1A0A73783CBF
          783282C3637083C22923638214E7A3B684B75F6CA053267BED2CFEA25F341818
          5C92F47C6F9FC9C019C091235E80CD9B2BF41BD6AFCCD8F6411DAEB55BF0E749
          7D987EFF6424A74D9036ABABBB2601C876C488B7B35063892831512B018CCEDD
          1B053E00F117FE5156766A54032FBEA86BCCCF5F9B2EBA8770DBD409856A0C62
          28B49414826C93EBA491ECEC8923C96414804763A31EC9C9A9DE581747C257CA
          1FA41D1605EC3DF9F42C3A44C914252535A3001B37EA5A0A0AD624B374CA71A3
          A7F025A21B37AE12C0949176CA37CF1C4F2F65BBD4110DB04CC83670BB45A98A
          C6C4C449CFF46146A5D84D5F48F2FDDCB94B04B04106D8B4A9BC2D3FFF492D13
          60B7B34F33F6E9E59216B14DDBDBDBA0D1444BB5DC4525DBE1609F5F0EE9136E
          80E576826442293788B48E96B85D6A7520F5530A2BC9B41216DD458B2028AC0A
          85601145DEAA562B4D25256BDE92005E7AA9FA3A2DD6D0CB165291954E60A593
          D2335BC859E8591AA3C5248CB7B067F95D362ED038AC046361F731636CC31D1D
          539D3535B9F71695FFFF75FC5B5EFF03E603C26CB0BCF0BA0000000049454E44
          AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage1'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D65004D6920323620466562
          20323030332031303A32363A3430202B30313030586F47FA0000000774494D45
          07D30306161A22475385D0000000097048597300000AF000000AF00142AC3498
          0000065A4944415478DAC5577B4C5367143F97DB17144A696B213C24A8482508
          894E0C0B88DB982E99B22D2C8A12FFF29F2D4BCCDCCCA266EACC22265627736A
          B2C4C5C4CDC98CC60720EA1C7333E06BC675803C040A222D0848CBB3A5F7B1F3
          DDCB2D6DA5E8E6745FF2E57EF7F6BBF7F73BE7FCBE734E29F89F07F52C9B8E1D
          BB2F9F3973C622978BCD6218269DE7F9A4F171361A800DE338007C364A516C1F
          3E6F6318BE96A2F86A992CF4566161A2E7B9080C0CF0A9EDEDF091C331B64A26
          630C11113428143250A96890C9680809012004C6C7015C2E0646473D30343402
          8F1F0FE2DAD51B1EAE3D6934C61ECCC9A11AFF1181C141DE68B5827968C85D64
          30001D1DAD4460DC8CBB795EDCC3B2223899642D1216EFC93EB71BC06EEF059B
          AD87512AD5C7349A98CF56AC08EB7F2A81EE6E3EB7B9D9F3537434171D1FAF44
          4BC50F32CC2498EF951022D7B13111547A261125A3B5B5131E3CB075C5C5CD59
          555060A8094AE0D1233EAFA9C95D9692225769B521828B09502028B912007225
          A02404BE1EF19D641F4D03381CC360B158460C8684FCA2A2C4AA2708F4F7F349
          B5B5E377D2D2E4515AADF858B2DAD7D5E4831E8F3809F054A0FE93C7F744778C
          8C0CC3EDDB771EC7C7A72C2A2A8A6BF32360B1F0E561619EB79392E47E2E97AC
          20E0E419B198803F1DD8973883DE64714D4157970DC3D17D79E3C6ACE55E0208
          9E8E82BBBB70A13244A91401A4D84A022B2DBDE65D4B31F68DB5EFFDD2A53913
          EFF2131E60913C0BC4B34E2705376E5CC75DCAEC4D9BB26A04029595035F2624
          283F379942BDD6FA5A3F3A0AC8BACF4F60BE020C7C6EC0A333E97ECE4B40AFA7
          500B2CB4B777415D5DDDB7BB77177C2010B870A1FF4A6A6AE41B8989B437AED2
          C7868727C311081828B660EE97088486024E0A1E3E1C85AAAA2B4D6673A14920
          70EE9CBD79F1E29864A311FC080C0D4D86A3A2E2DA13EE0EB65EB22447B03E90
          405818804E1782DEE4F07BE73DFBF6AD550804CE9EB5776466C6CC8C8999B4D6
          E110C9481FB5DBFBBC5692215938D55AAF3778C1398E15C2E0F1B0084E815A1D
          029D9D0C7ABD02F6EE5D4309044E9FEEFA73C182980CA331C49BD17C05E71BE3
          60F1F75F13EB396FFC0989F1710EE6CC51609665A0A78785B2B2F39E0307D689
          1E3875AAA3D46432AED6685441D57DF1E235BFEC163C0C3C646767FB807382FB
          E5721E525254D0D8388AB562042E5DBAD870F8F0FA5489C0873366A80FCF9EAD
          F7C63CF0E3DDDDFE2198CE333A5D94175C8C3F07C9C972E1BDFAFA31B05A5BE0
          DEBDDAFD070FAEFF4420505DCDC476773F6CCFCC4C944B4966AAF31D0814180E
          623DB19C004FC69E83840419683434DCBF3F82559308FA82472ED7A499CD2B9B
          BD99B0A262E0074C14457171915EF10523303589C9B84B6EC7BE00E2E365A87E
          0A85E7C22404988A6F9272FDB5D9FCFEC77EA9F8E64D3EB1B9B9F1AFCC4C9386
          1421721AA623E04F829F101E2B588CBF08594FAFA785DF3A3BDD58072874BF05
          1A1A1AAA552A53DEFEFD39AE27AA615515B7C6666B3A8E2428DFE2E33B496593
          0A1221C90BAEE2B16C7382D0424379C16272BE9C4EA278462075EBD60DEC0D6C
          BFC9E549EF9694BCE608DA0F54568E6CB0DBDBF66564A4C8D46AB95F38C820B9
          42BCE7271A14918074FCDC6E1E1318479A1AE1BEADAD056B4DAD075BB4AF5A5B
          A91D67CEBCE79EB62111F5E078ABA5A5FEBBF47453ACC1A0F38643A502149398
          A448A322251EB13CB31364798C713F2ABD0D67074B51F4B9C848E317DBB72FAD
          9D0A2B684F78F468DD3A954A716CFEFC64A104931111C10BAFD8ED2E2C28ADE8
          014AC8764470636344640E4C62031E9A56DEA5E950040EFF71CB96DC76986604
          2570E28433B6A7A7FE415E5E164DDA2D222C8D860052A8E47B98509ACE444468
          7F475510124891EA471176709CB17EE7CE8C6178C6316D577CE8D01F3FCF9D3B
          2B2F2A2A0AADF408C5442693C3E5CB3558A29977B66ECD3DFFAC40FF8AC0F1E3
          B6377B7BAD9772735FA548CB4DBA1ABD5E01E5E53524B7E76FDE9C5BF6420990
          6136D7941A0CE1ABD3D2D2D0EA31301A1570F5AA05FAFA06376CDBF6FA372F9C
          C09123ED1AABD5F2CBAC5989AFCC9B370FCF3A8747AB138F5663697171FE9A17
          4E808C9292BB914E67DFF70A05B5223D7D3EA5D56AE0E4C9D3F8CFC718B76BD7
          B2A7FEFD7A6E02D25EB3F9FA5A9BAD65874EA74B1E1C1C426F44AD2C2E5E5EFE
          B20808A3B0F057DA60B02EE3F99002B55AE7DCB327FFD3974AE0BF1E7F039B3C
          C65DD208FA900000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage2'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D650046722031392044657A
          20323030332030313A34333A3439202B303130300F84E1980000000774494D45
          07D30514173701B18CAECE000000097048597300000AF000000AF00142AC3498
          000005554944415478DAC5977B4C957518C7BFEFB9C13927452E220ACA2D590C
          D171D10CC1E5642B42E10F9A97D4D00CB69A335A2D73B5F98FB5956BAD5C4B9D
          5337B76AB99CCB346521161A6A936C080A0171448F1E2E07381C0E9C0BEFE9FB
          BCD5D61FAD305EEBD99E9DF77DCFF99DE7F37B7ECFED55F03F8B72BF0B366DDA
          54303A3AFAB5D7EB1D0F06838FD7D7D7DFF84F01366FDE5C131313F3BEDBED46
          7777F7EBE7CF9F7FE7410318AAAAAAA2028180A5AFAF6F283A3ABA74C68C195F
          4C4C4CA0ADADED437AE0A50701A0D0E8B37EBF7F6B381CCEA5DAA920841A0A85
          0623232363ED763B3A3B3B8F11608DEE00D5D5D5878D4663657272B2323030A0
          3DA3718C8F8F4376CEB3873CE7E7E5B367CF2ED51580679C69B3D95A0A0A0A94
          F6F67658AD56CC9B370FC3C3C3181A1AD294701AC0AD5BB75483C1907DFAF4E9
          56DD00366CD850949898F85D6666260607DD181B1B83D964E2CE55CD0B81801F
          6EF72042F4446F6F2F464646B69F3B776EAF6E00EBD6AD8BE50E5D252525C6AE
          CE4EC4CC49C7F4D878D8EDD3188E068CFB03F079DC7076FC846B4D4DE8EBEF3F
          74E1C285ADBA0188949797DF20C0233D8E6E3CF1DC9B082B06988C4050053C63
          2ABCAA1191632E1CFF6027DA3B3AAF5EB972255F5780D5AB57EFCFCDCDAD0EF8
          C75150B21ED1491930200C5F48C5885FC55848810501341CDE85868B8DDEA6A6
          A6682E0BE906505A5ABA312121E168FCCC99989FBD04694B9F423014843F18A6
          F130C80023E3A2EDD8DB3871F254989991DADCDCECD00DA0ACAC6C2EF3DDB170
          E142252A2A0A59E535080503A06D3016410E0C4F4440FD7E1F0E1F3922E9597C
          F3E6CD3ADD004456AC58F1F3A2458B1E362A2A1E5DFF0602A648ED396DA37B48
          8562894082E3143E7A77373C5EEF8B2C4A1FEB0A50545474203D3DBDCA68E0F5
          9AED50E3E64355C3B8E79BE02A03A6D92C983BD28CDDAF54331306F6F4F4F4BC
          A62B406161E1FAB8B8B84FA64F7B08990525184A5F8508930A9BD9085B8411F6
          483332AC1ED4AC2986F39EEBF8DDBB772B740558B66C5982C964724A394E4B4D
          81F5C99D301BC288341B608D30C04680F951C08EB52B71F5C76B4DEC8E79BA02
          88E4E5E55D6745CC321B15ACAA790FAAD98A285300E68017A36E275CBFB4E1E0
          FE7D68696D1DF0783C71BA03E4E4E4EC4D4B4BDBC601047313E7B01C87E072F5
          A29F7DC0C712ED1FF7332B54D0FDD77C3E5F8EEE002C46856C46DFB2341BA403
          B20DC36C366BDD9069AA754687C31166BF6861EB3E49D05D5C16D40D4084B560
          ADAAAA2F73105942E30AE34203904F7642D0F51A545757176EDFBEFD39973C43
          9DD00D4064CB962D47B9FB8DD282A5152B8AA201582C16ED5E84C671E9D22569
          D38778FB3C7E2B19FA007010DD939595F52AAB9DB6EBD9B36783330378EE90F8
          604BD67E27DEA8ADAD0D737690A2B46D32109302A8ACAC4CA0A1D6ECECEC68A7
          D30919C75823B47980812AB32152525220DF3536368A2704E22097BEF04FC731
          E9A9B8A2A2622D77FF6946468622A3D9AC59B32093B17880533238B08295533B
          92868606D4D5D5C9F4F499F05303530610292E2E3E101F1F5F959A9A0ABE1760
          F1E2C5329669B12019C17EA05D8B773A3A3A70E6CC19F4F7F7D772E9D3D49129
          032C5FBEDCCA73BF48B7E7CC64AB6676683121292999919F9F8F9696161052F3
          8804A5C4CD9D3B77EAB97C25FE2226EEFBC584D53185397F99DE889740144D4A
          4AD2D25082523C43831A905C4B5CF03B398258AA77CA00220B162C788CC5E71B
          8E6E3649C73F46761960C5A8A4240B94784186951FB8E42DEA97533E823F0B9B
          54195D7F8C9EB048208A41890797CB25BBBD4CFD8A7A82DAFE77FFF3AF014462
          63638BB9E31D3C120F6FAF531B7FD7E1C9FEC79400F4905F01ED4FA83F157086
          630000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage3'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D6500446F20313820417567
          20323030352032323A31373A3437202B303130308BC9D8D40000000774494D45
          07D3030415310935D0F72B000000097048597300000AF000000AF00142AC3498
          0000067E4944415478DAED977D6C55E51DC7BFCFCB39E7BE438B8502450B5241
          9D4E45A7711BC91030805916820E97450541987F08185434D315ABF305011312
          62F01D8C1AA06A1CDB18D6B12A84460B2C7241CAD65644D44AE9BDBDEFF79C7B
          CED9EF39EDB5B72D1D2CCBB298789227CF73EE3DF7F97E7EDFE7F77B9E7319FE
          CF17FB1EE03B033069F7984B449ADF20059FA24951A3095129858C50EF4A2112
          52E32725C4314DC88F8D0AD6F0465553DB7F0D507100E1E0E98A4524B04864D9
          C524C0680C12C599FAE258D7A51B28F7EDD774BE492BC3960DECBDDC7F06E082
          8DFE43681137B53A8D89516280C059213887D424B856C048B7FAB31F35D7AEBD
          65FEDB1B81079CB302546C9D1661CD0FBEC6AB9FBF498EAD67D2190EC9B54151
          4A257286E88BBDA36771717A3A7E766A05A4CF72BF8EC7FF5CB7F14FB7FE7DE7
          AAC4D000CB0F9597EBF99DD28E5C235900DA883D9097AC809039480407890F04
          F09A6470651E33BB57E0B2D46C58320DC6015DD3103D76BC69CB8B5B67347EF0
          6C6A30C01D8D223CACEC2FBA143768C2F126D684416234E9C43A88D1DB21DC08
          D9ABF7089540141B1736FC2288F9DD4F63943D0136374981D69354185104033E
          BCF9F6DEFA2756FF62DE20007D79EBFD219E7E4A12AD26D5E49C0018350D3AC2
          E065FBC127AD82344E931BA14110AE66A2CA998C5B936B6070032EB7C039F31A
          63CC8310F47CAEE0B8AB1ED878C7077FFBFDE63E80656DE7F90B89D680212294
          3B24DA2BDE0FC447D11B6017AC03AFDA42106102203768E68296C535F9B9F8B9
          B912AEC89292EB090B510AC03C39E5C273CFBFF3F98E77FF58D3D2B2CDEC0158
          F8D1F2E1C38CF53AFD4096880F06A112636188603BDC8BEE07573D41CC4DFF0E
          57393361CB0C18894B7ABE479CF7BA805E00950B12CD075AF0F8632FCC8B465F
          AAF73E1D7FDFA11DB1823347977D82FA9020CCCB0D8D0521C6BE8CDB43576324
          1B0F479A5E02F688736FAC001488125710CA0155D25F7774E1CE85B59B8F1EDD
          72BB0730EBA9B67FEEFD2A756140673D6245101A97429582309AE88AB0C0ECCA
          2C251BB9DE2B5E6C4A5881F45F065A5E4DA0FD7807962C7EFCD09123AF5EEE01
          DCB6E144C7BE8ED4C88469C39043087BAEF4DDBB14D2DCCA3C6A2294E5EA7B8D
          F703283A51042842E8BA869DBB3EC2D34FBEFA6534FAF2580FE097CF7EF6C579
          6163EC1B9F76226C887E420385B55E40974BDC3B214DC234B92A59AD08218676
          82D4C2E110EE5AFA0C0E47FFD1B67FFFA60B3D809FD61DDBB76EC684EBE6D41F
          855FEF89FE5BD1623E9438A3CA6E54C0C5C27139588C7BB696020C7443012807
          7C3E1D878F1CC7D2256B14D0FBCDCDCF4DF700E492E63507164F59B9AB2D8627
          9B4FA2DCAFF55B02BD247A05C3E8FEC765054CAD2850D9F544DC07D107A0C6C5
          DE20671D8761DECDB5482692C8E7CD5A0258DD5B86D16B9F98317ADF4FAAC26C
          675B1C9B8F7522E293FD9C28857069775C40D18FF451F26983C54B7B05100CEA
          EA7CC3E2C5EBF0C5890E58966D13CCA54D4DEB5BBEDD092F7AF844E32B378E9E
          DA95C9E3706716AFB7C74888C1DF2F29554F39A201F75653F64B7E86E87BC674
          247B51472201B4B67F85877FBB1989EE046CBB40D13BF57BF63C33AFFF5970D7
          892BEFB98A37CD9A58A677A52DE4F2363E3C95463463794BE1EF05506BFC8388
          8D3995A65709A511EBBAF72E406B2D11081848A672D8BEFD43ECFEEB416F1F50
          E2C9642AC958E8878D8D8FB60F3E0D7FD3BE6CEDD4F0FA712183C5B3164C2ACB
          54BE80561A77D82E7294F1AE90985F99C3C4306DB7B4ABA92A50A565181C3E43
          875928E0F8E7A770F0402B0E45DBE092A8E3D8349789743A43D68B5F3534D46D
          1DF27D802D6D7F6CF5B5FE87AA87FB588C9C48E72DE409244B8E64A8EFB468E3
          3A3F83804E11515DBB8E03D3A2E728DA53A7BB11EF8CC32A58B4CE66AFDD7914
          08AABB3B699B26BBBBA1A176D3D9DF88167C7AF72D357CEDF49A0A5F2C6D2295
          B390C911040124F20EA6942511D01CB8AEABB2D9135342AAA9488B6325ACFACE
          CEAE2ECBE20B76ED7AE4DD737B2553D7AF5B2E3F3F94DB386B62E8FAEAF2204B
          28105A8E58D6C61565290CD36DD88EEB090E1455F7B95C0EB158DC4E24D2DB5C
          D759B963C72327CFFD9DB0F4FB9B0FCE1E13B4964D1A21A68D1F11A6B344C7E4
          700223FC36AD2D285955D496279ECD66118FC748980C4F66B6017CC35B6FDDF7
          C9BF1738D76BE63B6360E667325D5E7FD3B8FCE4513EBBCA7539EDDCF637AE95
          3F9D4C65BE4CA79351C7B1F62512FEBDBB77AFCA9DCBB4DF9D3F26DF03FCAFAE
          7F0180808D3F6E8327750000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage5'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D6500446F203135204D6169
          20323030332031383A30333A3034202B30313030B7E0E7160000000774494D45
          07D3050F112A10A7C54E0C000000097048597300000B1200000B1201D2DD7EFC
          0000068B4944415478DAED57694C5457143EF7CDC22230ECBBA2522395228AB2
          6883DAD66A308851B06A9A5835124220B6684D0C6DD3FE50D2D41FB624565321
          316208D148BA606AD54A8256047105050D2EB81464DF419837AFDF79F0A6208C
          366D4DD3A63779B9336FEE3DE73BDF5947D03FBCC4FF005E86D05BB76E793436
          36AE952469B94EA70BC32B978181814A4747C75D73E7CE3DFED2003C7EFC38A2
          A9A929C3DEDE7E959B9B9BA1BFBFDFD2DCDCACB3582CE4E5E52575747490C160
          D83663C68C2FFF56000F1F3E7CABBDBD7D879393D31B8181819210C27CE5CA15
          71F9F265D1D7D727198D4681DF2CD1D1D1A2BBBB5BC6F705616161A57F0980A2
          28E2DAB56BF17ABD3ED3C5C5252A20208040B984F7E6D2D252AAACACD4810901
          6584330450BC2B5151510CF84C4C4CCCE23F05A0B6B6D6BEABAB6B2D2CDB0A6B
          43274E9C2846C8B1545555C9972E5DD2B3D500C094AB00100B2A081F1F1F6570
          70500113D3162E5C78770C80AED6C6E94D6D9D4916851CE1BB0659961BF8352E
          B9E0FB3C085E077F7A7B7A7A8E3100FE369F3B774E8780130838727070208D01
          060082F851DCDDDDA9A2A2227DF5EAD55FFF2E604BC32A6A6F49DE99E8F0E68E
          383FC3A04C64369B09C208CAC9CECE8E5C5D5D9FC798E5C2850BF4E0C103E1EC
          EC2C58393FCC005BCE00865D477E7E7E0A801E4C4C4CDC342470FDD54D92FD60
          CED6787FB17BB9FF1FF1BFBAB3606DB5B4B4C86565651C0662C2840956E5C356
          AB0F9FE7BB1E1E1ECAC58B174BE3E3E35F1F92B0F2448D14E83B5DCE0E63E964
          9615F502A7CFB36BA4523E33FC4EA9BE79D382F8905C4C261500D3CE00D8728D
          7EED2E7E5710C077972E5DFACAD09B65DFF54E9B1DE4707B6708F5F6CA564523
          95D9FA3C04D4AC149D2923936E4004789B887446522458AFD35BFDAF05212F04
          A782347DB264C912BFA137B1F9B7C3A282A65DFF229CDA3B07ADCA47A2B60582
          CFF475B4D086234DF443AD44B33C655AF99A81D687E9481660406FB032A1B980
          019C3F7FBE312E2ECE77484A4C412AC9837B7B8B9789DE7E0B2C1A728196BFB6
          5CC04BAFD7515BC3235AFD23914C7A6A83017D8AA0B4708936841B016288054D
          1603406628C5C5C5F7131212A65AA545BF7762DB87EFB8EF8E8D081466D9A2F9
          6A54D08D07C068D053ED9D3B149E2B518049A2AE1E3339391968B6B7A0BC2467
          1A20839A8A9A725EC828A5A8A8A862CD9A3551A3A4DDBC71FD93EE9EFE4FA158
          C794A17C325D36235F1566D453D1D91A5AB7AF9BC81D6739DD1CEC6843841DED
          497025B3308E712503387CF870614A4A4AD298BC46099D535F5F7F242828682A
          EA3B994C26E2C2C100C60361D00BE5D8C92ACAD8775F98E1EF7ED98EDC422751
          C9FB5EE4E56C4F3AC368009C31A8A254585898959E9EFEF1B885E5D4A9537B22
          23233FE0EE85B6AA16A34993268D2A265A0AF297BABABB425806C8D3DD958C76
          46D22103CCA05ED233FD76AAFFB50519CA1DB80C4198040085B600AC080D0DFD
          962D477B5541F08EBAAF1698912908FD0ADAB0E8E9E9E14AA9BA8C15B2DFB97A
          6A9F35C09C01A74F9F9651B802366EDCD8382E0094540F5C7E3273E64C1D0E52
          676727D779AAABABA32953A610D779666138551576556B6BABC00CA00260859C
          7ADA33B216C0004B7E7EFE2FC9C9C90B5497908D55525272353636369C15A3FB
          115B88D8E0A18382838355EB8697C282B9073003E803D606F46C35E4F47BF4E8
          119761C45F4ACE73011C3D7AF42B348B2D6C1D33C02078C7B86581D5E5FEFEFE
          312C9C5DE0EDED4D68C31CB0DC88AC7D80958EEC07E8A20AE43E41270D460DE8
          7D2E00A4C9AA458B161DE32C686B6BB302B877EF1EC7C40A0C219F41D02C2811
          BEBEBE0A1850871406C02E625768960F53AFF0FDB367CF6E45F0BD7824DBBF7F
          BF0FC6A65F232222248E0306C00FBB002C6422400FE2D8390099CC6D1A3B0F2B
          EACE00F861370D372285B3A8A0A0E07A4D4D4D647676F6E00B01E4E4E4BC8D18
          F8094127380E30C1A800B02BD5D5D5EDD82742992F06969F417320CE4AF0AD2A
          932B2833309C114A48480897DE5E30306FF3E6CD5523F5D80470E8D0A157C3C3
          C36F2013380304D7047605A29D60053AB5C5272323A3392F2F6F327E3B8E0C98
          3E7FFE7C09C14B00A58E6360469E33670E959797CB08BEC4D4D4D4A267F53C77
          263C70E0C02EA45A0A2C7587429E70B98A3D80AFB3D2D2D2BED1CEE5E6E69A50
          ACF642E15AC48D7A0EAC707C4AB0BC15CCBD0BBF9F1C4FC70B87D2ACAC2C09A3
          990F84D9436847666666ABADB3F0ED62B8E623B011F6F4E9D32E64D0F770C7E7
          DBB76FAFB775E7BFF9D7EC5F05E037B3D9034E9D8C7C690000000049454E44AE
          426082}
      end
      item
        Background = clWindow
        Name = 'PngImage5'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D6500536F20323820536570
          20323030332032333A34363A3538202B3031303040503DAE0000000774494D45
          07D3091C15312DD6CE742B000000097048597300000AF000000AF00142AC3498
          000009424944415478DADD960950146716C7FF3D3D33CC0CC388820301BC4004
          0F444519455C11F000E395F58ED9D294B14C9932258A079518F04041D45559F1
          027575B38A079E8986786EE2AA1810DD15C1C808C8310C3A883030D3DDD3FB66
          D81035EBEE96EBD6566D577DD3D35F77BFF7FBDEF77FEF3583FFF1C1FC5F0024
          271F52C8E5AA699CB565222F08C102CF696C22DF208A5CA1280A392E2EF5D9CB
          9625B4FC5700F6ECB931E6C993EA1D1246E812E0AF453B3767F08C04D68606D4
          D4D440AFAF8195E7F51A8DFAE3848479E7DF2A4066E6CDF90643557A586857B6
          639F3EA8115888124026052C561A661BA4F56528BB7505250F2A795757D7052B
          577EB2EBAD0090F318727E7AD2C401ACD1BD13BCDD000D59136CE49807383A37
          1084C942C3684163DE31E417FC5568DF5E33262969F9B7FF11807DCF5956717F
          50FFCE5DD8E0FE30FCE50AEEDDB886C52B56A08E9CB77040339DAD02401C8E68
          D4D698517E7E07CA2BAAF5466345E0A14387AD6F0C909A7A6236EDF9DE513363
          217155A0AEF836668D8DC192E47598347B369E359363B25C59568DD27B45081E
          1689268232DDC9C7F727F7411099593B766CFDC31B03AC5B77F444A0BFFB0455
          C870F4F5065819B07FCF3E6C4B4CC0E7197B11396E348A8B2AB06CF26878FA05
          2221F33824148A4A430B8A8FAC4595A1F6D8EEDDBB26BF31C0AA557FD48787FB
          7635770F45881668A239D109D8999C86137BD211366602F2AF7C8B2E3D83A11B
          3B0503A3C6412397A28A1E7C94938AE2FBC50F3233B37ABC314062E281BAF070
          7F372E4087DE24BE7ADA6FD21A144A206E7C2C4E641FC68891A3F1DEA72B111A
          390656DAED7694198FCD40D9A97414DD2DA8CDCCCAF2F805C08C1933587F7FFF
          9D7ABD3E561084831D3A7468673299EC0BCC964AA5035B5A5A4E6EDEBC79D6FE
          FD179706F5F270E583A2D183004C5CEBFB728AC2D19D19B892BD17AE9D7BE0B3
          DD0761A6B73912A307C115D75304680BF4A5FA077B32337F19810F3E98F9BE9B
          9BDBB6F2F2F2158064AB52A9BA6DB55AD51A8DA6A7D96C2E25A88E515151EA67
          CF644C075725E3163E019AF64A489856430CFD4858A0A8B0103EBE01903A2960
          253835CD49A83E94563CC3FDA349D0BED329372E2E6ED44B00DBB717FCE6CE9D
          B373ABAAF41A77775D5A4D4DCE3E5194ED7372923FE538F32296653A320C5BD9
          B76FDFA3BEBE41434A7F34F80F898D04EFD31B4AE90B96C456105E681D32FADF
          91565FDA08D4DD3C07DB93525C769AF47DF65CAFF09700D2D22E57F4E9D3CB47
          AD3681E3186CD8B01C7E7E7DD0BEBD3F2E5E4C47BF7E9FD4EAF5A73B4A24AAF2
          A953A738979494B8BFE3E102F7C113A1D2BA81B5FB161DFE61A31F090D156587
          0B0DBBF86A2BAAA02CCFC5E1BA01CD7FAAD3369AD67A46D3A377DA00366CB858
          317264844F703083F4F4ADD8B2652BF2F2F21017B7C861382B6B2F74BA50AC59
          93028BC586870F4B5055D9809E011E5004C540E1E109155148C9A29CC2CDD268
          2171D6913A1B2ACAA1A8B8840B4FFDC5FD853246943A3DC2EEE039E4F6721B40
          4ACA858AA8A8A13E21214EC8CDCD8542A1C0C081033165EA74641F3B8EE5F14B
          506BA84646C66E0406FA22FB480EAAAB6A71FD7A3EBC3C35E8D42B04BC360812
          17CA4B02B19173BEBE0696473761A92D468DAA9F987A5D0D9B4D64205394202B
          E423727BB50D60FDFADC8A8888A13E3A9DF295A4A31C2A3C09F88D2035B93B66
          6EDDBE8781C1BD5070EF476A38CD3877F60CEA8C35E8D05E0D676712252B0567
          69C1F3E78DD41778F8F61F6D5A7AC145D5CCD99C207716D164CCC19198CD64EA
          BB5700061380DA1172BB3AC4A7E56072E682D1E74398B01DC2A0A9602F1D00BB
          6336E5961A7AD29176DA42480647E14EFE6D141616A0A8A8188D8DCF1E938526
          B95C7E77F2CCB9E6E9BF6F1E556B327B42A6A2F7EACFE3C8D874BA5F48A3A20D
          60EDDA6F1E0F1FAEF31E3A54E3109258960766570428A1C1D04AF8715B08E03D
          C87E3B0DCCBD6BB06E7C80ADA907905BAEC497C963E0E2EE0E1909EE871F1EDA
          4243BBB33F17975B59B0D6CD014B91B50937703432F9EFCECB5ECA82E4E4738F
          C3C375DEC386B93A542C9A2A014311F0E411D813CBC14DDE4900BF86C8B62A5D
          5E7015D3B7DEC731A3373C8522C46A6F4380142D160ECDCD8D35324A83126690
          70D736D81B8CE38D4738191D0F51B84B17C53FF97D3102956161FDBD2222DC21
          08AD4EECCE24B9DBC0E624809B95095E37951A3E995A3F11ACAB17B4277BC088
          4EF4A00C33FB97236E6A109E35F190B10CCCD493C76CA2AF307B582432BCCBFC
          CE7AE6D4497BEEE7BDA8B03680356BBE360C1932401B19A905E9A635A7A9C048
          CE6E82343B1ED60F0F828F9801A7F5D3C15E390C4C588479D78DC8AA7C170247
          394715EF6C6247440FEDEF28C901F3F350A26F7418591EDB88CAFCE3FC812F8F
          D815CEFF4380D5ABCF1A74BA7EDA9123BD7E06B047A0E01CD86B87C045CE07DF
          7B30142933ECE104133402730FE762CEFCC518F62945D489855265C1F3434390
          FAB51909DB68FB943284050A5811D98CCB7F2EE4376EDA247BB5B1B501AC5AF5
          95212424483B60800F752F810044D28208DE2605432115A8A8DB0422932961E1
          4468DD182C5F3C1BA9C99FE362910DEF2FF98E1C2A3079B81447AFD91CC5DF2E
          FA23739A111014827DFB0FF0292929AF07484A3A63183428481B13D39944441D
          CE24C0C383A5AF5A0B3A7572425D1D672F22707191D25C23BA775763C1823948
          4A5C896EBE7E181B7F015F5DAA6CADBFF6EED4CC60DB47227A776B8711513188
          8F8FE7D3D2D25E0F909878C6D0AF5F6F6D68685702E060A62F5AB59AC1D3A71C
          F503164D4D82A3D3A8D53254579BA91ABA60E1C20F297249E8D6ADABC3143364
          7F6B3BE419C40E966361B488C8D1132023512C59B284DFB871E33F8BC0694370
          70A0363CBC3B39E3A88A0950A924046041BB7672C79C1D40A190C2686CA20868
          685573E9F32C193E3E3E0E1B17F2AA103DED14D8CE6A7CB34C8980BE83E0EDDD
          D971EFDF00B04720503B7EBC9F630B8C469E562EC18307F5707393C26068424B
          8B0552CA8CB2321382823CC8F9326A6229F0F2F26A331830F30CE68499316280
          277461BF6A9BFF97005F7C71EA2ACF0B01B5B506DE62E11B45D1F65C1499E7A4
          253A8B8D1209D3C030127B5E39E6E7CD8B0A494F5F3579F5EA55723F3F3F8768
          19A6D55C71D11DD2450F4A4785E3DA7E6FE9D2A51C6940FE5A803739A64C99B2
          C2D9D9F933722CB1D96C0E00FB90D0B06790E8682AAD8752A9DC979191F1F15B
          05781BC7DF00FD9EF94E4394EC0A0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage6'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002A744558744372656174696F6E2054696D6500446920322053657020
          323030332031373A31383A3438202B3031303077C3AC1D0000000774494D4507
          D30902130E30595D6ED0000000097048597300000B1200000B1201D2DD7EFC00
          0006A44944415478DAED567B685C551AFFDD3BEFF74C2633CDA4691EADA636B1
          44D318ACDA4DD5506D036A7D260A3E28824FACA01641B12E0AEA1FBACAA2BB2C
          442BB8CBD2A58860B1A0061F28ADB1A235ED346D34E9641E9DF7CC9DDC3B735F
          C7EFDE698BEC82766117117A660E67867BCEFD7EDFEFFBBEDF7738FCC6833B07
          E01C80DF1D00D6068F16C2B55071990A74E80C9C0E2C2A0C5FF0023E086451FB
          BF00609D70D167478161BBAD3B14B0B5FAC0DBE9B8A840298910F322AA45B9E2
          6678D5A9E2A5700A4B670D60E3C68DD6582C76B3C56259AB364742D7F503C160
          70667272526317606559C11EEB45B101EF482FC0D331490196EA80200155638A
          40B186744244AECA66622AAE8F663147AFB78C8E8EF62B8A7289A6692B68DA68
          1E3A70E0C0BFE8996A02181F1FDF35303070673A9D46BD5E07013056262B4A4E
          50B4F776C6F75D3334D6B3C27A7117514107887748F229E3E46899D6A2B10A40
          6909A5A28A29C997786DF5E51F38795C0FC62256AB95E3791EA150C8B471FCF8
          F1B70F1E3C789709606262E287F5EBD7F74C4F4F431004D066783C1E68644724
          8CDB3AD2D8DC4F7FDC6EC06527DC1A5023EFCB86D742732D182B85BF405390B1
          DBB1027F890DC3A529609A0A4992D06834D0D9D989E5CB97636A6A6A8100749B
          00B66EDDFAC78E8E8EA75B5A5AB07FFF7E964824767136FBA1F39C966DB198BF
          EFF5514A37BF1768F101210FD020EFF3B5A6F142937A14AB34E97749805A2570
          0DE07E773F66247D362535DEE2196BEBEAEA7A70DDBA7516320CB2F13CB1F094
          09606C6CCC41631FA11B31BC3F76EC183B7222B9EB606E7AD873DB9A3E744680
          2001089271BF0390B5A6D7A5D3007EE63D8191AB0D13638370CCA7119F387F60
          6F5F77D7F66834CACFCDCD21994C7E323B3B7B0D996E9CA9829191111FC5674F
          241219F5F97C584CA5915BF811CFF589B8AC8F0C7B8DE9041C3640A3C2131BCD
          D8576BCDF8532598394020D41AD14E39FAB9EAC0B3DE355876411F645144A954
          C2E2E2E247E572796BA160C4ECDFCA707878D8D6D6D6F68ACBE57AA0B5B5952B
          57059CC816D0ABA7F1E2157684DB2807780BCCE430AA40AC372BA062B04140CA
          CD443422F10CDF83AFDB56234AC0C56A15B55A8D91F13788FA47C994FC8B3AB0
          79CBD84DAAC5FA4624188880E994B53212991CAE8B96B163D00E9BD5204F3535
          004BA7CBB0C9C26B420BDE76F522E8F7C0CA18145D432295CA974E9E7C209FCB
          ED3E6B21FAB69B7BE2AFCB2F7A311EEE46D0B048401AAA8E4C3687DB23253CD2
          A3C2A2A8A7B4A08E37B36EFC0D9D7078FD30F44927E379A182C06C1CF7944B4F
          DEADE285B356C2AB46470775DE327983BD3C706DFD073CC956437047E0317130
          625F43BE90C71DAE0C823C30D96887D5E303D5BC39AAC498B83087FBF30B38D4
          793EF6CAF8AE5A2C6E2B160AD3BF0680DBB469D30EBBDDFEACC3EDB1DB5419FF
          38F92ED5BF0B7B94305ED7BBE0F085480899A945B2C64C4F6D4637A0552601CB
          244EE0D6E23C6EB12AE0A8581EEFFF0344AB1DA57C5E492593CFE472398309F6
          1F007A7B7B1D54866F050281719264549644E6887F2FBDE39C777B29F740C9FF
          3942784C5E85502472E62023C324DB50C8F88F54623BF92C3633094B941E792A
          949DF676A1B4EA3C8FD7E9E0AB948C0B0B0BBB3399CC9D74B4FE73003CF583DD
          244637CAB20C42598B27920F7F9A9BD58E046CBBBE0B2FE3F6B9BB60F1B7C06D
          61A6B73A1D2DD7964C0602C41028D9D829FA258AFDA595347AB345ACACC9F73C
          BC6A557199DF3F491516364A9174E65D2AC39B69BB6602181A1ADABE76EDDA97
          49863912093D9BCD4EFA834197C5EBBB32126E8D799C4E4E57485C8C3E418613
          9488A1F402C6C5149C4E27FEE96E47261C439880F004C3C813038E40FB25A99E
          6792382589E24992F7FBFAFBFBADF3F3F3387CF8F07692E7574D001B366C9819
          1C1CEC339A904193A1861CC7994DA952A910C594D13501B56C061BCA27306159
          C20009629D5CA67B80A9785FD579ECB505301D5A0647304482E938131E635037
          34FFF7F4F4804280783C7E8CD6DED30C7C443A7DD5E9CDC646E300196704289D
          2A95DEBFB790BCF806A73E14A376A053B6CBACA9478628EAA7A6400294213DFA
          94B37EF3F768743AE4766F71BBDDED246C9C9157C67BA9159BCE1D3D7AF46352
          C4AB4D00741768F57ABD0F513FE8A30D3A51931245718618F8B2582CC68D06FC
          2560AF38F14885E1318F1D512725A58533430F89A6D0309B6096B2E165EA977F
          BACD6C47E0E8BD6BE83D9752A82E2410ED0482A7501F2107FF4CCF73FFF595EC
          330292B56094A27289CAD061641E7D9334BFA2C71FDED1347CD6E3F777293D07
          E01C80FFF5F809A18F894E4F4D909A0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage7'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D6500446F203134204E6F76
          20323030322031363A34333A3036202B30313030DB0550ED0000000774494D45
          07D3080B100C0408F12084000000097048597300000AF000000AF00142AC3498
          000007BE4944415478DAC596095055D719C7FFF7DDFBF60728C88EBCB0088A0A
          2A1505C62881B44A26D5B424E9C49A8E6325D1199728D40D8516480C35245327
          EDC41A47DBC4AA31D2DA9A4CB58969C62DA252A1292EA92C3620CB139EEFF178
          CB5DFA9D7B896DD38274C8B467E67079F79E7BFFBF6F3D87C3FF7970A35974EC
          05E4F7F9512CF098210830EBF570E874683218611538440906DC8E09C3AFA615
          E3375F39C0FB5BF06AD73DACB30681339B010200894351B4FF0D06FA08FB8A02
          25310A7B62BE8355EAAFAF02E0C466ACE87661EFF85040940049D2448D46C064
          D4AE4C9C3C029E07FC5E203E0ACBE39EC6FE31037CBA12FC3901B7AC56C4F7F5
          0341661312E213A1A33706FD4EB8DCBD90E0434404D47BCC2B0CC6ED454B4130
          92B962C8630238B201594E0F3EF1FA80DC59B99899B3885C206ACE65FE2793AF
          5EAA436B6703268469B718846B004AD8387C6DF62A5C1913405D295675DCC54F
          EDB1F1786C4931E0F56BAB87020E990CD409387CAC02E1E1141A5E7BCF4B6198
          60C3F733D7E2CD31011CDD88CAF66E94AD5EB61AC67191B49214784103902919
          0201D5F7F517DEC11D47136C36CD031E0F101A841FCC5D8F1F8F156097C78D8D
          CB9E7F89C4C8F57ACA38C1A08148E40DD1A7666647FB9FF0E1B977C12A842526
          0B45A8191B7237E1D53101BCB506558941A1DBB28B4AB412305A088254784AF9
          00F9D9E726108290649C3CB5474DC4BBEE3BD09393426CF876FE161C1B13C0A9
          55A698826969EDC87A428BAEDE441E6000E4E70009FB07B52B836066BB7AB0EF
          BD7DB098204F8D447C7A293E1F13007D93C34F32FB90551842D1A58E63D4AC57
          867240F60F41783508571FEEB55EBC72BEEFB3130B7F881DA3111F114085F865
          66236273A7C314442B875A20F3B544162B0410189A2C27FAC960AEF335EEC9FA
          1746FCA6A2A4721C777D7400EF66BD0E5DC26A84C6D3CA2171F68A226B65A8E6
          805F6B91DD7FA56EE5F92EF7C485B74710CF9024293EEA655D6AEF36DDAE0703
          9CCA9E8FCFB9D3B06771AA202B4106C17A1C0B03136757914AF2CE9F071015B0
          738F373A86114FA14BE6BC9FB9175CB8E5CE13774517D1EFC6076E46CAA1CCD3
          E0E317605CB466394B383631B439B0A6D4DF46D6FB6AB86F9EDF348C38BD8CF9
          DF3BE89EF58B3F3497F006539BF446FA72BAF7D183010ECFB5A3DFFB09852112
          B6700DE28B4EC8AC1FEC84B7ADCB75694FFBE3F33E737D8C2FED84244E0984AF
          D79C1A48DEFC766395222B826034DF10F7CE5A49F73F1E39042F4FB2777428B5
          01BFB43826D9C4EB835835D8D4160C1D6B486EB45CF2E02FBFFF1BAB13457089
          8DE3A5C08ED9DDD2F1217181899FBEE68D5BF8D2E59D7E511A0F835511BCBDBF
          160F2DACA56767862FC3DA19398E3B9EE3BC451FA65344DC1CB0A3336F0D26BA
          1BC00506E00D4946B33312A9974FC0DC7A5C8D86FB6E003D37DD0AEF0C1C48F1
          4ACFA529CA4C874B9E94B2E1FCD6BBCEC129D05B20C8CE93E2A1C2DD247195E6
          EDFF08A0BC92627774E1B22DDA1CC6D391C7EBF4E146EF045C9C5F0193EC839F
          7237429071B5EE2CCEFAA2B033E40842E226A99BA5449D31A08F81C7E16998BD
          7367ED9CCA96C597AFB717813743E0E48BE2E1BCEA21F1B661AB40299B5CE734
          094B42228C90023244AF88EE66076E5A67C06D0C83BEA713C99326A3E29A1D07
          1D5310494D6F5BDA158830506756F76BE80212CEF08B7AEA6E59C2C1C9D4428C
          AD725D7E2914A989160CDF07941DC9699D4E348525D874E0E89C25731A844FC4
          408F07DE7B3E12E1604DCBC2F48F9E82C34F1B94A2C73333DBB1E1A9E9700E88
          D0F31C3CDE0016D67AB5E3924E8F6F19F78AC78E1EC92189FA7FD6FB3700DFBA
          A40A87C0970793F59C5A710A4451812C1204814801858E5E6451F434ECEB9B88
          1F35E4D23DB63FD011AE221C05B933D5AE9DFA7C3D6EB4B8596A6273A11BDD4D
          BF55F61D3848B4E4A89100FA5726FCD1176678D86011D47A67252FD31FD9AFA8
          00A25F9B426C3AF6F6C5E0D1A21598B78E3C6AE461B6F8E03A948D9AF73DD8BA
          BB19747E46CE64095B1E19C48586EB72F58B2FF25FD6FB17003A41E8962C8DEB
          09B1DB4299E51CEB7C6AC92BEA9498387942F211C0C40CBCE188C6DAD2127CD8
          2C6369C9191234A168BE80A3E76475DFA0A4C73BCB07913A3D13878F1C952B2A
          2A4606E87C3224B43360EB8D4AB672AAF5ECA93CD4FA69039298380B07F3803D
          037BC803C5EB4B90909884C74A3FC07BA76943B2E8B5763DC861F74A05531342
          9097BF08DBB76F97ABAAAA460668298C48EDE574D72212AD94F90A04938EC415
          75AA5E1015158025A5F1A10CFCDC198BE7366E4242C243EAA7B8EC035A831239
          14CE35606D818247BEB1187A4A8AB2B232B9BABA7A6480AE472327B704A44F83
          622CBA9ED601D83382D504542468109206C012D29830036F0EC461CDE632C4C5
          C5A9EF7F50DF8182A78FD3D661C3C94D66A4A6CF462C1D6AD91815001BB71784
          2DBB794F7C9D8EB941715383EF9F41598351C8F20041B0AB313103FBFDF158B7
          B51C313131F7DF4F7DE677589EE341DEAC28CCC979F8FEFD5103B0D196618DEE
          826E2375D66779231F6EB0F230516C05232DE7B5C4B44D9983FDEE08AC585F8A
          A4A424DC4F5AD6659A1B292F52A81C4D5A6FA167E5E5E5526565A5302A802FC6
          5BD44682134DD974D6CFA5C44B0F884A22B97F02B55C6BD2D267CD8D14F05B66
          B35962654A2A04A0703A9DCCAEB25AC2FFD8182D16CBD99A9A9AFCFF0AE07F31
          FE0ED1687E4E282AA82B0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage8'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D6500536F2031342044657A
          20323030332032303A34363A3233202B3031303066442EDE0000000774494D45
          07D30A061414214E4D4FFB000000097048597300000AF000000AF00142AC3498
          0000062B4944415478DAED565B4C9377143F5F2BE55AA0E00A42011507054B08
          891A249A48B28C6C8997647B204BD8DC7C583031612633DB83DB78E065C932F7
          224F5B7C702C2626327DE012F032109D5840285028722D6DB9585AA017E86DBF
          F3B730B6E8F0B2CC64F14B4EFAFFFEDFE9FFFCCEEF77CEF93E895EF125BD06F0
          BF02D0DDDD9D79EBD6AD475555551EDC06FF1300D7AE5D8B53A954EFB9DDEEE3
          7EBFFFA0DD6EEF1D1C1CFCA2A6A6A6038FDD9B01795100526F6F6FC9CCCCCCC7
          CBCBCBEF6B349A845DBB7651626222D96C36BA71E3861FCF7E061BDFD6D7D73F
          84FF2A2CF4D20040713A32ACF0F97C1F4644446873737325B55A4D232326723A
          1D54505048B1B1B1C2F7EEDDBBD4D9D9B900FFF3972E5D3A0F56E6B0EDFF3B90
          4D015CBD7A3512871E46D0E31E8FE76D641AA1D5E6D2E2A293A6A62648921408
          AEA0830773853F64A05028847D89161616E8E6CD9B3430306002235FD5D6D636
          C0651916D814C0BD7BF78A80FEB8D3E92C4F4D4D55EB74BB2929494546E320F9
          7C5E5A5D8DC6DA05BF87E4727968CB16894E9F2E23B53A0A99DFA7B4B454D268
          D270928CC6C626A8A5A525383D3DFDD3C58B176BE6E7E72D6159FE0AA0BDBD3D
          796565E5032E28DC1669B55A89B5B5D9AC64368F5354541C391C3108308D3D3B
          05027EF27A572935554945456A3C5F42E621CACFCF27B73B447ABD053EAB545C
          9C46C160881A1A1AE9C183074D757575552E976B0C3156D60140DFDA8989898F
          906D34B4A5848404DE2314190ECCC5DA451D1D63081000CD3EF2787C9493F306
          E9744A1CFE080C449256FB26D9ED7EEAE9B192C5B2003F37FC5C60CB45870EE5
          935219498D8D4D2CCBF9E6E6E6EF11767C1DC0E5CB97ABE572F9D963C78E893D
          D6116C20ABA87586AE5C31D0FDFB53B4776F06EDD82183F6168A8F4F26662914
          0AD2F5EB93606A1E6B96C80D765C30B7B0C5C5453A702047C8DFD4D43C0E29CE
          E0A65504BB70E1C20F93939327D2D3D363516874F4E851E8A779626D0C0E0E90
          D53A058D35949DCD192F50575717C96412EDDE9D47B76F8FD2D09019205690C0
          9F20DCEE6530E2A53D7B72D021BF8FA0337EC4717502407575F567C8F8BBE2E2
          62292E2E0E87DCA6C2C2422A2B2B5B0FDCD7D747000939F22833338B50D542A2
          D1D1514810A48C8C0C48A02585420EDF71CC023D40F8C2005C90C20D402EFC77
          6BA8A5A5B56E7878B817C7FE229D3B77EEECD2D2D2D71822728BC582824A453F
          17507F7F3F50BBA9B2B212DA29C55A269311FBA090C42F07CECCCCA4BCBC3C04
          F18A21C4B22526C693C1F090DADABAE1E315D90783ABD88F099A4CC3F5E8301B
          8237C1DAA453A74E7D890035C85CCAC9C9017D43A0D50E9DF78A0264202C4949
          49090128DDB97307836784B2B2B244E0402020C0B0740C928DD72A5502AAFE37
          9A9B9BC370DAC2DA8FB4B5B577CCCECE3A794E71D3C12CD2C993277F45F023D0
          1F83654A64CFD9E8F57A14DA0EE249C72098E28A8A0ACC001F8ACF29B2E78C39
          20FBAF05467B09E03C887A7BFBB955178DC681464C421764E6B1DC0933C06679
          6E49F1F1F1EAD2D2D26F40E5A7D9D9D9B2F1F17114589A28428C524129338321
          82CA5E1592A05B44665C071C742D3083E05F64C92CF2E0694522169CC194F7C0
          587733CCB5360DB90815B0CCFDFBF79703C0190C11254BC019F040191B1B13C6
          0C71F6986204D9C4C8C5DC10F76BF4F3FF1828F6FA51A07A87C3B114CEB61B36
          0A73C07C4F7A1744C05200E02D9D4E7776272E8542216639EBCC871B8D468A8E
          8E16C09895F2F272F19CC1716DB07CC8DC0EBF26AC3DA0DB8433F5B02118BF88
          BC4F7A236E1CC572980ADDB067DFBE7D9FA7A4A4946EDBB64DB25AAD428EC8C8
          48D1723CA01810D70A770C770440F8E1D78C5A9903339670C64C37AFDD1B5F3E
          FF0460ED3E0E960B109F2425259DD8BE7DBB8203B2EE3C23B8F0B8E8B8352149
          C86C36F7180C863EB0E008D3DD059B08D3EDDFEC6D2B3D652F12A64131BE8376
          AB4C4E4ECEC3578F6839D69EBB00BACF984CA65664CE05351CA6DB14A6FBA91F
          20CF0260EDE2E6DD8ACC0B20C161807817EF859D31313121145A03E6C53C5A71
          2A9C711FCC46CFF009F63C00F892C16260E9301DEA201F2CA8FCFC3A7C5C5CDD
          61BA179F85EE1701B0910D254C458F6B848BEA116CE179E87E19001BFDE5E175
          E06502BF28807FFD7A0DE09503F8030FC395B46427A6080000000049454E44AE
          426082}
      end
      item
        Background = clWindow
        Name = 'PngImage9'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D6500446920313620417567
          20323030352031333A35373A3530202B30313030D18698470000000774494D45
          07D3030415160708AD6849000000097048597300000AF000000AF00142AC3498
          0000072B4944415478DAC597796C14F715C7DF6F6676660FAFD7E72E1863C06B
          C038212431C621754A69509D1492265688ABA8ADDAB4426E545000953A525284
          1A0737B11361C80175141C8EB8E694088534B603711A686D033E30A4BEF0417C
          AEF1AEBD3B333B33BF5FDFAEDD46FDA3124B8DF2B4A359CD8CE6FB79DFF77E6F
          66087CCB41FED78903070E9844517C5A0B06F3744DCB92153951D33443D3F461
          4DD72FAAAA5A65B158CE6CDBB68DCE38C0952B571EEFEBED2DEBEEEA5C201B4C
          B624CCF60BF65883114274DF381718EA8BD226BD92C6E0AACD662B282C2CBC38
          6300CD4D4DAFB4B4346FEF1EF1F8EFCB7D6A2871DE3C45D3196806254A9091A0
          4E886230CED7D7659BBC541DE7B9D9234856DBC6EDDBB7FFE9FF06C0CC0B2F37
          D4BFA6C6BA8672F39E98140CE029A5049D079F06C1314537FC41C6648D115507
          E267024F5B3E4BE8BBF8D768C16CFD795151D1C13B06B8D4D8F8F057D7AE9D1F
          93ECA34F3EF3A40C3A2512018152CC9A113DA019EC960A41AFAC1B931A05BF62
          849C200A9338E9ABF3CEABB5270522880F949595B5DF11404D75F5975F365D5D
          FAF4A64D03566A88B13CB15A384E54180D0EA9D4AB52C6824832183054394889
          AC1A9C8C90AACE789522C4850F93DB9A2F9F7A6FDFBE672206387DFA74766F57
          C785D89CB55D4B17CDE762042245F360E139E018033A8000BE20533171E209E8
          C6846280A22104F685AC504E127813F18D58DB3E2A890B5248DBBB776F4F4400
          870F1D2AEEFD7AF0C565CF6FE94811759B5D0031743C5A2016AC80D1A7B0312C
          010D1A06F1A2250154C18D289AC1851A33DA2C88FD938445D7BD93D274B56D53
          45C5876F4704F07E79F9A76360CE74AFCD1F48110D8B5DE00419389523D88006
          3150D350513488194F2894297A481C7B23E402EE63245E1A56088BEFAC76D5FD
          E5F8E183070FFD322280B7F7EC6E51E2E7BBE6AEFCC1689C68087192600A3230
          28FE740A9839630AEE159512FC0F1A0A6325C2D9CB3A232E0B02C800499ED6D8
          3315BBEB2AABAA7E181140D9AEB75A34D7C259AE158F8E3A788363002CCA4478
          8E2380F7A70AAACA461804B470E3859B0F1D60C4AF53CE1D6DB2F44E8031D7DB
          167BAAFCCDBAAAA34723032879E3F54F685C7276624EDEA00934C0E60384A0FC
          F41AC139845E50A21B101E483A8A2B210023B401776FAC686D1831B4252375CE
          93873E3878FCC4895F4504B073E7CE57710DFF367AED6F6EF04680891C213876
          FF33E319C34EA40C47039B8698120FF581D3CC4B311231358C407051EBFE39D5
          9F7FF1EB63C78EED8BCC8192924C65D25B6F59F5939B428C4BE60195783C8999
          13BC8219532E4C01604D102D547B3CCFDFEB922CFF1CD1F4D46862FEF8B502BB
          6AB0D423478EDC8C08201445AFFEE1BC149DB0C278E417FDBC1608DFFD1B07B0
          04E842E848509F72010FF219F1A2194734B48E52FD61CF27AE8AFD1527CF9C3D
          FBECED8AFF170096E141DF2DCF05D7F23501EF821C0FAF2B616D142210EE8110
          C494FDB168794AB428FAB00E8D43547B6ED65842F1EF5E303BE212BC0E87E3A7
          C9C9C94F4DFAFD6FFEB1B8B8EDB60142B163C78E1754BFAF6C76F6631383AEEC
          5B26A2E344A2047B00789E10B3C0F10E118B83FEF4F9343A2C7374BD732CBEF4
          E58D96DCC7D74194DD0EE3E3E32CCEE9224D0D7FDF5552FAD68B110184E2A597
          0A37C913BED717DE9FA5CAA98F28832441167946041C4A0CB30FE02AF5A3152B
          9DBC39A6E773F3BB7BCA6C6B721FE3366CD800EDEDED08E1805327FE0CDFFB78
          A73FD33BF923D20C3511018462CB962DDFF179C777DB6D96C5698BD283E6A474
          D514EF52F0714779D96352FBAF49B5E7CE8943239E565B943D76F5EAD5196EB7
          1B727373A1B2F2302CB9B11766FB7C10D5DA275B073C79A401CE4604301D5C41
          41C11A39E0CFD3756DB9AEE94E4A0D8673E06BAC48BD244955185FE4E7E7CF42
          F1EBEBD7E73BAE777440BA51058B1239B00EF9007AC6001A3B14E81E799634C2
          A948016E2B366FDEFCE3F48C8C8F7C0115568C1E85CCEF2681CDE900F0AB0037
          4600FA4611A25385CEE1E710E2F88C036CDDBAD545256BD9AABFED5FFDC03D96
          C4E4CC05C02D4902B048382C82E8C2E834449706DD833F23FF80CA1905F877B0
          0CB8C79360AB89CF71BBC03D1B60316E3633E08B03424C3B71A95B878E81E749
          3D1C98718030C40A58020E5B3564A625419A0B21D089288450B56F9C68B8A69F
          87FB8A8FCEC93AB2A7F48DE619050843DC0F8B21CEFA2964A5CD85542740FA1C
          7CB3B1844628420C406BB7156AE2D6C150D7F54E1C7E69330E1086C88234B09B
          AB6179DA3C70879C40881811C6034970C9780202BE6176AEB6F695D2D2D2A2BB
          0230ED442AC4986B60B97B3EA43961387921049615814564F0DEBBEFB0FEFEFE
          EF9797979FBB6B00618895900226A1D6F3E052F7D9875E8655390FC189E3C760
          626202BABBBBD721C0E9BB0A1086C802F78EDCDFB72FCBCE2297EBEB99C96422
          C3C3C375F895F7287E4368771DA068D71E6EA8A7EB331E3F2B7C3EDF469EE7A3
          707FB9B2B232F4509FD9657827F12F3CC2D54E9F3858AD0000000049454E44AE
          426082}
      end
      item
        Background = clWindow
        Name = 'PngImage10'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F4000007824944415478DAC5977954D45514C7EF8F591C056158B44010195311
          4B7229334D04517687A08E9551340287252C714C3405D3224A21647108482191
          102B4D4591D2C9251637109CC18D102450603024C29CADFB667EC31969D8EA8F
          DE39DFF39B79EFCDDCCFBBEFBEFBEE8F82FFB951F4733C2A7B75F46A484D4B7D
          173FB7A31EFE9B3FF4F5F5753635354D7D3BF8EDF952895425128996DDB871A3
          1A87BA51EA81004A6B6A6A96DE69BC03274A4F74204400F655A17A0CFD68A0E6
          E7E7173A7DFAF45DB1B1B14C342C4F4949D9D5DEDE5E8143E5A86694D2204060
          406085E01DC13C6F5F6F3876F4181C2F39DE999E91EE874335A83F86697C8ABD
          BD7DCDB68FB771EEDDBB075E9E5E671B1A1A88E193A88B3E3E3E4EC5C5C595F8
          59A50FA2F3C0245F1FDFE311E1118E04629D701DEC48DAF11DF6C7A36EA0E4C3
          70FDC6050B167CB26AD52A282B2B5307040414A854AAA33824F6F6F6B645B873
          D8026B6B6B2F609F8C06E9031883729C3A65EAA75C33EEB29CDD3990BB275795
          FC457206F66F47B5A2148301A091CFFDFDFDD7A1A0BEBE1E4243437FB979F3E6
          565757571B8C8994A8A828B3F0F0F09D757575F938BD16F5973E800EC2812C66
          CEAC39717BF2F68CC9CBCD53272527A5605F32EAEE6010EEEEEEA1212121596E
          6E6EF0E8D123686E6E86CACA4A30363686458B16016E07040505ED6D6B6B2300
          BFD0F1F51800696CD09E081F84484208631A2215FB760C06811ED89D9595F50E
          F9AC542A81C964C2E8D1A335EAE9E981C8C8C8AEA2A2A23C1CFE1675DE9007F4
          E3C202C54788543D08B21D9F1BDA0E0CC00C5C7DA4A5A5A5E6FBE4C993FBC6D0
          EDC066B3FF2C292939DDDDDD5D8A5DC5A8FAFE31D0BF19A1CC09042A158FA80E
          4284DF13F52174C6EDECECE0DAF56B30F39999D0D5D5A5DEB469D30306836184
          2E6F91482417D02B5771FA197AFFFB4ED640000621BECEFB9A9C0E1D448B4020
          C8C5A05B696B6BABD9731E8F0763CD2CC07FB9CFEDAAAAAAB3A03DFBF7E9A704
          D5401B570F0760304F64BAB8B818A7A7A7BF656E6E0E972F5F0627272760734C
          80EFE7D588C6C9D92709886440196DB44BB7EFFDF77BA86610A2F56E2BB57EFD
          7A4DC45B5B3F891BCAD2375E86221E68346474A4008F4118191965565757B3C8
          76B4B5B78150280453AE15BCCCF719B1F191006820962C5992BDD86DB1203121
          11CACBCB81403C33FE1224E7B7B65CA9BDF6236D78D8C6470440A23DE1B38448
          EBF1D6B0AF601F6CDCB0116EFFB402ACECCDA0745FC61FAF6D95EFBCDFAD3E80
          53AFC3086ED2610110E389DB13239DA639C1C58B17C1C1C1014EED5D0FAF3EBB
          4F3BC1A509E427272A4AAB9E38F1D591E6988367954DB40786BC498704D0372E
          BD2E05F26CEF6807D7C5AECD2F584894390960AF18BB10980EEE78C233A05232
          B6E35C75538C50A438823F7F0074C2F95700FAC6659D32B0B4B0D43C97BA2F25
          012726EE96E48E0AB6E72AA619BFF401E6CF15A0941543BD384B7EBAA2656B58
          923C1BB4C750316280218CEBA2BD42B486F55CF872C69E9E2E3918CF5A093031
          4603D15B7F5C79E887CA9D4109727291DD1B08A20F80CFE7B3F1FE8EB5B2B45A
          3961C204163F903F69EEACB9D420C675D1CEDE1504A51102CE0BC035432F78F4
          41745E4883B31764398171F26DA04DDF728300B85A1E4551DF6D8EDFFC2C6F12
          0F2C2C2C1E9B34887112688CE800C673B3CD9525C16F72CC341036A10026B6A0
          EC9541D3994370AABC3A3D64BB9CD4152DFD3D419195ABD5EAAB711FC54D9939
          6326B0582C78F8507B8A381C8EE6397BF6ECA192CC98EDE1CCD76D548ACC375E
          E730FB3C61F5A206A2417C5075ECCC951DEFA5C9D3A0DF954E6129E513161176
          74E1FC85F0EBED5F81C164C00CC7199A3B9D00605109CECECE3FB7B6B61EC4F9
          E43A6D807F2619E249F38CF759119E53E41FF19C380C7D0818C5068948A0D85B
          C6DCF0D9370A5290B4E94E0785854474D4EAA854E955A922539429696C6CAC43
          83D33332339CE7CD9D0762B118A2A3A32BF14A25B50089FCFB03C42D49D7E3B2
          D6B2DE5BC2937FD00761F3269638B198114E4142F08ADE8A3B96D147C4B24338
          B713A5A6B0940AE4BFCCFF664BDC9622994C46C82E6161A1C8CFCF2FF4F4F484
          828202888F8F3F7DEBD6ADD421004863A2C6670B59EFDB8D910B3D5C391498E2
          364EC3ED37F6D7401C4814DEFFF2DBDF04272FAB7EC6B95D14DEE1E34C4C4C56
          E22DD78B1D248355797878F81716168AB85C2EAC15AE55676765EFC76A86A43D
          52503C80C11B8178226D35EB5D9E995CE8ED863141206C8311ED4380DF77C39A
          B0B49A9403CD21384F42E9A8515C54076E890D5E3A15313131A3F61FD80F719B
          E224F86643B2DAF7A07D4F18CE25A381D8266006BBD82BE25F5AC4616920781B
          D08A35488BD6C0A739BF27E4FFA8CCA1E80062107979794DC2FAAD3C222A825B
          545874F7F0E1C3573A3A3AEA70EC1C7D02484219EE9B12811817E6CBF0F7785A
          FD498007DB5C03F1E0219CBFCE82D2F3BDA59B772B3EA60CFC68026A3E6A2A68
          DFE7C8AAA5A07D5F540CD3B8AE918559384EA4E6D999AAB744BF027348E7E10A
          B8754E4A89AF35A90BFB0390EF63E92D214980D4EE1DF4533502C3FACD88FECF
          A796CE35F278DED1E845D10FCAFACE6EF525EC2B1F4941F25F1AB1338A5E982D
          ED6952A8B6FE0D9DC85E27C1E2D8A40000000049454E44AE426082}
      end>
    Left = 730
    Top = 242
  end
  object PngImageList2: TPngImageList
    PngImages = <
      item
        Background = clWindow
        Name = 'PngImage0'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D30A06140B15A2A3B5D0000000097048597300000B1100000B11017F645F9100
          0002B84944415478DA8D936D4814511486DFD90F6D5D7605D3C84A282DF3571A
          2C9691156125964810461926F4A32011334D0B2CB0C4142DD30C69250321A52C
          96A22C75C11003ED4728B6F995AE296AAEFBA9BB39FBD99969160DFCE1858739
          F7DEF3BE33F7CCB90CD631FAAAD1617620C9EB0538A667D074B91E05B46562D6
          A167B415B027661B65525908BFF0F60E83B4125CA0B0632D0366408D83260B92
          28DEE772214C220B8D3D926B10FB130483720A1BFE33E8ADC1B064E3DEE80079
          38822312101A998A00C52688C572DAB513CB441834C50A9CBE871A9A3CF11BF0
          CFAE2A780FE7D9E05ED6C1619982DDA803BB380FF89C70BB9DD899984F59A178
          7D2B1C67CA504B933AA6FBA1C805A952BC252E87D17F29C1FE4BDDB09BDA20DD
          20874CA140605010556E197323FD08893C8600791C5E154523BD5C30E8AC602C
          87AEF6064B8376A3B33C18498563B4DE03B85DBC90C7C7F2E87513D8AECA474B
          412CCE550A061F4A255F55679B55615107D05EB615C76FF693480B78C8C0CDAE
          1878584C0FEBB12D3E132FAEA723E38160D05A8CC68898A319F1E7D5D28FA551
          482EEAA25AB5F102789DC293FB02377C2E2FCC0E25DED73520F39160A0CE4556
          B8525C75A2F05DC8A7CA149CBCA1A182BF21A17395011753BA8881D5C842F3EC
          33B26A57FE82A2A930F065548C2A7941DF83D4BC46C0DACC579E0784C807B3C9
          09F3E42286BF2F607C6269365B8D16DAACE70CC43557706DD78ECDF7D9A53971
          5A5E35193C27110BF3EF253AB70DD37A87CF68745947A6A0BBDB8A29D22C1043
          84C6DF07C1DAC77B8C96990171CAC55318EDEBC2E4CF3F1E83C163189BC56883
          16E3F356BE8B2C849EF846CC10F37E03893A3F2607F6A1DBAC07B6013D069FB6
          F3C94641C425FF2066091B7789FE9D0DBED5ADCCDD9404228E3B16F18B1824CC
          8483B00ABDEC13586961617022A58048687EEEED2E61DF8735C65F4F692CB9EC
          72472A0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage1'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D6500446F203231204E6F76
          20323030322031313A34353A3435202B30313030B2AB05980000000774494D45
          07D30A06140B15A2A3B5D0000000097048597300000B1100000B11017F645F91
          000002BE4944415478DA8D936B48537118C69F33A773E854CC0B621750CA2E46
          9948164619524298082644117D08F38312195642D2D0C2D48854143F447D2828
          BA402569666A641735EC82D3A935B55C5EDAA64BDDE5EC6CE7F49EB399EB43E0
          1F9EC39FF7F0FCCE7B3B0C96717AAEA375D68A349E0744E92770FB64038AE8D5
          0CB30C3FD35609CBAE7C93D257192A059E5E6490598AA3746DFD072074C5AB98
          64CDC2C706A4CCCD238D42DB390EE17265D8969D27343E7E8191DE800ABADEF0
          0630DD351894AF4858E7171085E0553B101693013F15995C006B1B073BF30541
          D11BD0589682AC4BA8214FBD0468AB0231A196C980DD857AB0D6313090910430
          CC143D39F8CA1918463F233C36018F4A72905D8E5AB2D64980F62A0871A9A7D8
          C1F66AC5DE221D4546207D160EAA8BA52B89B7C130D24780783C28C9454E8517
          E06505844DE9E7594DF31545DAB9F714F94E4627154510979DCC04101CD0F77F
          C0CA8D89B877E12C0E5FF502BC2887B07E4F01ABEDA855EC2B7E42867177063C
          47A22C9C22C0065D770F62929270575D8523D79600CCF3CBE0D7A6645B863B1F
          06A417536FEC536474B9CD92DC657CFDA4416864149A6E35E158B517A0A98C00
          C9A9F6A1771DFE07CE1412C0480602081C1666CDE4B5C142738D5813826F7D06
          74B7F4E378EDD2149867A5E0A3E3626D3F0674CA8CFC2CC03A07BBC50AA7CB81
          C0603920E3A4396BDF4C604C372FE87F5A8CB9F5B843A106A9078D6A08219111
          AC69E29722336F2B35DFEE6E20E7C060AF1123C37661C6CC58BAB4E8AC6B769A
          650C4CBC8061B23E96003579285A1D8E4A31EB838754E8796BC1F424CF4D1AFD
          75BD633EDA9B2D940E6026FD268973EE234D8B5ADCC4D0BCFD28D81683D34E81
          31BF1AF0EFBDFFDA269A4C2403699434E401CC7960625DC222800A85B8E889A4
          CD625F3CDBA425CD92163C66E7E26FF377FFBDFE0511A2220579E2DE2601FF39
          7F009E1334BA56F889B90000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage2'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D30304132539392A6C60000000097048597300000AF000000AF00142AC349800
          0002894944415478DAAD936D48536114C7FFF75EEF6C9BDB4474A0B990654A69
          64B64ACD9C501242115A48529824125A24948108654921E55B2A7D29B3229020
          2489A414D95ACB91D6874C3456A12E1346736E5337DCEEBCB7C7B5A04041A803
          FF0FCF79F99DC3733814FED1A8B526BE6F459F7D01393C0F2C6BCE898EC22694
          AC19A0AB8727F38C5DCC8A2302EF6735140ED7825A15607E803D0E17F6F102D2
          381F94822832455B61637EC757050CB5C1CC446C4F1049A3A150A523527D0822
          99120C23255137D1225114BA2FC990776D05C0AB4608DAF373F02F8EC1E39C82
          DB3E06EFFC0F40F0C1EFF7217E6F25C98A445775348ED60501C6669A032B6762
          52CE5193A65AA49518E19E7D01769D1462990CA11209F9B945583F0F23429D03
          9134054FAA1250702308D0D553CECCF241052BD98CD1E7E5483A5843BC6F49D1
          0660E91B91954CE00D68726C02719A4A3CBEB80D850D4140FFCD90A1C4F55776
          5AEEF542DD7A0ACA380D8CD979D03496212C3D11F0997E0196BCF86E9E44ECAE
          22745E28C0F1A620A0AF0E77446DB252ED91640C8AE3E11C18C181540E069D13
          DA770D80A79F4CB33C811F02C7C3E191A3E7763B8A5A828097D751606BA13A4F
          9CCE62C60D5FA1DE2887E9F53476904068983ED019BC8F8824D3145C762FBA3B
          0C286EFB630BBDF9F9C5A20FBAFBD9FB55704F39604ECA446A7506E96E00FC16
          5228C031EB83C3320FF3E80C6CD685E993AD880D00DE00C5945A713723471502
          CF72370E7AD30C340FCF825671181F68C7B4C523B8E73827D9E4E0B166E4FE75
          0B5D0C3D925FB12579D46015EC6EDE9595C08643CE433FCC22E656E9FCC79EAB
          7A6538AAB22FE3D38AC76464E9A736099DBBE0F2974D008FB6D2186015D4A628
          87B03B0DF8F25FAE7135FB094722FF11563D08500000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage3'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D3081B112138566F3B44000000097048597300000AF000000AF00142AC349800
          0002A14944415478DAADD36D2CD4011C07F0EFDF3957C4D5354F212D955A3989
          44291659A459CDC4CA436BADADA617CCC3F542CB8629A18E556A4A2B6CB21929
          99D95DD7D51C95E1B4EB8E9087E3B8730FDDFDDD6336562FA4D9EAFBFAFBFBBC
          F9ED4BE01F43ACB6D857BD954BB3893C32F3900B998A84475A62DFBE9402E6AA
          8141FE0DBD95D096BA65F035447D32F47C9D4682648A5811103DC1218512E166
          10414E7E59BB3FC3D123EE7006A165B330595F871EA50971BDDF970302364414
          86DF0E1B3B57D03D82E1BC3309CDFA1790D877C29D7F0C0CBD3FC4AF9E212CC8
          00DF33E5CB01CE6D5842D35530920398D792F868EAC287759F405F6B875EF110
          061A94789A548381DA2844650E2D02BC522B03A80E944D7BAF12C3EFF3107481
          07522DC0943D030D780917862324835270DEF6222F240B91DBA3519FB319F145
          58043A6E117321973BE9545B6FB417D111913D04B94182F2E907707773C6B751
          19B8BC7E5CF13985509A3D5CBCA35197E98BC4E225A0FDA6B58079BA76BFA3D7
          41B415BA219225468BE439C6B64D403EAB0187DB8F18B720A4F90460ACBF09EE
          81C9A8C988C7D99225A0AD10951B3CC35303122BA9ADF95E38CEEA8388C741AE
          BA1A72824430CD1B790722001D171683190AAD035A2A1E21F9CE12D09A8F78C2
          44B97734A399F1A6381A2758025CCB666397A71398911BC1743482D0F100F342
          D98A8072761E8D555CA4B2F1FB0BAD056B1A1D5CFD636786F93899FE18FC777C
          988D2A04EED18246912E1C5AA090EBA1185143249C814CAA194FB90BF75F40D3
          755CB2B173A920D5524A6C7A19341355D09B4898753A4C8A55181FD15A7EA80C
          73463D3A134A11F5C72D7454308D8AF15E4A744A0CC4020E4687742652639A32
          9BD0EDB41E3961B9F8F2D73175DD0F382F147697585B630E16B49F2BC3C5FFB6
          C695F2137F5814205599C8590000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage4'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D30A06140B163BAAE46A000000097048597300000AF000000AF00142AC349800
          0003394944415478DA6D937B48537114C7BF77735B736EBAA5E58BA899594ABA
          28A3876642414425454F8A2C888A34CBD20AA90659A8BD3097212505153DC84A
          0C2312A3C71F9566A52C351FB94AD4DCE6D4BCCBE9BDBB9D2B57E88F0E7C2EE7
          777FE77C7FAF73188866862C42A77FA6F553CD85955BFDD9E268A0BF2C2188D3
          3585A872B9B1CCEB05443ABB706B4F09B269AA8F1103222F185E2C4E8E498E8A
          0843D9EDD76D7507BA7682C3674904D567C126A63BD50AB5616CBD0A33839453
          D8466E1563CCD7AFD04ED63C5DBF2E81D1A85470B36EDCB054365D9D925C0347
          65B09743908F3A306EE941BB1C92490205E4963221A7FC3E2E59337B4EF0443D
          044140EDBB1670FD6E3C4E30C310B2004AED24C8E51A6933C34410CA4F68B1F6
          348A68708509CBF3FF655C143229CC3011CDB536A4CEDA85D4982590B37D609D
          8DF0FCEEA59B1801C78D607A6216E504E2614E08D6E7C1428362664AAEAFA08F
          0F82BB8345C67B07D69C7902F3BB93D8179584D8702354BEBE7473C3E869A987
          C1B81C4A8D090F8ECDC0C60249203A47C1B1A600B9B79D87F9471F9469C5A8EE
          B90B81E391199304536020EDC03386ADB10353E765E15E761CB69C9704520B4D
          AE476C5300C7F0B8E1E2D0BA2D0B93C3ECD0281478F3C18AFD91B188D66B01DE
          83CEAF3684CFDF8E3B873762EB4549E079E9B22739BF7A57D5F35654C8BC68DF
          721C13FCDA10E0ABC61FCF30ACEF1B911F3F9B76C04118F5C2E5D6A1B2B814DB
          2F49022519D819BFE142C991863265A6E32D6A97A72134BC130A1F0675755F90
          362D14B3744ABA070A973118707A507EFD157658A457A08FEEE611D5FDA44D96
          15F515BBB1706F11CCAFCE614826E0685410A2FDE9F9C977F58DC0F5FD37BE7E
          71E05BC75077FA35DCA3DC1251405EB4179991D382F33D433DF2944385C8AECA
          C7E6E96A18798ECE3D884E9B5B703A47075A7EA231B70C3F29C7413413E58C54
          5CFED597639DFD5D0DF295A9ABD05AF312DFDBFFF0763B6F6FEB466B6935BEF5
          0E8C55513F61233E115D44EFB880CFB5AC9919609B4F7A780C36D860BDFA7C2C
          D8292589C14D443731283611312236DBB8806862A72C244CE2B1881F84957011
          6E6240AA6561BC4B45FB57404CD249C8A4E217571F95E605FCC7FE02B7224FB9
          824FEA170000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage5'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D308160B153B97976772000000097048597300000AF000000AF00142AC349800
          0002AF4944415478DAA5936B4893611886AFCFCFADB9A5E6D291C99865E93FB3
          83A02574B02C0A93A242A3A31249D219520389CC43666A07A230887E48FD2A44
          8BCCC28C69915964A4B5CA43A465D4DAC94DE7DCD667161124143DF0F0F2F2DC
          F7F5FC78EF57E03F4BF85B61EB19EA8D032CF37860B4AD662EA59593F1D78086
          521C0959463F999FFAFBBDE688404A3EC2B800C36516982C247ABCC4B986D178
          E5C1310BF77E167FCEC705B49CC520AA6747CA55A1046AE3099E9E8CDC5F8328
          AAA4A95DEA21A943A8CEF3674DC11F008D6578171EB03232D481C3DC2B9D0E04
          31101F51C1C8B08DC9E1732595826B87435957FC03A0AFF071210B10A7C6EC11
          7A1EE41397A1C76EAA47A15EC4C5CE5BBCB018F83468C4C72590A049607FDC3E
          6A8F84B3AED03906682815CC09BB1E05CA9451DC2D096469F65B5C6E133B9B0A
          88D54EA7D761E095A99B4F761B1F6D1674CE599469163367F9B131C0DD13BE2D
          D16BAFC68644CCA7BE388CA4DC4E2A9E9E4731C9236DD733E074621C1CE4ADA5
          97DDD3F269FEAC27F43D94A7D78C01EA8BA90CD2256E9B975629AB2B8C60456E
          179BEF641214E2A6FD6B07FEB289745B3F901D75868D91E9E43DCBE44AF56DBA
          8EF68C01EA0AD920B8C5F34B0ED6AA6F9F5CC9AAC36F48BAB1099D3292546D06
          3B5E2652145D49EA8C748EB7EF21F7FE59145D610C95F5FD7A85BA22457540E8
          DC942F3DCD24E73E21F9661666B983BAF887A8944AF083928E7DE4349F86AF6A
          749660CFBBE2D7A2F02B18EC94ABA69C1BB2F58B2987AE53DA7A8D53FD35CC0C
          D0D198D44689E100394D92D92D89DFC4489168CBE3A2B7E0B71C349C8B1E31F5
          3D17576E5D8DD11ECBFA47553C140D4C5080733443D600E80F97CCDD7A826CCB
          28C1F91BE0F18579DBDBDB5BCB7D7D31FBCA54F7527BEC99687D0E2228B7E054
          6A717B7A7119AB507B4B47CDFFF41BC7AB6FCB5C06205F9964EA000000004945
          4E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage6'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D30A06140B174CADD4FC000000097048597300000AF000000AF00142AC349800
          0003214944415478DA6D936948545114C7FFCFE738CDE49BD171148BC14A4A32
          240D2CA8100A0A5A248B5209534B08FD30B4A968D2669B1A11966DA4652595B8
          80444524427E08428A16CDDCD2995C731CC771167DB3BDCE1B5ED4870EFC1EF7
          BE73FEFF7BEF7BE732A05096C22CF3B20AAFCFE78607BC9D135EA31A27618089
          D2AE8E4AB45A9CD8E2F301222363A8CBBD8B42CA4D33A2018A91A95B12FAB82A
          EF3082C020AFFC3686CFDB32318736CA4EB65D812D496F56C8141A7FF9F3B30C
          52CEE3000D5B199C834ECE0674E6E56C0F89E05488E2C25074A916058ED89618
          E58760390B4DA0421BBFE9988985149241050D6B18D951BCD89C1EBF332A528B
          48B51A2EDE8B47F7DFE053DA1D84442420888B00CB2EA45A07314F84A3E53487
          3D17718326B7195951803529354E15AE0CC6FBF61E707C2806668C98C87D06A7
          B91BBC6D12105CF0785C589E54401A2D9A4B16615F19AA68728BD1143242F4EE
          688C769850AFD985C4E45CEC6AC84453F26128380E72A592BEDC3C26FABE4013
          BD15410B13D0581C83B40AC960433EE3EA5B152CE38C2A54F0A3482D1FA0F7EF
          008FDB2FF423F07E0CDD43589A5880FAC278ECBF2A19BC6ACA30A6B63747A923
          E4A865AD984DAB84CDF31E6BB58B11A70CF96BE0E531D26B806E5D169EE6A721
          E39A64D0780AB5C63539D9973B1B9827817628726EC2CB7CC6E7817EE857C522
          48107722EEC003C1ED83C5A9C2CB5B35C8BA2E19DC3B8A438BD5ECD5919D251A
          DDEB0B08CC2CC30245271CBC13B6E131A42F0B27031741E5010CAC661E2D0FDA
          71B04AFA0BF4E0EA8AE40DAB37666C337E7C006E6F297AC71BE061055A710EFA
          D830120AB04CBB6031DAD0FB6D0A8343F6717D35EA497B5734606FE4E1F88A65
          91E5BC7D824D395109581F928887E5979DCE3D8B118353309BDDD6BE61745F68
          C23069A6881EA285919A4BDD7673B57966EC2BBB233B19FD1D6F61FC31E73599
          BCA68171F4D7B46170D2EAEFA219C2407C22C6C436FF6310585DB0F2081C3D67
          A81167BF1AD075EF8DBFD82C89C4E2EFC438312B5E22F19211C21F0331C49BB2
          9E48108F45FC24BA080BE124AC522F0B12FEF8D74014A92402A4E61757774B79
          01FF89DF4CA44FB9AF1A01890000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage7'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D3080B0F2C02636C455E000000097048597300000AF000000AF00142AC349800
          00029B4944415478DAA5936B48536118C7FF6767E76CF3382F6B13B51B5E687E
          2853A6A153115223CC0B59895290612019249854265D589AA8792971951F5488
          10224592720D134194523FB4CA916935D0625DD4CDEB6EEE749C865F148C1EF8
          7F78DFE7797EF0FE9FF721F09F416CB570F81EB453F348723A8115CD9AD0945D
          83DC2D037AAAB0187B7E4A448924AEF3B31B04D2552036058CB62066C68C0427
          8B28BB0D3E2C2D0D8B2FF845FECD6F0A18ACC7282909DF43337EF0DC190D6960
          2A68B10F4892E1B20B9C2C9C64E8B826C6D1D20D00BDD560E30B67E1B0E8B168
          9AC0C2941ED6B99F006B83C36143705C11572545DB553F1C2F5F03F4D5F2ECA0
          3C48FFB00B84614085A8DC3E2C4C778112321089C510B8B971CE5960FCA48324
          300934A3C497D79D088A3EB70AE8A9224CB1F96F3C293739BA2B3C9178799CBB
          ED071C7657A34BACD525E38410BEF2B308BEF5039FAFEF5B057457F20743335A
          2365414A68CBB7E350B18E6B7AC549CA890FD83FAC01BC61655391F9448C1763
          DC932A435601DA72347AEF4EC889C86EA4346541387CA597F3AA0BA0B330343E
          8FBD3B2888E895012CA3E8291F350314688900D6D23580A60C99C43279FFE0C5
          4EC9CB3BC93872A98333BC1D70CF87A2C0080143A0FA9817DA75CB500F517088
          0438A124F1F894627D0A9ADBC20E0F3F45FA6F433F520B9B01732BB0AD182937
          A7F15CE7444C8807BE2FF130B144E16E9A1951C201B322ADC28B58FF18C8A319
          DF06CB9C914C2FACE3002D804F05EA1EEAD1AC9763E4EB1C9C421194010EB6BF
          3E83B7E12EF434843A66BEBD23934FA7606CB017B288476C53DB7B2239AB0007
          F2BA10B97F1712DD3536954A25D81030F420E2CCC8C8700D9F0F1358749FAC65
          3FAAD5EA9CC9C949B9D610C08BF337903209F3B6A4A424FC9FB771B3F8035CAA
          F41130C6DE4C0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage8'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D3081B112004601B7682000000097048597300000AF000000AF00142AC349800
          0002AF4944415478DAA5936B48530114C7FFD7BB5D37978FD4891651682414C8
          AA09AB2C61330D4D87A19258595814860A6A655236241B369B52996298128542
          583E7A98C830E683CC0F1929089192D8C33937DDC3B9DDED767D8408094607CE
          87F3FA7D38FF7308FCA711EB6D1CB88B0EBD19875D2E60C1678D7894AA46C6BA
          011A15AC1117F57C2EDF77316EBD41405E0C624DC0483D0E18662073319038EC
          0860287F51648E8EFC535F13D07F0F23A4EFEE1D942008DE5BF6C13F381E9467
          004852C0562DACDB5817A2F9BA27126FFE05D075074C64EE2C68DB30ACC67158
          F4C398374D028C1D346DC7F683F96C973F9A0A8390A45C0668CBDD1CE07A919B
          44D9C4586F3124195A58A6DF80CB13C0C34B084A10CA027830EB7F81E713088E
          BB1F9E158420A57419A05111C688CCF7DE5C8F5074967A23EACA1736DB033879
          9899D906AD5607EB3C05ABCD028E4B8738B90CDDD55148281C5D0274DEE6F487
          1D6B081786EC47877233A2AF0EB25AF5B0C361E8EB778728460C563998186052
          0774D79743BAD30A49FCB525408712351BB7CA4E8B536BB8ED25213852D005D0
          93687B4D419C2847567222944F9FC3C121D0F2A801E131A9E8ABCA4291F2FE12
          A0BD04298493AC92E6B5F9BE2D8B45DCE5E6C56B696CA520391E078BD989A2B3
          27D99C13226902A4A7D2D0A2B80495AA6C4585F65BBC66AFA0BDF2A9B11EC4E7
          D6B14B2351FF828F5DC949AC846CBDB616861F1388CF2F02878D9B14798C5AAD
          7623560E03E7294160A5CDF49394E756B00B9C46E34B3FF81DBA00D2935A5C37
          4D031B28E0FB37135EA93335758F9FC856DD81A6328C364C7C2263D38FE2EBC7
          41D87D329977C3020447A71394D00B14DB3D356E406F9DC2E8703AF6543EA81A
          5D05F8502D3E333434A0E670600483CE1315389793AD0826DD661FBA183ADC49
          BB303767FEECCEE3A72D0CFFD337AE65BF01734502209056F498000000004945
          4E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage9'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D650044692034204D727A20
          323030332031393A31383A3035202B30313030E27A682B0000000774494D4507
          D3071F112717A6D6A11D000000097048597300000AF000000AF00142AC349800
          00029E4944415478DAA5936B48530114C7FFD7BBCDD952714DC94A8A12A52F6A
          68684B31B42985B67C6459F848C342C9428D32C8404A33738A21854539CA3422
          929E6B0ECD46624B828A8D94F299B2CCE936DDA6DBDD6EB75AF84541EAC0FFC3
          79F0E3C0397F02FF19C472077BEB21D7CD42E47000BF64D4E356BA04B9CB0674
          54C31C59A07363BBF17FE78FCF131097835812D0D784EDD306C43A6844D8ACF0
          A1398290E8133FC8BFFD2501AAABE823F95B02383C5F78FA6D8360632238EE3E
          20491ED335319A63E48DB673EE48BAB008E0550DE8E82223A8390DCCFA519874
          1ACCCF4C00B4151465857F54093325C0C3B3BE48AD740294B52E36B03DC83521
          85C4507739227295304DBD009BCBC3003D8B23DDCD688EC98497F63BF81B45E0
          F042F0E04C00D2AA9C808E6A421F99FFD693BD22108A2A4FEC3CFD85A9BE8166
          6A18299D3750B8631F2EC96EA35D74109C1123368495A0F55430D2AF38018ACB
          2C555072CB56EF4D42C82BD722AEF403FA0DAD487C2645D99E5C68E9CFD01B2D
          68962971372014C2A863B8579C86431227405E8946AFF5B1D961E98D6CD59D1C
          F013F290FAB214657BF331607B0F9B95829DB2C33C6FC123990A2DE1F198506A
          117FBCEB0F40761169849DBC1653FC84DFFF5A863C733B462DE31070BD90238A
          81CE3209DA6687F47E0FCC5C33FCD9AE90ACCA44786AFDC2156415DC360FDF50
          310D1684C9D9CCB5D4087CDE84D2A42C7C35AAE1421390B674A23B528CD12103
          8C066A32AE40E14D2C3C068E7278AB1BE666B4A4B8A80E98FF84CD4FDB7052BC
          1F83C63E1034D024ED72D4CD52F203B5D8B5A8173A1A82A8E9B18FE4EEAC048C
          0F5388D3F4A0282305DF8C83CC0640ED4DE598B9C2B66E4933BDBB1E7658ADEE
          95B058D0838622C39D085E49B8FA39AC8C7B6CB09B601B410D2DFC27372E153F
          01F0C6092042E27AC40000000049454E44AE426082}
      end>
    Left = 767
    Top = 279
  end
  object JvDesktopAlert1: TJvDesktopAlert
    Location.Top = 0
    Location.Left = 0
    Location.Width = 0
    Location.Height = 0
    StyleOptions.DisplayDuration = 10000
    HeaderText = 'Okunmam'#305#351' Duyuru!'
    MessageText = 'okunmam'#305#351' duyurunuz var.'
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -12
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = [fsBold]
    ShowHint = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Buttons = <
      item
        ImageIndex = 0
        Tag = 0
      end>
    Left = 503
    Top = 264
  end
  object PopupDuyuru: TPopupMenu
    Left = 606
    Top = 216
    object YorumYaz1: TMenuItem
      Caption = 'Yorum Yaz'
    end
  end
  object JvDesktopAlertStack1: TJvDesktopAlertStack
    Left = 503
    Top = 312
  end
  object PopHavaDurumu: TPopupMenu
    Left = 40
    Top = 80
    object ehirDeitir1: TMenuItem
      Caption = #350'ehir De'#287'i'#351'tir'
      OnClick = ehirDeitir1Click
    end
    object Yenile1: TMenuItem
      Caption = 'Yenile'
      OnClick = Yenile1Click
    end
  end
  object PngImageList3: TPngImageList
    Height = 36
    Width = 36
    PngImages = <
      item
        Background = clWindow
        Name = 'PngImage0'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000AB1494441
          5478DAB5580B7054D519FECF7DECBD779F79431EC48414029B870A2101A30551
          C04E4CF051014198AA55A74ED5B13A543A852AB6881947A63A6AD582B55A19C1
          5A1A1E96672921F272434D80044179196A484842B27B77EFDEBDF7F43FF7EE42
          808060ED9939F79C7BF69CEF7CE7FFCFFFB84B00E03A4AE9BFA15F213800BDD3
          2B3EF4BCFBD4B4E053F5E079ED55620D9A6D2F50087700314F00E9DB3FC21AEC
          7BEC09EA7E6C1380D70032B8D59E6995803F1F461F387216F3E24DAA6FA69EF7
          1F05F2C5735308FD6C64354DBBB38E864F41746317B081C95456D683F30CC45A
          9F5E6D6304FC4940E53150D6B8F13C50F31FC5355CBA49C375D9E3949AB6A5B8
          F397673732D7164F0AFE217D8367F9A300B120403408540F82BEAE7DA9346AC3
          D3D6A4F07393174BB32A7E49222D007C2F0017C53604DA4779208D57D3CF6DB7
          A7B846FB7CF21D004DF7D36E2FF0C553D6987AE63D524D4DE4A2830E54CE9F14
          F0576B5B53464813BAF6E05B2F126F3C3729E02F0BD7797FE49873EF422E3B13
          B437568190D9F59830ECF8169C788009895357FA9E579E99F32BE053F0643DF6
          E9BA7A20D6D8B5C431FBB55FB049497D2FE56F76D78E19457515400F0321EDB8
          8706A4FBF89D50BE7795AD907B6753CF33B8B9D88DC78F600D010861D01B9F3C
          E2C87FF107094ED534ABAC0E7A3EC7891A8043431995803CFEF06DC8697D62D2
          C448C3A4878D5391E942C91700DA032015BD508313560F24824154CB4E2152DB
          119C1019584E1796803F079F780AC063431417765F62E6A48B8102FED2D09F9D
          3389E430F934B33BBA37753AD59511202A2E2E099ADC3F0DFC1A627C182A9A37
          0D0C14F01785DE75CEE1928520D532162A0BEE4149650150BC340656134F1153
          81AA31882C690973397A9D7CE3E6BFC4CF3F2921A431F892A16DF2F9F9A955B5
          FCA04C5C1CB1017031181A50C3407D4580707D408901E1B744704DDB5683EBF6
          2318390BA46D4999A8EDCA5CE07EB1C00931D49BA96335B1A2B2457C27F80E58
          49CCEA473F4D03E2AE58E1C8AE7B03C66EFFAAFFD1AA83CBCA7E27147594483F
          B427DB8BB072AC22231E191204F79642746D153886BF3793886D1B91D1055ADB
          5D3C55FF323757DF3BB256FE798B4CF4A308A0DA8B05AC9EE1A0BDE30432F461
          2A653F33154CCF66E0FA221703D9CC46E2B320DA72EB2D8E919BB68021F1D113
          336600CDAC10B3973F4E1CC7F0F6F3DD30BA79DFA5ED6DE0BBE4C11DFBB015B0
          8D5D99E1FE0FE5D240017F21323818EF4FC0FED6AB0742AF81CFCCF08AE44A2E
          0D4E4B13BB5BF1BDD33CAD485C6AD885A06B2F0F14F07BD1A2C68203A4DE8599
          BF3535A594930595A408AD5259F7721A76A750C271F2F8830B102C7A69A05DFE
          9AE84E25575D95F2AA5C9D0ED22377A18250ED948079EC38A88BB7835449E61B
          A7D3FDCAA4FA57106CE7F94001FF70EC17F62D499E45BF916B3C1FFD44015736
          DEEA68FC76872C3361E61279E513E0872A0BC0505C8ED21DB508D6D51F283FF4
          27EFE3A03B3CF253D50F72D9C36C10CB5859ABC6FB26868628A82F1F00478573
          9198DBBC8354EE5863037D3692605B82F59A33CF65D5799756E1713C764C6120
          3166B00C4CB70C99906E3063A9405B3BE60A4302DB705D33B252138C6E830827
          AB1BF2FEA63C32D65A4463CCFA63F6D1B04FC43E949566DBA07308681B0B1AE5
          92B79E3DCF8DD27F96DEA5AECC9ECE173AA74955B9C8408F33880111901909A3
          CD21A065FD08E6CCC6083B51E533F72C14D2B6FD11C14EDB40F52513FADE2E7A
          877775E4293FCB41FAB880EFB32D1F121E20EE0D78044ABA11B4756341C8685D
          24A4FE751D0235248E966B9E725686565EFF817B3ECA436DB37726D466C1EB71
          57C28062A0EF4465C8D39B1C398BEFBF30FEF9B0FF437555F943987E542BF7A1
          BAA96A1F872D1674BBCF1B40BDE3405F7F274805CF32EF588F403DE75FC8DDC5
          D978F9460557DEF1775ED943E487705CFDCA5A6C5D4A4544C11720C88C8890F7
          E95CCED9781C596FB13CC379407897685829244A588C34DCFE90194AA9266603
          700528EC880066FBB520940E5A0644768AE96FBF03A39B365CCED61C680EE538
          9A4C43E96EEDF0B4459CA777B7236FC572E03423D635F36621E50326DCFEA1E8
          5BDD4815C45C987BF1C340E865EA3B81004D57EF8FCE014A08A061CB616B7E77
          A0AB292CD98B6BF1BB96AB23C452560096478CC3DA4155C213274D374F0B4122
          D254E2452F11E544709898FBC0D758D16E611756DE92CEF742885D0813813960
          80AED0326FB53C39BC9BCFD183677E93F38A6FDEC92743EF65CD40F3A4AED96D
          1FF6BEEE5FE27D72DFE366BBD3ADEDCD2E576E3BB4C5C261DB106017C7B87A42
          01BF0B9FA3CD6EE2E43CD40102D0BE97936681293A391FEDD00F290F10C5003E
          890297970C5CB2DBDA90F684C03CD98BE98F13404A05616870198D48192041D0
          59B5E70330396A76F95AB8B46EF6613018C99DBC3C2176E118741406615B8E21
          896AF54A9EBA2AF9F7BC40C37C01EF94E7DE0E5C561A2A0137E5537136BBF0A6
          2D01E696199E11B4FC3A9C3C0991B7B7A33BCB514DD9ABC863F63D21147C7514
          0C01DD0AEC83F2A6F66F23843B593180C50257DF4BE98F18DF38AAC44202CE45
          33F1D402589938D5ED8D190B33DE6763FDFB46A28F551721FCEA7AA062297069
          EA5AE5A6756FE2E23360BB323A30A1803F1D9F7E609F5F5F8BEED0B2B4796650
          2C91ABBD20CD9980FED16713A02C54C6FA91B8A06F1AD61C2B7430C9614B28FA
          5A3119B44F0E80D95586C9A2DE24976E5C4CDC1DCC22F720A9CE81082551952B
          8BACF6DD123DE09E410D479E90110467EDDD98C21A7688B53660040C9B0412A0
          4C6566425AF100886304C276B4604449FC775721445E6FC60467127A58F3089F
          74788598B3752786A4DD89FBD49F9060760A63F57D9E71B143AED1C637AE6AC7
          CD9CD331D58F0664D89B21A8956727A4C23631E2E4F0E211FC10003617ECB936
          91783C64EF4A2644378590E3AD2AE7EB5CCDFB8E05785F73338867DA9050F385
          84147CE22D85EB41E3F8BEA5FEF9425E7094634609E2F5C45511BF13D48E9184
          D3EC70C7C6C805242C22D42698F8CDE3076D550F90A4298DD2D0379FC73812FF
          018E21A17D035DEA5BF0E964DDE8CEAC11DA2E77ADF3E92CE0B80E9C19B13760
          EAB2A440CFB510279478E7FA91607199AD139C18DF8681F6FE60709405E7F2C9
          DB5AE3BBF62099FA4B5919313B954A2D30E46E4EA6AA19520619C7C30F3AE7BA
          71AF53A81E540918E724C10858394EBF3E49908BCF61637212AA291FB4F73240
          B8366F2971F4B6039514DEB3792DA9D8BAF972668F791E64601D12A91F39C50C
          7AF3858C33FB63FBB3E6919C1645BE0F351A3C6AF919FBF47169B03E6F9E23CA
          FA8C88E403EA2804FDC32010697A98CF697DC18CE61611B1E38890F4D1BF7001
          4B3A9A12C9C7E53C35BA5EA844CF2A85B7DE384BCC6FAB37554FB27E78F84208
          1FC2537E0DE2040E88D381E442F6172A23C74B966A2014017D3B07C69745C0E5
          8F07216DF77C229CEE31D4D1378869CBE6A1FA832C43BCF2D0718E18FBBA95C1
          E093A32DE537388A7734440FDE34CEE8BEA64ACC697D5FFF4F652D91C37BC174
          15124160FF231CA486F77A7150FD5C43BD6136E73AB84648FA7847ACE7C79582
          AF6E0D90E82124D20E972957125C075B17CF4A43E11A1A4A1B4C5C9DCC1A413F
          3EA552CC5DDF10EBBC89A5F9944FAB6F8D75DD5529A47CDCC01C9E19297271F2
          FE13D847B61888AE2035B9FA7CC88E77BEB37F6704FC43F05980959118159F75
          F4DB24F1FD11FA3F1642C875FF051143B6762FC0B62F0000000049454E44AE42
          6082}
      end
      item
        Background = clWindow
        Name = 'PngImage1'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000B56494441
          5478DAC5580B7054D519FECF7DECDD4776B34936C13CC490088185A04048C088
          81587C9406475BC547A54EEB8CADB5B68C0E6AA752C516953A61C42A550BAD6D
          D511EC94410505444C2284C7864720C68222AF0049369BECE3DEBDEFFEE7EC2E
          26BC14DB999E9973CFD97BFFF39DEF9CF3BFCE1200B8D2B6EDDD30A8107C01D1
          39356F795F7BE8B6F843CDE07DF105C25E5AC79FB641E901621D0512DB3F9ABD
          EC3972D4EE4B2661D4C8CBA1A965CB35ECE5275B5A6D1E626F499E61732291FE
          247B39A8D8A9491A66D8DE7FDC0FE4DF4F5E4FEC9D631AECC0CD6B6CA51BB40D
          7D38416C4011CD434ED15B09549A0DF9E8E3A69E405E20D0D3DBFBFE1050EBFD
          71B3B97CCB56D6144F75CD3EBE1C26757C7E7A35D67BE366C6FF94BFDEFBE6FD
          00461C408B83ADC7415F7B6AB93471FDC34C4879F2BA67A4BB6A1E216A2758CE
          7CE08C0E003E01EADBA520D5C9F94CA8BBBBC78EF4F74379D908E0791E128904
          783C1ED0751D082170E642CF55ECA142A16083BA3977B434BD6F07FE8A22F1B6
          AF8442C12A658DEF46C7DC3B1672C585A02E5B0D4261DF2F84914736A1E02ABA
          6B9CBC2AFB29D7A3737F0D7C2EAEAC3FB5BABE7E30DAFA9638EE7EF1032AE48F
          3D37E2C3ACC59327DABA0CA02B48F6146E8E0A2472E466A8DEA5A40EE48EBB6D
          EFA300AA6F2C48EA46B088069C1805BD6DDE21C78867D7105CA613CF5391F801
          10A10F24FF2476361CC7C181839F532558424E9EEA964F9C38215E31BE52304D
          13A2D128F8FD7E300C83EDD1CEB6DD8D6CBA4D9B9BDEC5A5F6E6F8FD3FD2340D
          1425BAD4B2859F1714E4F3E38263965C783343C1127CE22A00970D1A6E47E47C
          A267038582E3137F73DF492487C507AC88B62B6F8EADBB4683E8F2707ED89B75
          6FE83760F00AD4B46F3C3750283836F19A7B2E9723C46DB560A16BC1AD004211
          9E9B066062B592A86932D8B201C9259F2A5C89BEC679F587AF23CB77BE020A05
          2763BF40DD981DE46F9AB5981F5688839329001C0CA60A366E20E849205C0C75
          C204E515113CB735CDC671FB11EC8BD340EAA6DC7A755BE182AC67CBDD602490
          818ED5C28A872DE26F82BF012B31585FDB12009255B3D251BC66194C69D93C78
          690DF11555BFE7EA722AB5AB6E4205F08143C43386041CEA3220124DC2D8CA3A
          D8BDA71D860D2B00E3C0011893DB7827118F6F4046BD294D8AC56C4549E2205B
          77F0A01C3BDCE52B1B53C16CC6425692249DDB36706CF3275B71D566C96946A8
          27F6D49AC94CCBA802655AFA9D2A182D1438D3CF7CA36DCB96D6E4D71B6528E8
          45EA316C056C8D6FAE47DFB29C1F2814AC40069FA5FBD3B1BFF9E281D06BE0B3
          50599953CB05202CD5473AF177AF1576495C9EE241D0F72E0C140AFAD0A2A680
          03A4E8C2C2DF59AA6B3CE71464922B744A5591376D252BD7261CE7ACFB6C0182
          69E707DA169CADB5BA86CBAB735F7036E48374DF2D785416756F601D3E02F233
          2D20D592C7CD707ED035B3792982B50E050A054761BF22B624E72EFBA473B6F7
          ED7B5CE02946ADD6D2DA9D606642CD25B9741DF065AE0560BA3C8EF15B172358
          DF60A01189BFFA1E04DDE1753ED4F013AE78640A84192B6DE574DF4295D5406E
          EC00478D7B9138BC7D2BA9DDFA6E0A68E718826D25D6CB069E2C5AE35B3E0B97
          E34DC5140A625083A5603A336442226019796077F6CC172E0D35E1B876642567
          18DD0049CE29AF2FFD97EBBE296C906D50EB37524BC33E1163B8576ACA78DD97
          82BAA1BCCD59F9CA1343DC88FDD1F85BE455C573F80AF76DD2ACE1C8404F3340
          7F2B2033A2007008C8AC1FC1DCC51861EB65BE70C74221D0F467040BA7809A2B
          A7C75E1DFB17DED353EAFA5909D2D741771621881B046D173241300E59120B08
          3A47F05F0DEADA292014742E12F2FEB916813EC92C6DB8D5EDAE4DAC9AF00679
          6A2668DC28742116380415C211052231150694009460484B2464E83A7112AE8E
          1E6E77143F7D4F3AFEA596168F75371AA6344F4B2A169F8C73CE6C0D445E87D0
          FE2854575FC53C01B5FA8C47A0251E4FC0CE509B3563FA353C03425F74ABAEE9
          2B758C3F026725A4A4E1097D7108A64EA9666E830EA6B1491084212691C4ACC6
          E974C2E6A696F767D44DBB91F4F686CB71B68386AE1BE1BE88E0CBF641715121
          13CE80C8B2CC12020A465790097AB4D0DFE88FA665825F6DEDD49A968CB3A24C
          689F7A47761869079631A78C83CB802150D9600F39019BED2824A3D013A22836
          720434D350A297140E0F9CE83A7CD0B4C5E2BCBC5C5738DCF747B7DBF5805372
          425F24F2ABFAE9D73CFF4D3CA48427A362CB616B5DBC63FB362514F4E364FDFF
          0DC4C5114227814F9A474CC5DA63CB84276E3BDF0A0B7122DA79C4875E42E344
          70587BF0FB31AC68B7B08D1E0FDB9DFF09A150D00116027340013D8915BE06E7
          75CA76BE448F0FFCB66469F6635DF3127F2FBA1D35C1F6DC7DFCADE84BC125BE
          79FB1EB44EB9B3D45DC5D5AE1B0E6C6238741A02D42ACD8B27140A7AF039C98A
          1037E7B51D80DA1C6BF4DF0596E8E6B2ED1EFD80EBC7C46502EFC7C4A03407B8
          9C2C36A1DD9F00AB2B8AE98F1B40CA03A12CBEC24E4A052041DC3D6BC71B6071
          B6D597FD2917881C42FC4B905CD785095185A3D01A0CC3B61A4392AD36BB4AE5
          D539CFF382ADF0E5BCDB39FF7BC01505F01070523E0FA56904B7523B40DD32C5
          33E3CCAF435717245F6D41EF5A225B4E9FCB3979DF2F85F22FBE0453C00000FB
          A07AEFA9AF238433B118400DD1137B2EFF3EF3A463965841C0BDE84E5C357A11
          9A89DB7A6A62CAC24AF7E9BBC17D33D3C7AA8BA0BCF001D8E278E002F27BAE69
          6B5FC6C103589B7197EC73130A05F3F119C4EA338F8959891581C7ACB858E96C
          F08134773AA6A4D92902360D95C6201267F42D93C9B0D041770E5B6263681573
          405DD701565F15268BFA5EE7F80DCF90AC1E6A913B68AE772E427E5BE6AA92EF
          645FAB7564DD6E9B8E52A1200EEEC5DFC714D64C855836012560A64820019B1E
          9995D9AD7400C4770430CCF07A8A28497FF75440F2A5764C706602715A8778FF
          C19562C9E656E0D5ED197D1A4C48B07A8529FA3EEF54E380679279D2D3E098C1
          B91D3705D180CCD46408CAF2ECCCAED049CC3439543C16EBA82CA46453448C54
          2A4D7FBB0A41DB98408EDF91B9ECDE77F8ECC3213EBBBD1DC481E348A8FD4C42
          2E7CA296C20450393EB63CF8B8501A9FE8B8BD12F1FAD34791D609BA2B1CEE02
          A7B296BD2367906044EC14C1CC376F10D4D5FD40FCD7B749652F3F059C9AFE00
          8791D0BE7329F5B5F874D3AED65A345ADD96B5D8FD701146B51E944C82E12803
          D9F55DD487000B440247632EEA88A5026F7C8A97F575A06932740EFC00C2C931
          C0E3B70277084CF41CBA950D39EE3E28587B0AA449D1F97C4E53677AD67E24D3
          7C3E2B23A63CFA5A3571C383E62523724C9DCFD53DF94192E746C1242601169B
          84C56F7A9B5155D87FC804DD7440202F9719278DDF95E3822C34337F98C6CF44
          D0CD1F374396A01F176C5DC9E2F62C1B59FB48E3595686375E21A9AAEBB13FC3
          34700283598B494CC3421C5554750FCF29A417D3BDEE1E190C8B67A724F00254
          554D84245E82A8A310311F187CF1A17F1860943E4D8C92A217655ABC5E2F4B89
          3E3FD8F97A5D5DFD0F87101A88461F360CF30F34B180B41312702B0481684437
          8584AA681D07BEF44EAB9DCA7627733DA7F2EC668693649292FCFCFCD3BB7166
          C9E42043DFA1DD874278514FD2FF2A6A4E1F597777CF346CEEEDE90D5FD61B0E
          D755574D62FA4657383891C9DCDE06E76C198CC1EDB9263F5F218483A3C78EC1
          E123471F382B966162341F9B45979614F365234AD9CAE9C4546E4FFB7E1835B2
          1CDC2E572AEB42C18E8E4EA81875394BDFBE22CAC3DE7D78DB9E7005A8AAC616
          468FB16DD76E183B36C8B685C92206FD1B23D4C6FE4FBB1F13AB65178CF648CE
          413D37D6300A33C13D2DCB1CAAEDAF8F9BC534C9DA5EEFFDA957B7BD155B12BF
          F7BBB993339C2472A4545AF7BA77F2DA63389EBAF75AAC54915A11E3541AB70C
          68AC649E163ECEBC3FDBCAFECF058FFFCAFF00A4B2714980DDE3100000000049
          454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage2'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F76000005D0494441
          5478DAED585B4C145718FE676777C75D6017DD2E022AA880068BCA1D45A56A4D
          4CDAB4263E9A465FFBD2A64DDAB79A5E5E7C30363135E9EDB14D4CDA3E98D807
          FBD02A22A504B968C1CAB222F502B20BC3E25EE6C6EEF6FB4766BB08516C9A28
          097FF2E7CC9C39E73BFFFF9FF35FCE0844549D4EA7FB288B0474D0E36476827D
          B158FC743C91F8A97075C139E1D78BAD9FB5EC6E3E9E4AA5C86EB7536B5BFB13
          A63FBD23149EE8B4D96C175CAE1567045555D30E87837AFBAED3C3687411180B
          D1E20781D3C3B747E4F1F1D0AABADA6A723A9DE647FE3670E3A69441FAEDD2E5
          DC57F6EC8AB2D6C964925848486D0E5CCC72E9E735281A8BFD6CE886E8F17886
          F01C8002DF78BD9E945D1415012F25B178FC6630384C95959B5D822090139A61
          1BA8B3ABFBFCDE96DD5F0AF1783C2D8AA2A932A3F2BEF40FDCA086BA5AC2A920
          DFAA55E733CB0D06826A69C95AC9322423325D6C6D3BFCFFEDDD626889013D18
          0F492B24C9919FEF8D2D0A086CC7B30156B087B2AA6AB24D10E491BFEF6CD434
          AD38994A8ACD3B9A682A324DF95E0F757476755554947D6C68C640647A3AB4B5
          6A8B9A7DBCF7C3998FED686C382A8A36F36863DF4DF6FBFD996DE4E3CF64CDC3
          213176ED6C729A40006941DF496CFE7D4DD7BF9524E70F9253BA8F03233635D4
          95DB7088A4D97361AA310BCA732F5DBE7276FFDE9623F36C04D09568EED5546F
          738FC3484545850591E987E91CB75B70BBDD747F7494D6141753EFB5EB899D4D
          0D6E8E1CF06461896DFF32D052040A87275623D28510509FBADA1C203C3BE1A4
          1F2AAA76D8D0F5A824493278122E1185EBF42000BB30E6ACCBE5121D0E3B72E3
          8A077380C0E7F07C08B948461096554595E19C7A70F8762DE09D70643B076DF6
          B13FFB6F10108E94AC5BDB1F18BA350ACF9FCC0692F1BC1221640AC11B936CF6
          6D552FBBA2D1184F32A33E86D2ACAF92AEEBD4DDDB4779B9797E004D6480E0A8
          8518FC2A6CF17DD5964A736533BF87420072111250B6FA991032333343ED1D9D
          DBE1FDD7B9B848EFD9B533136758058E45FC6EF50582B7485354AAA9D94EE300
          F7E4796852966965BE97BABA7B3F00D0294BA2AFA142B3A2A8A730EF4D84D637
          2291E9E36B8A8B4E141516524E8EFBDF1C6EE967AA6840A23FD601E8DEBCEDBF
          D2DE71BAA9B1FE5D9EC885004BC86449C96D36617172BB5DC24281EDF34D15E5
          EF3B9D0E1A824A7535D574B5A7CF40CC767475F72438E0DDBD7B8FBCB09B0363
          BA7BFA3E81449F2E3117791EB42CD0B240CB02BD5002E1EAE1348C990386611C
          40AC2D77D8ED3308950984CF08B2C62DB4BDE8EF40FAD170DD74E886E1C55865
          75813FFE9F05C2FB413447C1F5601F0055645725994C290C8E78ADF03D0895AF
          82C51310845BE3E6606047341AAD16EDA2806460E07B00B1DEC79818D3BD61C3
          FA2F3C79B90F3036857703F72B3D140E47903323C889A97902A13D84E69CF581
          174E288A827E050B28C881A620E189491F80CA1AEB6B09E500F1742B316567A8
          C70950341E0EA31E99A444221140B9F0368AE321FEC4C68750FA3C0BE1791D9A
          D7591008B02730147CEB259F4F5A5F5A42069232723E2EF8E29C2CC7CF4CD6FB
          938813BB55820C0E05D3A3A36397D0FD1192D8EF732C844CD88CE71315E5652D
          C8CD94E4448F7E9ECC0BF25F0668455CEE5B0264000421C359D626599EA2D1B1
          3113CB939787799C9A058282949B9B93992B4F45F8327B0642BD63F6A102D984
          F62BECEBBE4DE5655450E0376B1E1ECC82C04AB4BEB4946CB825A5F96700FF06
          81A0232377A8A4642DA99A46283248D37442C185F36227164B445DB0D016CA53
          53B054D26C43A1302BF81DBA8F41A0F4337919AC28A1A98257F971F33A89BAB4
          AA66FB36D3625C98F08D3CBB40E17E3881A914F34264955CAD6DED0934CD10EA
          DA53058220171AEBEB0EA2EA3117B1C633185793D616B235F84A28CC6E99B58D
          8FD3FCF24CE7CB2CE3BD07814E3F8B85DC68501F139B6098EB3BF46D66CD781D
          F0457A74A37E0DBC11FC17F84770F9EC18BEBCB68107C1FBC05BE99187FD02AC
          C09C43FD22D10B2510B6B2FA1FC18AB752778049A80000000049454E44AE4260
          82}
      end
      item
        Background = clWindow
        Name = 'PngImage3'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F760000069F494441
          5478DAC558696C5455143EB3CF30339DD2A163298B205B69595AA048A1941689
          1BF04B08C60430608801F11789C8F2C398283F15884A0445101195C4A0905296
          AE20308065298280AD60B5B5232DA5B3B59D797EE7F5BDE1B533AF9DA9106F72
          73DE3BF72CDF3DE7DD73CF8C8688B20541A806A5936515ABE716167CA40183AE
          5CAD11C68E194DA150988C4603894C1EBBAEFBD634FDFD60FBFA82273411A6B4
          C02F0E9189972978796765C68085BCD84D128EB422A3A3A34308068364B55ABB
          4B6CA96814BA31967E7CF121E3F53D35C227CBB2BABBE7515175CA933F33CFA9
          D1688857CACA2BCF4409C9086AD3A675E0510B88511BB17C7BC0ED5BBC249778
          51E6CB1B13DCE76A2977FAC821E08DC4AC8A128AE1EE49902444F74A94D0B113
          A5DF3C533467B1081AFC705820BD5ED785099ACED9B3F23CE17098743A3D478C
          CC6693A858F7FB9DD8EE14D9C800B61B5142581C06525F567A3D545894B10842
          07A3E2CF9493AC545475C7F981258A0493738418890C094B259E0B7A06D30866
          BB9C5459A14F77CA5172FCE4618BC5F2A22B3595468F7A0A1C81CEBA2F502010
          780501DFAF6AE84871C93093C974ADB020DFC6EF2CA3D3E9C8EFF71327C36C36
          93CC0F85426CF47294A113A5E52D132764393831CD2D2D9499318ECA2AAAA868
          CE6C6A686C2401D974B952F1699EA63905F9D4D0D048377EBD3933AEAD29F2F5
          12CEDC773535F594953584525DF63388535E9F31E2C8439115F8F51494F225FE
          B3782E892BB792C22E185A01437C68D2A1EC016F0778AB789D1DC89953968AE5
          20BB251B6D10B0AB185F05433B24437EC80DE869680B0EDD5BFCACFC46C00F83
          AF91F91856ACF97A3A882BD8303601641E0C7CA0269350D67076D781ECC374E1
          43BC9490A17D5F7D9D36383DFD2F7E460120AFD747369B8D4BDC5EB036C1E09D
          5E0DE1C3E4C3B6CD62364F9AF174AEF845F390E599FE5C7D99A64DCDD1C434B4
          75EB765D4666660EBE6437971F83C1201AE1E7D6D656B2DBEDE271511ABBDFDA
          AAEB6608282ECC989E3BC560D0479499FA0301329BBAEA98D1688CC8B36E27CE
          5AD5A99F9675338453FEB2CD6ADD8FB346EE0B1785A939D91A02F0A6260F0D1F
          3694AA4E9F11CFDCEDDBBF51727232399D29545A5EE9459C6C899EB54F415E93
          5EAFE27398D8AFF4F3D94381159FE5D21897212872159B0B859DD2FB2D181A25
          1912C0D7F669084AD5385393F9597938C177810CC2FB35A57C6F863AE05D2F6F
          03C30EE536694D8367215E43E940C45FAD0E88B64371AD1C27458D7A1FFC0DFD
          0976128CDCE780334AB57AD4CAF0259D1510F85CC55810C68C12A25721F745C4
          10EF198B61452D5606F73CC854C94E36F897C0D3818662C688EF5985A1CF20B8
          120A56386853F0BBA55C35D8509C0E522DDFA8311C1CC5DAF37D1AEA25C8EB41
          0EC2C84D359984B2D6D74005E58F75082ED7D1283FBBED36DB001F6E67BE8DB5
          5C4DBA7C9563CEC741F73E16403F1E294E432BE01E9A9E3E74DCB831D4D9D989
          FE4C2F962AB9A82A47B0BD9DEAEBFFA47BF79AE9415B1BA76221C045EEDA8401
          A1F42D3762F7D9932791C39124D650B6A1D56A233555699379BCA61CBC2EF731
          DC96DCBA5DFB3DD86F00587DAF8090020B9436A7A40C5C8D0ECB81EB84920082
          A4DDCB5D2B47C4EF0F90C9D455CC19806C570629F3D5C659F779F2F9FC79AA80
          006629C89EF168B29C2903233B63077C3DA1E58B389679F2CE65B0CA947134D8
          15DA6DF159BECEC466AEB9856A7EB97E17AF997DA6ACF8E831A756A75B09E739
          78F561B7A5EDEDC16346A3690D780BE1D4001B877C5EEF61B3C5B219D12A84B3
          7638FA1277E96E7DD2A0B73B6DCE8280C961D20AA16B41BF77674A73ED348BD9
          340FFADC9E9EC3DC80745DEED73714EFC0111F0B72839FB928CB432A853CB6E1
          F8BFD953EF7102E236A69CC17021936F0AB9F462940150D123010467B3403EA4
          87355C1E95986BB99E4B72C9201B0186AF309314219659079973B16C270C88EF
          01900770A2A9ABF3A003E41FCA261A316290BC7336688BD5F0C633FA1BA11F00
          68810AA0A8FB05F2F341166132BF13B318F300E48E3F12400A47DCA6B1B300E6
          E19E7714D6B985F100BC4305BC07334D7955C70404434EC9D10B12EBA8E4B029
          41C05C096B0168B80AA07B988395B779AC1FF2DCC58D5739AAF598C361201CC3
          F90890E730F9E75C0964FE50AC71ABF91EE6024C767E08731364EEF69A32EE8C
          401A00C6A5725419880B86FE51E8F07F4F93553610F9C11AEF88152106B5040E
          784723250775201B31F72BDB57FEE307A415B27A950DF088B4BFFD0294E8E0B6
          19E45D80E11FD33A69039C36FEC1CCFFB079FE5384FECF817B31FB5F0C67386A
          3CF607710000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage4'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000669494441
          5478DAD598796CD44514C77FBBDDB6F6A0D0965EF4E06A51399480A01195C4A3
          5C220650041B4D436B43C50402882488021251AB88060A14E4B280126A382247
          14C11839E4D01894A3147A17DA12A46577BBF4F0F3BAB3F8EB1EDDADE01FFE92
          97EFCCBB66E6CDF5E667D0346D604B4BCBAF9AEE33C0D07257E765533E091D9D
          9695696865CA872014463D78C4A1B914C65B6DCC1D1FC20284E3DB30F90AF4FE
          3A03990E5FDB517F01C67AC3CA556B4C541A614E8511E6ECE376477BA155B439
          7F6B737D7DBD413AAB6BBDBC5569FDC6CD66ABD5FA973484C29EBDFB0FB48C1A
          916A589DB7EE507373738E8B6B2C8D283683E7C07BF5CD05C33083E7C13E4E46
          BB5D3CB9F9763B87A82A806F6AFAAB11AA2E83D8E9682E1EDE75E83598CBA837
          2724C41BC68E192DA3DCD5AAB48FD1D4D4D66A6953261B50188F40A66813E596
          3673A76B721182052EC1D429C4A070050C910E537E521F828B946B610E55CA7E
          949BC06960AEBBE66E2008F3D89C93F22494BF6A5749293E039C42B9D65BC46F
          3BCADFB2ADC5DFDF5FABBD76EDBBA0A0A0A72D16CB2C1C7CA21C2E484C4C5858
          5A5AF630BCE38AF739301D9A076FA97ED98E82B1D731637171B1CD9595553F50
          7D343838D864369B0355505A17B1D20B056AA8DFE31C6E931822F8D1CD308D40
          1D149C929CAC5D282CDC81DE4497A1A1D803100773A02F500A7172B402DEEBBA
          BAACB70FE165789B917294E255791FE5911EF4AA9145799BB5C78062144B75BC
          0A6093FE1471E9114A5F02DDA03328BEE1E4F411A0127EB1AAA703171DF1F465
          53FAF4FDF78EE87A10309CAEEFF3D91146C91814EA9C64026B58E9E52693299E
          553E0179819BC6D2805790A53A1CAD829185D1F9D89898AE65E5E5E1088D4AD9
          0FB04272F2F553BC703F3FBF9AC08000ABD9628980DFE03C6B2F8A11825D9453
          288FA39CA36479DD9312334A4ACB3465F314B283CE4313E6F73A87B2596740FB
          3B85868EACABAF7F07F922250BA06C53E5F78154EA831D8EC4685960606053EF
          5E3D8D7FFC79567A15AC737C4D109EE3187E80F8FD866D51E6D4F4DE2EB38642
          5FC082C125550FA17C5395674447472DABA9A9D5B85FC4482EA9CBBE4CFF7D28
          9E053F0667F9BC8E30780FB802C92C9DC6F8B0CEA91C2FE9F0F274BCDFA90FF0
          DA23A5DC0FE533BAFA4E200E9A0FFF80DB1EB9711284B2057C99AAA40516373A
          5DE05F771E9A9C76CF42328C3751A87032CA85374D5797BB29D2971E99D482DC
          A1E3C9B53817EAEB384EDA3852D7738B07878300B3CCA03B19FC53CE43937D54
          A08696ECEC18B9DC6F837475B98BC7FA346B6E7AF09C66BFCB463BAEA47FE5A8
          BDEFAE39BA5B5F873BA432A8D546A3B16B6C6C8C565151D9405D2E1F4901AA3B
          DA01FCF9032D8E90B7E9D0AA356B2F85868424708CADA5BADCB172D4D2948B7C
          C9D0210F198EFF726221E5C52AA518C6A1BB9C9C713027BBA8AF8466BBDB50BA
          4E0C043E8B8C88789CDC4758DFA23FC66D84A40160C180FEFD522F1797687575
          755A4A726FADB8A4B4D666B36563F8753B0D0D23725B38F592A836D2D1754D4D
          4D72AB3441CF4333232323C2AD16AB76D36CDEAAD93774D99D4ED93C60110D9B
          7AF6E8AE5D2C6A3D918F41D98E3DA7F49E00E643C32123D7DC89C6C6C65CCAF9
          12599D9E74DE06AFCAA543BC192A22C2C3E3C8B87F922983F6A068959C99B2DC
          4E53FAA424379DBF503819FE76E530C66030E4F8FB9BD26CB65BC23A04A5212F
          6F67502F011FC5778B4B28AFA86C65A19FED69CAE4349EDD3D2929E36A757598
          AC8BE8A828C9734F12FE2C0C4FB6D350A2665FE0121D8DBCF828F62B74533631
          2C2CCC686B68B0581B1A9650CF918BFE8EA64C35BC11980415A9C632707CCC49
          2701908B505E2072B7FD2C93D0DE805C3AA4B6A0BC293EF590634B02B141DE91
          6E64B25664A18E417EDA8741F5D7EC6B2F0EFD1B5E2324598B66BFDEA2A02A79
          FB7520829381B7A191D895285EB44452F9940CA8DE6B843AD0E03940B6AB5C8D
          E334FBF65DE7415752D940C785EEED739E323FD5D062CDFE9AB1EA645D806DD0
          58F8B7DC342CCF04798BC93337DFCB8024BB9DA00632C4E70861783F20B9A23C
          E8CE7520820F0292334D810EAB3F1C72E0CE862E539FE953847C6C4CA6409EEB
          B2D3E4AC19A1D95F5FD33BE4E81F7FB18E43D1A5432A9492251E813ED04705D9
          60E020BCCE1E1CCBFF8C0DD05574E678E9849C57595017E781789B32894627E8
          867E3DF9306AF977B109929CFA1B480E3F49A6DE85E6CABF164FB6FFFF7CE83F
          ED8CC130F06F0473F88FEBA8C64C0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage5'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000A10494441
          5478DAB5580954935716BEC99F3D812C080883D651D02AA8202220A0A8282EC0
          E0B8D4A5DA4EEBF4D4ADEDD869DD46DBA91D1DA73D8AD656676C9DAA47716915
          05155184B0094604147041452CB24302842C24E49FFB024921045C66E69EF39F
          F7E7FEF77DEF7BF7DE77DF7B6100802F4DD385D8C2B5F48C5553C3277DC74005
          DC292EA1877B7942478709381C3698956541613AAFDC4CDE8AE277D4DFFB1C12
          9995101342C3F96C0681080A9830CAAC8C8A8A6126259D37ED2C5E48AFF739C5
          E8B4EC121CA85361301868BD5E0F42A1107A581061D0DB37D051D9255F4A3FD3
          AC5633C5090CA5AF7F9AA4E0E614F2F5B307CB4DBDBA64646537844E0C766230
          1840BEA4CB33737B1975316096AA53056BA2FEAAEE1C0B8D545322AE5114F82C
          E6099291FBF22FEEC4D0E979BA0FAFAD48D98B13635B9194E302BC96B9BBED42
          A3680B627CED167AB1EB36465FC3BD868D237AF78E75388B5C494D3B356DCAE4
          0566D2A837996860B1A84E24ECE9141612DC60329980A258C463C0E371CD1D9F
          543C05BBC375454290ABB8A1B10EA70C0C69AA17F0A8E169A962A23CA7FA8ADE
          31FD341B8D8CBF724A384E43EC12732CDF948FAB8AF09CEA76203683834606B3
          51E3B8406F998F4BB1F24E8D567AEB866061CEC41AA7C72E5EFBDF4C68CDA54F
          D1418C859DC4D5E37DEB45370B9DBB73DA7177217D4FC76D39EC77546C258E99
          B2021DF9BDC56863FE543A7DA346703D2557DBE7ECBA4BCAD56B17F87CFE6C17
          6767F01C36143534E429F241A7D32D4187C7F772B8452E26A70CE272B9A5E193
          4245E437B1A13001B45A2D9060F0783CB0E83B3A3A08E8ED5E40A96972D5681F
          6F31098C52A58251AF8F80F48C2C9832390C6A6A6B81C668BAB838636AE6C0E4
          49A15053530BF71F944DB4CBA8C93FC855969F5B6BAB9F991B1DFEB6F78CB4B8
          A9478596A0FEBA4CBA0391F835AB60F1C98BBBE32F26ADEB960D8C6987871AC6
          3A8FA28E9717D5244CF8D9CD76102B50FBB6AD7A8EB185D394943B12D9DCC308
          5DC50845442A667E7DC86BD3C7DF3DDE0632C96FE1F41B8524C5B4A4CFDCA2F9
          B71A4F341CC8D891FE2F33104E8564A98149C1A72243EDE7AC82721E025D42A0
          59F6A238B7203664D96B8159ED6C11E0345908DCD1636A4ABF807A6981C21941
          E623C84FF640DE49F7360C9579B2064A86405271C5E584D90933FB0C7F7F1299
          1FCDC766C165FFC4237D3BFB39826BF7CFD81CC3C70513B1E8A5808E1D3F31D0
          CDDDBD9ABC630180B6360D88442252E28EA2EA2F08F8B45F204CCC49D87CC3E7
          F1C604050698339A88C59EB40585B761BCBF1FC32ED0DEBDFBA8D7478DF2C34C
          5690F2C366B3CD20E4BDA5A5051C1C1CCCCBA53B58734B0BD5030859E4074D08
          18C766B3AC9D49ABD5E980C7EDAC631C0EC76A4FFA1A71AD65655F5FDE030857
          F9229150188F6B0D14F9B7687F3F5F0620F1FAFA06183CC803B27272CD6BEED1
          A3C7209148C0C9490669F2CC36F493E8A5C33F333F5A9FEC9FC8B5D5F7B56807
          E03269B0D57F52F6C1DDFBF72B8ACE479D5BD42710769EC014098F7C2271F4DC
          59594D8054364C8C1B7CE6525B371F8EC8F85A9EDA27903220D820DDBC96D5B2
          F787862502E1315C221F598C6273E79C8A72F75CE0828B76FBB4E3125C5BCD7D
          0299FEBD9F66365643537CCA90E56E2E3310E8A09989624E9C0FDDFCE1209917
          D401DF707591428891A4104C47BE638991E2BBB2732B0D9BB256B22C7AAFFAD4
          857AD1D5541762800B773A825D599A319A0E9605401BD5068A6643C94F41677C
          2C2CD63D5C5DB3CBF3DB815646EA254BEA45EE8201F0E80140432D3469A44C64
          B50981FE1699374D2EEB504F6CE5BA3425F927BA5A404EA8E254C7CAE49CC480
          B3022B103A9A497EB0591D4693DEB8475C58F02764341B812EDA4B81F7EE2C69
          7AC3335CFA55D2B933C90B2ECCB38D9A37C7D87A4D5454E28A20F310E4677B20
          731451ADD1CE83458364C3E1EF9BCEC464EECB48EC1935FF4083343F8FDDE59F
          14049A610B32236F56E172A9CFD85ABA1AD84237383E572EECB1B31369F6F5DB
          8A53FA0241921024CA1E9B48C5ACB6CFDCE70BD25417205367D06186F3FBCDEC
          BE04AB23614C4AEB2DAC90CFECE6D1FF42B08292D4F90D6EAE9E587E7E741089
          041ADC9DC96ECC24D5A4732C3971352EF4367B18FF35A1A48BC903F128A0F070
          77F71831C20B8C46239ECF58E6526529AADD45DFDE0ECF9E55415393125AD5EA
          76544523B994572684A5EF2D0ECEDE77EC18108B1DCD35946030994C6B4DED8E
          4974E45B7721DF2DE718722C79F8A83C01D56B90D8B37E096108F8D8698B4C26
          5D85272C316E27E08824A06BF696532BF18856AB032EB7B3981302165C0B498B
          BE2FC953DC048D461BDC272124B30C9B2323F190E524935A67460620DB131EF9
          AC035B7496995BC8760F19F106190A8FDBE677CB76663ECC29555072F7DE2FF8
          73D47343967CF98A1393A2DEC5C1FDF0A706679BD6DEAEBFC2E17057A32E1A07
          6523C679756BEB452E8FB705BD158EDB5E3B0E7414F7D21FD1AB6B29162B0C27
          60140A04E7EA1BEA8F0B85A23FE2B97606F627C7D31BF86CC270DD7EA51C7A19
          89CE890DF272F6385DDE58A3A95EFBD41F8B8DFA797D5E8850616068C81016F5
          4FBABD3D5DAAB8BEE679F65867648E14BF74DDE8B9AE99D5A5FA4B89B99BB587
          9AF72121FD2B1152854FDBC17474D8E0B0281A18023E14E6DC80BDC50F95754C
          A607564D4D7F80313763EECF761D36DC45E80262BE137C7B374553B7A7C63BEB
          70D69317F16A2F42CAF1C161DC80B1E7049193A498B9D0515800EA8CC2A4A532
          E97CFC5C8CCFEF9054A92D506C7AC44A898815375228E61022E431523C387D5B
          915DB7BE2A12BDD3F6D284704773A0C40E15E20FFE20855F9E80E97139B4E496
          CA25D7B3C3C977DC5748129223A7D553189EF11CADEA44A8D075189F2584868E
          3AB010BA545FA9A93D5017987530B3D8DEE02BCBDEDBF920BFA23175D1E57FD8
          25A40A995C277977BE33545680A9AA0A548AC7B874A1152F772C5CF4E47EFFD6
          3277D750342D4342DF9809DD9CBD51D656F9F9475E1F736E34A643A5BE1C1CF9
          32C8D11B3B4C3AFAD34B131377D912892A987B6FFD98051EBB8BCE326BB654CE
          CCB9703DA31721BC3B1FC40AF636AA8CE47A498A068BC3603A705B386A15B30E
          EFE453F16E52825E8A43F37224B4C72691C91F05A460D5E1938D9B66AB2D9179
          45BF7FDFD771F0F630F731D236DA0487B2934B9E6D783A1DC359DD6F5277E652
          609314AAA54AD3C016BC968BBB42464A31E93C0C09A9E00565F6D999033883B9
          4FA29C87081DBBC229AF2ED366C7176D926F4D8BEB37A989348F9FF00357DFB8
          544F39EEC633C946ABABA36272B0D98264529F4FC3EC3509B3C378C71B5A3D48
          182DB925C2F7C38F6E68EA5755F9A077CAFB258427ACE90C93E134CD60F9A267
          9E74111980CD7532592453F682641C6883F6E9BC01C325218E11105FB91F2CA4
          14ADAAF68727AB62E55FA65FB2ED67BBCA24A84895DECAF3EFE615F2DF50AC6D
          CEBC88449C1C2EA53C473489F50D3A119BCF68A6846A064D9DA97CBF6A25B940
          DBEBF37FDD3A5E56705FF4FD0FB6AF5245360D55E00000000049454E44AE4260
          82}
      end
      item
        Background = clWindow
        Name = 'PngImage6'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E000000097048597300002E2300002E230178A53F7600000A4D694343505068
          6F746F73686F70204943432070726F66696C65000078DA9D53775893F7163EDF
          F7650F5642D8F0B1976C81002223AC08C81059A21092006184101240C585880A
          561415119C4855C482D50A489D88E2A028B867418A885A8B555C38EE1FDCA7B5
          7D7AEFEDEDFBD7FBBCE79CE7FCCE79CF0F8011122691E6A26A003952853C3AD8
          1F8F4F48C4C9BD80021548E0042010E6CBC26705C50000F00379787E74B03FFC
          01AF6F00020070D52E2412C7E1FF83BA50265700209100E02212E70B01905200
          C82E54C81400C81800B053B3640A009400006C797C422200AA0D00ECF4493E05
          00D8A993DC1700D8A21CA908008D0100992847240240BB00605581522C02C0C2
          00A0AC40222E04C0AE018059B632470280BD0500768E58900F4060008099422C
          CC0020380200431E13CD03204C03A030D2BFE0A95F7085B8480100C0CB95CD97
          4BD23314B895D01A77F2F0E0E221E2C26CB142611729106609E4229C979B2313
          48E7034CCE0C00001AF9D1C1FE383F90E7E6E4E1E666E76CEFF4C5A2FE6BF06F
          223E21F1DFFEBC8C020400104ECFEFDA5FE5E5D60370C701B075BF6BA95B00DA
          560068DFF95D33DB09A05A0AD07AF98B7938FC401E9EA150C83C1D1C0A0B0BED
          2562A1BD30E38B3EFF33E16FE08B7EF6FC401EFEDB7AF000719A4099ADC0A383
          FD71616E76AE528EE7CB0442316EF7E723FEC7857FFD8E29D1E234B15C2C158A
          F15889B850224DC779B952914421C995E212E97F32F11F96FD0993770D00AC86
          4FC04EB607B5CB6CC07EEE01028B0E58D27600407EF32D8C1A0B910010673432
          79F7000093BFF98F402B0100CD97A4E30000BCE8185CA894174CC608000044A0
          812AB041070CC114ACC00E9CC11DBCC01702610644400C24C03C104206E4801C
          0AA11896411954C03AD804B5B0031AA0119AE110B4C131380DE7E0125C81EB70
          170660189EC218BC86090441C8081361213A8811628ED822CE0817998E042261
          48349280A420E988145122C5C872A402A9426A915D4823F22D7214398D5C40FA
          90DBC820328AFC8ABC47319481B25103D4027540B9A81F1A8AC6A073D174340F
          5D8096A26BD11AB41E3D80B6A2A7D14BE87574007D8A8E6380D1310E668CD961
          5C8C87456089581A26C71663E55835568F35631D583776151BC09E61EF082402
          8B8013EC085E8410C26C82909047584C5843A825EC23B412BA085709838431C2
          272293A84FB4257A12F9C478623AB1905846AC26EE211E219E255E270E135F93
          48240EC992E44E0A21259032490B496B48DB482DA453A43ED210699C4C26EB90
          6DC9DEE408B280AC209791B7900F904F92FBC9C3E4B7143AC588E24C09A22452
          A494124A35653FE504A59F324299A0AA51CDA99ED408AA883A9F5A496DA07650
          2F5387A91334759A25CD9B1643CBA42DA3D5D09A696769F7682FE974BA09DD83
          1E4597D097D26BE807E9E7E983F4770C0D860D83C7486228196B197B19A718B7
          192F994CA605D39799C85430D7321B9967980F986F55582AF62A7C1591CA1295
          3A9556957E95E7AA545573553FD579AA0B54AB550FAB5E567DA64655B350E3A9
          09D416ABD5A91D55BBA936AECE5277528F50CF515FA3BE5FFD82FA630DB28685
          46A08648A35463B7C6198D2116C63265F15842D6725603EB2C6B984D625BB2F9
          EC4C7605FB1B762F7B4C534373AA66AC6691669DE671CD010EC6B1E0F039D99C
          4ACE21CE0DCE7B2D032D3F2DB1D66AAD66AD7EAD37DA7ADABEDA62ED72ED16ED
          EBDAEF75709D409D2C9DF53A6D3AF77509BA36BA51BA85BADB75CFEA3ED363EB
          79E909F5CAF50EE9DDD147F56DF4A3F517EAEFD6EFD11F373034083690196C31
          3863F0CC9063E86B9869B8D1F084E1A811CB68BA91C468A3D149A327B826EE87
          67E33578173E66AC6F1C62AC34DE65DC6B3C61626932DBA4C4A4C5E4BE29CD94
          6B9A66BAD1B4D374CCCCC82CDCACD8ACC9EC8E39D59C6B9E61BED9BCDBFC8D85
          A5459CC54A8B368BC796DA967CCB05964D96F7AC98563E567956F556D7AC49D6
          5CEB2CEB6DD6576C501B579B0C9B3A9BCBB6A8AD9BADC4769B6DDF14E2148F29
          D229F5536EDA31ECFCEC0AEC9AEC06ED39F661F625F66DF6CF1DCC1C121DD63B
          743B7C727475CC766C70BCEBA4E134C3A9C4A9C3E957671B67A1739DF33517A6
          4B90CB1297769717536DA78AA76E9F7ACB95E51AEEBAD2B5D3F5A39BBB9BDCAD
          D96DD4DDCC3DC57DABFB4D2E9B1BC95DC33DEF41F4F0F758E271CCE39DA79BA7
          C2F390E72F5E765E595EFBBD1E4FB39C269ED6306DC8DBC45BE0BDCB7B603A3E
          3D65FACEE9033EC63E029F7A9F87BEA6BE22DF3DBE237ED67E997E07FC9EFB3B
          FACBFD8FF8BFE179F216F14E056001C101E501BD811A81B3036B031F049904A5
          0735058D05BB062F0C3E15420C090D591F72936FC017F21BF96333DC672C9AD1
          15CA089D155A1BFA30CC264C1ED6118E86CF08DF107E6FA6F94CE9CCB60888E0
          476C88B81F69199917F97D14292A32AA2EEA51B453747174F72CD6ACE459FB67
          BD8EF18FA98CB93BDB6AB6727667AC6A6C526C63EC9BB880B8AAB8817887F845
          F1971274132409ED89E4C4D8C43D89E37302E76C9A339CE49A54967463AEE5DC
          A2B917E6E9CECB9E773C593559907C3885981297B23FE5832042502F184FE5A7
          6E4D1D13F2849B854F45BEA28DA251B1B7B84A3C92E69D5695F638DD3B7D43FA
          68864F4675C633094F522B79911992B923F34D5644D6DEACCFD971D92D39949C
          949CA3520D6996B42BD730B728B74F662B2B930DE479E66DCA1B9387CAF7E423
          F973F3DB156C854CD1A3B452AE500E164C2FA82B785B185B78B848BD485AD433
          DF66FEEAF9230B82167CBD90B050B8B0B3D8B87859F1E022BF45BB16238B5317
          772E315D52BA647869F0D27DCB68CBB296FD50E2585255F26A79DCF28E5283D2
          A5A5432B82573495A994C9CB6EAEF45AB9631561956455EF6A97D55B567F2A17
          955FAC70ACA8AEF8B046B8E6E2574E5FD57CF5796DDADADE4AB7CAEDEB48EBA4
          EB6EACF759BFAF4ABD6A41D5D086F00DAD1BF18DE51B5F6D4ADE74A17A6AF58E
          CDB4CDCACD03356135ED5BCCB6ACDBF2A136A3F67A9D7F5DCB56FDADABB7BED9
          26DAD6BFDD777BF30E831D153BDEEF94ECBCB52B78576BBD457DF56ED2EE82DD
          8F1A621BBABFE67EDDB847774FC59E8F7BA57B07F645EFEB6A746F6CDCAFBFBF
          B2096D52368D1E483A70E59B806FDA9BED9A77B5705A2A0EC241E5C127DFA67C
          7BE350E8A1CEC3DCC3CDDF997FB7F508EB48792BD23ABF75AC2DA36DA03DA1BD
          EFE88CA39D1D5E1D47BEB7FF7EEF31E36375C7358F579EA09D283DF1F9E48293
          E3A764A79E9D4E3F3DD499DC79F74CFC996B5D515DBD6743CF9E3F1774EE4CB7
          5FF7C9F3DEE78F5DF0BC70F422F762DB25B74BAD3DAE3D477E70FDE148AF5B6F
          EB65F7CBED573CAE74F44DEB3BD1EFD37FFA6AC0D573D7F8D72E5D9F79BDEFC6
          EC1BB76E26DD1CB825BAF5F876F6ED17770AEE4CDC5D7A8F78AFFCBEDAFDEA07
          FA0FEA7FB4FEB165C06DE0F860C060CFC3590FEF0E09879EFE94FFD387E1D247
          CC47D52346238D8F9D1F1F1B0D1ABDF264CE93E1A7B2A713CFCA7E56FF79EB73
          ABE7DFFDE2FB4BCF58FCD8F00BF98BCFBFAE79A9F372EFABA9AF3AC723C71FBC
          CE793DF1A6FCADCEDB7DEFB8EFBADFC7BD1F9928FC40FE50F3D1FA63C7A7D04F
          F73EE77CFEFC2FF784F3FB25D29F3300000AEB4944415478DAB5570970944516
          FEFE39924C263393C99D4902B9231882E62024C188174781D69658CB96945B25
          22251E78162878808BCAE5B14229AE8AAE08BAE8B2882288182E212124E43E48
          420E929000992493995C73FDFBBA937F32C404C1DA7D550D99FE5FBFFEFAF57B
          DF7B2D00901597963B2F5DBE0C855CBE9A7EBF21A4A7A661FDDBEF5C9A993D23
          481445D8ED7608BF1C39E69995913EC0269828954A3E89E5CB1EC3E6FCA5E29A
          3B7709EC8330EBCC5CAE1162F2C4B9175B71BAE00CF8979F7EFE852F23136ABE
          346BFA3451E9E18196D65608030303A2200860C3E17040C8397A1CAF7EF9528A
          ADD85A38625850C0F458FB88D1BCFC02F4F5F5C166B341A150344E4A889FA8D3
          E9E0A5F2C2B1E3BF56F0D3BCF4DA1A4C888810931227A3A3A3034141411C22DB
          87160D1D846DBCEC91C5C8CACE162C4FF4AD6F78A876A54C2D93939E7368FFFC
          D990646BD453E2C77DDF8AC71754C8A439994C368489C9071F7E84B8F878F498
          4CD0EA74DEF4D140D375DC12FB876D79AEBA9A293D191F17BB8561318486C283
          1C72E4D87141B823FB76BCBCF675CCC8CC104FE5E5217B461624071DCE398AB8
          D8680819D3D2994F15878FE4D8980B98A8542A389D4EE6671CFFF5D423426DDD
          79313CCCC00132611F99C8E572EE0252DA21ECFAEA6BF24B30C7D41567822DDE
          78F1E0034723989B6878D2187429AD5EB9020F7C75B3B8E7D3F32F3A0F0F6C80
          9BB8FCE4B4751F9AEEED7BCFC1855704B956EE52E07727450944271C14143D0B
          DB20D3CA5075AE1A3D66335C7E92A4E06C317A7A7A505D558598D8587E18279D
          D0D2D3B3242030F06376EAB4945B31383888EA9A3A188DC6A5B4EC5306841BBA
          F3F69958BD66ED9065F22119524546453F3977F6DD1B0BC9F8C0E0006263A2A1
          F7F54557B7090D8D4DB82529915F087365EEE933953C9AD8CE2B5F7915AB9E7F
          0EEF7FF48F4D6A95EA058DC60709F171DCA53C4568030CA70AD3BF78F1220C06
          031A9B2EA0BEA1F12E6EE8B9152BEF4B494DF92E3CD4008552EE0A4776046688
          FDCD8C49F725E5DE884B8A441EBAE69E9E380AB21A7F7F3FB4B5B5EF235FDCC7
          C2A3A2A2AA5CE7AB4B3C1D721A938B26E77907A9A7474E9C80A2E2E20243A8E1
          D6C88911F2C2A212D162362BB8A14BED6D0821344E42F2C4D247B1FCB9E7B1BB
          6827E48FFA2C597FEBC28F5FD9FDCD675D9B2E2F169457DDCD55C20D5D6E6BC7
          E753BF84D83F0459841033B1B7B92C26304EA5D54FC43F5F3A79B3506EAFC435
          642446DC847C90E267ED3C6657FBA9D4462F79D5E3CD3C6E464B4979198852C6
          37C4020F320F38E422C28C0AB81BAAA9ABA510E8FE2D221A49344AD90F96DD1B
          366C828F46E38AA94EA311148C9C32E9F6160DEBB2E429186D884B587838BED8
          B11326DA6D0C431DE43DFFD4E45B688100AD560322C583A4B29C46ADCB905EEF
          876FF7FC872F7633A4A3B19F8CA5DD7DE74C8FB2F24A0AD05898CDBDA4AFE3B1
          5451598D0EA391E9F5082C4A8F9E38099BD5EA6E282C3434A4C5DF4F8F0BCD2D
          E4D041DC7E5B162AAB88B76263505C5286B4D4641EA0656515307675A9846929
          A9D8FCFE166E887649A780CB9B382102172E3443AE90332276B190C4482CF24B
          CACA1144BE0B0909C6AF277317F314494E4DC5F4CC4CECF9E61BCDE3CB9FEE89
          207F6929D728AAE1ADF2E669E66E8C95025663CE1697B234B291614F97A1B4F4
          746834BAC50F2CF8D3A78C2C99A3BBE9986CF7E0E0606E84CD31DF4879C77EE7
          9ECEA7FA62970B333232E56BDF7CABF58E99D9C136AB8D9254068BC5024F4F4F
          BE3B1B12A94A46DC857D27B2D5B014A9CBCC488F912882653ADB4D6200F6BF3B
          434B612119646468B55A95C2C19F7E66568F6B349ADB0499D0DFD161DC17131D
          BDD0E1B033023B3B2BF3AEE4D74AD7E1B6DECCB2A94949533A3A8D686969AD9D
          3E2D35AEBEF102CED7D52D50ABD57B8483870EE3CDB56BF0323164536323720E
          FF8CFCBC3C61D78E7F8BCB55CF6A1F899967DABEEABB7BC502DB419ECF234389
          A112C1618E69A824B7080987E211250B16E383A2B0FD2FDFF9091D62D735B37F
          B4A14F3EDAC6E9E4A6BD61E76679DF14DFE425626FC66141E6565AC635B4FA6F
          2BE0FFAEC135E961ED3D90E4893951019371ACC578AC6669DD4C41353EA99D39
          5B787503C0190442C42C8FC00B7D8E4EE87481D8FB45D333FD3F5AFE3E9E91C2
          E2A2A1666A2C3E52D8FB9AF4B085384C015B5AF3CD2F58F7597EAB43A171322F
          77E46863129B93DA00B917F41D5476F2CD7037E441A97122F7D46F7D74238658
          413C71EAE4D8CE1EEFEC919191D8B3771FCFB7EEAE2EB4B7B723362E8E47B4D4
          D5F03DE9777767273FAAAF5EAFA2F930CAD5005258A7F5F1B9CB4159C2EAA34C
          CA53E03C2D9B4FA3FABA00B1F6E5871F0F10110E37198C04AE01885D188D55FE
          7E7E6F4CBA2901BEBE5A4AC911EABA6A335A63A7CCA31A8C2B578C3051BF42F6
          1EA44FBB212588A4ACD56A7180D257AA52EE4646010A149DCE77A9395C346952
          828B1F18D0DAF3F52C9D3901492D1FF722FDCDF492A87FD153372C7D63E332F5
          FA3575F587686E19A9D6737A641F8807B0F6ADF5AE0AE00A73518C22509B8282
          02179017E0437A4A0F251A1A9A78EBEE4B1BE8F5BE9C09030202C05ACDD1CC27
          1D8C5A16223505BC08B0BFBF1EAC63910932FEED4CE159BA154B3607C484B938
          99AAC9C2458B30DCDCAAC9F02A6A6F56C553F9615D8AA5B717BD44FA664B2F62
          A223A1D3EAB8DBA927961E1B502AE8AD2213D80B870FD10D9075A84A71DD7335
          B57C6DD29444F4F5F6A1BCB2EA227969CA55806E494EC6EC79F361EAEAC48675
          EB10979010F9EC0B2B76EB74DAB4A953A7C041F1C2685BBA0626ECBA7A09289B
          F7F6F61E7A290CC797146F52B191C4CEEDB08A3680A29252F69BF5B28FD3B0BA
          03120890DF3D73E6DEEFE1A1CCF4F25485EB749A49A929C961EED5CC3A7CA55E
          5E5E3CDE1818C903ECE42C7EF843C80D801463636615E9B12C3C53585440FB64
          B182462FB8FEB90643D80FF4CA12D862E9F4EE22554817C5B805ED5815F34644
          4E0728292913E90A8339208A99343AD501222CBF8C69A99C5B9C649F4281370A
          ACA59972F36458877B01B679336513D363F1D53FD88F2BD60E78508933367551
          D3A1451805B7F4D0624D5945F53944514BAD56AB382D30619E2CAFA882B1B3D3
          D26BB124D25413EF8AD9C24E6307B66DDDAA58F3C69B29769B2D8B3CD2D5505F
          7F64F3FAB71A1393923C973CB66C36CD3D4C8B3CC953DFFEB47FFFF68B2DAD61
          7F7E74D16BD5FAF2BF5678967B263427EEACFEA47CB9D3C3699B7BEFFC25D400
          DE4FE7521329FEB86DEB962DB4CE3C67DEBCC586B0F00729E0C3E9366ADBDADA
          D67CF1D9F6538303030ECE6FA30081008100F12B22402040BC6B9A41EFD07736
          6EC0AC997391F2F4747A516D87CAE6FDD4BD11D3DE4F0C8AC48EDC9C9CCA0F6B
          9E91953ACA042FE10F5FDFEF027AEFEDCDF0F1F1198A156A0454195EF0795E37
          7F8243FB7D76403442B5E1281868C1DE5D2737DAFED5B71266BA0EC5FF10D0EB
          EBD6E39278095B751F4025AAAE0E3EAB2D4865B36F8ED0793D14EDED0FAD7700
          74EA40149ADB7A73DE3BFBA47D7FFFE7328DEC0F42190634AB60FEF5A8299D8E
          C1870D76EB9654B5C16340B0A34FE88341138666B913270E356EEBDF697A025D
          AC46DCB87758E1CD2F2C84C3E918A76D1825A22084C06A7A2F4B19B4F0EE9039
          F8E5F2F7B00BFDE8566A512D77E4D9BE362FEDFDBAA76CAC57DCB584D1086BCB
          A46C1CF2D075001A4245B1213A822157DDC3203AE4280BB8242BF154C8C48653
          260C7CD983DF03C488B3A8A498979FF1AFECC600D1B1585C89F42C0508100810
          AE05883563A5E5E554B74CD7B5CDFF0D1003525155854EAA8B372049FF0591C4
          B22A5E1810A90000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage7'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E000000097048597300002E2300002E230178A53F7600000A4D694343505068
          6F746F73686F70204943432070726F66696C65000078DA9D53775893F7163EDF
          F7650F5642D8F0B1976C81002223AC08C81059A21092006184101240C585880A
          561415119C4855C482D50A489D88E2A028B867418A885A8B555C38EE1FDCA7B5
          7D7AEFEDEDFBD7FBBCE79CE7FCCE79CF0F8011122691E6A26A003952853C3AD8
          1F8F4F48C4C9BD80021548E0042010E6CBC26705C50000F00379787E74B03FFC
          01AF6F00020070D52E2412C7E1FF83BA50265700209100E02212E70B01905200
          C82E54C81400C81800B053B3640A009400006C797C422200AA0D00ECF4493E05
          00D8A993DC1700D8A21CA908008D0100992847240240BB00605581522C02C0C2
          00A0AC40222E04C0AE018059B632470280BD0500768E58900F4060008099422C
          CC0020380200431E13CD03204C03A030D2BFE0A95F7085B8480100C0CB95CD97
          4BD23314B895D01A77F2F0E0E221E2C26CB142611729106609E4229C979B2313
          48E7034CCE0C00001AF9D1C1FE383F90E7E6E4E1E666E76CEFF4C5A2FE6BF06F
          223E21F1DFFEBC8C020400104ECFEFDA5FE5E5D60370C701B075BF6BA95B00DA
          560068DFF95D33DB09A05A0AD07AF98B7938FC401E9EA150C83C1D1C0A0B0BED
          2562A1BD30E38B3EFF33E16FE08B7EF6FC401EFEDB7AF000719A4099ADC0A383
          FD71616E76AE528EE7CB0442316EF7E723FEC7857FFD8E29D1E234B15C2C158A
          F15889B850224DC779B952914421C995E212E97F32F11F96FD0993770D00AC86
          4FC04EB607B5CB6CC07EEE01028B0E58D27600407EF32D8C1A0B910010673432
          79F7000093BFF98F402B0100CD97A4E30000BCE8185CA894174CC608000044A0
          812AB041070CC114ACC00E9CC11DBCC01702610644400C24C03C104206E4801C
          0AA11896411954C03AD804B5B0031AA0119AE110B4C131380DE7E0125C81EB70
          170660189EC218BC86090441C8081361213A8811628ED822CE0817998E042261
          48349280A420E988145122C5C872A402A9426A915D4823F22D7214398D5C40FA
          90DBC820328AFC8ABC47319481B25103D4027540B9A81F1A8AC6A073D174340F
          5D8096A26BD11AB41E3D80B6A2A7D14BE87574007D8A8E6380D1310E668CD961
          5C8C87456089581A26C71663E55835568F35631D583776151BC09E61EF082402
          8B8013EC085E8410C26C82909047584C5843A825EC23B412BA085709838431C2
          272293A84FB4257A12F9C478623AB1905846AC26EE211E219E255E270E135F93
          48240EC992E44E0A21259032490B496B48DB482DA453A43ED210699C4C26EB90
          6DC9DEE408B280AC209791B7900F904F92FBC9C3E4B7143AC588E24C09A22452
          A494124A35653FE504A59F324299A0AA51CDA99ED408AA883A9F5A496DA07650
          2F5387A91334759A25CD9B1643CBA42DA3D5D09A696769F7682FE974BA09DD83
          1E4597D097D26BE807E9E7E983F4770C0D860D83C7486228196B197B19A718B7
          192F994CA605D39799C85430D7321B9967980F986F55582AF62A7C1591CA1295
          3A9556957E95E7AA545573553FD579AA0B54AB550FAB5E567DA64655B350E3A9
          09D416ABD5A91D55BBA936AECE5277528F50CF515FA3BE5FFD82FA630DB28685
          46A08648A35463B7C6198D2116C63265F15842D6725603EB2C6B984D625BB2F9
          EC4C7605FB1B762F7B4C534373AA66AC6691669DE671CD010EC6B1E0F039D99C
          4ACE21CE0DCE7B2D032D3F2DB1D66AAD66AD7EAD37DA7ADABEDA62ED72ED16ED
          EBDAEF75709D409D2C9DF53A6D3AF77509BA36BA51BA85BADB75CFEA3ED363EB
          79E909F5CAF50EE9DDD147F56DF4A3F517EAEFD6EFD11F373034083690196C31
          3863F0CC9063E86B9869B8D1F084E1A811CB68BA91C468A3D149A327B826EE87
          67E33578173E66AC6F1C62AC34DE65DC6B3C61626932DBA4C4A4C5E4BE29CD94
          6B9A66BAD1B4D374CCCCC82CDCACD8ACC9EC8E39D59C6B9E61BED9BCDBFC8D85
          A5459CC54A8B368BC796DA967CCB05964D96F7AC98563E567956F556D7AC49D6
          5CEB2CEB6DD6576C501B579B0C9B3A9BCBB6A8AD9BADC4769B6DDF14E2148F29
          D229F5536EDA31ECFCEC0AEC9AEC06ED39F661F625F66DF6CF1DCC1C121DD63B
          743B7C727475CC766C70BCEBA4E134C3A9C4A9C3E957671B67A1739DF33517A6
          4B90CB1297769717536DA78AA76E9F7ACB95E51AEEBAD2B5D3F5A39BBB9BDCAD
          D96DD4DDCC3DC57DABFB4D2E9B1BC95DC33DEF41F4F0F758E271CCE39DA79BA7
          C2F390E72F5E765E595EFBBD1E4FB39C269ED6306DC8DBC45BE0BDCB7B603A3E
          3D65FACEE9033EC63E029F7A9F87BEA6BE22DF3DBE237ED67E997E07FC9EFB3B
          FACBFD8FF8BFE179F216F14E056001C101E501BD811A81B3036B031F049904A5
          0735058D05BB062F0C3E15420C090D591F72936FC017F21BF96333DC672C9AD1
          15CA089D155A1BFA30CC264C1ED6118E86CF08DF107E6FA6F94CE9CCB60888E0
          476C88B81F69199917F97D14292A32AA2EEA51B453747174F72CD6ACE459FB67
          BD8EF18FA98CB93BDB6AB6727667AC6A6C526C63EC9BB880B8AAB8817887F845
          F1971274132409ED89E4C4D8C43D89E37302E76C9A339CE49A54967463AEE5DC
          A2B917E6E9CECB9E773C593559907C3885981297B23FE5832042502F184FE5A7
          6E4D1D13F2849B854F45BEA28DA251B1B7B84A3C92E69D5695F638DD3B7D43FA
          68864F4675C633094F522B79911992B923F34D5644D6DEACCFD971D92D39949C
          949CA3520D6996B42BD730B728B74F662B2B930DE479E66DCA1B9387CAF7E423
          F973F3DB156C854CD1A3B452AE500E164C2FA82B785B185B78B848BD485AD433
          DF66FEEAF9230B82167CBD90B050B8B0B3D8B87859F1E022BF45BB16238B5317
          772E315D52BA647869F0D27DCB68CBB296FD50E2585255F26A79DCF28E5283D2
          A5A5432B82573495A994C9CB6EAEF45AB9631561956455EF6A97D55B567F2A17
          955FAC70ACA8AEF8B046B8E6E2574E5FD57CF5796DDADADE4AB7CAEDEB48EBA4
          EB6EACF759BFAF4ABD6A41D5D086F00DAD1BF18DE51B5F6D4ADE74A17A6AF58E
          CDB4CDCACD03356135ED5BCCB6ACDBF2A136A3F67A9D7F5DCB56FDADABB7BED9
          26DAD6BFDD777BF30E831D153BDEEF94ECBCB52B78576BBD457DF56ED2EE82DD
          8F1A621BBABFE67EDDB847774FC59E8F7BA57B07F645EFEB6A746F6CDCAFBFBF
          B2096D52368D1E483A70E59B806FDA9BED9A77B5705A2A0EC241E5C127DFA67C
          7BE350E8A1CEC3DCC3CDDF997FB7F508EB48792BD23ABF75AC2DA36DA03DA1BD
          EFE88CA39D1D5E1D47BEB7FF7EEF31E36375C7358F579EA09D283DF1F9E48293
          E3A764A79E9D4E3F3DD499DC79F74CFC996B5D515DBD6743CF9E3F1774EE4CB7
          5FF7C9F3DEE78F5DF0BC70F422F762DB25B74BAD3DAE3D477E70FDE148AF5B6F
          EB65F7CBED573CAE74F44DEB3BD1EFD37FFA6AC0D573D7F8D72E5D9F79BDEFC6
          EC1BB76E26DD1CB825BAF5F876F6ED17770AEE4CDC5D7A8F78AFFCBEDAFDEA07
          FA0FEA7FB4FEB165C06DE0F860C060CFC3590FEF0E09879EFE94FFD387E1D247
          CC47D52346238D8F9D1F1F1B0D1ABDF264CE93E1A7B2A713CFCA7E56FF79EB73
          ABE7DFFDE2FB4BCF58FCD8F00BF98BCFBFAE79A9F372EFABA9AF3AC723C71FBC
          CE793DF1A6FCADCEDB7DEFB8EFBADFC7BD1F9928FC40FE50F3D1FA63C7A7D04F
          F73EE77CFEFC2FF784F3FB25D29F3300000A514944415478DABD58095494D715
          BEFF6C300C33C3B0CAB0CA1A2C126491CDE09626312EED896D731ADAD3C6A43D
          AD4D4D55D4AAB111E35A93E8511B34A935C52C467BB449D3688C1B080A710164
          9745564161586681196698E9BD6FE61F4783569BD3DC73BE73E67FFFFBBF77DF
          7D777BC30180A0E25AB5F5D6EDDB20120AD7E2F3262E2D2515B6BEF5F6AD19D9
          D3FC6D361B582C16E04E9F2D74CBCA4833D20089582C66839097571D89CFA188
          9B88067E101C1227144AEA38FAF5E557A7D9674891C26665A54FB5892512E8EC
          EA02CE6834DADEDE590CB9CBB2616C6C0CB8EC99EF02D8CC9FE1970B10EEFC00
          4FCC31D2D2AF2FC3F0F03098CD66108944AD71B131614AA512DCA5EE5058545C
          C376B3FAF5F5101A12624B889F047D7D7DE0EFEFCF28681DFCC8BE110E0957AC
          A8F095C984BB0084C74CFAFD471D4B59D97A6C631B1A5C75E0E534E204623BC7
          8FBC93BF0FA26362403B34040AA5D2432010A871B88931B14F90ADA1BE9E26BD
          12131DB59B7451070682040D72B6B088E366664F87D7F236C0B4CC0CDB85D252
          C89E96C574249C3A730EA2A32280CB989A4636159D3A7BC64C2620914AA560B5
          5AC9CE50547CE125AEB1A9D9161CA4466A11D4D7F74244848A4D140A85CC0438
          E920F7D1C787D02EBEB0E18D86D7F15DEAA8E1F03C9B6D58486642B8214CDCC7
          873E81FCBD7DF4B1372218518FC846FC1EF11B44B7EB2457A1439C8F588ED0DE
          6F12C9DF11BF283AF73BE05C472F5FAD00AD560BF57575101915056850B0E20E
          F55AEDCBBE7E7EEFD1AE5393A780C96482FAEB4DA0D1687E8D9FEDA7E36344B3
          A6CF80B5EBF31CBEC31191347C62C42B739E7EF2CF5790DC683242546404A8BC
          BC606070086EB4B64162423C3B1032E5C5B24BB5CC9B68E555EBFE046B962F83
          5DFBDEDD2E934A73E5724F888D896626652142DEE908159A7FF3E64D50ABD5D0
          DAD60E2D375A6733A2652B572D484E49FE3438500D22B1D0E98EB40522A2DF44
          468749C2C7DE1D9394DB9857EAB4DA6874B2EB7EBE3EF0E147D76A434395932C
          16F482316DA7A67F2C78F9D2A7A0E87C61A99FBF7F7A7858289457545C5607AA
          A784878508AF9457DAF43A9D8811DDEAE906755010E4E696838787F0C7B8C822
          8407E206053DC779FCDC6C2AB18A245378252621EA8073B399747B996F33A2DB
          B77A207FDFD0BDB1928AB834CE714B110A841CF10122DF1970F7211A4F7622AA
          1C64838828C47A3A884725BA4B44220F3873EA45E0033701718D1E28BAB76DDB
          0E9E72B9D3A7FA351A40676429134F2FC7319782E7B22BA9D3B3838283A1E0E0
          87303438381E511F1EB84F4A52229915140A399C395744796609A2D149A45279
          C33F8E1E631FBB102911FF46B2D42767CD905455D7A28346814E67C0F94AE64B
          35B5F5D0A7D128594092979E3B5F02E6D15157A2A0C0C0099D3EDE2A68EFE804
          A3D104D39FC882DA3ACC5B519150515905A92949CC41ABAA6A40333020E5A626
          A7C09BBB7633225C250D1DAE342C3404DADB3B4028125222660BD047B4280979
          7E655535F8A3ED264C0880E2928B8B588824A5A4407A66261C3D7244BE78C9AB
          DA10B49702634DE9A5040FA987A308DC21A3524035E66AC5350A233312BB3989
          52D3D2402E572EFAD1C21FEEA76449861EC46DD2EA0101018C84C6C8367CDCD1
          F3C5B2AFB1BE5884DCB48C4C61DEE62D5D336764079847CD18A402D0EBF5E0E6
          E6C65627F049952771157A8FC9564E0ED994999116C9A7088AF48E8E413874B8
          0256AF9ACD0C4DC293F16EC11352321C1D1D157327BEFC8A588BE472F9134693
          D574E040EDAD9C9C84D0F3E73BC0661D694D4F8F0F8F8A9240734B6B556242C2
          E4BE7E0D74767635A64F4D896E696D87E6A6A6853299EC2877E2E429D89CB71E
          5EC30CD9DEA1838282AE9F501E7604E6A76396B6772CC65323A413A5221788C1
          5E22989A4EA2C54BD662116CF1C4B1CD08232211A14114988D45C725D2A7703B
          340C7310E71023A3862338660027D1DA95EB40E6F533DED3E721B0FEC2460729
          FD1E71D8360EF147C41EB0D7A563CE58BB87C8559E477CE2F23C17F132D9DD11
          5FB4B5D508C37F231A4F2873FED241B68FB6FD301A8DA721F5565E8893602FB1
          BF42E88B8B5E7D648D48DE7368C3F2D185929560311BFE2722A79495AE0393B1
          1FF8531A57C2C3C3E1E83F3F63F1363830003D3D3D10151DCD3C9AEF6A48A8A4
          0FF6F7B388F052A9A4381E84B1EA8B13362A3C3D678F614C527D14F0710AD0EC
          F08CFAF1D6FD8642FEFE01F0F917C73111EAEC1328093C40214AE588353EDEDE
          9BE21E8B052F2F0586E49DD475D762F88D65CC02DDDD3DD0DBAB8121EC5790EF
          057C7518F800E1272B140A388EE18B8DEF3748EE51C8CF66B5EEC0E630272E2E
          9659864F308DCD2D14CE2C01F12D1FB322FEA67909D8BFA8B01BE6DF116E63AF
          7FBDA9E5248EFD16A7B6B0F4482F300F40DE96ADCE0AC00BBE9B884A6DF7F7F7
          5B8856004F9C279688E1C68D36D6BA7BE1022A9517CB84BEBEBE40ADE6BD998F
          DF18B62C984044E08E0AFBF8A810DE789402F6EED295AB782AFA6CA610099938
          09ABC9F33939E0686E6548BC065BBD3531587EAC6805BDC100064CFA3ABD0122
          23C241A95032B3634FCC5F36402CC2BB8A80A31B0E83CD45A1517B9562731BAE
          37B26F1326C7C3B06118AA6BEB6EA29526DFA5506252123C3D771E0C0DF4C3B6
          8D1B213A36367C69EECAC34AA522F5F1C727C318FA8B90E54870366E745C0654
          94C63D3C3C180FEF5FBCBFF1C586170BE3A18A6684F2CA6BF44CBDEC62C4A8AB
          421C2AE4FDFD67E63C27918833DDDDA4C14AA53C2E253929C8B59A8D3A8ED4DD
          DD9DF91B29C35B80764EFEC32E422E0AF03E366E54E13C8AC24B57CA2FE33A59
          54D0F006373247AD0EFA1C6F591C7DCCEFDE5568E7B4606FAF1E9BEC618889F6
          A3D2EAB4C4FD167C1811E2062A2BAB6C7884014C21F49954DCD571ECE0BD33A6
          A6B0DC62B5911214613AA8AE6981593353D0917BE1E007E5EC78B2A6F982B7B7
          1B04ABC3C0D3D3DECC9375C837E88A11121CC4FB226BCA6AEA1B6022B6D43299
          94A50512B264754D1D68FAFBF506BD3E1E87DA580F4A1FF66BFA60EF9E3DA2F5
          9B36275BCCE62C81C0A6696DD35FCACF6FFB9E542A5C1418E81E111929EBAFAD
          D5272061A74E672E130A398C14C913E9E9BEFE8953543A8C98FDEFEFFFEB5B16
          B3C5F2EC82F92F6103F81CEE4B8649F18BBD7B76EFC68DE89E993B77913A28F8
          0574F8603C8DC6EEEEEEF50507FE76C164348E717C53ECA210A042D83260F2EA
          19811D3B9A714718A700F18EEC4A7D3E75D613C05E1AAF230A384EDA85F78131
          8BA90C7D42EA92328641229D0F0271046BB8E99DC97018F96F83BD208EE353AE
          0AEDFBCB1EF8C38A3CD8B2A5069D967D40EC5452A9FAD19F02D458538B1FE248
          AA7D0E65E9DDFBF771917004DD00A9E5DD80B8FA207F722A34804DD39B5B7782
          4CF5E283AE0F8F21B6517822D6C17DEA11CA4FC17E116E410422BA816E50F65B
          4210E259C4BFC07E9F19FE360A3D8AD09F13D4F0515E0973284556AD047B6F56
          E6D8D8B7B2D0C30A29F203B0DF3B4D8EE3A22E945A35BA53B5220AC17ECCDF99
          85E878E91FAE00442E4202F666F30AD83B5B67332A1088E07CE1124C07A6FFAB
          42AE420AF422BA5C0785227728295A8AD95FFB9D58E88142F7E892E2E5CE4ED1
          2109FF01CD293A9691B948960000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage8'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E000000097048597300002E2300002E230178A53F7600000A4D694343505068
          6F746F73686F70204943432070726F66696C65000078DA9D53775893F7163EDF
          F7650F5642D8F0B1976C81002223AC08C81059A21092006184101240C585880A
          561415119C4855C482D50A489D88E2A028B867418A885A8B555C38EE1FDCA7B5
          7D7AEFEDEDFBD7FBBCE79CE7FCCE79CF0F8011122691E6A26A003952853C3AD8
          1F8F4F48C4C9BD80021548E0042010E6CBC26705C50000F00379787E74B03FFC
          01AF6F00020070D52E2412C7E1FF83BA50265700209100E02212E70B01905200
          C82E54C81400C81800B053B3640A009400006C797C422200AA0D00ECF4493E05
          00D8A993DC1700D8A21CA908008D0100992847240240BB00605581522C02C0C2
          00A0AC40222E04C0AE018059B632470280BD0500768E58900F4060008099422C
          CC0020380200431E13CD03204C03A030D2BFE0A95F7085B8480100C0CB95CD97
          4BD23314B895D01A77F2F0E0E221E2C26CB142611729106609E4229C979B2313
          48E7034CCE0C00001AF9D1C1FE383F90E7E6E4E1E666E76CEFF4C5A2FE6BF06F
          223E21F1DFFEBC8C020400104ECFEFDA5FE5E5D60370C701B075BF6BA95B00DA
          560068DFF95D33DB09A05A0AD07AF98B7938FC401E9EA150C83C1D1C0A0B0BED
          2562A1BD30E38B3EFF33E16FE08B7EF6FC401EFEDB7AF000719A4099ADC0A383
          FD71616E76AE528EE7CB0442316EF7E723FEC7857FFD8E29D1E234B15C2C158A
          F15889B850224DC779B952914421C995E212E97F32F11F96FD0993770D00AC86
          4FC04EB607B5CB6CC07EEE01028B0E58D27600407EF32D8C1A0B910010673432
          79F7000093BFF98F402B0100CD97A4E30000BCE8185CA894174CC608000044A0
          812AB041070CC114ACC00E9CC11DBCC01702610644400C24C03C104206E4801C
          0AA11896411954C03AD804B5B0031AA0119AE110B4C131380DE7E0125C81EB70
          170660189EC218BC86090441C8081361213A8811628ED822CE0817998E042261
          48349280A420E988145122C5C872A402A9426A915D4823F22D7214398D5C40FA
          90DBC820328AFC8ABC47319481B25103D4027540B9A81F1A8AC6A073D174340F
          5D8096A26BD11AB41E3D80B6A2A7D14BE87574007D8A8E6380D1310E668CD961
          5C8C87456089581A26C71663E55835568F35631D583776151BC09E61EF082402
          8B8013EC085E8410C26C82909047584C5843A825EC23B412BA085709838431C2
          272293A84FB4257A12F9C478623AB1905846AC26EE211E219E255E270E135F93
          48240EC992E44E0A21259032490B496B48DB482DA453A43ED210699C4C26EB90
          6DC9DEE408B280AC209791B7900F904F92FBC9C3E4B7143AC588E24C09A22452
          A494124A35653FE504A59F324299A0AA51CDA99ED408AA883A9F5A496DA07650
          2F5387A91334759A25CD9B1643CBA42DA3D5D09A696769F7682FE974BA09DD83
          1E4597D097D26BE807E9E7E983F4770C0D860D83C7486228196B197B19A718B7
          192F994CA605D39799C85430D7321B9967980F986F55582AF62A7C1591CA1295
          3A9556957E95E7AA545573553FD579AA0B54AB550FAB5E567DA64655B350E3A9
          09D416ABD5A91D55BBA936AECE5277528F50CF515FA3BE5FFD82FA630DB28685
          46A08648A35463B7C6198D2116C63265F15842D6725603EB2C6B984D625BB2F9
          EC4C7605FB1B762F7B4C534373AA66AC6691669DE671CD010EC6B1E0F039D99C
          4ACE21CE0DCE7B2D032D3F2DB1D66AAD66AD7EAD37DA7ADABEDA62ED72ED16ED
          EBDAEF75709D409D2C9DF53A6D3AF77509BA36BA51BA85BADB75CFEA3ED363EB
          79E909F5CAF50EE9DDD147F56DF4A3F517EAEFD6EFD11F373034083690196C31
          3863F0CC9063E86B9869B8D1F084E1A811CB68BA91C468A3D149A327B826EE87
          67E33578173E66AC6F1C62AC34DE65DC6B3C61626932DBA4C4A4C5E4BE29CD94
          6B9A66BAD1B4D374CCCCC82CDCACD8ACC9EC8E39D59C6B9E61BED9BCDBFC8D85
          A5459CC54A8B368BC796DA967CCB05964D96F7AC98563E567956F556D7AC49D6
          5CEB2CEB6DD6576C501B579B0C9B3A9BCBB6A8AD9BADC4769B6DDF14E2148F29
          D229F5536EDA31ECFCEC0AEC9AEC06ED39F661F625F66DF6CF1DCC1C121DD63B
          743B7C727475CC766C70BCEBA4E134C3A9C4A9C3E957671B67A1739DF33517A6
          4B90CB1297769717536DA78AA76E9F7ACB95E51AEEBAD2B5D3F5A39BBB9BDCAD
          D96DD4DDCC3DC57DABFB4D2E9B1BC95DC33DEF41F4F0F758E271CCE39DA79BA7
          C2F390E72F5E765E595EFBBD1E4FB39C269ED6306DC8DBC45BE0BDCB7B603A3E
          3D65FACEE9033EC63E029F7A9F87BEA6BE22DF3DBE237ED67E997E07FC9EFB3B
          FACBFD8FF8BFE179F216F14E056001C101E501BD811A81B3036B031F049904A5
          0735058D05BB062F0C3E15420C090D591F72936FC017F21BF96333DC672C9AD1
          15CA089D155A1BFA30CC264C1ED6118E86CF08DF107E6FA6F94CE9CCB60888E0
          476C88B81F69199917F97D14292A32AA2EEA51B453747174F72CD6ACE459FB67
          BD8EF18FA98CB93BDB6AB6727667AC6A6C526C63EC9BB880B8AAB8817887F845
          F1971274132409ED89E4C4D8C43D89E37302E76C9A339CE49A54967463AEE5DC
          A2B917E6E9CECB9E773C593559907C3885981297B23FE5832042502F184FE5A7
          6E4D1D13F2849B854F45BEA28DA251B1B7B84A3C92E69D5695F638DD3B7D43FA
          68864F4675C633094F522B79911992B923F34D5644D6DEACCFD971D92D39949C
          949CA3520D6996B42BD730B728B74F662B2B930DE479E66DCA1B9387CAF7E423
          F973F3DB156C854CD1A3B452AE500E164C2FA82B785B185B78B848BD485AD433
          DF66FEEAF9230B82167CBD90B050B8B0B3D8B87859F1E022BF45BB16238B5317
          772E315D52BA647869F0D27DCB68CBB296FD50E2585255F26A79DCF28E5283D2
          A5A5432B82573495A994C9CB6EAEF45AB9631561956455EF6A97D55B567F2A17
          955FAC70ACA8AEF8B046B8E6E2574E5FD57CF5796DDADADE4AB7CAEDEB48EBA4
          EB6EACF759BFAF4ABD6A41D5D086F00DAD1BF18DE51B5F6D4ADE74A17A6AF58E
          CDB4CDCACD03356135ED5BCCB6ACDBF2A136A3F67A9D7F5DCB56FDADABB7BED9
          26DAD6BFDD777BF30E831D153BDEEF94ECBCB52B78576BBD457DF56ED2EE82DD
          8F1A621BBABFE67EDDB847774FC59E8F7BA57B07F645EFEB6A746F6CDCAFBFBF
          B2096D52368D1E483A70E59B806FDA9BED9A77B5705A2A0EC241E5C127DFA67C
          7BE350E8A1CEC3DCC3CDDF997FB7F508EB48792BD23ABF75AC2DA36DA03DA1BD
          EFE88CA39D1D5E1D47BEB7FF7EEF31E36375C7358F579EA09D283DF1F9E48293
          E3A764A79E9D4E3F3DD499DC79F74CFC996B5D515DBD6743CF9E3F1774EE4CB7
          5FF7C9F3DEE78F5DF0BC70F422F762DB25B74BAD3DAE3D477E70FDE148AF5B6F
          EB65F7CBED573CAE74F44DEB3BD1EFD37FFA6AC0D573D7F8D72E5D9F79BDEFC6
          EC1BB76E26DD1CB825BAF5F876F6ED17770AEE4CDC5D7A8F78AFFCBEDAFDEA07
          FA0FEA7FB4FEB165C06DE0F860C060CFC3590FEF0E09879EFE94FFD387E1D247
          CC47D52346238D8F9D1F1F1B0D1ABDF264CE93E1A7B2A713CFCA7E56FF79EB73
          ABE7DFFDE2FB4BCF58FCD8F00BF98BCFBFAE79A9F372EFABA9AF3AC723C71FBC
          CE793DF1A6FCADCEDB7DEFB8EFBADFC7BD1F9928FC40FE50F3D1FA63C7A7D04F
          F73EE77CFEFC2FF784F3FB25D29F3300000BE34944415478DABD587B5894551A
          7FBF99F9E6C2301740400690DB209288CA4544144DD332CD6CB57C56F7A9D672
          7773CB36AD6CCD5629AF5DB455B7521FAAD5ECA265E5DACDBB78C34405514090
          8B374062181866606ECCB7EF7B66BE69146A9FFED997E7F7C0F77DE7FCCE7BDE
          F3DE0E1C00484A2F5CF4DC6A69019954FA323EAFE472B2B261CD5BEB6E8DCB1F
          1D210802B8DD6EE00E1E3EAAC8CBCDB1D30B129EE7819B5432153C8227A76B41
          E4699922EB3F4EDB670F7013BF00E0E21E00EB33FD005F42D191BF0247537ED8
          7F904D430A35F141DEC811022F97C38D9B3781B3DBED02C77140E8E9E9F192CF
          4FCA17D63DA4DE80B37732E2F6C599A08A99CB5460A4C53F9640575717B85C2E
          90C9640DA92903E3743A1D28554A385A74FC12DBCDDF972D8701B1B1427ADA5D
          D0DADA0A1111118C81D6C1496C776CE1A79E980B138F4F58777A7CC942895A22
          5568E6DDE7E8DCFA2D5B6ED28F13D9AC42E312E19D8E6DAEA3B3418E1B7C9588
          1067117B994E24EFBCBB1992070E044B47076875BA20894462C0D757FC8AD392
          97ABAA68D0D303938D1B4917435414C8D120878F1671DCDDF9636169C1AB307A
          54AE70B2B818F247E78168A003878E40B23111B8DC11396453D981C3875C6402
          12954A051E8F87EC0C45C74F3EC1D55CA91562A20D803AB001F491442A953213
          E0A0EDDCC79F7C8A768984CAF315D032ADAE61DFECA204992257EFB61F330327
          53E078073B1392E9BA70E1D39D0DAB60FFCCF5F8B80621473CEAB07EE8B593C4
          E3FC2A4BA178F087875B3955CC1331F871006230622BD026E83041A60669D278
          303FDE0C8AE0C745D3E19104C1A1037F04BF31494ACE9582C56281AACA4A4832
          1AD9663CB843ABC5F264BFF0F0ADB4EBECCCE1E07038A0AAFA0A984CA63FD161
          D17E19D1F8B1E3E0E5E5055ED741159048159F90F8F4E47BEF79FD2C92DB1D76
          30262542885E0FE6F60EA86FB80AC3D2D3D88190294F9D3E53C1BC89565EFCCA
          3F60C9A285B061F39637D42AD5F31A4D30A40C4C66266521820B802F54687C63
          6323180C0668B87A0DEAEA1B2630A2852F2E9E969995F9754C940164BCD4EF8E
          B40522A2BF894C3C2F31F67E36C97981B96EA7C5928C4E561D16160A4D4DCD7B
          D016D3D28CA930F3C62CF77AD77AD9A00C23ECDB7FB0383C2262647CDC00385F
          5A5A6288320C8F8F8B959E3D5F26583B3B658CE8567313F4476D9A3D4DF0416B
          21685254B317A54CDDB1ECCB2F7659565F7F4415B6482F08DD1407B710BF477C
          8E687476EDAE143C16AF6D279DB93F50CBA8587B636352681268740360C7B2E2
          41928A4197316EC861FE80988CD021CE2036F888BD44CC47FC4EA1D64A0D63CD
          52A5B4A5E5A1C628895E02523E8D65189F8CA1434614882FA4520CA583F37A11
          01173D1E244A00D3F446E883C82FBC5C0307F73DEA7F263F4A475CA0078AEEB5
          6BDF80608DC6EF536D2613A033B29489A737C7379682A72490D8EFD9D13131B0
          6DFB0EE8686FEF8BA8150F3C2C2B63184EE040ABD5C0A12345DFE39005881A3F
          514848287CBEFB4B363980888CFA0D9265DF337E9CBCFC62053AA8113A3B6D38
          5EC77CE9524515B49A4C34CEC291971E3976025C4E672051745454FF1B61A121
          70EDFA0DB0DB1D30764C1E545462DE32264169593964676530072D2FBF0426B3
          59C58DC8CC8237376C6444B84A0E3A5C71DC8058B876ED3A4865524AC4FE2C24
          6624F2FCB2F28B1081B6EBDF3F128E9F38359785484656168C1C350A76EFDAA5
          99BFE0594B2CDA4B8BB1A6D3EB204815C4C22C908C4A01D59873A517288C5C48
          ACF01365E7E48046A39B3B73C6F4424A9664E876DC26AD1E1919C948E81DD946
          8C3B7A3E75FA47AC2F6E29373A7794B460D5EA9B778FCB8F74395DE86012B05A
          ADA05028D8EA0431A98A248142DF31D96A28D6AE8CCACD49125304453AAD2666
          00FA1D98A145B7100929193A9D4E9EFBFE87FDC45AA4D168C67012AEBBB5D5B4
          27293171D625CF2538D772DEB568C8DFF8A65BB7A0A1E16AF9B0F4F421AD6D26
          B871E366CDC81159C9750DD7A0F6CA95196AB57A37F7FDBE03B0AA60392CC50C
          79B5A101F3EF7E2C56D5FAC7DE9961DEBEEC9BE950ECDAE3CD415D8252BBE019
          57D7DE2D9E9E66F215DE5700999A7EA265CB57C0324D0168DA9430D81823DCD5
          DF089B1FDE1D2CED4CB3C9E41923716C13620B82F2740AC7290EDB3BDFC51226
          F1A5115FAD1125542A1526870F84165E069FE57DCDA9635F206D1EF4A590385F
          7535215602C7BB1C9D5B5880DC968F14AEEEA2C172614C42BF54385CDF7AAC76
          7E457E50FFE78928850A18C248E180F80A4185DF7F84FE06808272BC3CBCD5EE
          36834E170E5FEFB9B9B4FBE396952AED4222FAB32F38E723562168F53711769A
          7BBCE8D9807C44DC7153DEE2859E79AEF29E572CEFB6FF5310ECE02312177E1B
          B1D6672F26274FBC086E97ED4EA2A9DEAA53E60024823E886E93D3C5AF80C3DE
          7647AAFD8D442567564097CDAFD8ED253B50E2E3E361F7577B58BCB59BCDD0DC
          DC0CC6E464E6D16257C302199FDBDBDA5814E8434254F83E1A63B51F0E58A10D
          0E9ED0835142F55122C629402D4E2357A9EA6BDD5E0A518FB3F7DBEF301176FA
          C3EAD714A2548E5812161ABA3275500AE8F55A0CC99F53D76D8BE11C778F9B6A
          30FCF493093AB05F41BED9F869A73F40C4C15AAD16BEC3F0C5C6B717C91D0A85
          0B1ECF7A6C0EE7A4A6A6F8F303295A535B47E1CC1290D8F2312BE2DF342E1DFB
          9710EC86C56F8416ECF5ABAFD4EDC3774FE1D03A961EE903E6012858BDC65F01
          44C16F09A8D41B1111E133D00A108CE378390FF5F55759EBAEC7054242F42C13
          F6EBD70FA8D5BC33F3891BC39605939A0C94A87058580850C722E124ECDB99B3
          E7F054ACF94C211232710656935973E680AFB95523F1126C6F960CC4F2E3412B
          586D36B061D2EFB4DA2029311E745A1D333BF6C4E265037819DE55241CDD7018
          8400859CDE2AC5C65EAEAE6173D387A4A15377C1C58ACA46B4D290DB141A9691
          01F74E990A1DE63658BB620524A7A4C43FF7FC8B3B753A6DF6D0A143A007FD85
          D2B6780C24745C365494DE070505311ED1BF447F138B8D286EC64315CD0EE7CB
          2ED073A12FA9380315E250A1D089F74DFE9D5CCE8F522A54313A9D26352B3323
          3AB09A397D47AA542A99BF9132A20568E7E43FEC2214A080E8637D46158EA328
          3C73F67C09AE9347050D6F70DD930D86E8BD78CBE268B2B8FB40112BA428814E
          DB57C5FC2D22C50D9495950B7884914C21F4996CDCD577D8C187E68EC862B9C5
          23901200366B173A7003A4E195901625C5788E878F1A3F819AAE5A28485C0A2E
          CEC51424EB906FD0152336265AF445D6945DAABA0C09D852ABD52A961648C892
          172F5582A9ADCD6AB35AD3F0D555D65ED3C436532BBCB769936CF9CA55996E97
          2B0F1736D7D7D51D7E73CDEA86B4F474C5937F79EA5E9E933FDA286B0CAB3694
          C677F11D9AAE1269E124D7248FD6A09B474643F36FFDF7FB856FB95D6EF7FDD3
          1E98ABD787CEC4F778C9E4BE7D6FD3C68D68E1CEFBA64C996B888E998D0E1F83
          A751D3D4D4B47CDB07EF9F74D8ED3D2CBFDDA110A04258545CCC1275D5B5B069
          E7DB10531007DA50A59417F805C3C392D70D0E4F80ED270E1CBB5C58FB3477AE
          E70228EDC02BF2B079CE412B768B27918B588EA846BC8668F1FA8C121CB64F41
          F050CDE92379062AB479D3BFE0B9D52FC13AF57A50E20F38F0DC6EE071A8B929
          0909217B27851941AF8E846AC10C1FBEB76F1B6CEE7A8CD3399922A4102A43D7
          006A0E762022C1DB84EB11A58844441E78FBE822E014E0B47E8473AC81F9B977
          07122878D2595AC17D66980C136750388422E42A1D94B5B6349E28BCB8D0B9C7
          F61917EC085488A60D47BC00DE52301451474189380ADEAB6ACBAF39F89D372B
          BFE37B3CAE47E204C9C78F444C80067B1D5C77D643B46600B461BB7DE064FDAE
          EE0FDB677B9A6C6E993A1B78653E5572DAE642F0DEC07683B77D4AF429435D4F
          920F2F214EFEA242B75DAC024490F02991A19955E3C286C2B5EE3A70493C60C1
          CC7CE19065A7E375F32C498884B515327996A8104D5383F7FF0866C4289F82F5
          88D7111D8860DFEF9EC0B52412191C3BBA00A3CFF10B0A514AE191DB70373A3E
          7A2108BC44C9D97A4EDB7BDA57B7B11B201BD65BA13B857A43934FC1DEC72053
          C289A2E730D95AFE87857E56C8977131FF28394085E0372AD4A7F07C309C3CFE
          027477F776A7FFBB4274873E7562F16D5D6280A4FF173A39CF86FAA63A570000
          000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage9'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E000000097048597300002E2300002E230178A53F7600000A4D694343505068
          6F746F73686F70204943432070726F66696C65000078DA9D53775893F7163EDF
          F7650F5642D8F0B1976C81002223AC08C81059A21092006184101240C585880A
          561415119C4855C482D50A489D88E2A028B867418A885A8B555C38EE1FDCA7B5
          7D7AEFEDEDFBD7FBBCE79CE7FCCE79CF0F8011122691E6A26A003952853C3AD8
          1F8F4F48C4C9BD80021548E0042010E6CBC26705C50000F00379787E74B03FFC
          01AF6F00020070D52E2412C7E1FF83BA50265700209100E02212E70B01905200
          C82E54C81400C81800B053B3640A009400006C797C422200AA0D00ECF4493E05
          00D8A993DC1700D8A21CA908008D0100992847240240BB00605581522C02C0C2
          00A0AC40222E04C0AE018059B632470280BD0500768E58900F4060008099422C
          CC0020380200431E13CD03204C03A030D2BFE0A95F7085B8480100C0CB95CD97
          4BD23314B895D01A77F2F0E0E221E2C26CB142611729106609E4229C979B2313
          48E7034CCE0C00001AF9D1C1FE383F90E7E6E4E1E666E76CEFF4C5A2FE6BF06F
          223E21F1DFFEBC8C020400104ECFEFDA5FE5E5D60370C701B075BF6BA95B00DA
          560068DFF95D33DB09A05A0AD07AF98B7938FC401E9EA150C83C1D1C0A0B0BED
          2562A1BD30E38B3EFF33E16FE08B7EF6FC401EFEDB7AF000719A4099ADC0A383
          FD71616E76AE528EE7CB0442316EF7E723FEC7857FFD8E29D1E234B15C2C158A
          F15889B850224DC779B952914421C995E212E97F32F11F96FD0993770D00AC86
          4FC04EB607B5CB6CC07EEE01028B0E58D27600407EF32D8C1A0B910010673432
          79F7000093BFF98F402B0100CD97A4E30000BCE8185CA894174CC608000044A0
          812AB041070CC114ACC00E9CC11DBCC01702610644400C24C03C104206E4801C
          0AA11896411954C03AD804B5B0031AA0119AE110B4C131380DE7E0125C81EB70
          170660189EC218BC86090441C8081361213A8811628ED822CE0817998E042261
          48349280A420E988145122C5C872A402A9426A915D4823F22D7214398D5C40FA
          90DBC820328AFC8ABC47319481B25103D4027540B9A81F1A8AC6A073D174340F
          5D8096A26BD11AB41E3D80B6A2A7D14BE87574007D8A8E6380D1310E668CD961
          5C8C87456089581A26C71663E55835568F35631D583776151BC09E61EF082402
          8B8013EC085E8410C26C82909047584C5843A825EC23B412BA085709838431C2
          272293A84FB4257A12F9C478623AB1905846AC26EE211E219E255E270E135F93
          48240EC992E44E0A21259032490B496B48DB482DA453A43ED210699C4C26EB90
          6DC9DEE408B280AC209791B7900F904F92FBC9C3E4B7143AC588E24C09A22452
          A494124A35653FE504A59F324299A0AA51CDA99ED408AA883A9F5A496DA07650
          2F5387A91334759A25CD9B1643CBA42DA3D5D09A696769F7682FE974BA09DD83
          1E4597D097D26BE807E9E7E983F4770C0D860D83C7486228196B197B19A718B7
          192F994CA605D39799C85430D7321B9967980F986F55582AF62A7C1591CA1295
          3A9556957E95E7AA545573553FD579AA0B54AB550FAB5E567DA64655B350E3A9
          09D416ABD5A91D55BBA936AECE5277528F50CF515FA3BE5FFD82FA630DB28685
          46A08648A35463B7C6198D2116C63265F15842D6725603EB2C6B984D625BB2F9
          EC4C7605FB1B762F7B4C534373AA66AC6691669DE671CD010EC6B1E0F039D99C
          4ACE21CE0DCE7B2D032D3F2DB1D66AAD66AD7EAD37DA7ADABEDA62ED72ED16ED
          EBDAEF75709D409D2C9DF53A6D3AF77509BA36BA51BA85BADB75CFEA3ED363EB
          79E909F5CAF50EE9DDD147F56DF4A3F517EAEFD6EFD11F373034083690196C31
          3863F0CC9063E86B9869B8D1F084E1A811CB68BA91C468A3D149A327B826EE87
          67E33578173E66AC6F1C62AC34DE65DC6B3C61626932DBA4C4A4C5E4BE29CD94
          6B9A66BAD1B4D374CCCCC82CDCACD8ACC9EC8E39D59C6B9E61BED9BCDBFC8D85
          A5459CC54A8B368BC796DA967CCB05964D96F7AC98563E567956F556D7AC49D6
          5CEB2CEB6DD6576C501B579B0C9B3A9BCBB6A8AD9BADC4769B6DDF14E2148F29
          D229F5536EDA31ECFCEC0AEC9AEC06ED39F661F625F66DF6CF1DCC1C121DD63B
          743B7C727475CC766C70BCEBA4E134C3A9C4A9C3E957671B67A1739DF33517A6
          4B90CB1297769717536DA78AA76E9F7ACB95E51AEEBAD2B5D3F5A39BBB9BDCAD
          D96DD4DDCC3DC57DABFB4D2E9B1BC95DC33DEF41F4F0F758E271CCE39DA79BA7
          C2F390E72F5E765E595EFBBD1E4FB39C269ED6306DC8DBC45BE0BDCB7B603A3E
          3D65FACEE9033EC63E029F7A9F87BEA6BE22DF3DBE237ED67E997E07FC9EFB3B
          FACBFD8FF8BFE179F216F14E056001C101E501BD811A81B3036B031F049904A5
          0735058D05BB062F0C3E15420C090D591F72936FC017F21BF96333DC672C9AD1
          15CA089D155A1BFA30CC264C1ED6118E86CF08DF107E6FA6F94CE9CCB60888E0
          476C88B81F69199917F97D14292A32AA2EEA51B453747174F72CD6ACE459FB67
          BD8EF18FA98CB93BDB6AB6727667AC6A6C526C63EC9BB880B8AAB8817887F845
          F1971274132409ED89E4C4D8C43D89E37302E76C9A339CE49A54967463AEE5DC
          A2B917E6E9CECB9E773C593559907C3885981297B23FE5832042502F184FE5A7
          6E4D1D13F2849B854F45BEA28DA251B1B7B84A3C92E69D5695F638DD3B7D43FA
          68864F4675C633094F522B79911992B923F34D5644D6DEACCFD971D92D39949C
          949CA3520D6996B42BD730B728B74F662B2B930DE479E66DCA1B9387CAF7E423
          F973F3DB156C854CD1A3B452AE500E164C2FA82B785B185B78B848BD485AD433
          DF66FEEAF9230B82167CBD90B050B8B0B3D8B87859F1E022BF45BB16238B5317
          772E315D52BA647869F0D27DCB68CBB296FD50E2585255F26A79DCF28E5283D2
          A5A5432B82573495A994C9CB6EAEF45AB9631561956455EF6A97D55B567F2A17
          955FAC70ACA8AEF8B046B8E6E2574E5FD57CF5796DDADADE4AB7CAEDEB48EBA4
          EB6EACF759BFAF4ABD6A41D5D086F00DAD1BF18DE51B5F6D4ADE74A17A6AF58E
          CDB4CDCACD03356135ED5BCCB6ACDBF2A136A3F67A9D7F5DCB56FDADABB7BED9
          26DAD6BFDD777BF30E831D153BDEEF94ECBCB52B78576BBD457DF56ED2EE82DD
          8F1A621BBABFE67EDDB847774FC59E8F7BA57B07F645EFEB6A746F6CDCAFBFBF
          B2096D52368D1E483A70E59B806FDA9BED9A77B5705A2A0EC241E5C127DFA67C
          7BE350E8A1CEC3DCC3CDDF997FB7F508EB48792BD23ABF75AC2DA36DA03DA1BD
          EFE88CA39D1D5E1D47BEB7FF7EEF31E36375C7358F579EA09D283DF1F9E48293
          E3A764A79E9D4E3F3DD499DC79F74CFC996B5D515DBD6743CF9E3F1774EE4CB7
          5FF7C9F3DEE78F5DF0BC70F422F762DB25B74BAD3DAE3D477E70FDE148AF5B6F
          EB65F7CBED573CAE74F44DEB3BD1EFD37FFA6AC0D573D7F8D72E5D9F79BDEFC6
          EC1BB76E26DD1CB825BAF5F876F6ED17770AEE4CDC5D7A8F78AFFCBEDAFDEA07
          FA0FEA7FB4FEB165C06DE0F860C060CFC3590FEF0E09879EFE94FFD387E1D247
          CC47D52346238D8F9D1F1F1B0D1ABDF264CE93E1A7B2A713CFCA7E56FF79EB73
          ABE7DFFDE2FB4BCF58FCD8F00BF98BCFBFAE79A9F372EFABA9AF3AC723C71FBC
          CE793DF1A6FCADCEDB7DEFB8EFBADFC7BD1F9928FC40FE50F3D1FA63C7A7D04F
          F73EE77CFEFC2FF784F3FB25D29F3300000DCE4944415478DAB557795C94D7B9
          7EBED961F86618866119907D4D941844898868B4EE4BB9498CB97A1B5B4D9A98
          5F6A5A92DB78898992EB966A4DA3D62C6A9AC646738D4B6B92BA460DEEB20988
          B2C9260202C3B0CCC030DB77DFF3C11030B6FDAB87DFF90DDFF7BDE739EF7997
          E77D0F074072A3E4A6FB7E6B2B6452E95BF4BC814B4D198FCDBFDF767F6A467A
          802008703A9DE0BE3BF7BD72D2C4541B7BB1B76D0F5E36AE0437337F3EDC823B
          55A6935F935D761E6EFB43EB33DC8CC30017BE00B6AFFBF1C6F3E9C286C55F73
          1C01E3E4E9EF2097CB4110DE0C0F939E9820C8150A34DEBB07CE66B3091C09B2
          C93611C15F89CE10EEB7D4A0D39B6F11813BDF1C07DD97C11825511D1541AF5E
          CF476F6F2F1C0E076432595D627C5CB856AB85CA4B85EF732F9689A7F99FB5EB
          10366A949034FA11B4B7B723202080AD85CBE5628BC4D3891BAF5CB11C332E4E
          DF766D5A7E966A19BFF299E55377ED9FFBAD8464FDB999D76788ABF6C6640BBB
          BA3E775CFAEC9E42B94011CE399D5B5E884C59B47DFDF703076563D7871F2336
          2E0EDD5D5DD068B5DE1289C448AFABD93751886D59515ECE845E8D8B8DD9C174
          31060743410639F77D2EC73D9931056B72DE457ADA44E1F2D5ABC8489F048F81
          CE9C3D8FD89828701327A4329BCACE9C3BEB602660C3CBCB0B6EB75BB462EEC5
          CB2BB8AAEA3B42688811A48328C03E4AE86FFFB503782E753113DAC7ED3FF025
          D92510B78B6EA175614DDDA925B991AF7D3BDBBD6DD1F144692F574BEBFA459F
          B091A93508073EADD91891C96567043E8243DF5573C62946E1D673659C682789
          DBFED714A5F2A72717B573DACD16B93C22CE91AE940A270F74BDE8EE71ED119D
          09991AD2E86930FFBC05FCEA2E38C3A2778D75B5AFBCFC8AC015141761C8986C
          E417DE40777737CA6FDF46744C8C7818379DD0D2DDFD82BFC1B09B9D7AFCB8C7
          D1DFDF8FF2CA6A984CA65F3267B1F38A40D3A64CC55BEB724430664302F28A88
          8C7A75CEAC9FFCAE80C06DFD36C4444741E7EB0B7367176AEBEA313669B4E810
          66CA2BD7F26E89D1C4767EF3ED7790FD7A16B67FFCC916B597D71B3CEF83F8B8
          5848A55251182C12D82FCB30926F6A6A82D168445D7D036A6AEBA68B4059BF7D
          73E1B894717F0B0D364226970E85233B020362C962B7DB87403CC9C864064C52
          2488A1DBD3DD1D4B4156A9D7FBA1B9B9E518D962E1E898443CD3B8D8F9BEE37D
          5942720C4E9DFEEEEA45FD9527E64D8CC7A53DCD37E7A5CE4D0C0F0B95161415
          0B969E1E990874BFA51941A44D8BBB197F6ADF0B3EDE6BC9EBF1F3BF587BF4F0
          575DD9ADCFEA4F06C58EED955526F8C7215FDA8D2B13F26491C7635CC16ABDB3
          6847990FD9D5C6CDCC9B3BDC71C1A36C4D4DD17ED1E0B561D8977525C16F6350
          45705BA790E06540B1CC8EBBAFB52A63B7055D9F1792FCD89745C5971ADEAC4F
          A7E8C4408C78864CAD911AA798A52A696BEB7F34054B7C2550CED34131A60E92
          8838385DC2DB4BD461EF56DBCA11E29F802F5E2A8A144CAE3AD1DB0F00810B99
          06890A3065368101C91F77429136903D709013C6C746092E778F54C1B5999F6F
          466159B148302C8E926896303996DDEFBDB7053E3C3F14531D261328183D5E5A
          3A28AB64CE1A6E93A1C80E090DC5E7FBBE405767E7C380DA2982F429C9636901
          078D86C7D9F3B927486415CDAA21209DCE0F878E1C15170F03D2D2FC96C0C6FF
          64DA5445E9CD5B14A031E8E9B192BC568CA5B25BE5683799985C37C702ECFC85
          4B700C06DC205048707050A3DE4F8786BB8DB0D9FA3165F224DCBA4DBC15138D
          1BC5A5189F922C124A6969194C66B31737615C0AB66EDF2102D12EA911E16157
          C3C346A1A1E12EA4322923E21F5868909158E41797DE4400D92E282810172F5D
          592EA648724A0A9E484BC391AFBEE25F59F55AF728B29786724DEBAB85B79737
          3C84EB0163A580A54DE18D1296460E02560E018D4F4D05CF6B973FF374E65ED1
          9DB4BA938EC9760F0C0C14413CE5874DCFF3956BD7C9FD4E29973E314D9AB371
          D3BD27A766043AEC0E4A52092C160B944AA5B83B9B6C41BFCD06F9206D745101
          6005C993C444B63CCBB5EAB489A9D11E8A6019CD76F33000FB6583B100040E73
          6F2FC0A1902FA1F4510E912131839C3B71F23443CDE5797E3227E1FADADB4DC7
          A2A3A21697B9CB50D85AE4787DCCAFE5CDF7EFC354672AAD7822774C45550B32
          9A67D74C4A9F105553D7803BD5D54FABD5EA23DC895367B031671DD61043D6D7
          D5E1EC99D354AC2A7D97ED7ADABC6FEDB799B8EA38E6EE740953CF2659E61B26
          AA37EE397AA8F3D3F64590720A3AA68B8E2D8854EB015ABB6E3DD6F239E03B54
          78342654782428061F2F3AE2A39CA0B4062E509DCCD085CC4C081A8BB75E3EB0
          2A30D37F873D92BBEEFABAEF58BFC5BE5E8C6C4FADF10C3FA95498638843AB5C
          86A36B2E70CA97B4AB5FF289DF546EAF845C178EA34F5D8B08FAC4F854F698C5
          DBB2E66C9F2298DDB90340C3F848E9E8CB7D54214C8EF44FC4B9DAF60B8D875A
          3264CFABD6FC973AE27F1B9CF56433E52E4B85F5C8A2F98967747E61F820F370
          087A84A601A0C1068025E53485A1DDE634936B0DF8DBB17B6BFA3EE9DCA0DD69
          0517F0884166B7F73A249C35C16515E2F451B8459452B2A35AC149E018C947CC
          64E1F37E2F175C2F3A4A5D6F777FD8F981D0E3C62010E074C0A7A7D699AA4990
          42254151AFBBBEF697F5118C1DF30A0B1E049A3F50758AFB4140180144D11EE2
          340B51321D3A1402F2577704DB5B1D2D1216DD79D7FF05501F077EAD15827520
          D9A46106705AF52C05B574A67526706D022E5FBB3A92D81E1C11111138F2D763
          62BE759ACD686969414C6CEC40AB37D8D588894CCF9D1D1D6216F8EA745EF43E
          8472D59F04D66B7C7CA6BB284B587D9478F214B843CB58A8943F6CDF1F29C47A
          9C6FFE7E9C88B067886DFF99428CCA6966EBFDFC362426C4C3D75743E9F90375
          8DD88CD6385D4E5683D1D6664217F52B84B7843E1D642C3742218D4683E394BE
          D4F8FE08E401850C82DBFD3E35874B1313E387F881295A75A7068D8DF74402F2
          B47C1E3A647249D4BFE8887C3CDFD86CA55EBFB2BAE614BD5B49A235223DB20F
          C403C8D9B479A80278067D8B24A5B60404189E262BC087E4E40A396A6BEBC5D6
          DD9736D0E97C4526F4F7F7076B353D8A3C78306A5988D4645091C27ABD0EAC63
          917003AC995750485EB164880A79E83299AAC9E2A54B31D8DCAA09389BDA9BEC
          382A3F6EB282C56A859548BFC76245745404B41AAD6876EA893D970DC8657210
          39B21B8E3885610AD907AA94285B515925AE4D1A331ABDD65EDCBC75BB89AC34
          668442639393316BDE7C74993BF0DEFAF5888D8F8FF8CD1BBF3DA8D56AC63FF6
          D818B8285E44DA1E7483A7BC594951F6DEDBDB7BA84E0C5A57FCDF536C3CC329
          E2B08A66435171097B66BDEC2B34EDC315E24821BF19B3E73CA550C8D3544AAF
          50AD964F4C19971C32BC9A79BA48954A25C61B53C663017672163FE245689802
          9E187B6856B1224759985750944FFB4C62058D6E707D738CC6906FE896C5B1C5
          9ED30F1FECE41EEB782CE4D9C413A00F1B4A9912BBEFEF86BC598185510BC0FB
          F03FC297D2018A8B4B057261A0A810C5CC783AD571EAE0FD264E4811B9C52D30
          2500ABA59702B80EA3E94AC836658AC93939FED2740055BD779013B5060ECE21
          6EC2ACC362835D31C2468522BB621D220215B84B59CA5F35E28569CBA0F5D78A
          2E638359F266D96D983A3A2C568B6534BDAA17DB6B16C41DA6767CB473A76CDD
          868DE39C0EC724DAD85C5B53736EEBE64D75A39392942FBCBC72969C533CDF24
          6BD2571A6F44F4CABBF8DE7CE9DE998E996E8D51FB22331A997FF7815DFBDE2A
          1973F39DCC97D372D2340930516D3975F6464BE1D61B3F0BD7845D993177F62F
          8C21A14B28E043C91B55CDCDCDEB3EFFD3A797A9377189FCF680422085A8DE38
          444BD454DEC1CE837F40684E38347E2AA95C90AF7A5C1FBBED514324F65D3A73
          A162EF9D57B94257896017C0FFCC07AAC5EA79C63EF9F6D16AFF28834F208C9A
          507CDD5D8ACB6B4BD6BBAED9364B6412ABDBE286668B018949E139D5258DBC79
          6BDB3BB00A160F238E50E8E39D7FC46F36ADC636F5FB50D11FFAC96F8DE40E35
          372F3252F7CD4C7D0C7CD581A814CCF8ECA3539F0B5B2DCBBC57F842F50B9E97
          B45BB784B8FB5E0AA6FE5043770C3F6F03146A5F5CBCDBD056BABEEAE7F6FCBE
          BF1BB786C01527DDB1227AD6F213AD05DE656B6E2FA586E1205556E750903FD8
          810C1F147A291AC199375646C4E93DB8899716C5EDAD4D173F28C9A26EE8FFF8
          FF3628BB1A1BB664064EF8D5747D1A2E349F84C9DD86704D38F2E416DCC8AAF9
          353F59FD812255F59F893EFA0DA901B1913A9F00ECAFBAD8559E55992174B84B
          30ACCA3C78B31A0A7CB7DBF16CB820D9FF6CC074D4D96A70D75E8B103E0C1DD4
          6E9FB95CFB55EFCE8E258A142FA73A2B00CEBC520A78C7DB8AA8B877154E97D9
          25537879774A5FB4BADC87147C9FCD26951E7FDCDB7776B85A0F3FB270759F05
          E74F97FDB1F3CFA6D5E8FDC15DA242232E56C34B86441E1FE837AE7CAAFE3134
          F4D5C02171A39B98B9E46CF7C1FEDF99174B7412B13F513DA78732BD01421715
          D4584A14C70FA5C72D483E0BE86B58662012D4780740EBAD47904F108EF535A0
          7E55C31434537F271DB9EFC3156294225703C62729F0390A26412E5171560A4C
          57E7A60EF106288AFD438538F43A7AF74CD604AC78CEB010271A0FA3D97E17C1
          7C281A2432549CEFF855CF81AEDD14CCFDCC3AAC35B95E500097DBF52F151A64
          5CE21F150752082314A2C68B5D4B9533EC43CDD7D0A09E928B311E55F3924C85
          DD62EA5368FC384E71C2A9404E57767B9EBBD1412D002766336B153DDCF46F55
          481A1D04CE8F2E9FD41F31487659712A389042E05AA8ED2C291C2A458323E9FF
          014139D19792A744BB0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage10'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000B07494441
          5478DAB5580B7054D519FEEF6BEFBE376FC883040C18D88624E41DC01874B05A
          0C4E6B4594CA38B6333AB6BE46C7D65AA952471DB4A2E2B31D1DADD6073AD522
          A2202021C440E29290C44878079290E766937DDCBDF7EEBDA7FFB99B0D092F8D
          6DCFCCB9E7ECDD73BEF3FDE7FCAF73190028208434C384C2E00B18BDB1EC03C7
          5BF7AF08DC5F0B8E973630C64B72FA3912E64B8109EC04B3F7DDB9CC8EAF6AD6
          562E5EF888AEEBC0F33CD4D4D645A71BC5E39E0545EDC7C731CF5DA47A0971BC
          732730871EFB2943BE99573D9CB17193A8B403FBC51660C2E1301104019A9A5B
          60D4EF1FC3F0B8E380984BA078FF979340F52F7297B3C93A9136A557589677BF
          8E2B1F1D5F48FF2C7769E0D5E46D8EF7EE048804009400103500EA96BED7C5C2
          6D0F44A5C372E244079CEE1D81A2C20230994C0632FD4FFAE6EEB4F1E5A48625
          2B4C45DB3FA0526B9A069424CBB2C6C073043D4F21930779DCD5F2AE84B96295
          B7117F8D22F1FD670679DCC5D226E735A6D537AD65D353417EE513E053BD77F1
          734EEEC4811FD25D63431FBAFE62F9C3EA3F02978092F9A2D2797D10D9EF5D6F
          BAE5A5AD74509CFF99593BF8979F2C8CA82A58393F44A483600A7F09CC48EF2F
          A1A82EC0A03499019FAFF368E731983B2F17188601134A86C7001D75B55241FC
          BD1F33C16090701C67886C9C209E4BDBB7ED50525408C15008121312DE8911BF
          E290FDE3ED9959594C6C2329222D5FD5D45E79F6164C23727A0223761F47A9C2
          9394E482C5E3CEC0671F56141B149C387CA1A1E70279DC79C17F586F664493CE
          25E9C34A53E28D44B5CC05C16263E3A0C5FE1BCF9F20C24950D6BAFDFC401EF7
          4F826F5957B3F17C80C8296B2D6B6E00E0D3F0DC14000DAB8E52444240421108
          AFFF4E6233D44DE6C53BFE892C3F3D03E47197603F45DEEE7273D72D5BC74D4B
          C5C9381195CA68515509EDAB6160583FEA8406D2DF04B0ADD8BD1CE77D8B60C7
          A240072ACA49DED7F580871B0A0F8122F9802321E83C2D4140E621A2E9B0B0BC
          0C7C2323E0723AA16DFFBF60CE601BB090BE994FDABC4128FD74DBB86847BF7E
          F8E150E7BC0772AEBF318EE35843B5F1DC8D9A9C9C3C7E8C54FD63F6414B43A3
          27B2B0A24C308076EEDA5D89EF9E768AA37AC26073739FABEA0E872B04015498
          F90BAE061695481CD38B89BA41E7D6ECDEF3FE92AACA9BCE39B5C17D3795B586
          EFA829C8CF17FB7ABB475253335C2323A360B55A8DDADDD303E96969D074A025
          54515662A59E032D99F97EA3F4B81DB8997E6C796C233F5C8F7E64B93090C79D
          830C3AC6FA55D8DF357520F41AF84C9536C62F62936048BC62F820DD3E7DC822
          B289920D413FBB3890C7ED448B2A071388A36B531FD7654B1E6BE6434C027F50
          2C1E7E8F48F604C2B0ACF9F28E3508A65C18689F7BB9B2D79219FA246183B93A
          19C4DB7F01C0E9D4BD81DE7912424FED017111F3883694ECB62CAD7D01C1F64E
          06F2B82FC57E8E7F7DFC2AD26B5EEEF8E8560BD8D251FBA88D21901E4453910D
          5B0BBFF039709758D68066B199F2EAD721987722D0ACE09BCEBB413539CCF757
          FF9A4D9F1305318C95B6A1B1BE8EA14181D0B3ED602AB33E2164B6D6338BEA37
          4781BE9947D5743ED6AC91C7D236395F5F86E238A2864A3860541F1A2C05530D
          03669861D02389400E0E3CC8CFF0ECC679ADC82A146374358459B3B463F6C7C2
          5DBF03896441045DB7C8A920B00A30C888281D86F18AEAD7C0583341DE93D36A
          CE7EF6E1496E8448DD0D604E2BD142A32029C3A0A2F51314A9E3A40C3A6E7459
          691950A74D6DACB5AD1D66B9368369FF9CB0E66858678DDB44377D280AA44730
          CC72F6E0601F1C3E75128D9487DCDC7CF0FB0360B1980DAF8F6BC298AD82A228
          E0696A8605A19AE72CAE373F42A03A03A8B3FEBE2259CEBC2D9C74D59DB9EE79
          C6CAF47D7F7F3F0259C0893E2856C642AFD18F44225057BF2FFF8AAACA169A5C
          90CB16558CFB192A02F545F477ECDDA123474196C2B060413EF421B8D3E18421
          AF17E2E35CD0E8697A0081FE1AF347AF592DA64A7BA47EABDA95710F5C3A1B12
          4CFF86B0B00A52A74F079BCD7A2686C7E433445491D1DE1908D43529B3219225
          A799FBFD6F738B7F7E2D9D481301CA9096184BDA4E2C1232B55A2DCCD9B666DA
          177CF4EDF4ECC52B4C26010EA348450B0A70639BB48AB272CEE3F1E8F905F9EC
          A9535D86EF16708C677FF3A3C8E8B18BB9916510B161EEC5CD017E943AB45378
          3A2D53F7476700450490B165B1D57F3CD0540A4DF68ADA7DFF0DC4D408D19415
          80E6111558074888E1182B49D687F800239044C68936A9B00298F403F87F17D6
          72ACFBB072C6EEFC4F08A142808EC02C50405BF00D67B5F92AA981CB5003237F
          CE78C1F550CF7DC1B7D356A29E12DB2DDD1F8CBEEC5EEFBCAFED6EBDCF6A979B
          D24B2D571FDE69E0D06518D882C4B4A913F2B86DF82CD287192BEB2026E081F8
          9F8D5B05BA60655D64403D6CB98DB1A0CAC7116067C6031B6F371624BE20E83D
          A398FE5801C444E02F09BC41C2620A8810B02E6B7C177496E85ED7776CD230BD
          184C47723D172744158E422B300DDB520C4944AEB5CC0C7D12FF3CC71389CBE6
          ACE607AF05362D090F0117E512713455783DBA03D4B7533C2D60F875C01C21FC
          F73DE86B3242BAD9693197B4DDC3671F3B011A8F0100DAA0B4A5EFFB08E14A46
          0CA06EC2E67F26F976ADD7B44CC861C0FAC4CD28350F46264ED4E8C294853ED6
          A7EF26F6B5581FAB2A80B4612B10210FD8A4D06796CBB6BC869347B0D6E22E91
          F313F2B893F1E9C6EAD4BA047BF08DA487F48030DF5CED04717515A6A4AE2801
          424365640289B3FABA668C219410DD396C1982A1558807F9F376D0BDC5C0D8D5
          1673DE974F31F6016A918D486AF07C84E248882D0E7FEABA5269B7AF249A6926
          9F1200EBBAEB3185D5A22116FD6B844C8730A482CEB88067E956AA68420A66AD
          3E60956EF495C78D1C9A6114203CC62E9D9E8E1C15C69603E1975B31C1590A8C
          593FCEC51DD92864ECDA0B9CDC10D3A78984787D902FD7CDB7DFCAA4542C655C
          D36730F10E2682C08A1242E165D02261945C060EF36B9ED571B26AF4D1ABC3D1
          5E80FE51337078BD55953038443FC89AC9D8BD384B3F5C92700004B319D4BD48
          502D0B33CED11DC474B4D164AD6B60F8A12E24D43A9950C47703E15C1B635BA7
          2B0A91FCC30C083AA872D020C3E3E243230A740FA850525C08A2281AA7150B4C
          1323D4D9459224E81B1880818121D0FC23F20C7BEDE32EFE50170FFE304F7C1D
          42614DD3B94A7DECDE9590B0BC5296FDB21A485B7470104A12A7A5C0CCAC4C50
          312863CCC70B3E3729CAD13E2DB1DF172B34B0C7529043878FC0606F47EB34BE
          E195D90BD7BE324987304E2FC4FE9373666757A6A7A58246033DBEA793E982F4
          2B43082F9A34DD8F1118076098F11A138EB65EEF30F49C3E6D60391D0E9C4743
          330349898960B7DBC6E77A877DF432FB2246D6BB8C779881D0E4F355CC7B965C
          3A3B1B5252928D9C870EA644A82433B3B2304FC2C4817E0CA09F4190E8891327
          21333303C2B20C3EDF08C8B202993332307FE20D97C4615E70BE23F40E0FE34E
          6946DBDF3F8098F2FB3AE16F4642E4629E1A5D2F2C42CF2A4ABB16AF126675D7
          AAE1C464FFE9F96B341884BEF20AD0EC99B0203FCFD8319A98D01BF9C40485BE
          57F1EE4885A2F57C259672D5D4D651535C88A40E7CDF05BD644FE0E9170B8AAA
          4A31EB3116898DA760349B8C1D21DD0D7A2564C68E2C768C679773D33305EAF7
          3552BC7B91D0F33F24B84EC7A7CF137A901798C0CF444D4A4AB2348612B9B6A1
          C19E5F55F7265825216C4B4DD13B8F10D7771D8381EB568E0A1088105B8D9BDD
          B1B355BF46D4085E59206251897D1B62D1BBDA1288460409EB5624726892524F
          A944E39D6BFC7386C73D039FD958EBB0168E8D3A81FFF74D0DF8C712FA3F163C
          CA82FF00BCC5003D8E9959500000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage11'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F76000006BD494441
          5478DACD577D50545514BF2BFB70F9D8950F595C96C5049D494D5840012325C7
          4444C40F342B1D25A7649ACCE99FBE74F28B1A9B669AEA8F34FCA8B484B01A13
          414C4605A10F4D091544BECB05158C5DD885DD65177DFDEEFA96793DDEB29039
          C39D3973DEBBF7DC737EE7DCF3CE3B574208D1B22C5B4578438209B23767FFCE
          57B25EDE0EDE03EEEB98140EA7641524B4E047C0D7B896149DC0B6586CBB2CC1
          43496A4A725651F14FD33051C897D886895DAE75D0D1D1D12107CB502A955F89
          615C82E702D05CA82AC73B0B2E71090FDA9E82A60A08EA2118C0D7F4319E6781
          7663A1C8AD26B121049EF6C3B1E345D0C20E12827A06CF2BB0984F276BAE5F67
          C70706E60707073F3720545E51C14AA50C999D104FA3A8C57C24361C8666F8A0
          EC706A5A85851358B0E2B9003C9D339F04A13221A61998BC06C18CB97312CF4D
          9F364DCFC734CFC3C3236BE34B1B1C181A1A1B59855CBE04980A07847EFEE557
          B6A3E3AE75F9B2742F6CC8C27C214CB641F37A683E34F2383DCC1850F4F9BE03
          6743D521F374AD6DEF7B7979A55A2C963700EB0C97677BC136807C30D7CF0B46
          1E203F2F4CDBF9CE8D9C5028981DC4E03463387FEF436E1C78F7885C83320FB0
          31B04A15926F72F36E9A4C3D9A65E96987542A55A6A8225892787B7BD7C0A5A9
          53264790FA86463FBE65AC7705F8FBF7EA0D062DE6EFBA4494B3FF600D62A3E8
          EDED5D8ED78561619AB2C58B522A3825A7C182A1204A80B81D68838588141034
          F28492C04C203962548FB5DB9CDC3A9AAF6E6344330FAC0EC2B704F30AB8DCDD
          D0D84432962FB50389E7A3CDA3D1AF08C1DE8E38EC049721D8369A8CC3525457
          5FCF9E3D5776913CA897EFF1ABDBD74772D99E9EDE2D98DBCD33940DB60DC6D8
          4188703269607340EF62938D6F71FFC12FAB6563C74E47AE75A2C8C443419328
          222849C5E6933C8B35109E0E2E856B1BB1B687931B23E6E680A2BCFCA3B7BABA
          BA551111E1A4A9A999F05DC3E6062009C2E7E3EF2CC530700686E68FF8D42862
          994C56A4524D2031DAA831CED80C52949B97DFDC6D344E81C57BD8B402D93B01
          C20E77F2BFFBDEB07AD54A7F91939542A65F18235A8CF39217CC27A74BCE9442
          E13C1E9AD511E193BE6D6A6E5987D7933042DD1EC70FF85079E4F815D09A044E
          51D2CDE7102B2673DDDA4497C1AEADBDC1969E2FDFC2E55131AC3E0305F574ED
          D8F102F6CE9DF6194059CD33140D56ED2C7AFF2A6C60FB020303923B3BF519D8
          7489E79AD4CF6F9CC56CB6744AA5D2E2450B177C0105E5AEF2C8179B7B78162F
          433816DC0B79A4C25A33F7FF64F0FCBB4BD74ACBCEB3B537EAFAE472F92593C9
          94C8CF2364753FC629CCA5F10C5D85A148D160C3223DE2046C2816C9A31C8542
          BE313020E05E4CB436084A0CA2881E768C3E45FFD718FD80D0931CF2F4F4D4F4
          F5F5BD8D24B8E89CE7F23E1A1F0E3DF4B538FC6CFE3EAC1F5628148946A3F159
          DA41BB338C2C9C0CD642BFE2210141B117D8ABF8B0DE41B90C90482404AD0769
          F9F32F5275E56A1DD69E86C13B4203B4FE82BD09DAA50955337F77EAAB504E37
          E3DDD13CD0B24ADB74003039DBCE61456838030AC78351E52D78A6DF1A2D2503
          3F03801B0BB609CEBC06FD13F1EDEA9E4C884B0D0F0FAF76A77B1020B448B5D1
          DAC8C7AF555FBF60B3D93EC55409C80A5A0ACA8A8F9BF961A85AAD03802B8208
          95866942936EEA5AA97CA6B091113844DB29DAF627438F6D48403C0F5FE06816
          FA5C1FBDDE5065B658B261A8C09521ECA337A74F8282C66F089F34895456FE51
          65EFEF3FC9308C393D2DF504D6640070910C31C47288E6022BBCD5F0BC8B00DB
          05DA47F300EF347225A8C37459EAEC1BB90BD062103DD2AB98FF7138E920F695
          1D9D151BB3CAD0D54D6F2CB4F13C0B0FED3E3EDE2948F209784F75518277E057
          BEDD6AB55285F486F016FF2722708A1E571D1CDAE61690C0C813E4C1AD5206AA
          84810BEE3CC41E0D92F980362A32B9A9B999188D261212A2B226C4C7D5A36EA4
          00C4ED911ED91A3005E8A0B057E3BC7B0C2C07B492FB84FDF06CC291BD88484E
          B5DBED5BE9ED7238C7335C407108FD1E75882A16BD8B632E2A7206F1F5F5C1FD
          F237DA00C5C360A54864C2C0724189F87BDA11991D78FE08B27D224E7D06B659
          5814DD1ED95083361450680157801BF96BB4C1F064983D444266DB6C76A20E09
          B91F1BA3DDA156ABB3DDE9154BEA0B4A65D0D4F676470F7E001E1A38234AB0B5
          4FCF9D5388B6692640E40A4094605F126EE8AF3BBB67370E65D2880EB70E25A0
          17DB8A2E68215E99D909F144A76B25AD6D6DF48A97E52A47B08F76934770939B
          68369B7BDB6EDDFE00EFA74056DA280284060074E0BEE0A25FE023FBDB03DC4C
          B04DA0488691D6D8EDFDEBDD5DA91E29A0FF3A461520D42FED3FE87F0FE862A7
          87920000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage12'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000480494441
          5478DAED576B6C1455143E670A36581E6DAD8DC58A364693AA68A1BB43ADB154
          B3B6B4942A89958722A2811A354D638C097F0C4A90A098FAB65245304DB62D09
          4645DC828F2284655FA6FCE0914A2BE203A158FB9092B4658EDFDD9D25DB75D9
          567615487A939373EEB9DFFDEE376766EEDC6122CA1191560A698C843FE8CACD
          9352CDC8DFE7713BFDC93CABBE2E49E8B6D34C6B305E710E19717AD4E4B944A1
          55FFACC5E32EE75916EB0C8DA805563704C0F9A7FC23015DC7E0E641E8FE1157
          36AF2A03A15E65F096C53E576244CDA3BAB00B0741F451C4DB21FAA988201464
          1106ED00262F173E55C7323E5968C8E1752784821C00CD0168FE2D421B0E3215
          6D37B4EF7185568CCFC5D88BA1755A0686D7BA992A51E61B0D22549ACE025413
          D4F41D3A0523098F1FE805805E8AA998A369A11548C28AA7E183B5B52D11DEE6
          2039D3C954134D4DA8EC66008B8349557BF43F596AD14FD488968EDADB90EEC0
          7DE8405C3C8E6825FAAFECF1B8BF0C272AC6C4E610A249E8F71DCC9D25938929
          D3B78F175AF4FA77457B381571A9556F982264B37BDD69C05603FBFAB01A21D9
          8FE49531D5C8248A7AFB2E63A258DA254C84FAB4C14D83F960AF52606B19F857
          4420398449D926E172C4751516FD781F514A2FD320368C1CE4DA4743E49F6C12
          79105BEFB3EA158D86D674BF660CEEF6B8AF5864D1BB7F64520BDE198D280380
          E3265115E237E1AFC5BBF5CB2696EE67BDAE94272DFAC96CE2F176963C6C6B87
          A13213B85FC389A622F95B185126887E5ECF46E7CB5E77FA128BFEC7DDC4892B
          BCAE89AB2C7A9783A91AF04781B58512AD4462AD49B41FF11DC5567DA7DDD06C
          0B35E3A71D1EF70DBBF1023FAF89E1F4B8137C889FD6241DB84EE01F826F1AB6
          45C25F05AEF9B0C224A205E3848EF4303531D101E46E97804F855D0D535FBA2C
          D87BEA6A426FFFB77007907C26D6E7280D24A7E2F1408E11FD8F44FE2F47CC44
          B1B6B811C5AB451484724D8153AFDD31946DE8A2098290E970EA58703384F4A3
          7F2BE24DB039B0EB60B361258942F70C321DC1D6B611FDCF816D8BBB20B51DC2
          D582BC2CAC5AEAB4BC19F9A260AEDCA2EF5A2B5C9081634A0D1BE4646AFF8BA8
          92023613560FFCAA5805BDA5AA01225F380863EAA4F635C67699FDDC22A1E66A
          D1D46DA5D56C9C84A8428C1FC2D85D0F083B4A8526AED0FCDCF530156C836D1D
          E9110815E4A4C0A9BA2B82A0C7E10630566FF693A70A757C205A8AEA7FCCD2D3
          C0F220C6BF525BFE34A1B65AD152BF60197887457D641A912F7F4CB86133CB04
          ACF827A629FC37D104AD83FB14A0BD1104BDA1D60D560FFD9247841B170B4F52
          FD656C749D60CAC2786FBE55CF9F27BCA35238A99A8DEE36A66CE47FC79CB94B
          85ED13B0662DCB13EAE385DC3598BE93027F5C47C30525C21DC640569898C970
          2DC8CF34FBD7670BED794E385395125FB5A10F5936F633B5E2EF66768150D90C
          88C17D39FB114B4B1FFB8F3537A50A9594112738495C3F30BD8F5C2FAC07762F
          AC559DC38709321753E7A22AD87AD819D8DBB00530F57CA97F4617ACFDBFDC0A
          CEB70FA5990FE0051D6CC7048D091A1374D909BA98ED9212C4CC397F031D9816
          3B8CD2CF970000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage13'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000C55494441
          5478DAAD57075893D71AFEFE0CB2802C021141B622020EC02DD6114086A0206E
          5C55ABD756BDDADA4AB57ABD6A6DD5AAA56055A803475DAC22CA5270214B0505
          011544833141208324848C7BFE7841112AF6F69EE7F99FF3E7FCDF79BFF77CEB
          7CC1006088C160B88766C8BD96BF72E227BEB1185A80F2070F0DCE4E8E90A1DA
          07252FD5605C2C6849348C64CDC3FC4B8297483F13271A17B355BF1A4AEA72A1
          486338797EF0D979C6C58EB1E6C162E93EF704669745A4486E5CD8FA689B619D
          CD5A6030186F14C4D5AE683F1659425F78CE5B83F91507B3AE78A5B584654DFF
          2D59707111BE30092DE4948B2F183C2CC3B14ED0913EC3B182A242C3A5CB579A
          02FC046C915A047C5A1FB89677BDA053489015386EE99091F991BCCD58A524D5
          70A639455BA490C8A43B5F07750A859546EC4C1E76FE1BFC7DFBF38D6DB71FA7
          2A6CCD9D74715E299646A17DE5F30D596DB2B674EF146A54B19F5282517CD7BB
          85144DA22DC3F04D5D0EFACE81EDD0648EAC5BDE450811A76CFB7ED7894913C6
          CFC0300C163E5804F103E3814422BE391DDAC91D37665463B6EE3808480BE1A7
          DAC5C06DFA04160D5F0875CFEADF22EDA99A67B8AA5028356AA9682483EAF8AF
          2119D86DDD69C328E2EC3748FE252113BD31754ECE722901B7D5843881F5E811
          20949AF453C6B8C733DE9A20735A4AB25F52E885963DDA1F05BF5347EC37B4EF
          1F5DF4F6744785EB0D07C3F2FBD8EFA5E585F6F7ED3FDB6A1B36A564AA2EC32B
          9568149A96E7251A63E56AB56E402236256F48039D6E1F1D62ED9C10BFB370F1
          F598FCDF7AB493DFCDF1627F0B5B1EBEA963AD4763BE3F32B373D369345AA025
          8F0778C466356581F91336A8D5EA39C8E0A7FF14E8D2E54C5B0A855291C3CF34
          DDECB009199D04442211EAC47550CDB80447AB6EC3A9612700DFABD3E9E04E51
          495937A09CAB792DE59CFB4C07BB362890BC84ED4EBBE15AFE0D386FB211ECD8
          7DA11FA73F4CD0AF848AAA1AD863BE1726BCF6856164EFD15D80906F282EEA17
          6A4B735BE386D39595D15726A7EF109C213A0FB21F53D34AA6E8CD1BD8F46A2B
          E5CEF0BEAE6B290C3EEC179CE5213F36BE1B4B2434E99871BC7F920CE09CEE93
          BEA243812037D07AC3D899C26FC7FCC2187D88D7DA97600E4025429E445E9B3A
          36C5B19B8DA6DF0FF7FCD23DE2FE860D0723F377E79DC3336C448283627CDF21
          F4C3B505C8D729B8329859363BE677CFD3ABDE354927D0D7A502BD3DC705D390
          59FA5361D9E6CC8356015B1C23CE673C3B03361C1748082FA0F3F75A2FDA307A
          E62FBBB2CF9626FB277975039A7B7DA8D68D6147D451087069E10B5374E6D6F7
          3DB9A6D4CFE0CA71062B9623EC129CB54132C21E197D68084E13EDFAD879D501
          9DDF5CBD54648140F4EFCB7C14D03B59BF1E4D27D1638902F1FE5F023A79EA0C
          BF8FB5F54BFC1D1500686D55C285BA8BE0D0E274022D7D8B00EB7B04429E3241
          9361FB0F3F8ED2EBF5310C3ADD63E4081FC0CB8BD156355FC05CD57CF072F782
          BBF7CAC0DB6B68CF85EBC08118A2AB9BDB50DFB1A38B222BE742F2E073461004
          0A9F3E5C028BDC2683BB2C10D86CB631457030A94C46EC0284D2A364E4709F61
          040206B9FAD370F3C953D8E2BA19546A357CF1F8739860C583577A327C65B3C3
          28DFD0F612985A73282C2E8DEA0284B27C169D463B7D9B771E7CEC0601593810
          DC2D0641744534304D1E812D8AA7D4D74238C0DC0B2C160BCE190E8143A9B732
          C05FC0E876B4590541CF275B3BDBF4459BB64E384E47AE56FDFAF473436DE303
          E031FB42564DF38ECBC1E9D119F2186D42CDF5B6E7CB6B994846DB35690B03C5
          022A9347A653414D626B9266DCA0E2853524CF5DCA2712CDEB69FD00DD56D8C6
          8A39326FBE87D9C9D292E20B93CFFB74337648DE50C93FECE65994A8EE40BE52
          D58E3699747E2B9AF638CD27C979EEAD71559E6CEBFE78753818776371DE96AB
          6FCB289E9CE89D8CB46B828A03E2DB4458727670465AE771EFCF7EDAAED4AA15
          983825D665E3D7C79EEF034B961324CE28EC4C956E368A13EF101D0B4A764602
          0AFC7768C9B4F2AF8744BA4727242C210FC634E348B4138D7A393C6B66EC4B12
          A4ADED31B257542E7E8519488CD205F7B808A82DF45AD0BA692E0377DBA26344
          FB1E61A135292E372166F2CAABABB2637B4C91B0D2D05751F6232DE39F1618AF
          5DBF82E0B93E266D89B8CBF5542E1C0FB9424240BA8BF258D90F138FFAA3F7DB
          DD80A614073DFB8461DA0F37E06F578B0F65CECA581E90E52C5FE638DFB4565B
          03D7D0DD99E695CCF877ED3AC960BEABC576DFC3560848DC05C8AF38306206CD
          FE5CBDE6A9B14EC77F7AC7F97666C1134122D98BE7EC53A432E18A9386A5F1A3
          8AA73F0F73F4B1C911D5AA7E713B44EF5646FCEE4CDEFC153F746BA6F83C5460
          E68A34AF54B3F78542F2FD6E8CE5B1C7E08ACED43D6C4E197191D30DE8BF373B
          5E36EB51DC48DE1740DFF8B338CE2F6BA58F8C8C4F5DAE88CA5D9675A247A0DE
          46C0CDD1CD0E543A4B4430CD4F1A9A3CBE2799BF54217B1BA8825ACAE5723BBD
          4EE74267308E70D86C9A52A532DEC604548AB46896CB64B7982C961F2A88AD3D
          61FC6D427F5CBACCA752A94536D6D6360306B88056AB35B60A386E4751AD5254
          C129F131F0947843F0D060100A1BA0A9A919E40A850677252297F93F1342A56F
          8109997CD4C37D106C6FF81EBE745A0B3C131E100884CE82DC8159DE520E69D2
          7330C569187C579A08BFF27E061B1B1BE3F78E3E46F4EA153C7E529B8CC45721
          62C20F12422EA0A14D9B381CF64AD4613169542A989A99C217D56B21C265389C
          ADBA0531030E006AA440A552A3F94DED5221374554CD81B9D66E604EE3820A23
          C2DD8762F8D623FA4DBB8F615DF4C86432A8ACAA06A55235EA4F092132F3D174
          7CA0EB00E072D8C6D3C43E8B030E5303AE967650297D0124711F9861176EB40E
          994C369E7AD1FDC5D08FD0086C1A1B98880C4E2847F40C16604BC067C070BCDD
          366261440C6695CD8351BAE110CE0D8727B575CF913EB75E5D76F94A16379B9C
          9D80BA3481671F2B1AAE005774A2EA569BBF28A8D69262A94318A9A7E4C7F52A
          76ED062BA2924436310133EA1B4244137328AE93B6CFD144D5110984B42A7975
          D255DBDC2B5F0D8BA09FAFBC09D40276B987B9C7A288F06925BDC610DE08727F
          E6BE7037D15A71681CA302FC5111C870B9E6C195FAD57521A8B4B5E35D27E834
          92E5B663CD0610DDE1F093EF81413147D6E140994AF754A2508565FAA697CF2D
          0BDFE444E76EF2B270219B22C2FB1FA4B78A5708F19B41D46B502325E34C142F
          2F460F5E6D21697E0145D2FC4E4259AF1BA4E28296C1AA04297E0711D0D38EDF
          A0FE45FE338818610DCA2F16D66A38A13325ED46DF7404D0FFE00CFAB9F6A6DC
          3E1D6E6CD4EAF4C9D70A13657B5F7F8EF6CA3E2ACBFC6E8D3D426E7D3193C7B0
          3035A530414934952880F047FD52E1129CC0FBF2937EF7E7725C59950AAD8ADD
          FC99888D1A592A49DF7ED75AF9CCE60D91B7563E27AAD1BE5E2DF22CB871A7F2
          5D8C8F4AFBD9F7677F23D7A81637AE6C188C88287B92092899DABECD2B8AF858
          D6809DBE957B42BCA961293396FD3094EDE034D56236C4566F050C05340D05BB
          5C4751DCAD69FC29735AC6E6F7713E4828BC744688A785C36136C58C939C94BF
          4B192FDDF93EA1B082D03363ADFA4D7361F733C14F7EB6BA405A91F378BAFAA4
          E236DE51F9174FF9920084B5B81B493A7DB1460A1732FD2EEDFF339D3D129A52
          3AD5964DA416CDB4F3B1C295C43EBCD2DAB04738495BAD29C15B325C666AD224
          1F8A2D356FA4199BD611170C2A0B0E3EBAFA5AB25268F7EE5F86A0D230A11585
          6552BDF7C9DA1BF1D7133FE48D2E84F0268B1F6B59E66D66EECEA7F38C4A8044
          835365B7CB44EB5FF8E2AD0C0A76B6A15DF5C08BA8B776321B080DEDCF3BE3A2
          A8E5B5B222FF45C4D5155919385E6449E47793EDBC567B70EDD93B0ACFC825AB
          84C310C6E38F2214501498CD573D1F654165D2DF0DBED2A62659796EFD1A55A2
          EC38DE122142EE24A5F8D632C73033B5520165F24263B08AF464458D529EF187
          4F4A646076F04C173E77FF441B77A3851F4A5FEA93CEE5C5298EB6AC4718EA5E
          09F917FA650ED02B059BDCF6426CCD56D0601AA39276B22994D637A5356C10CE
          C4E3E1DD8D8818DE3EF4474F1D7AEEE1BD0B5AE3527486CAF14C16AFC38DF87C
          A42A4FD9F0A330E0E6999BD77B4BA04E0BF9DD1C97684A244C221A74740DD9CC
          A0C148A06DD27967092E3DEE0DC448B028E895835AC8F6E4FA909BF492CE4A2D
          473899C515A9926DA208BC887E34A1BF3390656C0CEA96C205FDC6F67121B941
          CACBE3608A2C8C93AA14B5C65635366EC90EC9907C0CD6FFB54143C41C89066D
          1486110C5A20A42237DEFD2BFB511730E43FC6B43076BAFDC2C3000000004945
          4E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage14'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E00000A3769434350735247422049454336313936362D322E310000789C9D96
          775453D91687CFBD37BD5092108A94D06B685202480DBD48912E2A3109104AC0
          90002236445470445191A6083228E080A34391B1228A850151B1EB041944D471
          70141B964964AD19DFBC79EFCD9BDF1FF77E6B9FBDCFDD67EF7DD6BA0090FC83
          05C24C5809800CA15814E1E7C5888D8B676007010CF000036C00E070B3B34216
          F8460299027CD88C6C9913F817BDBA0E20F9FB2AD33F8CC100FF9F94B9592231
          0050988CE7F2F8D95C1917C9383D579C25B74FC998B6344DCE304ACE22598232
          569373F22C5B7CF699650F39F332843C19CB73CEE265F0E4DC27E38D3912BE8C
          91601917E708F8B932BE26638374498640C66FE4B1197C4E36002892DC2EE673
          53646C2D63922832822DE37900E048C95FF0D22F58CCCF13CB0FC5CECC5A2E12
          24A78819265C53868D93138BE1CFCF4DE78BC5CC300E378D23E231D89919591C
          E1720066CFFC5914796D19B2223BD8383938306D2D6DBE28D47F5DFC9B92F776
          965E847FEE19441FF8C3F6577E990D00B0A665B5D9FA876D6915005DEB0150BB
          FD87CD602F008AB2BE750E7D711EBA7C5E52C4E22C672BABDCDC5C4B019F6B29
          2FE8EFFA9F0E7F435F7CCF52BEDDEFE56178F39338927431435E376E667AA644
          C4C8CEE270F90CE69F87F81F07FE751E1611FC24BE882F944544CBA64C204C96
          B55BC813880599428640F89F9AF80FC3FEA4D9B99689DAF811D0965802A5211A
          407E1E00282A1120097B642BD0EF7D0BC64703F9CD8BD199989DFBCF82FE7D57
          B84CFEC816247F8E63474432B81251CEEC9AFC5A02342000454003EA401BE803
          13C004B6C011B8000FE0030241288804716031E0821490014420171480B5A018
          9482AD6027A80675A0113483367018748163E03438072E81CB6004DC0152300E
          9E8029F00ACC40108485C810155287742043C81CB28558901BE403054311501C
          940825434248021540EBA052A81CAA86EAA166E85BE828741ABA000D43B7A051
          6812FA157A07233009A6C15AB0116C05B3604F38088E8417C1C9F032381F2E82
          B7C09570037C10EE844FC397E011580A3F81A7118010113AA28B301116C24642
          917824091121AB9012A4026940DA901EA41FB98A4891A7C85B1406454531504C
          940BCA1F1585E2A296A156A136A3AA5107509DA83ED455D4286A0AF5114D466B
          A2CDD1CEE800742C3A199D8B2E4657A09BD01DE8B3E811F438FA150683A1638C
          318E187F4C1C2615B302B319B31BD38E398519C68C61A6B158AC3AD61CEB8A0D
          C572B0626C31B60A7B107B127B053B8E7D8323E27470B6385F5C3C4E882BC455
          E05A702770577013B819BC12DE10EF8C0FC5F3F0CBF165F8467C0F7E083F8E9F
          2128138C09AE8448422A612DA192D046384BB84B78412412F5884EC470A280B8
          8658493C443C4F1C25BE255148662436298124216D21ED279D22DD22BD2093C9
          46640F723C594CDE426E269F21DF27BF51A02A582A0428F014562BD428742A5C
          5178A688573454F4545CAC98AF58A178447148F1A9125EC94889ADC4515AA554
          A37454E986D2B43255D9463954394379B3728BF205E547142CC588E243E1518A
          28FB286728635484AA4F6553B9D475D446EA59EA380D4333A605D05269A5B46F
          6883B429158A8A9D4AB44A9E4A8DCA7115291DA11BD103E8E9F432FA61FA75FA
          3B552D554F55BEEA26D536D52BAAAFD5E6A879A8F1D54AD4DAD546D4DEA933D4
          7DD4D3D4B7A977A9DFD340699869846BE46AECD138ABF1740E6D8ECB1CEE9C92
          3987E7DCD68435CD3423345768EED31CD09CD6D2D6F2D3CAD2AAD23AA3F5549B
          AEEDA19DAABD43FB84F6A40E55C74D47A0B343E7A4CE63860AC39391CEA864F4
          31A6743575FD7525BAF5BA83BA337AC67A517A857AED7AF7F409FA2CFD24FD1D
          FABDFA53063A0621060506AD06B70DF1862CC314C35D86FD86AF8D8C8D628C36
          1875193D3256330E30CE376E35BE6B423671375966D26072CD1463CA324D33DD
          6D7AD90C36B3374B31AB311B3287CD1DCC05E6BBCD872DD0164E16428B068B1B
          4C12D39399C36C658E5AD22D832D0B2DBB2C9F591958C55B6DB3EAB7FA686D6F
          9D6EDD687DC7866213685368D363F3ABAD992DD7B6C6F6DA5CF25CDFB9ABE776
          CF7D6E676EC7B7DB6377D39E6A1F62BFC1BED7FE8383A383C8A1CD61D2D1C031
          D1B1D6F1068BC60A636D669D77423B7939AD763AE6F4D6D9C159EC7CD8F91717
          A64B9A4B8BCBA379C6F3F8F31AE78DB9EAB9725CEB5DA56E0CB744B7BD6E5277
          5D778E7B83FB030F7D0F9E4793C784A7A967AAE741CF675ED65E22AF0EAFD76C
          67F64AF6296FC4DBCFBBC47BD087E213E553ED73DF57CF37D9B7D577CACFDE6F
          85DF297FB47F90FF36FF1B015A01DC80E680A940C7C095817D41A4A00541D541
          0F82CD8245C13D21704860C8F690BBF30DE70BE7778582D080D0EDA1F7C28CC3
          96857D1F8E090F0BAF097F1861135110D1BF80BA60C9829605AF22BD22CB22EF
          44994449A27AA315A313A29BA35FC778C794C74863AD6257C65E8AD38813C475
          C763E3A3E39BE2A717FA2CDCB9703CC13EA138E1FA22E345798B2E2CD6589CBE
          F8F812C5259C254712D18931892D89EF39A19C06CEF4D280A5B54BA7B86CEE2E
          EE139E076F076F92EFCA2FE74F24B92695273D4A764DDE9E3C99E29E5291F254
          C016540B9EA7FAA7D6A5BE4E0B4DDB9FF6293D26BD3D0397919871544811A609
          FB32B533F33287B3CCB38AB3A4CB9C97ED5C36250A12356543D98BB2BBC534D9
          CFD480C444B25E329AE3965393F326373AF7489E729E306F60B9D9F24DCB27F2
          7DF3BF5E815AC15DD15BA05BB0B66074A5E7CAFA55D0AAA5AB7A57EBAF2E5A3D
          BEC66FCD81B584B5696B7F28B42E2C2F7CB92E665D4F9156D19AA2B1F57EEB5B
          8B158A45C53736B86CA8DB88DA28D838B869EEA6AA4D1F4B7825174BAD4B2B4A
          DF6FE66EBEF895CD57955F7DDA92B465B0CCA16CCF56CC56E1D6EBDBDCB71D28
          572ECF2F1FDB1EB2BD73076347C98E973B97ECBC50615751B78BB04BB24B5A19
          5CD95D6550B5B5EA7D754AF5488D574D7BAD66EDA6DAD7BB79BBAFECF1D8D356
          A755575AF76EAF60EFCD7ABFFACE06A3868A7D987D39FB1E364637F67FCDFABA
          B949A3A9B4E9C37EE17EE98188037DCD8ECDCD2D9A2D65AD70ABA475F260C2C1
          CBDF787FD3DDC66CAB6FA7B7971E028724871E7F9BF8EDF5C341877B8FB08EB4
          7D67F85D6D07B5A3A413EA5CDE39D595D225ED8EEB1E3E1A78B4B7C7A5A7E37B
          CBEFF71FD33D56735CE578D909C289A2139F4EE69F9C3E9575EAE9E9E4D363BD
          4B7AEF9C893D73AD2FBC6FF06CD0D9F3E77CCF9DE9F7EC3F79DEF5FCB10BCE17
          8E5E645DECBAE470A973C07EA0E307FB1F3A061D063B871C87BA2F3B5DEE199E
          377CE28AFB95D357BDAF9EBB1670EDD2C8FC91E1EB51D76FDE48B821BDC9BBF9
          E856FAADE7B7736ECFDC5973177DB7E49ED2BD8AFB9AF71B7E34FDB15DEA203D
          3EEA3D3AF060C1833B63DCB1273F65FFF47EBCE821F961C584CE44F323DB47C7
          267D272F3F5EF878FC49D69399A7C53F2BFF5CFBCCE4D977BF78FC3230153B35
          FE5CF4FCD3AF9B5FA8BFD8FFD2EE65EF74D8F4FD5719AF665E97BC517F73E02D
          EB6DFFBB98771333B9EFB1EF2B3F987EE8F918F4F1EEA78C4F9F7E03F784F3FB
          8F70662A000000097048597300002E2300002E230178A53F7600000688494441
          5478DAD5987B6C944510C0BF6B69AFEDDDF545AF570B2612E4A1A0142A012226
          C81F5A4C0B48A1943E853E80688860C0209A80101A8D018DA27D5090D27745E4
          21206094202028B1501495402020D06BE91DD77BB5D7EBF95BFA951C6DE995AB
          89B0C9647667676767676767E6FB149224C5B85CAE5AC9AD2920485F14143DB3
          78614E5DF1D66DAEACF9998A4E623A0CEF3131DC9D5307A1BEA878AB2B276B7E
          0767D7D68D788770ECF809F3D9BA73812CF7ED94E5CBC0094EB84328292DABB3
          58ACA3212A7A96E1DE587600CEB81E99CA2AAA5C2693E93C0C4FC3280E60038C
          8C9B7B927411B409688161D33D92B66D2F73B5B4B434E6662FD0C23805921938
          03A3A3C7D3F76A0D24E4B2B2F0BE4CA56515AEB4D4790A189F6438100867C1FE
          7B980A8A8AD7B7B7B7EFA3FB03937EE595D5AE94E42445B7EDC485B6B6B67E4D
          57DCE50C982B7AD2690313CBC02E61FA6E3AEDDABDD739637ABC2F0CE10CE381
          D330FE7E0F135BED62ABB7E99E6432A4A4B4DC959196D25DA73ED9A93FAD9BA0
          D2F2CAC6B494E408F47F5EA9547ECC75AE875C819A019D3C5F96945EB2D96C6F
          40DBD7278D1026FC40050C064CC05EE06504D8990B031B7A1504D34AD051E017
          60080BFE8466A16F078218077A3C1A0BF668B511F1EDCE7629694EA242A6E583
          4622604AE1E62DDF3B9DCE50FAB1BD0AAAACAE6935188C1ABA89D8682E365A45
          FF2C0B7DEEDAB1ACC2D86C3627403BDA571B39414280D8FD0C90CFE21CE87EF4
          A3E85FF564A344A9C3DB2EBBD1AE831E036E408FF668236FDB2326080FBE8207
          C78B40FE408230E854A9C3E1F6965756B5DEBE6D1A161414586BB5DA32A0ED91
          794629148A738B72B315F71524331E074D029E63F16941235C5D1D30604015E1
          41A356A992D3D35242FA7C34048E8FD46A4FDD6A6AAA23063FCBF8035F5FDF66
          FAEBE827B349656F479B062A05C45BFB0C667F91D75441417919E9A983659E53
          1CCDC2D15EF47434E16CCB11B294FE74F06E707C54946E8FD96C96CC668BB0D7
          764FC61631D400A3ABBA66C70983D1783362E0C099FA860625B456373E0B6355
          6F82C46335C94311CC52A0F98484043BB941B18952A552DDB0582C4F3077A5AF
          C6F6D1A8D56DF22BFFB6B2AAC6816D9C73936607F4C4DF55A304D008167EB4BD
          ACA21D9BA894FEFE675B5A5B85E13F91795EF2F1F1F96E614E96473F12864C03
          EEAA2F6E2A3030B0012F578287BE969136E441FC28212C3474B7C56AD553E3E8
          186743BE85F09DF4578357F776B4C9A01F818DC0429883A1BD101C1CBC3F75DE
          5CB5E0C92FDC7C0D74103F5AE0E9684A507667A921D3C610C76B1D8E36C96834
          4E66EE589F8FF6A0EDE113F45FB5474F21910A4529D985960B2AE0254ABC4409
          5FB7E2F389F01DE8454E28483CB23C514978A510426248FE3F93FCC503AB63D3
          8BDA8888571A1A1B6F311D8BE01B32DF48D0E1F0F0305D539321137AB99B8C57
          89CF257E7E7E2ABBDDFEAEAC90CB2B85BA2837061405FC84400BE3A708254B28
          84CF432B940BAFC7E9EFE7A18F22B24A3C29A9A1A151E44361BD0BFDBE32B129
          165A838544A9A89769DAD0D0D03AABD5EA478A7B07D2B8B0B0B05C83C17089FE
          D4AED1575E13404A2CA4364B67BFD9F0ECF0562111485F073E244D069247249D
          2ED2555FAF5FD4F54303DE390101CA72BBBD4594A649C01160268A14046B34DA
          26834144B715AC6BF3DA42BD281A013A1819A91DABD737B4D3FF14784BFE021C
          4FBF18184D6A3E498CCEEEFCC0606E90D451EAB57B6BA1D9513A5DCDCDFAFA43
          0CD702E23ADE0732816508DE088F3F796E0B7252B1C6BEB6B636E12F763719BE
          A03C32F572ACD488CF4D64FEA2D71692AF2D19075E8C302D9BEE6253F1B1ED10
          BED1B9B9CCB7017833766C8CF5F46FB5DFC03B8D3561ACAD604D16BC364FD6F7
          642151A24723E89A3B9D8CB60EABACF2F7F737F194D51A8D5AD1DC6C168EFFB9
          BC4EE4DF71C011688D326D28A80C5802ED94B70A0DE594C7389D6EC4F061D6BF
          FEBE70898A743415E91F4C4F40B0D9CDA70EE9222363EAF5FA359D395C588DB6
          0219E243CFE67038163057EDB585BA2827AA5751605D16818D711C165AC9D33F
          076D9D0892D0444D50A356ABE3446938283A5AFAE7FA75514A67BA7F18F6E7CA
          2604050515127344CD7946A60D0F0D09F9D566B7EB894FA2BA89D5683479CDDC
          19FDB89EAE43FCCF41F99D586812FBCD12D590D71612960015117D078BE84B7A
          68213DCC72FFA696F926723507B85E254EBC1467FE0AF27C52C65AD28E8FC964
          12BE93DF2F0B79D3504C7C1288203881287F182BAEE874EC7E5FD9FFD11E2A85
          789131FF02959C2400C291D71A0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage15'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E000000097048597300002E2300002E230178A53F7600000A4D694343505068
          6F746F73686F70204943432070726F66696C65000078DA9D53775893F7163EDF
          F7650F5642D8F0B1976C81002223AC08C81059A21092006184101240C585880A
          561415119C4855C482D50A489D88E2A028B867418A885A8B555C38EE1FDCA7B5
          7D7AEFEDEDFBD7FBBCE79CE7FCCE79CF0F8011122691E6A26A003952853C3AD8
          1F8F4F48C4C9BD80021548E0042010E6CBC26705C50000F00379787E74B03FFC
          01AF6F00020070D52E2412C7E1FF83BA50265700209100E02212E70B01905200
          C82E54C81400C81800B053B3640A009400006C797C422200AA0D00ECF4493E05
          00D8A993DC1700D8A21CA908008D0100992847240240BB00605581522C02C0C2
          00A0AC40222E04C0AE018059B632470280BD0500768E58900F4060008099422C
          CC0020380200431E13CD03204C03A030D2BFE0A95F7085B8480100C0CB95CD97
          4BD23314B895D01A77F2F0E0E221E2C26CB142611729106609E4229C979B2313
          48E7034CCE0C00001AF9D1C1FE383F90E7E6E4E1E666E76CEFF4C5A2FE6BF06F
          223E21F1DFFEBC8C020400104ECFEFDA5FE5E5D60370C701B075BF6BA95B00DA
          560068DFF95D33DB09A05A0AD07AF98B7938FC401E9EA150C83C1D1C0A0B0BED
          2562A1BD30E38B3EFF33E16FE08B7EF6FC401EFEDB7AF000719A4099ADC0A383
          FD71616E76AE528EE7CB0442316EF7E723FEC7857FFD8E29D1E234B15C2C158A
          F15889B850224DC779B952914421C995E212E97F32F11F96FD0993770D00AC86
          4FC04EB607B5CB6CC07EEE01028B0E58D27600407EF32D8C1A0B910010673432
          79F7000093BFF98F402B0100CD97A4E30000BCE8185CA894174CC608000044A0
          812AB041070CC114ACC00E9CC11DBCC01702610644400C24C03C104206E4801C
          0AA11896411954C03AD804B5B0031AA0119AE110B4C131380DE7E0125C81EB70
          170660189EC218BC86090441C8081361213A8811628ED822CE0817998E042261
          48349280A420E988145122C5C872A402A9426A915D4823F22D7214398D5C40FA
          90DBC820328AFC8ABC47319481B25103D4027540B9A81F1A8AC6A073D174340F
          5D8096A26BD11AB41E3D80B6A2A7D14BE87574007D8A8E6380D1310E668CD961
          5C8C87456089581A26C71663E55835568F35631D583776151BC09E61EF082402
          8B8013EC085E8410C26C82909047584C5843A825EC23B412BA085709838431C2
          272293A84FB4257A12F9C478623AB1905846AC26EE211E219E255E270E135F93
          48240EC992E44E0A21259032490B496B48DB482DA453A43ED210699C4C26EB90
          6DC9DEE408B280AC209791B7900F904F92FBC9C3E4B7143AC588E24C09A22452
          A494124A35653FE504A59F324299A0AA51CDA99ED408AA883A9F5A496DA07650
          2F5387A91334759A25CD9B1643CBA42DA3D5D09A696769F7682FE974BA09DD83
          1E4597D097D26BE807E9E7E983F4770C0D860D83C7486228196B197B19A718B7
          192F994CA605D39799C85430D7321B9967980F986F55582AF62A7C1591CA1295
          3A9556957E95E7AA545573553FD579AA0B54AB550FAB5E567DA64655B350E3A9
          09D416ABD5A91D55BBA936AECE5277528F50CF515FA3BE5FFD82FA630DB28685
          46A08648A35463B7C6198D2116C63265F15842D6725603EB2C6B984D625BB2F9
          EC4C7605FB1B762F7B4C534373AA66AC6691669DE671CD010EC6B1E0F039D99C
          4ACE21CE0DCE7B2D032D3F2DB1D66AAD66AD7EAD37DA7ADABEDA62ED72ED16ED
          EBDAEF75709D409D2C9DF53A6D3AF77509BA36BA51BA85BADB75CFEA3ED363EB
          79E909F5CAF50EE9DDD147F56DF4A3F517EAEFD6EFD11F373034083690196C31
          3863F0CC9063E86B9869B8D1F084E1A811CB68BA91C468A3D149A327B826EE87
          67E33578173E66AC6F1C62AC34DE65DC6B3C61626932DBA4C4A4C5E4BE29CD94
          6B9A66BAD1B4D374CCCCC82CDCACD8ACC9EC8E39D59C6B9E61BED9BCDBFC8D85
          A5459CC54A8B368BC796DA967CCB05964D96F7AC98563E567956F556D7AC49D6
          5CEB2CEB6DD6576C501B579B0C9B3A9BCBB6A8AD9BADC4769B6DDF14E2148F29
          D229F5536EDA31ECFCEC0AEC9AEC06ED39F661F625F66DF6CF1DCC1C121DD63B
          743B7C727475CC766C70BCEBA4E134C3A9C4A9C3E957671B67A1739DF33517A6
          4B90CB1297769717536DA78AA76E9F7ACB95E51AEEBAD2B5D3F5A39BBB9BDCAD
          D96DD4DDCC3DC57DABFB4D2E9B1BC95DC33DEF41F4F0F758E271CCE39DA79BA7
          C2F390E72F5E765E595EFBBD1E4FB39C269ED6306DC8DBC45BE0BDCB7B603A3E
          3D65FACEE9033EC63E029F7A9F87BEA6BE22DF3DBE237ED67E997E07FC9EFB3B
          FACBFD8FF8BFE179F216F14E056001C101E501BD811A81B3036B031F049904A5
          0735058D05BB062F0C3E15420C090D591F72936FC017F21BF96333DC672C9AD1
          15CA089D155A1BFA30CC264C1ED6118E86CF08DF107E6FA6F94CE9CCB60888E0
          476C88B81F69199917F97D14292A32AA2EEA51B453747174F72CD6ACE459FB67
          BD8EF18FA98CB93BDB6AB6727667AC6A6C526C63EC9BB880B8AAB8817887F845
          F1971274132409ED89E4C4D8C43D89E37302E76C9A339CE49A54967463AEE5DC
          A2B917E6E9CECB9E773C593559907C3885981297B23FE5832042502F184FE5A7
          6E4D1D13F2849B854F45BEA28DA251B1B7B84A3C92E69D5695F638DD3B7D43FA
          68864F4675C633094F522B79911992B923F34D5644D6DEACCFD971D92D39949C
          949CA3520D6996B42BD730B728B74F662B2B930DE479E66DCA1B9387CAF7E423
          F973F3DB156C854CD1A3B452AE500E164C2FA82B785B185B78B848BD485AD433
          DF66FEEAF9230B82167CBD90B050B8B0B3D8B87859F1E022BF45BB16238B5317
          772E315D52BA647869F0D27DCB68CBB296FD50E2585255F26A79DCF28E5283D2
          A5A5432B82573495A994C9CB6EAEF45AB9631561956455EF6A97D55B567F2A17
          955FAC70ACA8AEF8B046B8E6E2574E5FD57CF5796DDADADE4AB7CAEDEB48EBA4
          EB6EACF759BFAF4ABD6A41D5D086F00DAD1BF18DE51B5F6D4ADE74A17A6AF58E
          CDB4CDCACD03356135ED5BCCB6ACDBF2A136A3F67A9D7F5DCB56FDADABB7BED9
          26DAD6BFDD777BF30E831D153BDEEF94ECBCB52B78576BBD457DF56ED2EE82DD
          8F1A621BBABFE67EDDB847774FC59E8F7BA57B07F645EFEB6A746F6CDCAFBFBF
          B2096D52368D1E483A70E59B806FDA9BED9A77B5705A2A0EC241E5C127DFA67C
          7BE350E8A1CEC3DCC3CDDF997FB7F508EB48792BD23ABF75AC2DA36DA03DA1BD
          EFE88CA39D1D5E1D47BEB7FF7EEF31E36375C7358F579EA09D283DF1F9E48293
          E3A764A79E9D4E3F3DD499DC79F74CFC996B5D515DBD6743CF9E3F1774EE4CB7
          5FF7C9F3DEE78F5DF0BC70F422F762DB25B74BAD3DAE3D477E70FDE148AF5B6F
          EB65F7CBED573CAE74F44DEB3BD1EFD37FFA6AC0D573D7F8D72E5D9F79BDEFC6
          EC1BB76E26DD1CB825BAF5F876F6ED17770AEE4CDC5D7A8F78AFFCBEDAFDEA07
          FA0FEA7FB4FEB165C06DE0F860C060CFC3590FEF0E09879EFE94FFD387E1D247
          CC47D52346238D8F9D1F1F1B0D1ABDF264CE93E1A7B2A713CFCA7E56FF79EB73
          ABE7DFFDE2FB4BCF58FCD8F00BF98BCFBFAE79A9F372EFABA9AF3AC723C71FBC
          CE793DF1A6FCADCEDB7DEFB8EFBADFC7BD1F9928FC40FE50F3D1FA63C7A7D04F
          F73EE77CFEFC2FF784F3FB25D29F3300000C684944415478DABD587B5C555516
          FECE7DC3E5DECBE5F2900BF27EA82199A2081ABED27C0F3356F6D329CB6CD2A6
          B1B2666CD0521A9F695A6A9699D5E894A5696556BED252E42182BC5404454004
          042E97C7BDBCEEE3CCDA070E2262CDAF3F66F1DBE03967ED6FAFBDF65ADF5A5B
          0E802427AFC079ABA60632A974193DAFE662638663DDDB9B6E8D4D18EDCDF33C
          EC763BB89F4EFDA21C1517DBC65EECAAFD080B8D8BC04D3A3F1D4EDE192BD3CB
          3364A9F603B55B6A6671130F005CE00CB47DD70E7BA915A9FF3E0B8E8071F4F8
          4F90CBE5200835C3C3A8912378B942818A9B37C1B5B5B5F11CC7810DB68800FE
          7C68027FABBA041F3F91C509C00D4B87C1FD0B5FA4269CEC044D3F771E2D2D2D
          B0D96C90C964A503232302753A1D542E2AFC723AE5A2B09B7FAE588980FEFDF9
          E8A841A8ABAB83B7B7379B0B87C3C12609BB13165EF4CC7C4C4C99B02963FCF9
          25AA799A458F2E18B7FDB3C987254C999B746EA2306B575812BFBD71B7EDECA7
          3715CA198A40EB567399E36207241249A74D4CB6BFBF03E11111686A6C8456A7
          73A58F467A7D554062BFD892570A0B99D20B11E1615B992D465F5F28C821A77E
          39CD71E312C66079F29B181D1FC7A7A6A72361F428880E3A71F267848785808B
          1B11CB7C2A3B71EAA48DB980898B8B0B9C4EA7E0C5D329A9CF70C557AFF1FE7E
          46C14026ECA3847E3ECFD88BC7636733A53DDCE77BBF20BFF8E0F2854BA89959
          527A6CCEE9E017BF9FEC7C67F69160CE822A9AD72E9C0993449D17BFF7E39235
          41895C5282CF207C94788E83AC73F3829F24CE8E6F6294CA3F1C7DB48ED3ADB3
          C80DFA01B6D2A5558242C6F94C088709991AD2D0F1303F550DCD6B8D20253025
          A6D0ED2751CE67E7A0A9A90985972F23342C4CD88C937668696A5AE0E9E5B593
          ED7AF8B007D0DEDE8EC2A2AB30994C7F6187C5F62B008D1F3316CB5626772293
          0F09C8252838E485290F3FF4561681B7B5B7212C34047A7777981B1A71BDB40C
          43A2A3840361AE4CCBC8BC2444135B79E9EB6F20E99525D8B2E3C30D6A179757
          351A37444684432A950ACAB402C0FEB20C23FDCACA4A188D46949695A3E47AE9
          040168C93F96CE1C1633EC5B7F5F236472697738B22D3020962C1D1D1DDD2062
          32329D4E975CE085D06D6E6A0AA7202B32183C5055557D887C31332A6C201EA9
          986DDF6CDB2C1B30340CC78EFF949E62481B392D2E12673FAA2A98163B756060
          80BF34EB422E6F696E960940B7AAABD08FACA97656E193BA5DD044BACC792572
          FA672BBE3EB0BF31A9E631C3D17EE1435A6445033C23705EDA847393B2659C92
          73F43C286E52E6D49ECFBEFDDB2A2B433D42A1D10560CF92B4011E6BFA5DF1AD
          6DE007B8782157D6819B6F980C6DE5EDF5E8259D31228A4CAD951AC798A52A69
          4DCD1F2B7D25EE1228A7E9A1185C0A2E28021E8D12DCD86D024B4426B905F920
          4AE913089CDF7848548029B112F7022A389887A6E6E63B2DA2114D238F3DB0EC
          5EBF7E03DC349AEE98AA379940C1289ED2DC2E5D253BACDE4082F8F9FB63F79E
          CFD0D8D0D017501D45902166E8109AC041ABD5E0E4CFA78F90CA621AC5DD407A
          BD07BE3AF8B530B907908EC6F70436FCA1F16315F905972840C3D0DC6C257D9D
          104B172F15A2CE64627A4D1C0BB09FCF9C85AD2BE0BA80FC7C7DFB55183CF428
          BF51410E6DC7980747E1D265E2ADB050E4E4E66378CC508150F2F32FC26436BB
          702386C560E396AD0210AD121B1418901E18D01FE5E5372095491911DF66A12E
          4662919F9B5F006FF25DBF7E3E48399B365F4891A1313118191F8F83FBF76B9E
          5FFC62537FF29796724DE7AE83AB8BAB90663DC158296069939D93C7D2C846C0
          CA6EA0E1B1B1D06874F31F9995B88B91257374036D93ADEEE3E3238088E5870D
          F1392DE31CD517BB941B1D172F4D5EB3F6E6B8B1093EB60E1B25A904168B054A
          A552585DA80034A19D024FDE451B8D54005841129398C856C372ED6A7C5C6CA8
          48112CA3D96A2203B0BF4C180B80E730F5F20C7CE5F705946ECA6E3224669073
          478E1E67A8A7351ACD839C846BADAB331D0A0D09997DD17911D935176CAF0C7E
          495E75EB164CA5A6FC2B234F0FBE525C8D84AAC925A3468F0829292DC7B5AB57
          67A9D5EA83DC916327B0267925961343969596E2E489E354AC8ADCE76D9F65DE
          B3E2FB44A4DB0E391B1CFCD893D196695E71EAF59F1EFAB2FEC39AC72185821D
          60D74037D08A95ABB042930C4DBD0AF785F9F383FA8561C7A307DD942394569F
          19AAA3097ABF4903FA0DC1B2857B1773571C5BEFCA7EB1D688E22195F253BC22
          502397E1EBE56738E573BAD79E738B5C5BD85104B93E10DFCECF0CE2CC7CD9DD
          403DF848696B3D7D9F827F30D873204E5DAF3B53F1557582EC49D5F23FAB83FE
          556E2F239F29B7D7BC5AF5574E7147F1416676D6ED068025E57885575D9BDD4C
          47EB856F0FDD5CDEFA61C36ADD362B38EF415E1247478BC22EB156CFAF04A7BA
          0D949573A1B399EAE62376FA81D3DE96F38E676DF98ED79BDE6F78976F76A20B
          080404028208C442E36C7A5A1F0C29004DEFAC3AB9ED2020DC0B48A15120252D
          F51E54FB3F02D52FAC454A761A7A0B877B485050100E7E7348C8B706B319D5D5
          D5080B0FEF6CF5BABA1A2191E9B9A1BE5ED8AABB5EEF42EFFD28573D496195D6
          CD6D8283B284D5478998A7C0359AC642A5B0AF75EF3288F538877FF89188B0B9
          9B6D7FCD20766034920C1E1EAB070E8884BBBB96D2F33675DDB118CDB13BECAC
          06A3B6D68446EA57086F0E7DDAD79D20A2B256ABC58F94BE6295EA09D2CB202F
          DEE9DC4CCDE1DC810323BBF981195A7CAD041515370502125B3E910E995E34F5
          2F7A221FF11B1B35D4EB175D2D3946EF16916A89408FEC03F10092D7AEEBAE00
          A2D0B760326A83B7B7D72CF202DC484FAE90E3FAF532A17577A705F47A778109
          3D3D3DC15A4DD190DE1BA39685484D0615196C30E8C13A1609D7C99A9959D974
          2A9604C12026CCC543A99ACC9E3B175DCDAD9A8093A8BD498AA0F2E3242F58AC
          565889F49B2D5684860441A7D5096EA79E58BC6C402E9383C891DD7084C1F730
          A8A3B34A09BA578A8A85B9D183A3D0626D41C1A5CB95E4A5C177183464E8503C
          3C6D3A1ACDF558BF6A15C22323835E7EF51FFB743AEDF0FBEF1F0C07C58B40DB
          5DC7C0841D97950C65EF5D5D5DBBEB449777857F8BC54614BB80C32A5A1B2EE4
          E6B167D6CB3E4FA3A3A7411C19E43171F2943F2914F27895D2C55FA7D30C8C19
          36D4AF673513BB48954A25C41B3346F400DB398B1FE122D4C30031C6FACC2A56
          E4280B33B32E9CA77546B1824637B8D62946A3DF61BA65716CB2B8FB9EC2762E
          7A47F490B88818A07D8952A6C4CE5B3B21AF526066C80C68DC3477E14B6903B9
          B9F93C1DA18F6010C5CC70DAD58FD4C17BC48D8811B8C5C9332300ABA58502B8
          14517425648B32C3E49C1CFFA9DC8BE2966B480E590E1B67131661DE61B1C1AE
          1801FDFD91746525827C14B84159AA493762C1F879D079EA842363C23C5970F1
          324CF5F516ABC51245AFCA84F69A0571BDA90E1F6CDB265BB97ACD30BBCD368A
          16365F2F2939B571DDDAD2A8E868E582858B1E96738A272B65958622634E508B
          BC51D3725EBA6B926D92536BD43DCB9C46EEDFB977FB9E6579830BDE485C189F
          1CAF1D00136C387632A73A7B63CE1381DA80B48953273F6DF4F39F4301EF4FA7
          515C5555B572F7271FA7526FE210F8AD974120834006099E2829BA866DFBDE81
          7F7220B41E2AA99C972F7EC010BEE93EAF60EC397BE2CC955DD75EE0B21D797C
          070FCD136E50CD564F33B6CAB744A93D43BCDC7C60D4FAE3BBA67CA4BE91B7CA
          99D9BE8E9372D67BD786AE98EA69D08E6DEFE1E5B5AF61937A3354F483763AB7
          0A3A0E35372D38587F7892210CEE6A1F14F1667CFAC1B1DDFC46CB3CD767DCA1
          7A5AA391D45937F8395B9FF3A5FE504B770C0F572F28D4EE48B9515E9BBFAAF8
          294771C70FBDEB7B9F06F5EE407A0A855E8C96B7670E911171BA762DE2A2436E
          5D4D65CABB794B381E5F6AFEEEA56CAC28DF90E833E26F130CF1385375142667
          2D02B581C8945B90975CF69233A3FD5DBA41FDA6319D06DD79B3EA0E7CA7D3F6
          58202FF9FC31EF09286D2BC18D8EEBF0D304A09EDAED13A9D7F7B76CAB9FA388
          71B1AB9778C39E994F016F7B5D1112F1A6C2EE303B640A17D706E9B36D1A1CA8
          7BCFE4B067B577F46C5AEECA608A9D73595970381DBD2E563D8497C8237D3C86
          158E35DC8FF2D612D8244E341133E79D6CDAD7FE9679B6442F11DA0AD5E30628
          4797836FA4821A1E05DED601E23CE8CC12B4D225860C021984BE0C6234C2DA32
          F1BF3D040FF56910A314B91A308EA3C0E7289878B944C5591D196D8E86B5F5C2
          0D5050FB1D0631F2646D5D6B6B6BDF47F61B0675312EF10F019241F8BD06B1AE
          2E272F8FEAA1E5D763E8FF619024DF89BCE282BBEECF7D48F47F01908A585E7A
          D041570000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'PngImage16'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000240000002408060000019607A8
          0E000000097048597300002E2300002E230178A53F7600000A4D694343505068
          6F746F73686F70204943432070726F66696C65000078DA9D53775893F7163EDF
          F7650F5642D8F0B1976C81002223AC08C81059A21092006184101240C585880A
          561415119C4855C482D50A489D88E2A028B867418A885A8B555C38EE1FDCA7B5
          7D7AEFEDEDFBD7FBBCE79CE7FCCE79CF0F8011122691E6A26A003952853C3AD8
          1F8F4F48C4C9BD80021548E0042010E6CBC26705C50000F00379787E74B03FFC
          01AF6F00020070D52E2412C7E1FF83BA50265700209100E02212E70B01905200
          C82E54C81400C81800B053B3640A009400006C797C422200AA0D00ECF4493E05
          00D8A993DC1700D8A21CA908008D0100992847240240BB00605581522C02C0C2
          00A0AC40222E04C0AE018059B632470280BD0500768E58900F4060008099422C
          CC0020380200431E13CD03204C03A030D2BFE0A95F7085B8480100C0CB95CD97
          4BD23314B895D01A77F2F0E0E221E2C26CB142611729106609E4229C979B2313
          48E7034CCE0C00001AF9D1C1FE383F90E7E6E4E1E666E76CEFF4C5A2FE6BF06F
          223E21F1DFFEBC8C020400104ECFEFDA5FE5E5D60370C701B075BF6BA95B00DA
          560068DFF95D33DB09A05A0AD07AF98B7938FC401E9EA150C83C1D1C0A0B0BED
          2562A1BD30E38B3EFF33E16FE08B7EF6FC401EFEDB7AF000719A4099ADC0A383
          FD71616E76AE528EE7CB0442316EF7E723FEC7857FFD8E29D1E234B15C2C158A
          F15889B850224DC779B952914421C995E212E97F32F11F96FD0993770D00AC86
          4FC04EB607B5CB6CC07EEE01028B0E58D27600407EF32D8C1A0B910010673432
          79F7000093BFF98F402B0100CD97A4E30000BCE8185CA894174CC608000044A0
          812AB041070CC114ACC00E9CC11DBCC01702610644400C24C03C104206E4801C
          0AA11896411954C03AD804B5B0031AA0119AE110B4C131380DE7E0125C81EB70
          170660189EC218BC86090441C8081361213A8811628ED822CE0817998E042261
          48349280A420E988145122C5C872A402A9426A915D4823F22D7214398D5C40FA
          90DBC820328AFC8ABC47319481B25103D4027540B9A81F1A8AC6A073D174340F
          5D8096A26BD11AB41E3D80B6A2A7D14BE87574007D8A8E6380D1310E668CD961
          5C8C87456089581A26C71663E55835568F35631D583776151BC09E61EF082402
          8B8013EC085E8410C26C82909047584C5843A825EC23B412BA085709838431C2
          272293A84FB4257A12F9C478623AB1905846AC26EE211E219E255E270E135F93
          48240EC992E44E0A21259032490B496B48DB482DA453A43ED210699C4C26EB90
          6DC9DEE408B280AC209791B7900F904F92FBC9C3E4B7143AC588E24C09A22452
          A494124A35653FE504A59F324299A0AA51CDA99ED408AA883A9F5A496DA07650
          2F5387A91334759A25CD9B1643CBA42DA3D5D09A696769F7682FE974BA09DD83
          1E4597D097D26BE807E9E7E983F4770C0D860D83C7486228196B197B19A718B7
          192F994CA605D39799C85430D7321B9967980F986F55582AF62A7C1591CA1295
          3A9556957E95E7AA545573553FD579AA0B54AB550FAB5E567DA64655B350E3A9
          09D416ABD5A91D55BBA936AECE5277528F50CF515FA3BE5FFD82FA630DB28685
          46A08648A35463B7C6198D2116C63265F15842D6725603EB2C6B984D625BB2F9
          EC4C7605FB1B762F7B4C534373AA66AC6691669DE671CD010EC6B1E0F039D99C
          4ACE21CE0DCE7B2D032D3F2DB1D66AAD66AD7EAD37DA7ADABEDA62ED72ED16ED
          EBDAEF75709D409D2C9DF53A6D3AF77509BA36BA51BA85BADB75CFEA3ED363EB
          79E909F5CAF50EE9DDD147F56DF4A3F517EAEFD6EFD11F373034083690196C31
          3863F0CC9063E86B9869B8D1F084E1A811CB68BA91C468A3D149A327B826EE87
          67E33578173E66AC6F1C62AC34DE65DC6B3C61626932DBA4C4A4C5E4BE29CD94
          6B9A66BAD1B4D374CCCCC82CDCACD8ACC9EC8E39D59C6B9E61BED9BCDBFC8D85
          A5459CC54A8B368BC796DA967CCB05964D96F7AC98563E567956F556D7AC49D6
          5CEB2CEB6DD6576C501B579B0C9B3A9BCBB6A8AD9BADC4769B6DDF14E2148F29
          D229F5536EDA31ECFCEC0AEC9AEC06ED39F661F625F66DF6CF1DCC1C121DD63B
          743B7C727475CC766C70BCEBA4E134C3A9C4A9C3E957671B67A1739DF33517A6
          4B90CB1297769717536DA78AA76E9F7ACB95E51AEEBAD2B5D3F5A39BBB9BDCAD
          D96DD4DDCC3DC57DABFB4D2E9B1BC95DC33DEF41F4F0F758E271CCE39DA79BA7
          C2F390E72F5E765E595EFBBD1E4FB39C269ED6306DC8DBC45BE0BDCB7B603A3E
          3D65FACEE9033EC63E029F7A9F87BEA6BE22DF3DBE237ED67E997E07FC9EFB3B
          FACBFD8FF8BFE179F216F14E056001C101E501BD811A81B3036B031F049904A5
          0735058D05BB062F0C3E15420C090D591F72936FC017F21BF96333DC672C9AD1
          15CA089D155A1BFA30CC264C1ED6118E86CF08DF107E6FA6F94CE9CCB60888E0
          476C88B81F69199917F97D14292A32AA2EEA51B453747174F72CD6ACE459FB67
          BD8EF18FA98CB93BDB6AB6727667AC6A6C526C63EC9BB880B8AAB8817887F845
          F1971274132409ED89E4C4D8C43D89E37302E76C9A339CE49A54967463AEE5DC
          A2B917E6E9CECB9E773C593559907C3885981297B23FE5832042502F184FE5A7
          6E4D1D13F2849B854F45BEA28DA251B1B7B84A3C92E69D5695F638DD3B7D43FA
          68864F4675C633094F522B79911992B923F34D5644D6DEACCFD971D92D39949C
          949CA3520D6996B42BD730B728B74F662B2B930DE479E66DCA1B9387CAF7E423
          F973F3DB156C854CD1A3B452AE500E164C2FA82B785B185B78B848BD485AD433
          DF66FEEAF9230B82167CBD90B050B8B0B3D8B87859F1E022BF45BB16238B5317
          772E315D52BA647869F0D27DCB68CBB296FD50E2585255F26A79DCF28E5283D2
          A5A5432B82573495A994C9CB6EAEF45AB9631561956455EF6A97D55B567F2A17
          955FAC70ACA8AEF8B046B8E6E2574E5FD57CF5796DDADADE4AB7CAEDEB48EBA4
          EB6EACF759BFAF4ABD6A41D5D086F00DAD1BF18DE51B5F6D4ADE74A17A6AF58E
          CDB4CDCACD03356135ED5BCCB6ACDBF2A136A3F67A9D7F5DCB56FDADABB7BED9
          26DAD6BFDD777BF30E831D153BDEEF94ECBCB52B78576BBD457DF56ED2EE82DD
          8F1A621BBABFE67EDDB847774FC59E8F7BA57B07F645EFEB6A746F6CDCAFBFBF
          B2096D52368D1E483A70E59B806FDA9BED9A77B5705A2A0EC241E5C127DFA67C
          7BE350E8A1CEC3DCC3CDDF997FB7F508EB48792BD23ABF75AC2DA36DA03DA1BD
          EFE88CA39D1D5E1D47BEB7FF7EEF31E36375C7358F579EA09D283DF1F9E48293
          E3A764A79E9D4E3F3DD499DC79F74CFC996B5D515DBD6743CF9E3F1774EE4CB7
          5FF7C9F3DEE78F5DF0BC70F422F762DB25B74BAD3DAE3D477E70FDE148AF5B6F
          EB65F7CBED573CAE74F44DEB3BD1EFD37FFA6AC0D573D7F8D72E5D9F79BDEFC6
          EC1BB76E26DD1CB825BAF5F876F6ED17770AEE4CDC5D7A8F78AFFCBEDAFDEA07
          FA0FEA7FB4FEB165C06DE0F860C060CFC3590FEF0E09879EFE94FFD387E1D247
          CC47D52346238D8F9D1F1F1B0D1ABDF264CE93E1A7B2A713CFCA7E56FF79EB73
          ABE7DFFDE2FB4BCF58FCD8F00BF98BCFBFAE79A9F372EFABA9AF3AC723C71FBC
          CE793DF1A6FCADCEDB7DEFB8EFBADFC7BD1F9928FC40FE50F3D1FA63C7A7D04F
          F73EE77CFEFC2FF784F3FB25D29F3300000AA24944415478DABD58097494D515
          BEFF2C994C92C96481844C0209D9301A0266850443542C52ACA5C553ACB43D85
          6A5B3D16857A50E3167A0041ADB46211A4EA3922B5150F522AE2C21AF6358404
          0810B21148844C96C94C32FBF4BBEFFFFF308645B4E7F49EF39DF9FFF7BF77DF
          BDF7DDED8D44449A63C76BFD5F5FBA443AADF639BC2F928AF20B68C99F5FFFBA
          AC74425C201020AFD74BD2D6ED3B0D25E38B9C7ABD86DC6E1FE9F57A924ACBFE
          8615F405309914520755CA076A2431EDABAD6219784E647E5432AE30A00F09A1
          D60B1748723A9D014992A8ADBD97E2E3C2059F17B0EA38500BAC1CCCF813C174
          FFC1C3D4D7D7471E8F87743A5D53D6A8CC64B3D94CA1C650DA59B9FB84D0E6D9
          972A68C4F0E1819CEC5BA9A3A383E2E2E2040B9FCFC78B8476A4D56AA8BCBC7A
          DED8EC63CB6AEB6E5F83EF435DF6777F0813F983155B0DE8808D2C83224B0E50
          01FC5252A55BF1D62ACAC8CC245B4F0F459ACD611A8DC682E17A205C4CE22D4F
          D7D5F1A4C73333D297B32C9684040A8141B6EFAC94A43B4B27D2F30BFE44138A
          C707F6EEDF4FA5134A880DC4D8B26D0765A4A79234BEB0886DAADBB27D9B874D
          C064341AC9EFF7B39DA972F7DEDF4867EBCF0592122D0419C4E0C2C5DBA8FC99
          32A13A6F8B496BA47F7CF84F7A7DD9A5B05FFFCAD3F7CE7B3A32997487FCDE86
          073CCECA663035002E36811E0FAF00A1C01F807781C7940936C0C39342F03002
          B80B783BE8CCFE0554038B071F66300D05BAA0A6570A1E3D7CF418D96C36AA3B
          758AD2D2D385327E2863B7D91E1E3274E86AD6BA20EF7672B95C5477A69EAC56
          EB6FB1EC1DC02F18DD35B18C9EAB58203B296C0846C69491A98F4F993CE99523
          60EE7439293D2D95A2A3A2A8ABBB871A9B9A696C4EB63810B6DABE03874E0A6F
          E29D9F7EE1452AFFE33C7A63D5DBAF861B8D4F994C11342A33034EA41593B103
          11FF728461FEC58B17C962B15053730B353436DD2D18CD9BFFF4FD79F979FF4E
          4AB0904EAF1D7047568119F9217848883CCE1450185E31495540B86EAFCD9601
          273B131B1B436D6DED1B618BFB333352E983B5077B9C4EC9EC76EB31E7323676
          A5AE5EF5635E78D89260B93D2579B8F6485575C0DEDBAB534F44033C027CC64E
          CC47A5C4E08F80B10A8E00D380DB0644910CE4EA5DC90F0371C246FF05F03325
          5E3E579CA55759C221784979FE18D80B58010E9378E0C9C13E920C3C033C4AD7
          A7254034700B9B0BA8045EBC91B37D1B71FA3AACD52226B73E2254CA51EC21A2
          7BE9D25729C2641AF0A94EAB95E08C2265E224672A7339360E07731DF0ECC4A4
          247A7FCD5AEAE9EEBE16A30EE8109B9F3B96CD4A919126DAB6A392ED3807383B
          C0283A3A863E5E2FE7A2204666601398154CBAAB2CA4A6F6241C349D7A7B1D98
          6F16BE74E2641D7558AD3CCF26B197EED8B5873C6E7730A3C4848461ADB131D1
          D472BE959C4E174DBCA3844E9E42DE4A4FA363D53554909F2BB24D4DCD09B276
          7519A5C2BC7C7AED8DE5821176294A491EB13F79C4706A69394F5A9D9613B1D8
          8017F1A64CECE1D535B51407DB0D1B164FBBF7EC9B2D4224373F9FC61517D3FA
          75EB4C8FCD79C2361CF68A44AC99A3CC14660C136116CC8C4B01D798A3C78E73
          1879C0D830C0A8A0A80869CD3CFB81E9D3DEE164C986EE869ABC7B7C7CBC60C2
          636C1B86FABEEFC041D417AF569A30BE58BB60F1CB17EE2C2B8DF7B83DA264D8
          ED7632180C62777EF77A03F8BDC22498780E92AD8983B6BE787C519A9A2238EA
          7937BFDF871DB574BEB58BD67C50450B5EFA01F5F7BB859AAA646A327423AAA5
          CFBFF88AB9569A4CA63B248DD4DFD161DD98969A3A0326F5CE9DB7DD336952A6
          B1BDDD86C98EB64977672724A7E8E8FCF90B67C715E6673434B5D0B9FAFAE9E1
          E1E1EBA5CFBFDC428B1754D063739E9356BCD5303A2525BC71CFF60AFBFCE7FF
          1E58BBF6742A365D0EC410E96BDD8E0F1E0904FA354A8C7145F0291888FE314A
          3473402EE368013E026A94D492075401BB800DAA7DDC8E7550D141C18C1E5052
          884F89A3CBC0EF800825553C0BCC52A4E0FAB714D817CC54659404C02EC4AA14
          905C1956051D4EAC223127BA32929B0EF6D414E009A05765C4D5AE59490DBC53
          09C959D2758DF4F190223D33FF2BC989EEAA16E945603370E83A39887BAB8540
          1370111842728AEEFB3E898D257952D9AC1BA8DC5DF9047DDF0C99A030E9DFBB
          673E793D0E92AE3733252585D66FD828E2ADBBAB8BDADBDB293D234378B4DAD5
          307149EFEEEC141111151D6DC47822627508262C8C8C88B8DB8728E1FAA851E3
          94E81C96DD07D45D6BDFAB048A8B8BA74F3FDB8C4428172291046E2010A772A0
          3C36266651D62DA3282A2A1209E34AEAFAC66658E3F579B906D3E5CB56EA41BF
          027EEC04ECFBBE6F08141919499B11BE687CAF623248A0A101BF7F199AC39959
          59A306BA3616F4ECB9066A6DBD201290DAF2092BE299E7E5A07F894637AC7E63
          5C42AF7FA6BEE14B8C71256D10E9913F200FD08297970C540095F06D24847A35
          2E6EE874588122304F1FA2A7C6C666D1BA476183E8E8289109870C1942DC6A0E
          CE7CAA62E83C901D75140A816363A3893B168DA411DF0E1D398A53B1970A8198
          D8C4B9A8263366CE24A5B90D07E372B437E599283F7E58C1EE70900349BFD7EE
          A0B4D41432479A85D9D113AB970DD2EB7057D1487CC311080409E496AB94987B
          FACC59B136677436F539FAA8F6E4A98BB0D2E86F0834363797264FBD8F7ABA3A
          69E9C28594316A54CADCA7E67F643647168C19331A79D72B9A37F51898F8B81C
          1094C7C3C2C2041FD5BF547F538B8D4A5EC1872B9A93AAAA8FF33B672C4E3EEE
          608124081473CFBD537E1A12A22F0E351893CC6653567E5E6E627035732B471A
          1A1A2AFC8D85512DC09AB3FF888B509000AA8F5D33AA308FA3F0D091AAC3D8A7
          840B1A6E70FD532C96C44F71CB9278B1AA7D30C955523BF0AE3A2657CCAEAE7E
          DAB5BB9134782E29E6A30C159176B3A48502D5D535011C61BC10083E5300AD36
          A3838F195F982F728B1F0AC11544A3C02DCDE8DB6E25B7B83B6AE1C06E3A70F0
          0C9AF51E2A2CCC82B07E5ABBB68A0CA1061A37CE8CA3D5C07F4C141363A0D4D4
          58044208D5A0871A993C02C1631C10962D597BE214593B3BED0EBB3D1B43CDA2
          4F6727EEB476D0CA37DFD4552C5A9CE7F5784A6091AEC68686EDAF2D79B9293B
          27C7F0F0EF1F9D8CB159B868EB1A1A6C5F6EF8E462ADC3E19B94961E31CD68D4
          A7F6F57935369BA7A5A3C359E9F5FA9DE9E96123C78C89494A4E36FA8CA1DA4F
          572C5FFE262CDC7BEFD4A9B32D89490FC1E193701A67DBDADA2ADE7FEFDDBD2E
          A7D327F2DB0D523E5FDDB828F14D6C3E703AE81BDFFBD2492EA169249700B392
          D7B814B40375921476C4DDFF9F733E77ADCB10318BBCAE7D88D6563EA4EB1E5F
          B0403CEB27C05F482EE4DC25704B6F5184E2549F056C023E04EE518439095C00
          9E22B91CBF018C24B9FBE032B1431192295151943B12FBB70944418B9E5598BA
          1421B807E070AA20B981184CBCF98324A77F16B631E8DB04E59D797155E6B6E9
          3D925B24FEC697A2BE6B09C4372AEE54E6026E85F183CA38DFAA3A48BE456D01
          56DE6400719F51AA5893AF78B10A58C04C929B1E7E5EA20A35D8425AC5422D8A
          85E628422C527C6818D07A93C2A8544C72EBF67392EFA6AC2CB770DC499D27F9
          2F18C78D8E2C98F85EC4D7C8DAEF28844AEC9333142B342B563002E12407001F
          3557F3E749F1A9FFE5EAF95D8903631EC93EC47F526D52AC853CA6A35D3BE720
          3FB9FEAF025D455A5D28EDA99C8B7264538772FE0BE696B93D8FA2C71F000000
          0049454E44AE426082}
      end>
    Left = 759
    Top = 351
  end
  object ImageList1: TImageList
    Height = 32
    Width = 32
    Left = 726
    Top = 392
    Bitmap = {
      494C010111001500040020002000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      000000000000360000002800000080000000A000000001002000000000000040
      0100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D1D1D1000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F5ECEC00E9D8D800FBF8F8000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F6EFEF00C79A9900B3777500DDC2C200FDFB
      FA00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E9D8D800F7F1F100F6EFEF00C99D9C00B67C7B00DFC5C400FDFC
      FC00FCFAFA000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F2E8E800CBA1A000C08E8D00E9D7D70000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E1CAC900C6999800AB676500BF8C8B00B87F7E00AF6E6D00C3929100AF6F
      6E00C99E9D00FBF8F70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FEFD
      FD0000000000F1E6E600C4949300BA838100EDDFDE00FDFCFC00F3EAEA000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E7D4D300DBBFBE00B67C7B00B57A7900B87F7E00AA656400CDA4
      A300FAF7F7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FDFBFA00D3B0
      AF00E0C7C600F0E4E400CAA09F00BD888700E2CBCA00D5B3B200C99E9D00DDC2
      C200000000000000000000000000000000000000000000000000000000000000
      000000000000ECDDDC00DABCBB00B9807F00B67B7A00B77D7B00AE6D6B00CCA4
      A300FAF7F7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FDFCFC00DDC2
      C200B1727100D6B5B400B1737100B0706E00B9807F00C18F8E00B87E7D00D4B1
      B000000000000000000000000000000000000000000000000000000000000000
      0000E1CAC900C89B9A00AB686600C08E8D00B8807E00B0717000BE8A8900AE6E
      6C00C99E9D00FBF8F70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFEFE00F3EA
      EA00CFA9A800B5797800C18F8E00B3767400AB686600D1ACAB00D4B2B100FAF5
      F50000000000000000000000000000000000F6EFEE00F7F1F100000000000000
      0000DFC5C500B87E7D00C4959400D0AAA900D7B6B600D8B8B700CBA1A000CDA4
      A300C3939200FAF5F50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C1908F00B4777600B77D7B00A65E5C00BD898700C2919000F7F1F1000000
      0000000000000000000000000000F0E3E300CBA1A000CCA4A300F1E6E6000000
      000000000000E6D2D200F4EBEB00F7F0F000C89C9B00B5797800DDC2C100FCF9
      F900FBF8F7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FDFBFB00DCC0
      BF00B8807E00C4949300BA828100B2747300B77D7B00C08E8D00BF8C8B00DEC4
      C300FDFCFC00FAF6F60000000000EFE3E200BC868400BD888700F0E5E5000000
      0000FDFBFB000000000000000000F7F1F100C6989700B1737100DEC3C200FDFB
      FB00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FEFDFD00DCC0
      BF00C1908F00DBBEBD00CAA09F00BF8C8B00B77D7B00C79B9A00B67C7B00D5B4
      B300DEC3C200CFA9A800E1C8C800ECDDDC00BC868400BF8B8A00ECDDDD00DFC5
      C400DEC3C200F8F3F3000000000000000000F4EBEB00E7D4D400FAF6F6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F3E9E800BE8A8900B57A7900EFE2E10000000000000000000000
      0000EDDEDE00D7B6B600C89C9B00BE898800B87E7D00B77D7C00BE898800C89B
      9A00EFE0DF00FAFAFA0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FBF7F700ECDDDC00CFA8A700FAF7F70000000000FEFEFE00FEFE
      FE0000000000F1E6E500BB848300B4777600AB676500AC6A6800B2747300C28B
      8A0000000000FDFDFD00FDFDFD0000000000FEFEFE00FEFEFE00FAFAFA00F9F9
      FA00FEFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FCFC
      FC00E1E1E000E7E6E600F3F2F20000000000FAFAFA00EAEAE900D2D0CF00D2D3
      D100E4D2D100C79C9C00B07F7E00A8747200A3696700AA6F6D00BD8B8A00BF8F
      8E00BCA5A400C5C0BE00DCDBDB00EFEFEF00F8F8F800D5D4D400C7C6C400C2C0
      BF00E8E7E700FDFDFD0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F4F4F400CDCB
      CB00CAC8C700D4D3D100CDCCCA00D0CFCE00D0CFCE00C5C3C100DAD8D700E7E8
      E700B69492009A504E00B2858300BC8E8C00B77F7D00AE767400AE848300AC7E
      7C00CFB3B200EAEAEA00D3D3D100C7C6C500C2C1BF00D4D2D100ECECEC00F0F0
      F000C1BFBD00E4E3E300FEFEFE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F1F0F000C4C3C100C6C4
      C200F9F9F900F9F8F700F9F9F900EFEFEF00D3D2D100FDFDFE00F8F8F800FBFC
      FC00CFBAB900C0A09F00E9D6D500E7D8D700B67D7C00BD858300CCBDBB00CEB9
      B800E2CECE00F5F0F000FBFBFC00D3D1CF00F1F0F000FAFBFB00F8F8F800F8F8
      F800D3D1D000C4C2C000F6F6F600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FDFDFD00CAC8C600DDDCDB00F8F8
      F700F7F7F700F7F7F700F7F7F700F8F8F800FBFBFB00F9F9F900F9F9F900F9F9
      F900F8F8F800F9F8F800FAFDFD00E8DCDB00B67E7C00B7807E00ECE1E000FDFF
      FF00F7F6F600F7F7F700F7F7F700FAFAFA00F8F8F800F7F7F700F7F7F700F7F7
      F700FCFCFC00C7C5C300D5D4D300FEFEFE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000EAEAEA00D3D1CF00FDFD
      FD00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800FAFAFA00FDFDFD00FDFD
      FD00FBFBFB00FAFAFA00FBFDFD00F2ECEC00D1B0AF00D2B3B100F2EDEC00FAFB
      FB00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800FCFCFB00CFCDCC00FAFAFA000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00E6E5E500C7C5
      C300FFFFFE00F9F7F800FAF9F900FCFCFC00FCFCFC00F9F9F900F0F0F000FDFD
      FD00F6F6F600F9F9F900F9F9F900FBFCFC00FAF7F700FAF8F800FDFDFD00FBFB
      FB00FAFAFA00FAFAFA00F9F9F900F9F9F900F9F9F900F9F9F900F9F9F900F9F9
      F900F9F9F900FBFBFB00C8C7C500FCFCFC000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FCFCFC00E0DFDF00D2D0CE0000000000FAFAFA00FAFAFA00FCFC
      FC00F5F5F500EBEBEB00E8E8E800E8E8E800F5F5F50000000000FEFEFE00FDFD
      FD00FEFEFE00FEFEFE00FDFDFD00FCFCFC00FCFCFC00FBFBFB00FAFAFA00FBFB
      FB0000000000C5C4C200E7E6E600FFFEFE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E9E9E900D0CECD00D2D0CF00FFFFFE00FBFBFB00FEFE
      FE00FCFCFC00FCFCFC00F9F9F900EEEEEE00F1F1F100FBFBFB00FDFDFD00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FDFDFD00FDFDFD00FDFDFD00F9F9F900FBFC
      FC00C5C3C100D9D8D700FEFDFD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F6F6F600DDDCDA00BDBBB900CAC8C700D9D7D600D6D5
      D400FBFBFB00F4F4F300FEFEFE00FEFDFD00FDFDFD00FEFEFE00FEFEFD00FEFE
      FE00FCFCFC00FDFDFD00FEFEFE0000000000F4F4F400E5E5E500F9F9F9000000
      0000E1E0DF00C5C3C100EFEEEE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FCFCFC00DEDDDC00C9C7C500ECEBEB00E9E8E900DEDDDD00D4D3
      D200E9E9E800F8F7F700EAE9E800EEEEED00F3F3F200F2F2F100F7F6F600F8F8
      F700FEFEFF00FEFEFE00FEFEFE0000000000F9F9F900F8F8F800FDFDFD00D8D7
      D600F6F6F500ECEBEB00C9C7C600FBFAFA000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F1F1F100C8C6C500DEDDDC00FAF9F900FBFBFB00F7F7
      F800C2C1BF00E1E1E00000000000FEFEFE00FDFDFD00FEFEFE00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE0000000000FBFBFB00E2E2E100CFCECC00BFBD
      BB00FAFAFA00FBFBFA00E1E1E000E8E7E6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F7F7F600D5D4D200D6D5D300E8E7E600F3F2
      F200D9D7D600BEBCBA00CDCBCA00DDDCDB00D1D0CF00E5E4E30000000000FEFE
      FE00FEFEFE00FEFEFE00FEFEFE0000000000CECDCB00D2D0CE00D9D7D600EAEA
      E900FEFEFE0000000000CDCCCA00F0F0EF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FBFBFB00F8F8F800E0DE
      DE0000000000E7E7E600CFCDCC00CBCAC800C7C6C400C4C2C000E9E9E8000000
      0000D7D6D500EAE9E800FAFAFA00CBC9C700CDCBCA00F7F7F70000000000FDFD
      FD00FCFCFC00D2D0D000D0CFCD00FDFDFD000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FAF9
      F900D4D2D200FBFBFB0000000000FCFCFC00FBFBFB00D9D8D600BEBCBA00C5C3
      C100C2C0BE00C2C0BE00C0BEBC00C4C2C000F0F0EE0000000000FDFDFD00FCFC
      FC00E5E5E500D3D2D100F7F6F600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DDDCDB00C9C7C600F0EFEF00FEFFFF00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE0000000000FBFCFB00E3E3E200D0CE
      CD00E9E9E800FEFEFE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E0DFDF00C6C4C200C5C3C100C1BF
      BC00F1F1F00000000000F2F1F100F8F8F80000000000D4D2D000D3D1D000E6E6
      E500FFFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00F6F6F600F1F0
      F000CAC8C700C8C6C400C1BFBD00C2C0BF00C1BFBE00CAC8C600F5F5F5000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FDFDFD00D1D1D100000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E9E8E700E1E0DF00F4F4F300F6F6F600F2F2F200FCFCFC00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E7F8E600A3E5A400A5E6
      A500000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D1D1D1000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E0F4E80045C8530035C55D0043CC
      68007ADA7B00FDFDFD0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000EBF9EB004FCA570078E2A400A2E6C90044CD
      7A0067DE9300A0DEA800F0F9F000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F5F5F5009B9B9C0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DBF5
      DA00F0FBF0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000EEFAEE004EC9540070DE9E00ACE9D20048CF
      7D006EE19B006AD57700BBDABA00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A3E4A40032C35C0093E1
      BC003FCB760051D4810055CE5400F6F6F6000000000000000000000000000000
      0000000000000000000000000000000000000000000070CF750045CD6F0056D6
      88007CE8A6008BEFAE005DCC5A00EAEAEA000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FCFCFC00DEDDDD00D5D4D300F2F2
      F2000000000000000000000000000000000000000000ECECEC00A4A2A000AEAD
      AB00AAA8A600A4A2A000E8E7E700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F2FBF5009BE298004BCB490051CD53005ED75C00AED4AE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000077D878003BC76D00C9F1
      EA0044CD7A0056D6880062DB830085D18600F8F8F80000000000000000000000
      0000D3F2D100B8EBB600CFF1CD00F0FBF00000000000F2FBF1005ACD5C005BD8
      8C0081EAA90094F3B8005CCE5B00D0D7D0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E2E2E100A5A3A200AAA8A7009A989600ADAC
      AA0000000000000000000000000000000000E9E8E800A4A2A0009D9B9900D7D6
      D500D1D0CF00A2A09E00AAA8A600D6D5D4000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D9F3E20038C15B0067D49B0045CB7D0043CD780052DB6A0083BB
      7E00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C3EEC20045C761006AD5
      9B0048CF7D005BD88C006EE19B0053CC4F00E4E5E40000000000000000000000
      000043C65A003AC75A004CCD63005CD26000BCEBBD0000000000DAF5DA0064D1
      6F0086EDAD0099F6BC006AD66F00B5C7B5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E7E7E600A4A2A0009B999700BDBCBA00C8C7C600A5A3
      A100EFEFEF000000000000000000E7E6E600A09E9C00ACAAA800E6E5E5000000
      000000000000EAEAEA00A6A4A200A5A3A100C1C0BF00FDFDFD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F1FBF1007AD981005AD08700BFEEE30049CC7F0046CF7C005EDB8E0064E0
      7C0000000000000000000000000000000000FBFDFB00F1FBF000E9F9E800F7FD
      F700000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000079D8770034C3
      65004DD2810060DB900073E49F006AD47500B7D5B600FDFDFD0000000000E0F6
      DF0086E4B0007ADAA80044CD7A0056D6880063D6770089DC870000000000C2E8
      C1008AEFB0009DF8BF0085E9950093C19200F9F9F90000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E9E9E800B4B3B100ECECEC000000000000000000F0F0
      EF00AEACAA00E6E5E500D1D1D000A9A7A500A19F9D00EAE9E900000000000000
      00000000000000000000F6F6F600B5B4B2009B999700DFDEDE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FDFEFD00BEECBE0047C863008ADEB90068D6990047D07C0065DD970068E1
      8500FCFCFC0000000000000000000000000093D6A30048CD490051CD5B0051CF
      5200F9FDF900FAFBFA0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000005FD1
      5E0056D6880069DF97007CE8A6007AE4920091CA8F00F6F6F60000000000C5EE
      C300A0EEC60080DCAD0048CF7D005BD88C006DE1990056CE5300F8F8F8000000
      00007DE18D00A6FCC6009AF6B20072C67200EEEDEE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00009B999700AAA8A7009A989600A8A6A500EBEBEA0000000000FEFEFE00D7D7
      D600DFDEDE000000000000000000FDFDFD00CCCBCA00F4F3F300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EDFAED006ED4780030C3630040CC780053D5860069E0990071E4
      9300E1E5E0000000000000000000A5E5A20040C7610065D49C0055D0890046D0
      7E0097D79600F1F3F10000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FEFE
      FE0059D783006EE19B0081EAA9008AEEA90070CB6F00F3F3F30000000000F3FC
      F30041CA78006AD79B004DD2810060DB900073E49F0066D67000C9E1C8000000
      0000AAE6AA0090ECA000A8FEC60059CB5500E2E2E30000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F9F9F900F2F2F1000000
      0000E2E2E100B7B6B400C4C3C200F5F5F50000000000FAFAFA00B7B5B400A6A4
      A200B4B2B100B8B7B600F8F8F800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000DAF5D90048CB520047CF82005CD98D0071E39F0080EC
      A500BCCCBC0000000000FAFEFA008ADC8E0069D88900A3EBCC005CD28F0047D0
      7C005AE36600AABCA80000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00005DD15E0073E49F0086EDAD0098F6BB0053CC4F00ECECEC00000000000000
      00005BCB700044CD7A0056D6880069DF97007CE8A6007CE7950093D49100FDFD
      FD000000000092E190009AF3B1004ECC4900D2D2D20000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F6F6F600BEBDBC00B4B2B1009A989600B4B3
      B10000000000000000000000000000000000F8F8F800AFADAC009A989600BEBC
      BB00B5B3B2009E9C9A00AFADAB00EEEEED000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D8F4D7004FCF580061DB960075E4A1008AEF
      B0009BB99A000000000000000000AAE7A60040C95D0072D8A80068D799004CD2
      80006BE3850085C08600E7E8E700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EBF9EA0064D468008AEFB0009DF8BF005DCF5C00D5DBD500FCFCFC000000
      0000D8EEDA0050CD5A005BD88C006EE19B0081EAA90091F2B4005DCE5900F6F6
      F600000000000000000061D25C006CD76D00B9C6B80000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F1F1F100A7A5A3009A989600C2C1C000ABAAA800A3A2
      A000FAFAFA000000000000000000F7F7F700ADABAA00B0AEAD00CCCBCA000000
      000000000000D0CFCE00A09E9C00A3A19F00DDDCDC0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C9E9C80058D665007CE9AB0093F4
      BB0084B67F000000000000000000F6FDF6008EDE920039C5630043CE7C0058D7
      8A007DECA2006CD37300C6CDC600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000CBF0CB0081E48B0084E893009FCA9D00F7F7F7000000
      000000000000000000008ADA8B006FDF8E008AEFB0009DF8BF006ED57200CEE2
      CD0000000000ABE7AA005CD05A0051CD4D0075D57600B0E1AE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FEFEFE00F4F4F3000000000000000000000000000000
      00009C9A9800A7A5A3009B999700A6A5A300D5D4D3000000000000000000F2F2
      F100F7F7F7000000000000000000F1F1F100B0AEAD00EAE9E900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFEFD00B5ECB7007DE6
      8E0081CF8300DBE2DB00000000000000000000000000CAF4CA0066D6790063DB
      900096F5BF0069E772009AB09900F6F6F6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000A4E5A20090EB9F0086CE8500F5F5F6000000
      00000000000000000000000000006ED56D008DEFAD00A6FCC6007CE38700B7D8
      B600BCECBC003AC358004ECD830034C56E0041CB6F005DD074009BD89D000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C7C6C500A6A4A300A7A6A400E1E1E0000000000000000000D2D1D000ABA9
      A800ADABAA00D5D4D30000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F2F4F200AAF2
      AD0084DE8D00C2D1C10000000000FEFEFE00FEFEFE0000000000B0CEAF0067E3
      7B0099F7C00081EC920088BA8700E6E7E60000000000FEFEFE00FAFAFA00F9F9
      FA00FEFEFE000000000000000000000000000000000000000000000000000000
      0000EFEFEF006565670000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000B0E9B00068D16400F7F7F7000000
      00000000000000000000000000000000000050CD4A00ABFFCA0091F1A6008FD1
      8E005FD15F0067DB9500C0EFE30041C9790044CD7A0055D6830064D57C00A2D6
      A000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000DCDBDA00B4B2B100AAA8A600CBCA
      C90000000000FCFCFC00000000000000000000000000C6C5C4009A989600CCCB
      CB00A4A3A1009C9A9800C0BFBD00FBFBFB000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FCFC
      FC00E1E1E000E7E6E600F3F2F20000000000FAFAFA00EAEAE900D5D0D200BDCE
      B90073E07D00AFD1AE00D6CFD400C5C3C100C5C3C200DFDEDD00000000009DC1
      9C009AF8C00095F8AD0073BD7500C9CDC900F8F7F800D5D4D400C7C6C400C2C0
      BF00E8E7E700FDFDFD0000000000000000000000000000000000000000000000
      0000686769003C3B3E008A898B00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FEFE
      FE00FAFAFA00FEFEFE0000000000ADE8AC008EDF900094E09400C8E8C6000000
      000000000000000000000000000000000000ECF8EC006ED66D00A0F9BB006FCF
      6E0099E19D004ACE7100B8ECDC0058D08C0048CF7D005BD88C006BDF930065CB
      6400000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FAFAFA00B8B7B5009A989600AEADAB009A989600ACAA
      A900000000000000000000000000FEFEFE00C3C2C000A8A7A500B3B1B000F8F8
      F800F5F5F500B6B5B300A5A3A100AEACAB00F3F2F20000000000000000000000
      0000000000000000000000000000000000000000000000000000F4F4F400CDCB
      CB00CAC8C700D4D3D100CDCCCA00D0CFCE00D0CFCE00C5C3C100DAD8D700EEE7
      ED0048CC440081C17D00D4C6D000EEEDED00F8F8F800D7D6D400C5C4C300CEC3
      CC0086EE9A00A3FFC1006EC973009EAC9B00C0BBBB00D5D3D200ECECEC00F0F0
      F000C1BFBD00E4E3E300FEFEFE0000000000000000000000000000000000E7E7
      E700ECECEC00F3F3F3007E7D7F0039383B008F8F9000B5B4B500E0E0E000FCFC
      FC00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000087DC8D002ABD530033C55F0042CC6B005DD36E0093E1
      96000000000000000000000000000000000000000000F1F9F10064D4620050CD
      4B00F1FBF0005BD05E0028C064003BC973004DD2810060DB900073E49F0051CD
      4D00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000DEDDDC00B1AFAE00B5B4B200E7E6E600F3F3F300C0BE
      BD00D2D1D00000000000FDFDFD00BFBDBC009A989600BAB9B700FCFCFC000000
      000000000000FEFEFE00C8C7C600ADABAA00A4A2A000F1F1F100000000000000
      00000000000000000000000000000000000000000000F1F0F000C4C3C100C6C4
      C200F9F9F900F9F8F700F9FAF900EFEEEE00CFCDCD00F9F9F900F8F8F800FAFA
      FA00A6E1A30083D77E00FFF9FF00FAFAFA00F8F8F80000000000DAD9D800E3E2
      E1007FD8790085EF990074DE7C008EA68900EDE8ED00FCFCFC00F8F8F800F8F8
      F800D3D1D000C4C2C000F6F6F600000000000000000000000000000000006565
      67000000000000000000F0F0F00092929400B0AFB100B2B2B3007D7C7E00403F
      44004241530055536300706E790099989A00BCBBBC00BBBBBC00909093009696
      9800B8B8B900D1D1D200AAAAAB00A3A3A4009A999B008F8F9000B1B1B200A5A5
      A6008E8D8F00EAEAEB0000000000000000000000000000000000000000000000
      000000000000D1F2CF0040C55A00A3EFC7008CDFB70044CD7A0055D684006ADF
      9800FEFEFE000000000000000000000000000000000000000000FBFBFB0068D1
      650000000000B9EBB70059CE730044CD7A0056D6880069DF97007CE8A60068D5
      7100F9F9FA000000000000000000000000000000000000000000000000000000
      00000000000000000000F8F8F800DAD9D900000000000000000000000000FEFE
      FE00A09E9C00BBBAB800A9A7A500AFADAC00BAB9B800FDFDFD00000000000000
      0000000000000000000000000000DCDBDA009E9C9A00E1E0DF00000000000000
      000000000000000000000000000000000000FDFDFD00CAC8C600DDDCDB00F8F8
      F700F7F7F700F7F7F700F7F7F700F8F8F800FBFBFB00F9F9F900F9F9F900F9F9
      F900F9F9F900FAFAFA00F7F7F700F7F7F700F7F7F700F7F7F700FAFAFA00FAFA
      FA00FBF9FA0093E2940048D04400A0C09F00F0EBF000F9F9F900F7F7F700F7F7
      F700FCFCFC00C7C5C300D5D4D300FEFEFE000000000000000000F9F9FA004E4D
      5000000000000000000000000000F4F4F4005C5B5D000000000000000000E6E6
      E7003632D4003632C2003935A50086858D00ACABAD007A797D003E3C7E003632
      A9006A69750092929400757477003B394F003A37970065638200B6B6B700C1C1
      C20099989A00BFBFBF0000000000000000000000000000000000000000000000
      000000000000D4F3D30043C55A00A2EFC70086DEB20048CF7D005BD88C006EE1
      9B00E8F2E800FCFCFC00FAFAFA00FEFEFE0000000000C1EDC10072D7720067D4
      6600FCFEFC00FEFFFE009CE39B005AD17A005BD88C006EE19B0081EAA9007FE6
      9600F4F4F4000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000ADACAA00AFAEAC009B999700C6C5C400FEFEFE0000000000EAEAE900ACAA
      A900B8B6B600EEEEED000000000000000000F4F4F400FEFEFE00000000000000
      00000000000000000000000000000000000000000000EAEAEA00D3D1CF00FDFD
      FD00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800FAFAFA00FDFDFD00FDFD
      FD00FBFBFB00FAFAFA00FAFAFA00F9F9F900F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800FFFCFF009AE59A00A0CC9F00EDEEED00FAFAFA00F8F8F800F8F8
      F800F8F8F800FCFCFB00CFCDCC00FAFAFA000000000000000000C7C6C7009F9F
      A0000000000000000000000000000000000059595B00F5F5F500000000000000
      00003632D5003732ED003732E3004E4D5C0000000000000000007D7C93003632
      C20037363A0000000000000000007A7987003632CC0044426400EEEEEF000000
      0000A6A6A700BBBBBC0000000000000000000000000000000000000000000000
      000000000000FAFEFA0058CD550030C46B0058D18B004DD2810060DB900073E4
      9F00A8DEA600FEFEFE000000000000000000DBF3E50037C356003DC76F002EC3
      64004CCC4600FAFDFB00000000009BE19B0061D7800073E49F0086EDAD008BEF
      A600EFEFEF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F5F4F400CFCECD00C6C5C400E7E7
      E600FCFCFC00E0DFDF00EFEFEF000000000000000000E1E0E0009E9C9A00B1B0
      AE00A5A4A2009D9B9900DAD9D900000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00E6E5E500C7C5
      C300FFFFFE00F9F7F800FAF9F900FCFCFC00FCFCFC00F9F9F900F0F0F000FDFD
      FD00F6F6F600F9F9F900F9F9F900FBFBFB00FEFEFE00FCFCFC00F8F8F800F4F4
      F500FAFAFA00FAFAFA00F9F9F900F9F9F900EAEAEA00F5F5F500F9F9F900F9F9
      F900F9F9F900FBFBFB00C8C7C500FCFCFC0000000000000000006D6D6F00EAEA
      EB0000000000000000000000000000000000A8A7A900BFBFBF00000000000000
      000045436D003732ED003732ED0046448400D8D8D90000000000ECECEC004341
      68003F3C9D00C1C1C20000000000D6D6D600424188003B37A700B5B4B5009A9A
      9B00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D3EED2005ECD69005BD88C006EE19B0081EA
      A90056CE5200F8F8F800000000000000000059CC5E006CDD9800B1EAD60040C9
      77005BD88C0064DA8000A1D79F0000000000000000005AD1560094F2B700A6FC
      C600D4D9D400FCFCFC0000000000000000000000000000000000000000000000
      00000000000000000000E2E2E100A8A6A400A19F9D00CBCAC900D7D6D500AAA9
      A700E7E7E6000000000000000000DAD9D9009C9A9800AEACAB00F0F0EF000000
      000000000000F4F3F300AFADAC00A9A7A500B4B3B100FAFAFA00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FCFCFC00E0DFDF00D2D0CE0000000000FAFAFA00FAFAFA00FCFC
      FC00F5F5F500EBEBEB00E8E8E800E8E8E800F5F5F50000000000FEFEFE00FDFD
      FD00FEFEFE00FEFEFE00FDFDFD00FCFCFC00FCFCFC00FBFBFB00FAFAFA00FBFB
      FB0000000000C5C4C200E7E6E600FFFEFE00000000000000000061616300F1F1
      F10000000000000000000000000000000000B1B1B200B6B6B700000000000000
      000042415D003732ED003732ED00423F9600C9C9CA0000000000F0F0F0004341
      61003B38A400BABABB0000000000C1C1C2003D3A9B003534380042424400CBCA
      CB00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FAFAFA00A0D19E0062CD760073E49F0086ED
      AD0063D06300B7C2B400CBC9C700DDDCDB00ADD6AD0043C25B0036C46F003CCA
      740060DB90006EE1930062C26200C7C5C300DCDBDA00E7ECE6005ECF5B00ABFF
      CA0097AF9500EFEEEE0000000000000000000000000000000000000000000000
      00000000000000000000EFEEEE00C0BFBE00F6F6F6000000000000000000F7F7
      F600A7A5A300D6D5D500C2C1C000ABA9A700A7A6A400F3F2F200000000000000
      00000000000000000000FCFCFC00C1C0BF009B999700DEDDDD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E9E9E900D0CECD00D2D0CF00FFFFFE00FBFBFB00FEFE
      FE00FCFCFC00FCFCFC00F9F9F900EEEEEE00F1F1F100FBFBFB00FDFDFD00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FDFDFD00FDFDFD00FDFDFD00F9F9F900FBFC
      FC00C5C3C100D9D8D700FEFDFD000000000000000000000000006C6C6E00EBEB
      EB0000000000000000000000000000000000A8A7A900BFBFBF00000000000000
      000046456C003732ED003732ED0043409400CACACA0000000000E5E5E5004644
      740043409700C8C7C800E0E0E00068676C0035343900C5C5C700EAEAEA000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E8E8E700C4C2C000C6C4C30091D08F0072D98A008AEF
      B00071DA7800C6DDC400FDFDFD00F1F1F000C1BFBD006CC76B003BC5690044CD
      7A0069DF97007CE8A6004ECC4900E6E6E700DCDBDB00C1BFBD00ECEBEB004FCD
      4A008DBA8B00BDBBBA00F1F1F000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00009E9C9B00AFADAC009A989600AEADAB00F4F4F40000000000FAFAFA00C9C8
      C700CFCECD00FCFCFC000000000000000000DCDBDB00F8F8F800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F6F6F600DDDCDA00BDBBB900CAC8C700D9D7D600D6D5
      D400FBFBFB00F4F4F300FEFEFE00FEFDFD00FDFDFD00FEFEFE00FEFEFD00FEFE
      FE00FCFCFC00FDFDFD00FEFEFE0000000000F4F4F400E5E5E500F9F9F9000000
      0000E1E0DF00C5C3C100EFEEEE000000000000000000000000008B8A8C00D7D6
      D7000000000000000000000000000000000098989900CDCDCE00000000000000
      0000444287003732ED003732ED0046457C00DFDEDF0000000000D0D0D1003F3D
      8D00353437007E7D7F007F7E8000BBBBBC00FCFCFC0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E8E8E700C1BFBD00E8E7E600F9F9F900F6F6F6008DD78C0087E6
      9E008AED9D00A3D7A100F6F6F600F8F8F800FDFDFD00FCFCFC005ECD5D004ACF
      7B006EE19B0081EAA90062D26600C5D3C500FBFAFA00FEFEFE00FBFBFB00FCFE
      FC008ECD8D00E1E0E000C8C6C500FCFCFC000000000000000000000000000000
      00000000000000000000000000000000000000000000ECECEC00E3E2E200FBFB
      FA00EFEEEE00C4C3C200D3D3D200FCFCFC0000000000F4F3F300ABA9A800AAA8
      A700AEADAB00ACAAA900F0F0F000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FCFCFC00DEDDDC00C9C7C500ECEBEB00E9E8E900DEDDDD00D4D3
      D200E9E9E800F8F7F700EAE9E800EEEEED00F3F3F200F2F2F100F7F6F600F8F8
      F700FEFEFF00FEFEFE00FEFEFE0000000000F9F9F900F8F8F800FDFDFD00D8D7
      D600F6F6F500ECEBEB00C9C7C600FBFAFA000000000000000000B8B8B900AFAF
      B000000000000000000000000000000000005E5D6000F2F2F200000000000000
      000038359D003732ED003732ED0039384000FEFEFE000000000072717900413F
      620061616300D2D2D20000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FAFAFA00CCCBC900D4D3D200F5F4F400FAFAFA00F6F6F60082D7
      80009CF7B6007BD17900F6F6F600F9F9F900FCFBFB00F1F1F000F3F3F3005ECD
      5E0073E49F0086EDAD0078E288009EC89D00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE007ED47A00F3F3F300E0DFDE00E8E8E7000000000000000000000000000000
      0000000000000000000000000000EDEDEC00B1AFAD00A6A4A3009A989600C8C8
      C70000000000000000000000000000000000F1F0F000A7A5A3009B999700CBCA
      C900C2C1C000A09E9C00AAA8A700E2E2E1000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F1F1F100C8C6C500DEDDDC00FAF9F900FBFBFB00F7F7
      F800C2C1BF00E1E1E00000000000FEFEFE00FDFDFD00FEFEFE00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE0000000000FBFBFB00E2E2E100CFCECC00BFBD
      BB00FAFAFA00FBFBFA00E1E1E000E8E7E6000000000000000000E9E9E9007070
      7200000000000000000000000000EBEBEB006C6B6D0000000000000000000000
      00003632D4003732ED0035337C0051505D00CACACA0078787A00515052009A99
      9B00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FDFDFD00DDDCDB00D2D1CF00E4E3E200ECEBEB00F8F8
      F7009FF7B90065D06300F7F7F700FEFEFE00F6F5F500FCFCFC00FCFCFC00F3F3
      F30077E6A2008AEFB0008DF0A70077C57600F2F2F200FDFDFD00FEFEFE00FEFE
      FE00FEFEFE00F0F0F000CAC9C700F1F1F1000000000000000000000000000000
      00000000000000000000ECECEB00A4A2A0009A989600B3B2B000BAB8B700B0AE
      AD00F5F5F5000000000000000000EFEFEF00A5A3A100ACABA900DBDBDA000000
      000000000000DFDEDE00A2A09E00A2A09E00CFCECD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F7F7F600D5D4D200D6D5D300E8E7E600F3F2
      F200D9D7D600BEBCBA00CDCBCA00DDDCDB00D1D0CF00E5E4E30000000000FEFE
      FE00FEFEFE00FEFEFE00FEFEFE0000000000CECDCB00D2D0CE00D9D7D600EAEA
      E900FEFEFE0000000000CDCCCA00F0F0EF000000000000000000000000005554
      5600000000000000000000000000B8B8B900AFAFB0000000000000000000C9C9
      CA003C3997003B394C00424057003F3E42009B9B9C00E3E3E400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFE00F7F7F700F2F1F100C3C1
      BF007AD6790052CE4D00F7F7F700FDFDFD00FBFBFB00FEFEFE00FEFEFE00FCFC
      FC005FD1600094F3B800A3FBC1005BCC5800EDEDED00FEFEFE00FEFEFE00FDFD
      FD00FAFAFA00CFCDCC00D1CFCE00FFFEFE000000000000000000000000000000
      00000000000000000000E5E4E400AEACAA00E1E0E0000000000000000000E8E7
      E700B4B3B100F3F2F200DFDEDE00A9A8A6009D9B9900E1E0DF00000000000000
      00000000000000000000EEEEED00AFADAB009B999700E2E1E100000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FBFBFB00F8F8F800E0DE
      DE0000000000E7E7E600CFCDCC00CBCAC800C7C6C400C4C2C000E9E9E8000000
      0000D7D6D500EAE9E800FAFAFA00CBC9C700CDCBCA00F7F7F70000000000FDFD
      FD00FCFCFC00D2D0D000D0CFCD00FDFDFD00000000000000000000000000DBDB
      DC00F7F7F70000000000DDDDDD005E5D6000F0F0F000D9D9D900A7A7A8006D6D
      6F0056555A00A4A3A500E1E1E100000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E6E6
      E500EDECEC0075D27100E6F5E600FBFBFB00FDFDFD00FEFEFE00FCFCFC00FBFB
      FB00CEEBCE0079DC8100ABFFCA004FCD4900E2E2E200FEFEFE00FDFDFD00FCFC
      FC00E2E2E100D4D3D200F8F8F800000000000000000000000000000000000000
      0000000000000000000000000000FDFDFD000000000000000000000000000000
      00009A989600A6A4A3009A989600A7A5A300E2E2E10000000000000000000000
      0000000000000000000000000000F9F9F800BFBEBD00EFEFEF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FAF9
      F900D4D2D200FBFBFB0000000000FCFCFC00FBFBFB00D9D8D600BEBCBA00C5C3
      C100C2C0BE00C2C0BE00C0BEBC00C4C2C000F0F0EE0000000000FDFDFD00FCFC
      FC00E5E5E500D3D2D100F7F6F600000000000000000000000000000000000000
      0000F3F3F300E4E4E400FCFCFC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F8F8F800C6C4C200D9D7D700FEFEFE00FAFAFA00FEFE
      FE00FEFEFE00FEFEFE00D7F2D70078DC7D00ACC7AB00F8F8F700DEDDDC00CDCB
      CA00EEEDED000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DDDCDB00C9C7C600F0EFEF00FEFFFF00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE0000000000FBFCFB00E3E3E200D0CE
      CD00E9E9E800FEFEFE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F7F7F600D0CFCD00C1BFBD00C6C4C200C1BF
      BD00FAFAFA00FDFCFC00F0EFEF00B8EAB7009ECF9C00C9C7C500D8D6D500E9E9
      E800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E0DFDF00C6C4C200C5C3C100C1BF
      BC00F1F1F00000000000F2F1F100F8F8F80000000000D4D2D000D3D1D000E6E6
      E500FFFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FAF9F900EFEFEF00E3E3
      E200CDCBCA00C4C2C000C1BFBD00C2C0BF00BFBDBB00C3C1C000FCFCFC000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00F6F6F600F1F0
      F000CAC8C700C8C6C400C1BFBD00C2C0BF00C1BFBE00CAC8C600F5F5F5000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E3E2E100E5E4E400F9F9F900F4F4F300F4F3F300FFFEFE00000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FDFDFD00D1D1D100000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E9E8E700E1E0DF00F4F4F300F6F6F600F2F2F200FCFCFC00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D1D1D1000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D1D1D1000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E7F9E600CDF1CB00F0FBF0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F4FCFF00F9FEFF000000000000000000FCFEFF00FDFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007ED27E0045CB4E0048C9610048CB4C0080DB7F00D9F5D800FDFEFD000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FDFF
      FF000000000000000000E7F9FF00C9F2FF00FBFEFF00D1F4FF00D1F4FF00ECFA
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00003CC8610082DDB2004DCC830035C770004CD271008ADD9400ECEEED000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F2FC
      FF00ECFAFF00DEF6FF00E3F8FF00C1EEFF00E1F6FF00C0F0FF00C7F1FF00D8F6
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F2FBF5009BE298004BCB490051CD53005ED75C00AED4AE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C3939200CAA09F00F5ECEC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F2FBF5009BE298004BCB490051CD53005ED75C00AED4AE000000
      0000000000000000000000000000000000000000000000000000000000000000
      00002EC1540069D49C0054CE890041CC780056D6890069E0930069D26C00E6E8
      E600000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FAFEFF00DBF3FB00C6D6DB00C2C2C000E5E4E300EFEF
      EE00D7D9D900C7C6C400F0F0F000F7F7F700E2E1E100C7C7C500ECEBEB00FEFD
      FD00CBCACA00DCDBDA00FAFAF900F6F5F500DEDDDC00CAC8C600ECEBEB00FDFD
      FD00CFCDCC00E0DFDE0000000000000000000000000000000000000000000000
      00000000000000000000F8F8F800E5E5E400E2E2E100F5F4F400000000000000
      0000000000000000000000000000000000000000000000000000F9F9F900C2C1
      C000A7A6A4009A989600BAB9B800E9E9E900FEFEFE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D9F3E20038C15B0067D49B0045CB7D0043CD780052DB6A0083BB
      7E000000000000000000000000000000000000000000FAF7F700F8F2F2000000
      0000B87E7D00C5979600F6EFEF00FDFBFA00F8F2F100FEFDFD00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D9F3E20038C15B0067D49B0045CB7D0043CD780052DB6A0083BB
      7E00000000000000000000000000000000000000000000000000000000000000
      000090DE8A0030C25A0032C56F0048CF7D005BD98C0073E5A40055DC5600CED3
      CE00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D3F4FF00C4CDD000F4F3F300FDFDFD00FAFAFA00F9F9
      F900F7F7F700FCFCFC00F9F9F900F9F9F900FAFAFA00FDFDFC00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFDFD00FEFEFE00FEFE
      FE00F8F8F800C3C1BF00E4E3E200000000000000000000000000000000000000
      0000E9E8E800BBBAB8009C9A98009A989600D1D0CF00B5B3B200BFBEBD00FCFC
      FC000000000000000000000000000000000000000000E8E7E700A6A5A300BDBC
      BB00CECDCC00EAEAEA00EEEDED0000000000FCFCFC0000000000FEFEFE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F1FBF1007AD981005AD08700BFEEE30049CC7F0046CF7C005EDB8E0064E0
      7C0000000000000000000000000000000000F3EAEA00D4B2B100C99E9D00E4CE
      CD00B87E7D00CAA09F00EADAD900D5B3B300CBA2A100DFC6C500FCF9F9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F1FBF1007AD981005AD08700BFEEE30049CC7F0046CF7C005EDB8E0064E0
      7C0000000000000000000000000000000000FBFDFB00F1FBF000E9F9E800F7FD
      F7000000000085DA840042CA6D004FD3850064DD93007CE9AA0061D86900B4CB
      B300000000000000000000000000000000000000000000000000000000000000
      0000E3F8FF00C8F2FF00C5EEFF00BFEDFC00C3D7DD00D8D8D900FAFAFA00FCFC
      FC00F7F7F700F9F9F900FAFAFA00FCFCFC00FDFDFD00FCFCFC00F7F7F700FEFE
      FE00FCFCFC00FCFCFC00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FDFDFD00F6F5F500D8D7D600000000000000000000000000000000000000
      0000C1C0BF00C6C5C4009D9B9900B1B0AE00BBBAB800B3B2B1009A989600E1E1
      E00000000000000000000000000000000000D6D5D5009F9D9B009A989600B8B6
      B500000000000000000000000000000000000000000000000000EDEDED00F7F7
      F700000000000000000000000000000000000000000000000000000000000000
      0000FDFEFD00BEECBE0047C863008ADEB90068D6990047D07C0065DD970068E1
      8500FCFCFC00000000000000000000000000FFFEFE00CFA9A800A9646200CBA1
      A000B0716F00AD6B6900CBA2A100BD888700AE6E6C00E7D4D300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FDFEFD00BEECBE0047C863008ADEB90068D6990047D07C0065DD970068E1
      8500FCFCFC0000000000000000000000000093D6A30048CD490051CD5B0051CF
      5200F9FDF900000000007AD97C0056D47A0069DF990080EAAB0074E1870095C6
      9400000000000000000000000000000000000000000000000000000000000000
      0000F5FDFF00C3F1FF00BEEFFF009AB1F900B3DBFD00AED0FA008C8AE900788A
      E600CFCECC00FDFDFD00FAFAFA00F8F8F800FEFEFE00FCFCFC00FEFEFE00FEFE
      FE00F6F6F600FAFAFA00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FCFCFC00C3C2C000F4F3F300000000000000000000000000000000000000
      0000B4B3B100D1D0CF00F8F8F8000000000000000000F6F6F600D2D1D000F9F9
      F90000000000000000000000000000000000B5B3B200B1B0AE00D5D4D3000000
      000000000000000000000000000000000000000000000000000000000000F7F7
      F700000000000000000000000000000000000000000000000000000000000000
      000000000000EDFAED006ED4780030C3630040CC780053D5860069E0990071E4
      9300E1E7E100000000000000000000000000FDFBFA00EFE2E100D6B6B500C89B
      9A00B9807F00B2747200BF8B8A00C89B9A00E0C7C600F5EEEE00FFFEFE000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EDFAED006ED4780030C3630040CC780053D5860069E0990071E4
      9300E1E5E0000000000000000000A5E5A20040C7610065D49C0055D0890046D0
      7E0097D79600FAFBFA00CDE3CD0071D97F006BDF950083ECAD0089F1A6007CCB
      7C00000000000000000000000000000000000000000000000000F0EFEF00DAD9
      D700D0D1D000C4D3D600BFDEE600B6D1EB00AAA8CE00C3C1C600CECECE00B9D0
      D300ACC3C700DAD9D800F4F4F400F2F1F100F7F7F600FCFCFC00FDFDFD00FEFE
      FE00FDFDFD00FDFDFD00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFD
      FD00D6D5D400F8F8F80000000000000000000000000000000000000000000000
      0000FAFAFA00000000000000000000000000000000000000000000000000FAFA
      FA00FBFBFB0000000000FAFAFA00FEFEFE00F5F5F500F2F1F100000000000000
      0000ECECEB00DAD9D800EAEAE900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000DAF5D90048CB520047CF82005CD98D0071E39F0080EC
      A500BDD0BC000000000000000000000000000000000000000000EBDADA00BA83
      8100A8626000B67B7A00B3757400CDA4A300F6EFEE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000DAF5D90048CB520047CF82005CD98D0071E39F0080EC
      A500BCCCBC0000000000FAFEFA008ADC8E0069D88900A3EBCC005CD28F0047D0
      7C005AE36600A8B5A80000000000C0ECBF0073DA840083EBA90099F7BA0067D5
      690000000000000000000000000000000000F6F5F500D1CFCE00C6C4C200E9E8
      E800F8F8F800F9F9F900FDFDFD00D9D8D700F8F7F700FAFAF900F8F8F800F6F6
      F500DBD9D900F7F7F700F0F0EF00E1E0DF00DBD9D800F7F6F600FBFBFB00FBFB
      FA00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00EDEDEC00EAE9E800D9D8
      D600D4D6D5000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FEFEFE0000000000FEFEFE0000000000000000000000000000000000ECEC
      EB009F9E9C009A989600B5B3B200F2F2F2000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D8F4D7004FCF580061DB960075E4A1008AEF
      B0009CBF9A00000000000000000000000000F7F0F000DEC4C300C3929100C08D
      8C00B3767400B5797800C2919000BC868400CA9F9E00E6D3D200FDFBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D8F4D7004FCF580061DB960075E4A1008AEF
      B0009BB99A000000000000000000AAE7A60040C95D0072D8A80068D799004CD2
      80006BE3850085C08600E6E6E60000000000B1EAB00082E49400A5FCC60060DC
      6100FEFEFE00000000000000000000000000DFDEDD00C1BFBD00F5F5F500FAFA
      FA00F8F8F800F8F8F800F8F8F800FBFBFB00FBFBFB00FDFDFD00FDFDFD00FDFD
      FD00FCFCFC00F9F9F900F9F9F900F9F9F900EFEFEE00D6D5D300CFCDCC00CECC
      CC00FDFDFD00FDFDFD00E7E7E600F7F7F700F5F4F400C2C0BE00E3E2E100EDED
      EC00C2C0BE00E3E2E10000000000000000000000000000000000000000000000
      000000000000E5E5E400C2C0BF00ADABA900B6B5B300BEBDBC00EAEAEA000000
      00000000000000000000000000000000000000000000FDFDFD00CDCCCB00AAA9
      A700A9A7A500BEBCBB00C6C5C400F8F8F800FAFAFA0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C9E9C80058D665007CE9AB0093F4
      BB0084B67F0000000000000000000000000000000000C99E9D00A9636200CEA7
      A600C2919000BB858400CFA9A800C18F8E00A9636200E5D1D000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C9E9C80058D665007CE9AB0093F4
      BB0084B67F000000000000000000F6FDF6008EDE920039C5630043CE7C0058D7
      8A007DECA2006CD37300C6CDC60000000000000000009AE497009AF4B00063DE
      6500FCFCFC0000000000000000000000000000000000F1F0F000D0CFCD00E4E3
      E200FBFBFA00FAFAFA00FDFDFD00FAFAFA00FEFEFE00F4F4F400FEFEFE00FBFB
      FB00FBFBFB00FBFBFB00FCFCFC00FDFDFD00FEFEFE00FDFDFD00FDFDFD00FCFC
      FC00D2D1D000D0CFCD00DDDCDB00DBD9D800DCDBDA00EFEEEE00FAFAFA00FAFA
      FA00EBEAE900DBDAD90000000000000000000000000000000000000000000000
      0000B5B3B100BBBAB9009A9896009A989600C7C6C500D2D2D1009C9A9800EBEB
      EA0000000000000000000000000000000000F3F3F300B1B0AE009A989600A9A8
      A600FCFCFC000000000000000000000000000000000000000000F2F2F2000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFEFD00B5ECB7007DE6
      8E0081CF8300DBE2DB0000000000000000000000000000000000000000000000
      0000B2747300C2919000F6EFEE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFEFD00B5ECB7007DE6
      8E0081CF8300DBE2DB00000000000000000000000000CAF4CA0066D6790063DB
      900096F5BF0069E772009AB09900F6F6F600000000000000000000000000B2EF
      B500F6F6F600000000000000000000000000000000000000000000000000CDF3
      FF00D3F2FB00D5E3F500CAC8CB00E0DFDE00FEFEFE00FAFAF900FBFAFA00FEFE
      FE00FEFEFE00FEFEFE00FBFBFB00FBFBFB00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FAFAFA00FDFDFD00FEFEFE00DAD9
      D800C9E7F0000000000000000000000000000000000000000000000000000000
      0000D5D5D400FDFDFD000000000000000000000000000000000000000000FCFC
      FC00FEFEFE0000000000FEFEFE0000000000D7D7D600CAC9C800FCFCFC000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F2F4F200AAF2
      AD0084DE8D00C2D1C10000000000FEFEFE00FEFEFE00FEFEFE00FDFDFD000000
      0000D3AEAD00E1C7C600FAFAFA0000000000FEFEFE00FEFEFE00FAFAFA00F9F9
      FA00FEFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F2F4F200AAF2
      AD0084DE8D00C2D1C10000000000FEFEFE00FEFEFE0000000000B0CEAF0067E3
      7B0099F7C10080EA910084B78400DFE1DF0000000000FEFEFE00FAFAFA00F9F9
      FA00EEEEEF00FDFDFD000000000000000000000000000000000000000000FBFD
      FE00FEFEFE00EEEEF200E7EAF300D7DEDE00C9CDCE00CCCFCF00CDD0D000C8C6
      C500F8F8F700F0EFEF00F8F8F800F8F8F800F9F9F800FDFDFD00FEFEFE00FEFD
      FD00FEFEFE00FEFEFE00FEFEFE00F6F6F600F8F8F800FDFDFD00C8C7C500BBBD
      D100F0FAFE00CDF3FF00FDFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FBFBFB0000000000FAFAFA00000000000000000000000000000000000000
      0000B3B1B000A19F9D00B8B6B500FCFCFC000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FCFC
      FC00E1E1E000E7E6E600F3F2F20000000000FAFAFA00EAEAE900D5D0D200BDCE
      B90073E07D00AFD1AE00D6CFD400C5C3C100C5C3C200DFDEDD00F4F4F400F6F6
      F600C9C7C500C6C4C200DBDAD900EFEFEF00F8F8F800D5D4D400C7C6C400C2C0
      BF00E8E7E700FDFDFD000000000000000000000000000000000000000000FCFC
      FC00E1E1E000E7E6E600F3F2F20000000000FAFAFA00EAEAE900D5D0D200BDCE
      B90073E07D00AFD1AE00D6CFD400C5C3C100C5C3C200DFDEDD00000000009DC1
      9C009AF8C00095F8AD0073BD7500C9CDC900F8F7F800D5D4D400C7C6C400C2C0
      BF00E8E7E700FDFDFD0000000000000000000000000000000000FAFEFF00FEFE
      FE00FEFEFE00F8F8FC00E7EBF300E5F0F300DAE9EE00D2E5EB00CFE6EF00C9D7
      DC00F6F6F600FDFDFD00FDFCFC00FDFDFD00FDFDFD00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00F5F5F500E0E0DE00CDCBC900C0C0C800C2E5
      F100C2EEFC00DAF5FE0000000000000000000000000000000000000000000000
      00000000000000000000EEEDED00D9D8D700D5D5D400E9E9E800000000000000
      0000000000000000000000000000000000000000000000000000F4F3F300B6B5
      B400A7A6A4009A989600B5B4B200EDEDEC00FDFDFD0000000000000000000000
      0000000000000000000000000000000000000000000000000000F4F4F400CDCB
      CB00CAC8C700D4D3D100CDCCCA00D0CFCE00D0CFCE00C5C3C100DAD8D700EEE7
      ED0048CC440081C17D00D4C6D000EEEDED00F8F8F800D7D6D400C5C4C300C5C3
      C100E6E4E400E9E8E700D3D2D000C7C6C500C2C1BF00D4D2D100ECECEC00F0F0
      F000C1BFBD00E4E3E300FEFEFE00000000000000000000000000F4F4F400CDCB
      CB00CAC8C700D4D3D100CDCCCA00D0CFCE00D0CFCE00C5C3C100DAD8D700EEE7
      ED0048CC440081C17D00D4C6D000EEEDED00F8F8F800D7D6D400C5C4C300CEC3
      CC0086EE9A00A3FFC1006EC973009EAC9B00C0BBBB00D5D3D200ECECEC00F0F0
      F000C1BFBD00E4E3E300FEFEFE00000000000000000000000000D3F5FF00EAF8
      FE00FEFEFE00F9F9FE00F0F4FB00E6F1F400DFEEF200D6E8EE00CFE5ED00CCE7
      F100C3CED200C2C5C500C7C7C600C3C4C300C5C4C200FAFAFA00FCFCFC00FDFD
      FD00FEFEFE00FBFBFB00D4D2D100A9C9CF0088E1F2007DB5F400B0B2F800B7CB
      F900CEF0FE00EFFBFF0000000000000000000000000000000000000000000000
      0000DCDBDB00B3B1AF009A9896009B999700DDDDDC00BEBDBC00B3B2B000F9F9
      F9000000000000000000000000000000000000000000DDDCDB00A09E9C00BBBA
      B900DAD9D900F7F7F600F7F7F70000000000FDFDFD0000000000FCFCFC000000
      00000000000000000000000000000000000000000000F1F0F000C4C3C100C6C4
      C200F9F9F900F9F8F700F9FAF900EFEEEE00CFCDCD00F9F9F900F8F8F800FAFA
      FA00A6E1A30083D77E00FFF9FF00FAFAFA00F8F8F80000000000DAD9D800E3E2
      E100F9F9F900F9F9F900FAF9FA00D3D1CF00F1F0F000FAFBFB00F8F8F800F8F8
      F800D3D1D000C4C2C000F6F6F6000000000000000000F1F0F000C4C3C100C6C4
      C200F9F9F900F9F8F700F9FAF900EFEEEE00CFCDCD00F9F9F900F8F8F800FAFA
      FA00A6E1A30083D77E00FFF9FF00FAFAFA00F8F8F80000000000DAD9D800E3E2
      E1007FD8790085EF990074DE7C008EA68900EDE8ED00FCFCFC00F8F8F800F8F8
      F800D3D1D000C4C2C000F6F6F600000000000000000000000000FCFEFF00CEEE
      FF00D3DBFC00E5E5FD00F2F6FE00ECF7FA00E2F1F400DBEDF200D3E9EF00CCE6
      EE00C7E9F500C2E8F600BFE9F900BCE9FB00BCD1D800C4C3C200C8C7C500C0C1
      C000B9C5C600B8C4C600A2CDD60073DFF8007BE7FD0071AFF800ABADF800B8CD
      FB00C7EFFF00D9F6FF0000000000000000000000000000000000000000000000
      0000CDCCCC00BEBCBB00A4A2A000BEBDBB00C3C2C100B1B0AE009A989600E2E2
      E10000000000000000000000000000000000CCCBCA00A2A09E009A989600C4C3
      C200000000000000000000000000000000000000000000000000F0F0F000F4F4
      F40000000000000000000000000000000000FDFDFD00CAC8C600DDDCDB00F8F8
      F700F7F7F700F7F7F700F7F7F700F8F8F800FBFBFB00F9F9F900F9F9F900F9F9
      F900F9F9F900FAFAFA00F7F7F700F7F7F700F7F7F700F7F7F700FAFAFA00FAFA
      FA00F7F7F700F7F7F700F7F7F700FAFAFA00F8F8F800F7F7F700F7F7F700F7F7
      F700FCFCFC00C7C5C300D5D4D300FEFEFE00FDFDFD00CAC8C600DDDCDB00F8F8
      F700F7F7F700F7F7F700F7F7F700F8F8F800FBFBFB00F9F9F900F9F9F900F9F9
      F900F9F9F900FAFAFA00F7F7F700F7F7F700F7F7F700F7F7F700FAFAFA00FAFA
      FA00FBF9FA0093E2940048D04400A0C09F00F0EBF000F9F9F900F7F7F700F7F7
      F700FCFCFC00C7C5C300D5D4D300FEFEFE000000000000000000F2FCFF00C3F1
      FF00BCECFF006D79F5004F81F6008FE6FE00BBEEFB00D1EEF600DAEDF200D3E8
      EE00CCE9F200C9EAF500C5EAF600C3ECFA00BFECFC00B9E9FB00A9E2F50092E3
      FA0090E0F60083DEF70056DBFD0052DBFE0074E5FE005F9AF700ADB8F800BFEE
      FF00DEF7FF000000000000000000000000000000000000000000000000000000
      0000B3B2B100DDDDDC00FEFEFE000000000000000000FCFCFC00DFDEDD00FBFB
      FB0000000000000000000000000000000000B8B7B600B0AFAD00E1E0E0000000
      000000000000000000000000000000000000000000000000000000000000FAFA
      FA000000000000000000000000000000000000000000EAEAEA00D3D1CF00FDFD
      FD00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800FAFAFA00FDFDFD00FDFD
      FD00FBFBFB00FAFAFA00FAFAFA00F9F9F900F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800FCFCFB00CFCDCC00FAFAFA0000000000EAEAEA00D3D1CF00FDFD
      FD00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800FAFAFA00FDFDFD00FDFD
      FD00FBFBFB00FAFAFA00FAFAFA00F9F9F900F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800FFFCFF009AE59A00A0CC9F00EDEEED00FAFAFA00F8F8F800F8F8
      F800F8F8F800FCFCFB00CFCDCC00FAFAFA000000000000000000F2FCFF00C6EF
      FF005D62F2004C48EF00405EF30093E8FD0090EAFE008AE7FE008BE8FE00A3E7
      FA00CBE8F000CBEAF400C6EAF500C0EAF800B0E9FB0095E3FD0074DAFD006CD8
      FD0069DDFD005FDBFE0058DBFE0057DBFE007EE6FE00517CF6009695F600A2AA
      F800BEEEFF00E9FAFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FCFC
      FC00FAFAFA0000000000F8F8F800FEFEFE00FBFBFB00F9F9F900000000000000
      0000DFDFDE00CDCCCB00DFDFDE00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00E6E5E500C7C5
      C300FFFFFE00F9F7F800FAF9F900FCFCFC00FCFCFC00F9F9F900F0F0F000FDFD
      FD00F6F6F600F9F9F900F9F9F900FBFBFB00FDFDFD00FEFEFE00FCFCFC00FBFB
      FB00FAFAFA00FAFAFA00F9F9F900F9F9F900F9F9F900F9F9F900F9F9F900F9F9
      F900F9F9F900FBFBFB00C8C7C500FCFCFC0000000000FDFDFD00E6E5E500C7C5
      C300FFFFFE00F9F7F800FAF9F900FCFCFC00FCFCFC00F9F9F900F0F0F000FDFD
      FD00F6F6F600F9F9F900F9F9F900FBFBFB00FEFEFE00FCFCFC00F8F8F800F4F4
      F500FAFAFA00FAFAFA00F9F9F900F9F9F900EAEAEA00F5F5F500F9F9F900F9F9
      F900F9F9F900FBFBFB00C8C7C500FCFCFC0000000000FEFFFF00D3F4FF00D8F6
      FF00BEF0FF00A4C8FC00434DF00083D7FB008EEAFE009CEEFE009BEDFE0094EB
      FE0091E8FE0092E8FD0089E5FE0082E3FE007DE1FE007CE0FD007ADEFD0077DD
      FD006FDAFD0065DBFE005EDBFE0062DCFD0071D7FC006776F400B4DAFD00BEF0
      FF00E2F8FF00F7FDFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E2E1
      E100A2A09E009A989600BAB9B700EFEFEF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FCFCFC00E0DFDF00D2D0CE0000000000FAFAFA00FAFAFA00FCFC
      FC00F5F5F500EBEBEB00E8E8E800E8E8E800F5F5F50000000000FEFEFE00FDFD
      FD00FEFEFE00FEFEFE00FDFDFD00FCFCFC00FCFCFC00FBFBFB00FAFAFA00FBFB
      FB0000000000C5C4C200E7E6E600FFFEFE000000000000000000000000000000
      000000000000FCFCFC00E0DFDF00D2D0CE0000000000FAFAFA00FAFAFA00FCFC
      FC00F5F5F500EBEBEB00E8E8E800E8E8E800F5F5F50000000000FEFEFE00FDFD
      FD00FEFEFE00FEFEFE00FDFDFD00FCFCFC00FCFCFC00FBFBFB00FAFAFA00FBFB
      FB0000000000C5C4C200E7E6E600FFFEFE000000000000000000FDFFFF00E3F8
      FF008FADF90097B8FA0088A2F800404CF1008ADAFC0096EFFE00AFF5FE00AAF3
      FE00A8F2FE00A3F0FE009EEFFE009DEEFE0098ECFE0093EBFE0092E9FE008DE8
      FE008BE6FE0086E4FD0085E1FD007CD4FD005B6FF300A7C1FB00AFD1FC00ACCB
      FC00F2FCFF000000000000000000000000000000000000000000000000000000
      0000B1B1AF00C3C3C2009A9896009A989600BCBBB900C8C7C6009A989600E7E6
      E60000000000000000000000000000000000ECECEB00A8A7A5009A989600A8A7
      A500000000000000000000000000000000000000000000000000EFEFEF00FDFD
      FD00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E9E9E900D0CECD00D2D0CF00FFFFFE00FBFBFB00FEFE
      FE00FCFCFC00FCFCFC00F9F9F900EEEEEE00F1F1F100FBFBFB00FDFDFD00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FDFDFD00FDFDFD00FDFDFD00F9F9F900FBFC
      FC00C5C3C100D9D8D700FEFDFD00000000000000000000000000000000000000
      00000000000000000000E9E9E900D0CECD00D2D0CF00FFFFFE00FBFBFB00FEFE
      FE00FCFCFC00FCFCFC00F9F9F900EEEEEE00F1F1F100FBFBFB00FDFDFD00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FDFDFD00FDFDFD00FDFDFD00F9F9F900FBFC
      FC00C5C3C100D9D8D700FEFDFD0000000000000000000000000000000000EEFB
      FF00C8F2FF00BEF0FF007789F6004440EF004567F4009FEDFE00A3F4FE00B5F7
      FE00AFF5FE00AEF5FE00A9F3FE00A8F2FE00A3F1FE009EEFFE009DEEFE0098ED
      FE0092E9FE0091E8FE0096E3FE004F76F5007D7BF4009CB0F900BEF0FF00CBF3
      FF00000000000000000000000000000000000000000000000000000000000000
      0000CACAC900B4B3B100DCDBDA00F7F7F700FAFAFA00DBDADA00B2B1AF00F0F0
      F00000000000000000000000000000000000B3B1B000B6B5B400B5B4B200F5F4
      F400000000000000000000000000000000000000000000000000FDFDFD00EEEE
      EE00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F6F6F600DDDCDA00BDBBB900CAC8C700D9D7D600D6D5
      D400FBFBFB00F4F4F300FEFEFE00FEFDFD00FDFDFD00FEFEFE00FEFEFD00FEFE
      FE00FCFCFC00FDFDFD00FEFEFE0000000000F4F4F400E5E5E500F9F9F9000000
      0000E1E0DF00C5C3C100EFEEEE00000000000000000000000000000000000000
      00000000000000000000F6F6F600DDDCDA00BDBBB900CAC8C700D9D7D600D6D5
      D400FBFBFB00F4F4F300FEFEFE00FEFDFD00FDFDFD00FEFEFE00FEFEFD00FEFE
      FE00FCFCFC00FDFDFD00FEFEFE0000000000F4F4F400E5E5E500F9F9F9000000
      0000E1E0DF00C5C3C100EFEEEE0000000000000000000000000000000000DFF7
      FF00BEF0FF0091B1F9007D93F6009DC0FB00494AF1004D77F500A2EFFE00A2F5
      FE00BCF9FE00B7F8FE00B6F8FE00B5F6FE00B0F5FE00AAF4FE00A8F3FE00A3F1
      FE0099EDFE009AE5FD00507FF6007679F500AED1FC009EB6FA00ABCBFC00BEF0
      FF00000000000000000000000000000000000000000000000000000000000000
      0000E2E1E100000000000000000000000000000000000000000000000000FDFD
      FD00FDFDFD0000000000FDFDFD0000000000E0DFDF00D5D4D300FEFEFE000000
      000000000000F9F9F900FEFEFE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FCFCFC00DEDDDC00C9C7C500ECEBEB00E9E8E900DEDDDD00D4D3
      D200E9E9E800F8F7F700EAE9E800EEEEED00F3F3F200F2F2F100F7F6F600F8F8
      F700FEFEFF00FEFEFE00FEFEFE0000000000F9F9F900F8F8F800FDFDFD00D8D7
      D600F6F6F500ECEBEB00C9C7C600FBFAFA000000000000000000000000000000
      000000000000FCFCFC00DEDDDC00C9C7C500ECEBEB00E9E8E900DEDDDD00D4D3
      D200E9E9E800F8F7F700EAE9E800EEEEED00F3F3F200F2F2F100F7F6F600F8F8
      F700FEFEFF00FEFEFE00FEFEFE0000000000F9F9F900F8F8F800FDFDFD00D8D7
      D600F6F6F500ECEBEB00C9C7C600FBFAFA00000000000000000000000000FDFF
      FF00EBFAFF00BEEEFF00BEF0FF00A7CFFC004440EE00494AF2004566F40091DC
      FC00AFF9FE00C2FCFE00BEFBFE00BCFBFE00BCFAFE00B6F8FE00B5F7FE00A9F4
      FE0089D5FD004D70F5006F72F5007875F300B2DAFD00BEF0FF00C8F1FF00ECFA
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FCFCFC0000000000FBFBFB0000000000000000000000000000000000FCFC
      FC00A7A5A4009A989600B1AFAD00F9F9F9000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F1F1F100C8C6C500DEDDDC00FAF9F900FBFBFB00F7F7
      F800C2C1BF00E1E1E00000000000FEFEFE00FDFDFD00FEFEFE00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE0000000000FBFBFB00E2E2E100CFCECC00BFBD
      BB00FAFAFA00FBFBFA00E1E1E000E8E7E6000000000000000000000000000000
      00000000000000000000F1F1F100C8C6C500DEDDDC00FAF9F900FBFBFB00F7F7
      F800C2C1BF00E1E1E00000000000FEFEFE00FDFDFD00FEFEFE00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE0000000000FBFBFB00E2E2E100CFCECC00BFBD
      BB00FAFAFA00FBFBFA00E1E1E000E8E7E6000000000000000000000000000000
      000000000000D3F5FF00BEEEFF007A8FF600A8D0FC009DC0FB004440EF00404C
      F10090DCFC00ABF4FE00A9F7FE00A9F7FE00A9F7FE00AAF6FE00AAF0FE008CD7
      FC00505FF2006C6AF200AACEFC00B1DAFD009BB1F900C5F0FF00D0F4FF00DCF7
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000FDFDFD00E1E0E000CCCBCA00C9C8C700DDDCDB00FDFDFD000000
      0000000000000000000000000000000000000000000000000000EBEAEA00AEAD
      AB00A5A3A2009E9C9B00B4B2B100F0F0F000FCFCFC0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F7F7F600D5D4D200D6D5D300E8E7E600F3F2
      F200D9D7D600BEBCBA00CDCBCA00DDDCDB00D1D0CF00E5E4E30000000000FEFE
      FE00FEFEFE00FEFEFE00FEFEFE0000000000CECDCB00D2D0CE00D9D7D600EAEA
      E900FEFEFE0000000000CDCCCA00F0F0EF000000000000000000000000000000
      0000000000000000000000000000F7F7F600D5D4D200D6D5D300E8E7E600F3F2
      F200D9D7D600BEBCBA00CDCBCA00DDDCDB00D1D0CF00E5E4E30000000000FEFE
      FE00FEFEFE00FEFEFE00FEFEFE0000000000CECDCB00D2D0CE00D9D7D600EAEA
      E900FEFEFE0000000000CDCCCA00F0F0EF000000000000000000000000000000
      0000F6FDFF00CBF3FF00C3ECFE00BEEEFF00BEF0FF007D92F600788AF60088A1
      F800434BF000425BF300537BF5005F8CF7005F8BF700547BF6004661F4005059
      F20098B2F9008EA2F80096ACF800BEF0FF00C0EFFF00E4F5FF00FDFFFF00E9FA
      FF00000000000000000000000000000000000000000000000000000000000000
      0000D1D0CF00AFAEAC009A9896009B999700E7E7E700C8C7C600A9A8A600F5F5
      F50000000000000000000000000000000000FEFEFE00CFCFCE009C9A9800B5B4
      B300E7E6E600000000000000000000000000FEFEFE0000000000FAFAFA000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FBFBFB00F8F8F800E0DE
      DE0000000000E7E7E600CFCDCC00CBCAC800C7C6C400C4C2C000E9E9E8000000
      0000D7D6D500EAE9E800FAFAFA00CBC9C700CDCBCA00F7F7F70000000000FDFD
      FD00FCFCFC00D2D0D000D0CFCD00FDFDFD000000000000000000000000000000
      00000000000000000000000000000000000000000000FBFBFB00F8F8F800E0DE
      DE0000000000E7E7E600CFCDCC00CBCAC800C7C6C400C4C2C000E9E9E8000000
      0000D7D6D500EAE9E800FAFAFA00CBC9C700CDCBCA00F7F7F70000000000FDFD
      FD00FCFCFC00D2D0D000D0CFCD00FDFDFD000000000000000000000000000000
      00000000000000000000F3FCFF00D8F6FF00C4EFFF0092B2F900BEF0FF0097B6
      FA00A3C9FC004B47EF006E79F5005656F2005A5AF2007580F5005C58F100A9CF
      FC00A2C3FB00BEF0FF00A2C2FB00C7F0FF00FAFEFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D9D9D800B5B4B300AFAEAC00CBCAC900CECDCC00B5B3B1009A989600E4E4
      E30000000000000000000000000000000000C3C2C100A5A4A2009C9A9800CFCE
      CD00000000000000000000000000000000000000000000000000F4F4F400F1F1
      F100000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FAF9
      F900D4D2D200FBFBFB0000000000FCFCFC00FBFBFB00D9D8D600BEBCBA00C5C3
      C100C2C0BE00C2C0BE00C0BEBC00C4C2C000F0F0EE0000000000FDFDFD00FCFC
      FC00E5E5E500D3D2D100F7F6F600000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FAF9
      F900D4D2D200FBFBFB0000000000FCFCFC00FBFBFB00D9D8D600BEBCBA00C5C3
      C100C2C0BE00C2C0BE00C0BEBC00C4C2C000F0F0EE0000000000FDFDFD00FCFC
      FC00E5E5E500D3D2D100F7F6F600000000000000000000000000000000000000
      0000000000000000000000000000FAFEFF00CBF2FF00D1F4FF00C8F2FF008FAB
      F900BEF0FF005C62F200BCECFF00849BF800869CF800BCEDFF006A70F300BEF0
      FF009CBAFA00BEF0FF00BEF0FF00BEEFFF00FCFEFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000B9B7B600EAE9E90000000000000000000000000000000000EBEBEA00FCFC
      FC0000000000000000000000000000000000BFBEBC00B4B2B000EBEAEA000000
      000000000000000000000000000000000000000000000000000000000000FCFC
      FC00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DDDCDB00C9C7C600F0EFEF00FEFFFF00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE0000000000FBFCFB00E3E3E200D0CE
      CD00E9E9E800FEFEFE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DDDCDB00C9C7C600F0EFEF00FEFFFF00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE0000000000FBFCFB00E3E3E200D0CE
      CD00E9E9E800FEFEFE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E3F8FF00F2FC
      FF00D3F5FF00D1F2FF00BFF0FF00CAEDFE00BAEAFF00C2F0FF00BEEEFF00E5F9
      FF00CDF3FF00FCFEFF00F9FEFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E0DFDF00C6C4C200C5C3C100C1BF
      BC00F1F1F00000000000F2F1F100F8F8F80000000000D4D2D000D3D1D000E6E6
      E500FFFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E0DFDF00C6C4C200C5C3C100C1BF
      BC00F1F1F00000000000F2F1F100F8F8F80000000000D4D2D000D3D1D000E6E6
      E500FFFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E8F9FF0000000000FBFEFF0000000000ECFAFF00C9F2FF00F1FCFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00F6F6F600F1F0
      F000CAC8C700C8C6C400C1BFBD00C2C0BF00C1BFBE00CAC8C600F5F5F5000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00F6F6F600F1F0
      F000CAC8C700C8C6C400C1BFBD00C2C0BF00C1BFBE00CAC8C600F5F5F5000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F2FCFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FDFDFD00D1D1D100000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E9E8E700E1E0DF00F4F4F300F6F6F600F2F2F200FCFCFC00000000000000
      000000000000000000000000000000000000FDFDFD00D1D1D100000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E9E8E700E1E0DF00F4F4F300F6F6F600F2F2F200FCFCFC00000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D1D1D1000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D1D1D1000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FBFEFB00F9FDF800C9F0C700BDECBB00ECFAEB0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F2F2
      FE00000000000000000000000000E9E9E900B2B1B10000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F0F9F2004CCC46003EC75A0046CB650059D15F0095E09700FDFDFD000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000EBDBDB00F4EBEB000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E0DFDF00BAB9B700B5B4B200DDDCDB00FDFDFD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00009998F8000000000000000000FEFEFE0081808000B9B8B800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00004FCC4D0055D388009CE4C50041CC780051D484005ED97F0052CE4D00F8F8
      F800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EEE0E000BF8B8A00BC868500E9D8D800FFFEFE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EEEEED00BEBDBB00A9A7A600B4B2B100A7A6A400C5C4C200000000000000
      0000000000000000000000000000000000000000000000000000E9E8E800ADAC
      AA000000000000000000000000000000000000000000D9D8D700B8B7B500E6E6
      E500000000000000000000000000000000000000000000000000000000000000
      00003935EE004440EF00000000000000000000000000C4C4C4007D7C7C000000
      0000000000000000000000000000000000000000000000000000000000000000
      00006AD267002DC0630074D9A3004ED183005BD88C006EE19B0074E3910080CA
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000DAF4DA0056CE5F003FC7
      5E0049CF54009ED8A30000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DBBE
      BD00CEA7A600D6B5B400C89B9A00D2AEAD00E5D0CF00D9BAB900BA828100CA9F
      9E0000000000000000000000000000000000000000000000000000000000FEFE
      FE00C0BFBE00F0EFEF00000000000000000000000000EBEAEA00A09E9C000000
      00000000000000000000000000000000000000000000BFBEBD00C8C7C6000000
      0000000000000000000000000000000000000000000000000000F4F3F300CBCA
      C900000000000000000000000000000000000000000000000000000000000000
      00008381F6002832F7009191F70000000000000000000000000075737300D0D0
      D000000000000000000000000000000000000000000000000000000000000000
      0000F4FCF3005CCF5C003BC973004DD2810060DB900073E49F0085EDAB0056CC
      5300000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000EEFAED007ED9840051CB800099E3
      C40043CE7D0051D36D0075DF6E00DDE8DD000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DBBF
      BE00B67C7B00B9818000B3767400AD6B6A00D1ADAC00AB686700B9807F00D3B0
      AF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000A9A7
      A500000000000000000000000000EBEBEA009F9D9B00EFEFEF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000B8B7B5000000000000000000000000000000000000000000000000000000
      0000DDDCFC003F43F4003C40F400E2E1FD000000000000000000C5C4C4008281
      8100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000053CC530055D6860069DF97007CE8A6008FF1B40065D1
      6700000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000EAF9EA006DD577005DD08B00B4EB
      DA0047CF7C0060DC900061E17600ACC7AC000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D6B6B500B0717000AE6E6C00BF8B8A00AD6B6A00CEA7A600D8B9B800F9F5
      F400000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FBFB
      FB00CAC8C700D4D3D300B8B7B500C4C3C2000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F5F5F5000000000000000000000000000000000000000000000000000000
      0000000000004341EF001D33FF00403CEF000000000000000000FBFBFB005A58
      5800000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F1F9F10056CE57006EE19B0081EAA90094F3B80074DB
      7E00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FCFEFB00B5E9B40044C662005AD0
      92004CD2800067DF9A0065E27D0091C48E00FDFEFD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D0ABAA00BA838200AE6C6B00B87F7E00B87E7D00CBA1A000E6D1D100FDFB
      FA00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E7E7E600DEDDDD00F4F3F300000000000000000000000000000000000000
      0000CDCCCB00A4A2A0009E9C9A00C9C8C700F3F2F20000000000000000000000
      0000000000000000000000000000000000000000000000000000FAF9FF00FDFD
      FF00FDFDFF00A1A0F7003537F2002636FB008B8AF70000000000000000007F7E
      7E00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D6F4D70064D56F0086EDAD0099F6BC0092F2
      A700FDFDFD000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E7F8E50077D67F0037C3
      690055D687006BE19B0074E7950081D38400DEE5DE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E9D7
      D70000000000000000000000000000000000000000000000000000000000E0C7
      C600B67C7B00B8807E00B57A7800B3757400C4959400AD6B6A00C2929000D3B0
      B000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000EFEEEE00E8E7E700F0EFEF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000ECEC
      EC00E4E4E300FDFDFD0000000000E8E7E700BAB8B700C6C5C400000000000000
      00000000000000000000000000000000000000000000000000008785F5003B37
      EE003E3AEF003D39EF003D3EF2002A40FF003E42F400DDDCFC00000000009A99
      990000000000000000000000000000000000C9F0C700BDECBB00CCF1CB00F6FC
      F60000000000000000000000000000000000B8ECB80079E08A009DF8BF009BF7
      B400EBEBEB000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EFFAEF0088D8
      91005EDA910072E49F0087EFAE0074E38100B6CAB40000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EEE1E100B57A
      7900EEE1E100000000000000000000000000000000000000000000000000DABC
      BC00C89C9B00BE898800C89C9B00D9BBBA00D6B6B500CBA1A000AC6A6800CCA4
      A300000000000000000000000000000000000000000000000000000000000000
      0000DEDDDC00A7A6A400C0BEBD00C9C8C700BEBDBB00AFADAC00F5F4F4000000
      0000000000000000000000000000000000000000000000000000D8D7D600C3C2
      C1000000000000000000000000000000000000000000EAEAE900A19F9D00D5D5
      D400000000000000000000000000000000000000000000000000DDDCFC006666
      F4006373FF004D5EFF003D50FF003A4DFF00263CFF003C38EF00FEFEFF00A4A3
      A30000000000000000000000000070D573004BCA640039C65B0050CE67005BD0
      5B00000000000000000000000000000000000000000094DF930096F0AC00A9FE
      C700DEDEDE000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D8E0
      D80060DB8B0077E5A4008FF2B70076ED8500A4C0A30000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFEFE00F0E5E500DFC5C500F8F2F100EFE3E200B57A
      7800ECDDDC00EBDBDB00E4CECE00FBF8F800FDFBFA0000000000000000000000
      0000EEE0E000EFE2E100BC868500B57A7900E9D7D700FCF9F900DDC2C200F5EC
      EC0000000000000000000000000000000000000000000000000000000000FEFE
      FE00D5D4D300FCFCFC00000000000000000000000000F9F9F800B6B5B300FDFD
      FD0000000000000000000000000000000000F5F4F400A9A7A600DBDADA000000
      0000000000000000000000000000000000000000000000000000FEFEFE00DDDD
      DC00000000000000000000000000000000000000000000000000000000004E4A
      F0007381FF005967FD003732ED00413DEF003E39EF003C38EF00BBBAF9009998
      98000000000000000000A9E6A70032C15C00A0E5C80060D292003FCB760051D4
      8400AFE5AD0000000000000000000000000000000000000000006BD56700A9FC
      C500CFD3CF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000059D469007BE8A70097F6C0007BEE8C0098C6960000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FBF8F800D3AFAE00A9636200C99E9D00DCC0BF00CDA5
      A400C18F8D00C99E9D00B77D7B00D7B7B6000000000000000000000000000000
      000000000000F2E7E700BC868500B67B7A00EADAD90000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000B4B3B100C0BFBE00A19F9D00D8D7D6000000000000000000000000000000
      000000000000FBFBFB00F9F9F800000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F5F5
      FE00A5AFFF008592FF006470FD006B69F3000000000000000000F7F7F7005957
      57000000000000000000DAF5D90057CB650053CE88005ED2910048CF7D005BD8
      8C0059CE5900DDE4DD0000000000000000000000000000000000000000000000
      0000A9D6A8000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000B1E8AE007FE68F009FFCBB0087D38800DCE2DB00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FDFCFC00EBDBDB00CBA2A100BA838100B67C
      7B00BC868400CBA2A100F3E9E800FEFDFD000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F6F6F600EEEEED00FEFEFE00000000000000000000000000000000000000
      0000B9B8B600A9A7A600AFADAC00B4B2B100E3E3E20000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000969EFD00A5AFFF007D8BFF005252F300E7E6FD0000000000B8B8B8008E8D
      8D0000000000000000000000000099E1970045C66B003BC973004DD2810060DB
      90006CDC7D00AFD4AD00FBFBFB00FBFBFB00F9F9F90000000000000000000000
      0000FBFBFB00F2F1F20000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FEFEFE00FEFE
      FE0000000000F4FCF400A5E4A40089EE9A0083E38C00C4D2C40000000000FCFC
      FC00FDFDFD00FDFDFD00FDFDFD0000000000FEFEFE00FEFEFE00FAFAFA00F9F9
      FA00FEFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F6EFEF00DBBFBE00CAA09F00B4777600BA83
      8100B4787700CFA8A700DDBFBF00FAF7F70000000000FEFEFE00FDFDFD00FCFC
      FC00FDFDFD00FDFDFD00FDFDFD0000000000FEFEFE00FEFEFE00FAFAFA00F9F9
      FA00FEFEFE000000000000000000000000000000000000000000000000000000
      000000000000FDFDFD00DFDEDD00D6D5D500E0DFDE0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DCDB
      DA00F3F3F3000000000000000000F6F6F600CFCECD00B1AFAD00FAFAFA000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007172F600A5AFFF009DA7FF006C77FC007674F400FAFAFA0066646400E2E1
      E10000000000000000000000000000000000B2E5B7004BCC630056D6880069DF
      970084EBA20078CC7600F6F6F600000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FCFC
      FC00E1E1E000E7E6E600F3F2F20000000000FAFAFA00EAEAE900D2D0CF00D0CE
      CD0000000000EEEDEE00D2D7D0008CCE8C005DD45E00B3D1B100F4F3F400F7F7
      F700C9C8C600C6C5C200DBDAD900EFEFEF00F8F8F800D5D4D400C7C6C400C2C0
      BF00E8E7E700FDFDFD000000000000000000000000000000000000000000FCFC
      FC00E1E1E000E6E6E600F2EFEF00DABCBB00B2747300AB706E00BA9796009F57
      5500BB868400BC888600A86B6900B2929100C6C5C200DFDEDD00F4F4F400F6F6
      F600C9C8C600C6C5C200DBDAD900EFEFEF00F8F8F800D5D4D400C7C6C400C2C0
      BF00E8E7E700FDFDFD0000000000000000000000000000000000000000000000
      0000CBCAC900A5A4A200D4D3D200DDDCDB00D3D2D1009E9C9A00E6E6E5000000
      00000000000000000000000000000000000000000000FDFDFD00C4C3C200D7D6
      D5000000000000000000000000000000000000000000F8F8F800ABAAA800C1C0
      BF00000000000000000000000000000000000000000000000000000000000000
      00003B37EE00A5AFFF00A5AFFF0095A0FF005150F2009B9AA2009A9999000000
      000000000000000000000000000000000000FEFEFE0086DA8A0059D57C006EE1
      9B008FF1B10062CE6000F3F3F300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F4F4F400CDCB
      CB00CAC8C700D4D3D100CDCCCA00D0CFCE00D0CFCE00C5C3C100DAD8D700E7E7
      E600C9C8C700C5C4C200CDCCCA00FAEFF90096E493007EC17800CEC4CB00C5C3
      C200E6E4E400E9E8E700D3D2D000C7C6C500C2C1BF00D4D2D100ECECEC00F0F0
      F000C1BFBD00E4E3E300FEFEFE00000000000000000000000000F4F4F400CDCB
      CB00CAC8C700D5D4D300CAC3C100B5908E00A9737100B6989600CCBBB900BF94
      9200BA9D9C00B18C8C00AE7F7D00D2B4B300F4F0F000D8D8D700C5C4C300C5C3
      C100E6E4E400E9E8E700D3D2D000C7C6C500C2C1BF00D4D2D100ECECEC00F0F0
      F000C1BFBD00E4E3E300FEFEFE0000000000000000000000000000000000FDFD
      FD00E6E6E5000000000000000000000000000000000000000000CCCAC900F2F1
      F10000000000000000000000000000000000E6E6E500A4A2A000ECEBEB000000
      000000000000000000000000000000000000000000000000000000000000EEED
      ED00F9F9F9000000000000000000000000000000000000000000000000000000
      00009B99F7004F4DF1009CA5FE00A5AFFF006F75CF0057556C00F8F8F8000000
      000000000000000000000000000000000000000000000000000068D3680070E2
      970099F6BC005ACF5800E6EBE600000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F1F0F000C4C3C100C6C4
      C200F9F9F900F9F8F700F9F9F900EFEFEF00D3D2D100FDFDFE00F8F8F800F9F9
      F900DDDCDB00DCDBD90000000000F6F8F600E2F2E100E7F2E700D6D3D400E4E3
      E300F9F9F900F9F9F900FAF9FA00D3D1CF00F1F0F000FAFBFB00F8F8F800F8F8
      F800D3D1D000C4C2C000F6F6F6000000000000000000F1F0F000C4C3C100C6C4
      C200F9F9F900F9F8F700FAFAF900EDE9E900CBBEBD0000000000EADEDE00B982
      8100D0C1BF00D7D3D100F6EDED00F9F9F900F8F8F80000000000DAD9D800E3E2
      E100F9F9F900F9F9F900FAF9FA00D3D1CF00F1F0F000FAFBFB00F8F8F800F8F8
      F800D3D1D000C4C2C000F6F6F600000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000BBBA
      B9000000000000000000FAFAFA00C7C6C500CCCAC90000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000B0AFAD000000000000000000000000000000000000000000000000000000
      0000D5D4FB004743EF005F5CF100413CDB00525066004C4ADB00F2F2FE000000
      0000000000000000000000000000000000000000000000000000000000004ECD
      49009DF8BF0068D56A00CCDACC00FCFCFC000000000000000000000000000000
      000000000000000000000000000000000000FDFDFD00CAC8C600DDDCDB00F8F8
      F700F7F7F700F7F7F700F7F7F700F8F8F800FBFBFB00F9F9F900F9F9F900F9F9
      F900F9F9F900FAFAFA00F7F7F700F7F7F700F7F7F700F7F7F700FAFAFA00FAFA
      FA00F7F7F700F7F7F700F7F7F700FAFAFA00F8F8F800F7F7F700F7F7F700F7F7
      F700FCFCFC00C7C5C300D5D4D300FEFEFE00FDFDFD00CAC8C600DDDCDB00F8F8
      F700F7F7F700F7F7F700F7F7F700F8F8F800FBFBFB00FBFDFD00EBDEDE00BC88
      8600E6D5D500FEFFFF00F7F7F700F7F7F700F7F7F700F7F7F700FAFAFA00FAFA
      FA00F7F7F700F7F7F700F7F7F700FAFAFA00F8F8F800F7F7F700F7F7F700F7F7
      F700FCFCFC00C7C5C300D5D4D300FEFEFE000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00009D9B9900AAA9A700ABAAA800E9E9E8000000000000000000000000000000
      0000C6C5C400ACABA900ABA9A800C2C1C000EBEAEA0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000D2D0F4005F5BF2008C89F5000000
      000000000000000000000000000000000000000000000000000000000000F2FB
      F200A6FCC60080E48C00ABD0A900F9F9FA000000000000000000000000000000
      00000000000000000000000000000000000000000000EAEAEA00D3D1CF00FDFD
      FD00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800FAFAFA00FDFDFD00FDFD
      FD00FBFBFB00FAFAFA00FAFAFA00F9F9F900F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800FCFCFB00CFCDCC00FAFAFA0000000000EAEAEA00D3D1CF00FDFD
      FD00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800FAFAFA0000000000F3EA
      EA00FEFFFF00FAFAFA00FAFAFA00F9F9F900F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800FCFCFB00CFCDCC00FAFAFA000000000000000000000000000000
      000000000000FDFDFD00EEEEEE00E6E6E500F2F2F10000000000000000000000
      000000000000FBFBFA0000000000000000000000000000000000FEFEFE00D3D2
      D100AFAEAC009A9896009C9A9800BEBCBB009A989600BBBAB800F2F2F2000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000EDEDFD00EFEFFE000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084E08A0092F2A7008ACD8A00F7F7F7000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00E6E5E500C7C5
      C300FFFFFE00F9F7F800FAF9F900FCFCFC00FCFCFC00F9F9F900F0F0F000FDFD
      FD00F6F6F600F9F9F900F9F9F900FBFBFB00FDFDFD00FEFEFE00FCFCFC00FBFB
      FB00FAFAFA00FAFAFA00F9F9F900F9F9F900F9F9F900F9F9F900F9F9F900F9F9
      F900F9F9F900FBFBFB00C8C7C500FCFCFC0000000000FDFDFD00E6E5E500C7C5
      C300FFFFFE00F9F7F800FAF9F900FCFCFC00FCFCFC00F9F9F900F0F0F000FDFD
      FD00F6F6F600F9F9F900F9F9F900FBFBFB00FDFDFD00FEFEFE00FCFCFC00FBFB
      FB00FAFAFA00FAFAFA00F9F9F900F9F9F900F9F9F900F9F9F900F9F9F900F9F9
      F900F9F9F900FBFBFB00C8C7C500FCFCFC00000000000000000000000000D3D2
      D1009A989600B9B8B700A2A09E00A4A2A000C2C1C000A6A5A3009E9C9A00E1E0
      E00000000000000000000000000000000000DFDEDD00A19F9D00B9B8B600A19F
      9D0000000000000000000000000000000000EDECEC00B4B3B1009F9D9B009A98
      9600E1E0E0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFEFE000000
      000000000000F9FBFA0050CD4B00F7F7F7000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FCFCFC00E0DFDF00D2D0CE0000000000FAFAFA00FAFAFA00FCFC
      FC00F5F5F500EBEBEB00E8E8E800E8E8E800F5F5F50000000000FEFEFE00FDFD
      FD00FEFEFE00FEFEFE00FDFDFD00FCFCFC00FCFCFC00FBFBFB00FAFAFA00FBFB
      FB0000000000C5C4C200E7E6E600FFFEFE000000000000000000000000000000
      000000000000FCFCFC00E0DFDF00D2D0CE0000000000FAFAFA00FAFAFA00FCFC
      FC00F5F5F500EBEBEB00E8E8E800E8E8E800F5F5F50000000000FEFEFE00FDFD
      FD00FEFEFE00FEFEFE00FDFDFD00FCFCFC00FCFCFC00FBFBFB00FAFAFA00FBFB
      FB0000000000C5C4C200E7E6E600FFFEFE00000000000000000000000000A6A4
      A200B2B0AF00DEDDDC00FCFCFC0000000000F6F6F600BEBCBB009A989600BFBE
      BD000000000000000000F6F6F600BFBEBD009F9E9C009A989600B3B2B000F4F4
      F400000000000000000000000000000000000000000000000000DCDBDB00A5A3
      A2009A989600C4C2C10000000000000000000000000000000000000000000000
      0000000000000000000000000000FAFAFA00E0E0DF00D5D4D200D8D6D500E7E6
      E600DDDCDB00CBC9C800CBC9C700DDDCDB00EDECEC00CDCBCA00C0BEBC00C7C5
      C300EEEEEE00D2D1D000C5C3C200BFBDBC00DCDBDA00EEEEED00D3D2D100C7C6
      C400D3D2D000F4F3F30000000000000000000000000000000000000000000000
      00000000000000000000E9E9E900D0CECD00D2D0CF00FFFFFE00FBFBFB00FEFE
      FE00FCFCFC00FCFCFC00F9F9F900EEEEEE00F1F1F100FBFBFB00FDFDFD00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FDFDFD00FDFDFD00FDFDFD00F9F9F900FBFC
      FC00C5C3C100D9D8D700FEFDFD00000000000000000000000000000000000000
      00000000000000000000E9E9E900D0CECD00D2D0CF00FFFFFE00FBFBFB00FEFE
      FE00FCFCFC00FCFCFC00F9F9F900EEEEEE00F1F1F100FBFBFB00FDFDFD00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FDFDFD00FDFDFD00FDFDFD00F9F9F900FBFC
      FC00C5C3C100D9D8D700FEFDFD0000000000000000000000000000000000E4E4
      E300000000000000000000000000000000000000000000000000C7C6C500B2B1
      AF00B4B2B100B7B5B4009D9B9900A6A4A300A5A3A100CDCCCB00FEFEFE000000
      000000000000FDFDFD00FDFDFD0000000000000000000000000000000000FAFA
      FA009D9B9900AEACAB0000000000000000000000000000000000000000000000
      00000000000000000000E8E8E700C4C2C000C8C6C500EBEAE900F3F2F200E6E5
      E400D6D5D300F1F0F000FDFDFD00F1F1F000C1BFBD00DDDCDB00FEFEFE00F9F9
      F900C1BFBD00E6E5E500FEFEFE00FBFBFB00DCDBDB00C1BFBD00ECEBEB00FDFD
      FC00E6E5E400C4C2C000F1F1F000000000000000000000000000000000000000
      00000000000000000000F6F6F600DDDCDA00BDBBB900CAC8C700D9D7D600D6D5
      D400FBFBFB00F4F4F300FEFEFE00FEFDFD00FDFDFD00FEFEFE00FEFEFD00FEFE
      FE00FCFCFC00FDFDFD00FEFEFE0000000000F4F4F400E5E5E500F9F9F9000000
      0000E1E0DF00C5C3C100EFEEEE00000000000000000000000000000000000000
      00000000000000000000F6F6F600DDDCDA00BDBBB900CAC8C700D9D7D600D6D5
      D400FBFBFB00F4F4F300FEFEFE00FEFDFD00FDFDFD00FEFEFE00FEFEFD00FEFE
      FE00FCFCFC00FDFDFD00FEFEFE0000000000F4F4F400E5E5E500F9F9F9000000
      0000E1E0DF00C5C3C100EFEEEE00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000CFCE
      CD009C9A9800BBBAB9009A989600B0AEAD00EBEBEA0000000000000000000000
      0000B5B4B2009C9A98009C9A9800B3B2B000DAD9D800FEFEFE00000000000000
      0000F3F3F300F5F5F50000000000000000000000000000000000000000000000
      000000000000E8E8E700C1BFBD00E8E7E600F9F9F900F9F9F900F8F8F800F9F9
      F900F6F6F600F8F8F800F7F7F700F8F8F800FDFDFD00FCFCFC00FBFBFB00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FBFBFB00FBFAFA00FEFEFE00FBFBFB00FEFE
      FE00F9F9F900E9E8E800C8C6C500FCFCFC000000000000000000000000000000
      000000000000FCFCFC00DEDDDC00C9C7C500ECEBEB00E9E8E900DEDDDD00D4D3
      D200E9E9E800F8F7F700EAE9E800EEEEED00F3F3F200F2F2F100F7F6F600F8F8
      F700FEFEFF00FEFEFE00FEFEFE0000000000F9F9F900F8F8F800FDFDFD00D8D7
      D600F6F6F500ECEBEB00C9C7C600FBFAFA000000000000000000000000000000
      000000000000FCFCFC00DEDDDC00C9C7C500ECEBEB00E9E8E900DEDDDD00D4D3
      D200E9E9E800F8F7F700EAE9E800EEEEED00F3F3F200F2F2F100F7F6F600F8F8
      F700FEFEFF00FEFEFE00FEFEFE0000000000F9F9F900F8F8F800FDFDFD00D8D7
      D600F6F6F500ECEBEB00C9C7C600FBFAFA000000000000000000000000000000
      000000000000F4F4F400DDDCDC00D5D4D300E0DFDF00FBFBFA00000000000000
      0000D2D1D000D1D0CF00E9E9E800000000000000000000000000F9F9F900C2C0
      BF00B7B6B5009A9896009B999700B5B4B2009A989600ABA9A700E5E4E4000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FAFAFA00CCCBC900D4D3D200F5F4F400FAFAFA00F9F9F900FAFA
      FA00F8F8F800F8F8F800F8F8F800F9F9F900FCFBFB00F1F1F000F3F3F300F8F8
      F800F8F8F800F6F5F500FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FBFBFB00FAFAF900E0DFDE00E8E8E7000000000000000000000000000000
      00000000000000000000F1F1F100C8C6C500DEDDDC00FAF9F900FBFBFB00F7F7
      F800C2C1BF00E1E1E00000000000FEFEFE00FDFDFD00FEFEFE00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE0000000000FBFBFB00E2E2E100CFCECC00BFBD
      BB00FAFAFA00FBFBFA00E1E1E000E8E7E6000000000000000000000000000000
      00000000000000000000F1F1F100C8C6C500DEDDDC00FAF9F900FBFBFB00F7F7
      F800C2C1BF00E1E1E00000000000FEFEFE00FDFDFD00FEFEFE00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE0000000000FBFBFB00E2E2E100CFCECC00BFBD
      BB00FAFAFA00FBFBFA00E1E1E000E8E7E6000000000000000000000000000000
      0000B6B4B300C5C4C300A7A5A3009A989600BDBCBB00A7A5A300DDDCDC000000
      00000000000000000000000000000000000000000000E8E7E700A8A6A4009A98
      9600C5C3C200ECECEB00EDEDEC00CDCDCC00A19F9D00ACABA900A4A2A100BDBC
      BB00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FDFDFD00DDDCDB00D2D1CF00E4E3E200ECEBEB00FAFA
      F900FAFAFA00FBFBFB00FAFAFA00FEFEFE00F6F5F500FCFCFC00FCFCFC00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FCFCFC00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00CAC9C700F1F1F1000000000000000000000000000000
      0000000000000000000000000000F7F7F600D5D4D200D6D5D300E8E7E600F3F2
      F200D9D7D600BEBCBA00CDCBCA00DDDCDB00D1D0CF00E5E4E30000000000FEFE
      FE00FEFEFE00FEFEFE00FEFEFE0000000000CECDCB00D2D0CE00D9D7D600EAEA
      E900FEFEFE0000000000CDCCCA00F0F0EF000000000000000000000000000000
      0000000000000000000000000000F7F7F600D5D4D200D6D5D300E8E7E600F3F2
      F200D9D7D600BEBCBA00CDCBCA00DDDCDB00D1D0CF00E5E4E30000000000FEFE
      FE00FEFEFE00FEFEFE00FEFEFE0000000000CECDCB00D2D0CE00D9D7D600EAEA
      E900FEFEFE0000000000CDCCCA00F0F0EF00000000000000000000000000C3C2
      C0009A989600ACAAA900ACABA900B5B3B200BAB8B700A3A19F009A989600D2D1
      D000000000000000000000000000FEFEFE00CDCCCB009C9A9800B6B5B300ABA9
      A70000000000000000000000000000000000F8F8F800C5C4C2009E9C9A009A98
      9600CFCFCE00FCFCFC0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFE00F7F7F700F2F1F100C3C1
      BF00FCFCFC00F8F8F800FCFCFC00FDFDFD00FBFBFB00FEFEFE00FEFEFE00FCFC
      FC00EEEEEE00F6F6F600FBFBFB00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFD
      FD00FAFAFA00CFCDCC00D1CFCE00FFFEFE000000000000000000000000000000
      00000000000000000000000000000000000000000000FBFBFB00F8F8F800E0DE
      DE0000000000E7E7E600CFCDCC00CBCAC800C7C6C400C4C2C000E9E9E8000000
      0000D7D6D500EAE9E800FAFAFA00CBC9C700CDCBCA00F7F7F70000000000FDFD
      FD00FCFCFC00D2D0D000D0CFCD00FDFDFD000000000000000000000000000000
      00000000000000000000000000000000000000000000FBFBFB00F8F8F800E0DE
      DE0000000000E7E7E600CFCDCC00CBCAC800C7C6C400C4C2C000E9E9E8000000
      0000D7D6D500EAE9E800FAFAFA00CBC9C700CDCBCA00F7F7F70000000000FDFD
      FD00FCFCFC00D2D0D000D0CFCD00FDFDFD00000000000000000000000000A8A6
      A400C3C2C100EFEFEF000000000000000000FDFDFD00CFCECD009A989600CECD
      CC00FEFEFE0000000000E8E7E700B1AFAD00A3A19F009A989600C4C3C200FBFB
      FB00000000000000000000000000000000000000000000000000ECECEB00B2B1
      AF009A989600B7B6B40000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E6E6
      E500F0EFEF00FEFEFE00FCFCFC00FBFBFB00FDFDFD00FEFEFE00FCFCFC00FBFB
      FB00FBFBFB00FCFCFC00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFDFD00FCFC
      FC00E2E2E100D4D3D200F8F8F800000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FAF9
      F900D4D2D200FBFBFB0000000000FCFCFC00FBFBFB00D9D8D600BEBCBA00C5C3
      C100C2C0BE00C2C0BE00C0BEBC00C4C2C000F0F0EE0000000000FDFDFD00FCFC
      FC00E5E5E500D3D2D100F7F6F600000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FAF9
      F900D4D2D200FBFBFB0000000000FCFCFC00FBFBFB00D9D8D600BEBCBA00C5C3
      C100C2C0BE00C2C0BE00C0BEBC00C4C2C000F0F0EE0000000000FDFDFD00FCFC
      FC00E5E5E500D3D2D100F7F6F600000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DFDE
      DD009C9A9800B3B2B0009D9B9900C1C0BF00F7F7F60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FDFDFD00FDFDFD0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F8F8F800C6C4C200D9D7D700FEFEFE00FAFAFA00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00F8F8F700DEDDDC00CDCB
      CA00EEEDED000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DDDCDB00C9C7C600F0EFEF00FEFFFF00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE0000000000FBFCFB00E3E3E200D0CE
      CD00E9E9E800FEFEFE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DDDCDB00C9C7C600F0EFEF00FEFFFF00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE0000000000FBFCFB00E3E3E200D0CE
      CD00E9E9E800FEFEFE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E4E3E300E2E2E100F7F7F700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F7F7F600D0CFCD00C1BFBD00C6C4C200C1BF
      BD00FAFAFA00FDFCFC00F0EFEF00FCFCFC00FCFBFB00C9C7C500D8D6D500E9E9
      E800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E0DFDF00C6C4C200C5C3C100C1BF
      BC00F1F1F00000000000F2F1F100F8F8F80000000000D4D2D000D3D1D000E6E6
      E500FFFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E0DFDF00C6C4C200C5C3C100C1BF
      BC00F1F1F00000000000F2F1F100F8F8F80000000000D4D2D000D3D1D000E6E6
      E500FFFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FAF9F900F3F3F200E9E8
      E700CDCBCA00C4C2C000C1BFBD00C2C0BF00C1BFBD00D0CFCD00FCFCFC000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00F6F6F600F1F0
      F000CAC8C700C8C6C400C1BFBD00C2C0BF00C1BFBE00CAC8C600F5F5F5000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00F6F6F600F1F0
      F000CAC8C700C8C6C400C1BFBD00C2C0BF00C1BFBE00CAC8C600F5F5F5000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E3E2E100E5E4E400F9F9F900F4F4F300F4F3F300FFFEFE00000000000000
      000000000000000000000000000000000000FDFDFD00D1D1D100000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E9E8E700E1E0DF00F4F4F300F6F6F600F2F2F200FCFCFC00000000000000
      000000000000000000000000000000000000FDFDFD00D1D1D100000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E9E8E700E1E0DF00F4F4F300F6F6F600F2F2F200FCFCFC00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CFCFCF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F4FCFF00F9FEFF000000000000000000FCFEFF00FDFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F4FCFF00F9FEFF000000000000000000FCFEFF00FDFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FDF8EE00FAECD000FBEDD400FEF9
      F100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FDFF
      FF000000000000000000E7F9FF00C9F2FF00FBFEFF00D1F4FF00D1F4FF00ECFA
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FEFDFD00FAFAFA00000000000000000000000000FDFE
      FE00EEEDED00FBFBFB00E7F9FF00C9F1FE00E9EAEA00C9DBE000CCE3EA00EBF9
      FE00FBFBFB00EDECEC00ECEBEB00F9F9F9000000000000000000F7F6F600EAE9
      E800F9F9F9000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FEFBF500F9E6C200E8C28800E8C18700E8C18700F5D8
      9E00FEFCF7000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F2FC
      FF00ECFAFF00DEF6FF00E3F8FF00C1EEFF00E1F6FF00C0F0FF00C7F1FF00D8F6
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F3F3F200D3D2D000C2C0BE00C7C5C400C7C5C300D8D7D600E4E3E200C6C5
      C300D1CFCE00C7C6C500D2D9DA00C2C6C600CBC9C800DBDAD900D5D3D200C5C9
      C900C3C1BF00D1D0CE00D3D2D000C2C0BE00DBDAD900D3D1D000CAC9C700D6D5
      D300C3C1BF00E4E3E20000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFEFD00FDF7EA00FDF7EC00FFFEFD0000000000000000000000
      00000000000000000000F8E3BA00E8C18700D4A16700CD965C00D4A16700E8C1
      8700F8E2B8000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FAFEFF00DDF7FF00CDF3FF00BFF0FF00BEF0FF00ADCB
      FC00BEF0FF00A1A9F800BEEEFF00AFC7FB00B1C8FB00BEEEFF00ADB6FA00BEF0
      FF00BAD9FD00CCF3FF00C6F1FF00DBF6FF000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F1F0
      F000F8F8F800F6F6F600F9F9F900F8F8F800F8F8F800F9F9F900FBFBFB00FBFB
      FB00FCFCFC00FAFAFA00FBFBFB00F9F9F900F8F8F800F8F8F800F8F8F800F9F9
      F900F8F8F800F8F8F800F8F8F800F8F8F800FBFBFB00F9F9F900F8F8F800F8F8
      F800F9F9F900F9F9F900C3C1BF00F7F7F6000000000000000000000000000000
      0000000000000000000000000000FBFBFB00DCDBDA00C3C2C000E5E4E300EFEF
      EE00DBDADA00C7C6C400F0F0F000F7F7F700E2E1E000C8C6C400ECEBEB00FEFD
      FD00CECCCA00DCDBDA00FAFAF900F6F5F500DEDDDC00CAC8C600ECEBEB00FDFD
      FD00CFCDCC00E0DFDE0000000000000000000000000000000000000000000000
      0000E8C18700D4A16700CD965C00D4A16700E8C18700F5D79C00F9E6C2000000
      000000000000FFFDFB00F5D79C00E8C18700D4A16700CD965C00D4A16700E8C1
      8700F5D79C00FFFDFB0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D3F4FF00CCF3FF00BEEEFF00ABCCFC00BEF0FF00AFD0
      FC00B5DBFD009897F600A5B1F9009EA1F700A2A5F800ABB8F900A5A4F700BAE0
      FE00BADCFD00BEF0FF00BADBFD00CEF3FF00ECFAFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FAFAFA00F2F1
      F100C4C2C000F7F6F600F6F6F600FBFBFB00FAFAFA00FBFBFB00FAFAFA00FBFB
      FB00FAFAFA00FCFCFC00FDFDFD00FCFCFC00FCFCFC00FBFBFB00FBFBFB00FAFA
      FA00F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8F800F8F8
      F800F8F8F800FAF9F900DEDDDC00E5E4E3000000000000000000000000000000
      0000000000000000000000000000D2D1CF00F4F3F300FDFDFD00FAFAFA00F9F9
      F900F7F7F700FCFCFC00F9F9F900F9F9F900FAFAFA00FDFDFC00FDFDFD00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFDFD00FEFEFE00FEFE
      FE00F8F8F800C3C1BF00E4E3E200000000000000000000000000000000000000
      0000E8C18700CD965C00C0804700CD965C00E8C18700F5D79C00F5D79D00FEFC
      F8000000000000000000F7DEAE00F5D79C00E8C18700E8C18700E8C18700F5D7
      9C00F7E0B3000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E3F8FF00C8F2FF00C5EEFF00BEEFFF00BEF0FF009FB7FA009FB2F900A7C1
      FB00667BF4004C84F600439BF80040A7F80040A8F800449FF800518AF7007388
      F600B7D2FC00B7CCFB00B8D0FC00BEF0FF00C5F1FF00FDFDFF00000000000000
      00000000000000000000000000000000000000000000FDFCFC00EBEAE900EAE9
      E900E5E4E500D2D1D000D4D2D200DAD9D800E2E1E000FEFEFE00FBFBFB00FBFB
      FB00FBFBFB00FDFDFD00FEFEFE00F9F9F900EDEDED00EFEFEF00F3F3F300FAFA
      FA00FEFEFE00FEFEFE00FDFDFD00F9F9F900F9F9F900F9F9F900FAFAFA00FAFA
      FA00FAFAFA00F9F9F900CAC8C600F0F0EF000000000000000000000000000000
      0000000000000000000000000000FCFCFC00DFDDDD00DCDAD900FAFAFA00FCFC
      FC00F7F7F700F9F9F900FAFAFA00FCFCFC00FDFDFD00FCFCFC00F7F7F700FEFE
      FE00FCFCFC00FCFCFC00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FDFDFD00F6F5F500D8D7D600000000000000000000000000000000000000
      0000E8C18700D4A16700CD965C00D4A16700E8C18700F5D79C00F5D79C00FEFB
      F5000000000000000000FDF6E800F7DFB000F5D79C00F5D79C00F5D79C00F5D7
      9C00FDF8ED00000000000000000000000000FFFFFE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F5FDFF00C3F1FF00BEEFFF009AB1F900B3DBFD00AED1FC007F7DF4005A74
      F40040E3FD0046EDFE003BEAFE0035E9FE0034EBFE003BEEFE0045F2FE003DE7
      FE006A88F600A9A9F800BBDFFE00BCE5FE00B9D0FC00E6F9FF00EFFBFF000000
      00000000000000000000000000000000000000000000F9F9F800EEEDEC00EAE9
      E800EAE9E900ECECED00EEF1F200EBECF200E3E5E800C1BFBD00FAFAFA00FDFD
      FD00FEFEFE00FAFAFA00F9F9F900EBEBEB00E7E7E700E8E8E800FDFDFD00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFDFD00FCFCFC00FCFCFC00FCFC
      FC00FCFBFB00C9C8C600CECCCB00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00F3F2F200EEED
      ED00CFCECC00FDFDFD00FAFAFA00F8F8F800FEFEFE00FCFCFC00FEFEFE00FEFE
      FE00F6F6F600FAFAFA00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FCFCFC00C3C2C000F4F3F300000000000000000000000000000000000000
      0000F5D79C00E8C18700E8C18700E8C18700F5D79C00F5D79C00F6DBA600FFFF
      FE0000000000000000000000000000000000FEFAF300FBEFD700FBF0D900FEFB
      F4000000000000000000FEFAF100F8E4BD00F5D9A000F6DAA200F9E6C000FEFA
      F400000000000000000000000000000000000000000000000000000000000000
      0000E9F9FF00BDEEFF00BEF0FF00B1D9FD007A78F3007679F5004480F60049E1
      FD0029DCFE0021DBFE001FDEFE001EDEFE001DDFFE001CE1FE001BE3FE0021EA
      FE0044E8FE004B8FF7009FA4F900B1B1F800BCE4FE00BEF0FF00BFEFFF00F7FD
      FF00FDFFFF0000000000000000000000000000000000FBFBFB00F2F2F100EEED
      ED00EAE9E800E9E9EA00E9ECED00EAEDF100E4E3F300CFCDD400C3C1C000F6F6
      F600F9F9F900FCFCFC00F7F7F700FEFEFE00FEFEFE00FAFAFA00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00F6F6F600FDFD
      FD00C4C2C000D3D2D000F9F8F800000000000000000000000000F0EFEF00DAD9
      D700D2D1D000D9D7D700E8E7E600EDEDEC00D5D3D200CAC9C700D1D0CE00D5D4
      D300CAC8C600DAD9D800F4F4F400F2F1F100F7F7F600FCFCFC00FDFDFD00FEFE
      FE00FDFDFD00FDFDFD00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFD
      FD00D7D5D400F8F8F80000000000000000000000000000000000000000000000
      0000F6D9A100F5D79C00F5D79C00F5D79C00F5D79C00F5D9A100FBF0D9000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FBEFD700F5D89E00E8C18700E8C18700E8C18700F5D79C00F5D8
      9F0000000000000000000000000000000000000000000000000000000000F4FC
      FF00C9F2FF00A3C4FB0096ADF800AACDFC007073F500428AF60055E6FE0035DA
      FE0028D7FE0027D9FE0024DBFE0023DBFE0021DEFE0020DEFE001FDFFE001DE2
      FE002AEBFE0051F1FD00459AF8009FA4F900BBDFFE00B7D0FC00BADCFD00C3F1
      FF00F4FCFF000000000000000000000000000000000000000000F6F6F500F2F2
      F100EBEAE900E8E8E900E5E6EA00E5E7EC00DFDFF000D6E1F300CEDEDF00C4C9
      C900C7C6C400CBC9C800FDFDFC00F5F4F400F5F5F400F9F9F900F7F7F700FEFE
      FE00F9F9F900FEFEFE00FEFEFE00FDFDFD00FEFEFE00F0F0F000F0F0F000FDFD
      FD00D5D6D600000000000000000000000000F6F5F500D1CFCE00C6C4C200E9E8
      E800F8F8F800F9F9F900FDFDFD00D9D8D700F8F7F700FAFAF900F8F8F800F6F6
      F500DBD9D900F7F7F700F0F0EF00E1E0DF00DBD9D800F7F6F600FBFBFB00FBFB
      FA00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00EDEDEC00EAE9E800D9D8
      D600D8D6D5000000000000000000000000000000000000000000000000000000
      0000FEFCF800FBF0DB00F8E5BE00F8E5BE00FBF0DA00FEFCF700000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFE00F6DCA800E8C18700D4A16700CD965C00D4A16700E8C18700F5D7
      9C00FFFEFD00000000000000000000000000000000000000000000000000F2FC
      FF00BEF0FF00BEF0FF008FA4F8006E6CF200447AF5005DE6FE0039D6FE0032D4
      FE002ED6FE002DD7FE002AD9FE0029D9FE0027DBFE0024DDFE0023DEFE0022DF
      FE001FE2FE0027E7FE0058F0FD004D8DF700A9A9F800B6CCFC00BEF0FF00C3F1
      FF0000000000000000000000000000000000000000000000000000000000F3F8
      F800F0EFEF00EBEAEA00E7E7E900E2E1EA00DBDFEC00DCEDF100D5EEF400D0F0
      F800CAEDF600C2C6C600DAD9D800FCFCFC00FDFDFD00FEFEFE00FDFDFD00FBFB
      FB00FDFDFD00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FCFCFC00F3F2F200DBDA
      D900F1F0F000000000000000000000000000DFDEDD00C1BFBD00F5F5F500FAFA
      FA00F8F8F800F8F8F800F8F8F800FBFBFB00FBFBFB00FDFDFD00FDFDFD00FDFD
      FD00FCFCFC00F9F9F900F9F9F900F9F9F900EFEFEE00D6D5D300CFCDCC00CECC
      CC00FDFDFD00FDFDFD00E7E7E600F7F7F700F5F4F400C2C0BE00E3E2E100EDED
      EC00C2C0BE00E3E2E10000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FEFDFA00F5D79C00E8C18700CD965C00C0804700CD965C00E8C18700F5D7
      9C00FEFDFA00000000000000000000000000000000000000000000000000FEFF
      FF009CBBFA00A3C4FB0098B3F9004E64F3005ADAFD0044D7FE003BD4FE0038D4
      FE0036D5FE0033D6FE0031D8FE0030D8FE002DD9FE002BDBFE002ADCFE0026DD
      FE0024DFFE0022E1FE0032E9FE0053E4FD006987F600B7D2FC00BADCFD00B9D9
      FD0000000000000000000000000000000000000000000000000000000000FEFF
      FF00B8CDF800CADAF500C8D3F200D2D5EA00DCE8EB00D4E7EC00D2EAF100CDEC
      F400CBF0F900C4E9F300C1C8C800C7C5C300D9D8D700DAD8D700D2D0CF00FCFC
      FC00FEFEFE00FDFDFD00FDFDFD00FEFEFE00FEFEFE00C1BFBE00C3C9D000C1CB
      D5000000000000000000000000000000000000000000F1F0F000D0CFCD00E4E3
      E200FBFBFA00FAFAFA00FDFDFD00FAFAFA00FEFEFE00F4F4F400FEFEFE00FBFB
      FB00FBFBFB00FBFBFB00FCFCFC00FDFDFD00FEFEFE00FDFDFD00FDFDFD00FCFC
      FC00D2D1D000D0CFCD00DDDCDB00DBD9D800DCDBDA00EFEEEE00FAFAFA00FAFA
      FA00EBEAE900DBDAD90000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FDF8EE00FAECD000FBEDD400FEF9F10000000000000000000000
      0000FFFEFD00F6D9A200E8C18700D4A16700CD965C00D4A16700E8C18700F5D7
      9C00FFFFFE00000000000000000000000000000000000000000000000000C7F2
      FF00BEF0FF00A9CEFC004F5DF20069D1FC0054D3FE004CD4FE004BD5FE0048D4
      FE0044D5FE0041D6FE0040D6FE003FD6FE003BD7FE0038D8FE0037D8FE0034DA
      FE002FDBFE002DDDFE002CDEFE0036E2FE005BE3FD007387F600B9E0FE00BEF0
      FF00CCF3FF00000000000000000000000000000000000000000000000000C7F2
      FF00BEF0FF00A9CEFC004F5DF20069D1FC0054D3FE004CD4FE006EDAFA00B8E3
      F000CFEBF300CCEDF700C7EFF900C0EDFA0097E9FD004EDCFE0044D6F80098C7
      D000BCC1C00089CBD6008FCAD3009EC8CE008CD2DF007588F500B9E0FE00BEF0
      FF00CCF3FF000000000000000000000000000000000000000000000000000000
      0000FBFBFB00F6F6F600CECDCB00E0DFDE00FEFEFE00FAFAF900FBFAFA00FEFE
      FE00FEFEFE00FEFEFE00FBFBFB00FBFBFB00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FAFAFA00FDFDFD00FEFEFE00DAD9
      D700F1F0F0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E8C18700D4A16700CD965C00D4A16700E8C18700F5D79C00F8E2B8000000
      00000000000000000000FCF3E200F9E6C100F6DBA500F6DBA700F9E7C300FCF4
      E50000000000000000000000000000000000000000000000000000000000CAF0
      FF006C71F3005C58F1004268F4007CDBFD005ED1FD005CD0FE0059D2FE0053D3
      FE004BD5FE0048D6FE0045D6FE0044D6FE0043D7FE0040D7FE003FD8FE003BD9
      FE0037DAFE0034DBFE0030DDFE002FDDFE006CEDFE005487F700A4A3F700ACB6
      FA00F1FBFF00CDF3FF00FDFFFF0000000000000000000000000000000000CAF0
      FF006C71F3005C58F1004268F4007CDBFD005ED1FD005CD0FE0059D2FE0054D4
      FE0087DEF7007DDEFA0069DCFC004CD8FE0043D7FE0040D7FE003FD8FE003BD9
      FE0039DAFD0034DBFE0030DDFE002FDDFE006CEDFE005487F700A4A3F700ACB6
      FA00F1FBFF00CDF3FF00FDFFFF0000000000000000000000000000000000FEFE
      FE00FEFEFE00F3F3F200F4F4F300E0DFDE00D1D0CE00D3D1D000D3D2D000C8C6
      C500F8F8F700F0EFEF00F8F8F800F8F8F800F9F9F800FDFDFD00FEFEFE00FEFD
      FD00FEFEFE00FEFEFE00FEFEFE00F6F6F600F8F8F800FDFDFD00C8C7C500D5D4
      D200FEFEFE000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFE
      FC00E8C18700CD965C00C0804700CD965C00E8C18700F5D79C00F5D79C00FFFD
      FA00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F7FDFF00E8F9
      FF00BCEDFF007681F5004982F60076DAFC0066D6FD0063D4FD0062D3FD0061D2
      FD0059D3FD0052D5FE004ED7FE004DD6FE0049D7FE0048D7FE0047D8FE0043D8
      FE003ED9FE003BDAFE0037DBFE0036DBFE0060E8FE005098F700ABB9F900BEEE
      FF00C0F0FF00DAF6FF0000000000000000000000000000000000F7FDFF00E8F9
      FF00BCEDFF007681F5004982F60076DAFC0066D6FD0063D4FD0062D3FD0061D2
      FD0059D3FD0052D5FE004ED7FE004DD6FE0049D7FE0048D7FE0047D8FE0043D8
      FE003ED9FE003BDAFE0037DBFE0036DBFE0060E8FE005098F700ABB9F900BEEE
      FF00C0F0FF00DAF6FF000000000000000000000000000000000000000000FEFE
      FE00FEFEFE00FCFCFC00F4F4F300F3F3F200F0EFEE00EDECEB00F0EFEF00DEDC
      DC00F6F6F600FDFDFD00FDFCFC00FDFDFD00FDFDFD00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00F5F5F500E0E0DE00CDCBC900CCCAC900F2F1
      F100FCFCFC00FEFEFE0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFD
      FB00E8C18700D4A16700CD965C00D4A16700E8C18700F5D79C00F5D79C00FFFD
      FB00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000D3F4FF00BBEA
      FF00869CF8005B5AF2005290F70077DCFD0070DBFE006CD8FD006BD8FD0067D6
      FD0065D4FD0062D2FD005CD2FD0056D6FE0051D7FE004DD7FE004CD8FE004BD9
      FE0046D9FE0043D9FE003FDAFE003EDAFE005AE4FE0052A0F800A0A3F800B1C8
      FB00CEF1FF00EFFBFF0000000000000000000000000000000000D3F4FF00BBEA
      FF00869CF8005B5AF2005290F70077DCFD0070DBFE006CD8FD006BD8FD0067D6
      FD0065D4FD0062D2FD005CD2FD0056D6FE0051D7FE004DD7FE004CD8FE004BD9
      FE0046D9FE0043D9FE003FDAFE003EDAFE005AE4FE0052A0F800A0A3F800B1C8
      FB00CEF1FF00EFFBFF000000000000000000000000000000000000000000FEFE
      FE00FEFEFE00FEFEFE00FBFBFB00F4F4F300F3F3F200EFEFEE00EEEDED00F1F1
      F100D4D3D200C8C6C400C9C7C600C6C5C300C5C4C200FAFAFA00FCFCFC00FDFD
      FD00FEFEFE00FBFBFB00D4D2D100D2D0CF00F3F2F200F9F9F800FEFEFE00FCFC
      FC00FEFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F5D79C00E8C18700E8C18700E8C18700F5D79C00F5D79C00F7E0B3000000
      00000000000000000000FEFCF600FCF4E400FDF8EF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FCFEFF00CEEE
      FF00849BF8005756F2005290F7007CDFFD0079E0FE0075DEFE0074DEFE0071DB
      FD006CD8FD006BD8FD0068D5FD0067D4FD0061D4FD0058D7FE0055D8FE0051D8
      FE004FD9FE004BD9FE0047DAFE0046DAFE005FE3FE00549FF8009C9EF700AEC6
      FB00C7EFFF00D9F6FF0000000000000000000000000000000000FCFEFF00CEEE
      FF00849BF8005756F2005290F7007CDFFD0079E0FE0075DEFE0074DEFE0071DB
      FD006CD8FD006BD8FD0068D5FD0067D4FD0061D4FD0058D7FE0055D8FE0051D8
      FE004FD9FE004BD9FE0047DAFE0046DAFE005FE3FE00549FF8009C9EF700AEC6
      FB00C7EFFF00D9F6FF0000000000000000000000000000000000000000000000
      0000FEFEFE00FEFEFE00FEFEFE00FAFAFA00F5F5F400F3F3F200F0EFEE00EFEE
      EE00F5F5F500F7F6F600FAFAFA00FBFAFA00DBD9D800C5C3C200C8C7C500C4C2
      C000CAC8C600CAC8C600D9D7D600F9F9F800FDFDFD00FDFDFD00FEFEFE00FEFE
      FE00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F7DFB000F5D79C00F5D79C00F5D79C00F5D79C00F7E1B400FDF8ED000000
      0000FEFCF900FAE9C900E9C38A00E8C18700E8C18700F7E1B400FDF7EA000000
      0000000000000000000000000000000000000000000000000000F2FCFF00C3F1
      FF00BCECFF006D79F5004B7EF50086E4FD0083E5FE007FE2FE007EE2FE007AE0
      FE0075DDFD0072DBFD0071DBFD0070D9FD006CD8FD0068D5FD0064D7FD005BDA
      FE0054D9FE0054D9FE004FDAFE004EDAFE006CE4FE005292F700A5B2F900BEEE
      FF00DEF7FF000000000000000000000000000000000000000000F2FCFF00C3F1
      FF00BCECFF006D79F5004B7EF50086E4FD0083E5FE007FE2FE007EE2FE007AE0
      FE0075DDFD0072DBFD0071DBFD0070D9FD006CD8FD0068D5FD0064D7FD005BDA
      FE0054D9FE0054D9FE004FDAFE004EDAFE006CE4FE005292F700A5B2F900BEEE
      FF00DEF7FF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FBFBFB00F7F7F600F3F2F100EFEE
      EE00F3F2F200F5F5F500F7F7F700FBFAFA00FDFDFD00FCFBFB00F6F5F500FBFA
      FA00F7F7F600F8F8F700FEFEFE0000000000FEFEFE00FEFEFE00FEFEFE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FEFAF200FBEED500FBEFD800FEFAF40000000000000000000000
      0000F6DCAA00E8C18700CD965C00CD965C00CD965C00E8C18700F5D79C00FCF2
      DF00000000000000000000000000000000000000000000000000F2FCFF00C6EF
      FF005D62F2004C48EF00405EF30093E8FD0090EAFE008AE7FE0088E7FE0084E4
      FE0080E2FE007CE0FE0078DFFD0077DDFD0076DDFD0072DBFD0070D9FD006CD8
      FD005EDBFE0059DAFE0058DBFE0057DBFE007EE6FE00517CF6009695F600A2AA
      F800BEEEFF00E9FAFF0000000000000000000000000000000000F2FCFF00C6EF
      FF005D62F2004C48EF00405EF30093E8FD0090EAFE008AE7FE0088E7FE0084E4
      FE0080E2FE007CE0FE0078DFFD0077DDFD0076DDFD0072DBFD0070D9FD006CD8
      FD005EDBFE0059DAFE0058DBFE0057DBFE007EE6FE00517CF6009695F600A2AA
      F800BEEEFF00E9FAFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FAFA
      FA00F1F0F000F4F3F300F6F5F500F9F8F800FCFCFC00FEFEFE00000000000000
      0000FEFEFE00FEFEFE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F5D79C00E8C18700CD965C00C0804700CD965C00E8C18700F5D79C00F8E1
      B5000000000000000000000000000000000000000000FEFFFF00D3F4FF00D8F6
      FF00BEF0FF00A4C8FC00434DF00083D7FB008EEAFE009CEEFE009BEDFE0094EB
      FE008EE8FE0089E7FE0084E4FE0082E3FE007DE1FE007CE0FD007ADEFD0077DD
      FD006FDAFD0065DBFE005EDBFE0062DCFD0071D7FC006776F400B4DAFD00BEF0
      FF00E2F8FF00F7FDFF00000000000000000000000000FEFFFF00D3F4FF00D8F6
      FF00BEF0FF00A4C8FC00434DF00083D7FB008EEAFE009CEEFE009BEDFE0094EB
      FE008EE8FE0089E7FE0084E4FE0082E3FE007DE1FE007CE0FD007ADEFD0077DD
      FD006FDAFD0065DBFE005EDBFE0062DCFD0071D7FC006776F400B4DAFD00BEF0
      FF00E2F8FF00F7FDFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FEFEFE00FDFDFD00FEFEFE00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F5D79C00E8C18700CD965C00CD965C00CD965C00E8C18700F5D79C00F7E0
      B200000000000000000000000000000000000000000000000000FDFFFF00E3F8
      FF008FADF90097B8FA0088A2F800404CF1008ADAFC0096EFFE00AFF5FE00AAF3
      FE00A8F2FE00A3F0FE009EEFFE009DEEFE0098ECFE0093EBFE0092E9FE008DE8
      FE008BE6FE0086E4FD0085E1FD007CD4FD005B6FF300A7C1FB00AFD1FC00ACCB
      FC00F2FCFF000000000000000000000000000000000000000000FDFFFF00E3F8
      FF008FADF90097B8FA0088A2F800404CF1008ADAFC0096EFFE00AFF5FE00AAF3
      FE00A8F2FE00A3F0FE009EEFFE009DEEFE0098ECFE0093EBFE0092E9FE008DE8
      FE008BE6FE0086E4FD0085E1FD007CD4FD005B6FF300A7C1FB00AFD1FC00ACCB
      FC00F2FCFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFEFE000000
      0000F9E7C300F5D79D00F5D79C00F5D79C00F5D79C00F5D79C00F7DEAD00FDF9
      F00000000000000000000000000000000000000000000000000000000000EEFB
      FF00C8F2FF00BEF0FF007789F6004440EF004567F4009FEDFE00A3F4FE00B5F7
      FE00AFF5FE00AEF5FE00A9F3FE00A8F2FE00A3F1FE009EEFFE009DEEFE0098ED
      FE0092E9FE0091E8FE0096E3FE004F76F5007D7BF4009CB0F900BEF0FF00CBF3
      FF0000000000000000000000000000000000000000000000000000000000EEFB
      FF00C8F2FF00BEF0FF007789F6004440EF004567F4009FEDFE00A3F4FE00B5F7
      FE00AFF5FE00AEF5FE00A9F3FE00A8F2FE00A3F1FE009EEFFE009DEEFE0098ED
      FE0092E9FE0091E8FE0096E3FE004F76F5007D7BF4009CB0F900BEF0FF00CBF3
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FAFAFA00E0E0DF00D5D4D200D8D6D500E7E6
      E600DDDCDB00CBC9C800CBC9C700DDDCDB00EEEDED00CFCECC00C3C1BF00C7C5
      C300EEEEEE00D7D2C900DBCDB300E8D2A900EAD9B900F0E8D900D4D2D000C7C6
      C400D3D2D000F4F3F3000000000000000000000000000000000000000000DFF7
      FF00BEF0FF0091B1F9007D93F6009DC0FB00494AF1004D77F500A2EFFE00A2F5
      FE00BCF9FE00B7F8FE00B6F8FE00B5F6FE00B0F5FE00AAF4FE00A8F3FE00A3F1
      FE0099EDFE009AE5FD00507FF6007679F500AED1FC009EB6FA00ABCBFC00BEF0
      FF0000000000000000000000000000000000000000000000000000000000DFF7
      FF00BEF0FF0091B1F9007D93F6009DC0FB00494AF1004D77F500A2EFFE00A2F5
      FE00BCF9FE00B7F8FE00B6F8FE00B5F6FE00B0F5FE00AAF4FE00A8F3FE00A3F1
      FE0099EDFE009AE5FD00507FF6007679F500AED1FC009EB6FA00ABCBFC00BEF0
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E8E8E700C4C2C000C8C6C500EBEAE900F3F2F200E6E5
      E400D6D5D300F1F0F000FDFDFD00F1F1F000C1BFBD00DDDCDB00FEFEFE00F9F9
      F900C1BFBD00E6E5E500FEFEFE00FBFBFB00DCDBDB00C1BFBD00ECEBEB00FDFD
      FC00E6E5E400C4C2C000F1F1F00000000000000000000000000000000000FDFF
      FF00EBFAFF00BEEEFF00BEF0FF00A7CFFC004440EE00494AF2004566F40091DC
      FC00AFF9FE00C2FCFE00BEFBFE00BCFBFE00BCFAFE00B6F8FE00B5F7FE00A9F4
      FE0089D5FD004D70F5006F72F5007875F300B2DAFD00BEF0FF00C8F1FF00ECFA
      FF0000000000000000000000000000000000000000000000000000000000FDFF
      FF00EBFAFF00BEEEFF00BEF0FF00A7CFFC004440EE00494AF2004566F40091DC
      FC00AFF9FE00C2FCFE00BEFBFE00BCFBFE00BCFAFE00B6F8FE00B5F7FE00A9F4
      FE0089D5FD004D70F5006F72F5007875F300B2DAFD00BEF0FF00C8F1FF00ECFA
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E8E8E700C1BFBD00E8E7E600F9F9F900F9F9F900F8F8F800F9F9
      F900F6F6F600F8F8F800F7F7F700F8F8F800FDFDFD00FCFCFC00FBFBFB00FCFC
      FC00FEFEFE00FEFEFE00FEFEFE00FBFBFB00FBFAFA00FEFEFE00FBFBFB00FEFE
      FE00F9F9F900E9E8E800C8C6C500FCFCFC000000000000000000000000000000
      000000000000D3F5FF00BEEEFF007A8FF600A8D0FC009DC0FB004440EF00404C
      F10090DCFC00ABF4FE00A9F7FE00A9F7FE00A9F7FE00AAF6FE00AAF0FE008CD7
      FC00505FF2006C6AF200AACEFC00B1DAFD009BB1F900C5F0FF00D0F4FF00DCF7
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000D3F5FF00BEEEFF007A8FF600A8D0FC009DC0FB004440EF00404C
      F10090DCFC00ABF4FE00A9F7FE00A9F7FE00A9F7FE00AAF6FE00AAF0FE008CD7
      FC00505FF2006C6AF200AACEFC00B1DAFD009BB1F900C5F0FF00D0F4FF00DCF7
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FAFAFA00CCCBC900D4D3D200F5F4F400FAFAFA00F9F9F900FAFA
      FA00F8F8F800F8F8F800F8F8F800F9F9F900FCFBFB00F1F1F000F3F3F300F8F8
      F800F8F8F800F6F5F500FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FBFBFB00FAFAF900E0DFDE00E8E8E7000000000000000000000000000000
      0000F6FDFF00CBF3FF00C3ECFE00BEEEFF00BEF0FF007D92F600788AF60088A1
      F800434BF000425BF300537BF5005F8CF7005F8BF700547BF6004661F4005059
      F20098B2F9008EA2F80096ACF800BEF0FF00C0EFFF00E4F5FF00FDFFFF00E9FA
      FF00000000000000000000000000000000000000000000000000000000000000
      0000F6FDFF00CBF3FF00C3ECFE00BEEEFF00BEF0FF007D92F600788AF60088A1
      F800434BF000425BF300537BF5005F8CF7005F8BF700547BF6004661F4005059
      F20098B2F9008EA2F80096ACF800BEF0FF00C0EFFF00E4F5FF00FDFFFF00E9FA
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FDFDFD00DDDCDB00D2D1CF00E4E3E200ECEBEB00FAFA
      F900FAFAFA00FBFBFB00FAFAFA00FEFEFE00F6F5F500FCFCFC00FCFCFC00FEFE
      FE00FDFDFD00FEFEFE00FCFCFC00FCFCFC00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00CAC9C700F1F1F1000000000000000000000000000000
      00000000000000000000F3FCFF00D8F6FF00C4EFFF0092B2F900BEF0FF0097B6
      FA00A3C9FC004B47EF006E79F5005656F2005A5AF2007580F5005C58F100A9CF
      FC00A2C3FB00BEF0FF00A2C2FB00C7F0FF00FAFEFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F3FCFF00D8F6FF00C4EFFF0092B2F900BEF0FF0097B6
      FA00A3C9FC004B47EF006E79F5005656F2005A5AF2007580F5005C58F100A9CF
      FC00A2C3FB00BEF0FF00A2C2FB00C7F0FF00FAFEFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FEFEFE00F7F7F700F2F1F100C3C1
      BF00FCFCFC00F8F8F800FCFCFC00FDFDFD00FBFBFB00FEFEFE00FEFEFE00FCFC
      FC00EEEEEE00F6F6F600FBFBFB00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFD
      FD00FAFAFA00CFCDCC00D1CFCE00FFFEFE000000000000000000000000000000
      0000000000000000000000000000FAFEFF00CBF2FF00D1F4FF00C8F2FF008FAB
      F900BEF0FF005C62F200BCECFF00849BF800869CF800BCEDFF006A70F300BEF0
      FF009CBAFA00BEF0FF00BEF0FF00BEEFFF00FCFEFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FAFEFF00CBF2FF00D1F4FF00C8F2FF008FAB
      F900BEF0FF005C62F200BCECFF00849BF800869CF800BCEDFF006A70F300BEF0
      FF009CBAFA00BEF0FF00BEF0FF00BEEFFF00FCFEFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E6E6
      E500F0EFEF00FEFEFE00FCFCFC00FBFBFB00FDFDFD00FEFEFE00FCFCFC00FBFB
      FB00FBFBFB00FCFCFC00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FDFDFD00FCFC
      FC00E2E2E100D4D3D200F8F8F800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E3F8FF00F2FC
      FF00D3F5FF00D1F2FF00BFF0FF00CAEDFE00BAEAFF00C2F0FF00BEEEFF00E5F9
      FF00CDF3FF00FCFEFF00F9FEFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E3F8FF00F2FC
      FF00D3F5FF00D1F2FF00BFF0FF00CAEDFE00BAEAFF00C2F0FF00BEEEFF00E5F9
      FF00CDF3FF00FCFEFF00F9FEFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F8F8F800C6C4C200D9D7D700FEFEFE00FAFAFA00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00F8F8F700DEDDDC00CDCB
      CA00EEEDED000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E8F9FF0000000000FBFEFF0000000000ECFAFF00C9F2FF00F1FCFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E8F9FF0000000000FBFEFF0000000000ECFAFF00C9F2FF00F1FCFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F7F7F600D0CFCD00C1BFBD00C6C4C200C1BF
      BD00FAFAFA00FDFCFC00F0EFEF00FCFCFC00FCFBFB00C9C7C500D8D6D500E9E9
      E800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F2FCFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F2FCFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FAF9F900F3F3F200E9E8
      E700CDCBCA00C4C2C000C1BFBD00C2C0BF00C1BFBD00D0CFCD00FCFCFC000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CFCFCF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E3E2E100E5E4E400F9F9F900F4F4F300F4F3F300FFFEFE00000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000080000000A00000000100010000000000000A00000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFE000000000000000000000000
      FFFFFF1F000000000000000000000000FFFFFE0F000000000000000000000000
      FFFFF807000000000000000000000000F87FF003000000000000000000000000
      E81FF807000000000000000000000000C00FF807000000000000000000000000
      C00FF003000000000000000000000000C00F3003000000000000000000000000
      F01E1807000000000000000000000000C002160F000000000000000000000000
      C000031F000000000000000000000000F87003FF000000000000000000000000
      F8480907000000000000000000000000E1000003000000000000000000000000
      C000000100000000000000000000000080000001000000000000000000000000
      0000000000000000000000000000000080000000000000000000000000000000
      80000000000000000000000000000000F8804008000000000000000000000000
      FC000001000000000000000000000000FC000111000000000000000000000000
      F8000100000000000000000000000000FC020100000000000000000000000000
      FE002104000000000000000000000000FF881020000000000000000000000000
      FFE20041000000000000000000000000FFFE0083000000000000000000000000
      FFFF0487000000000000000000000000FFFF801F000000000000000000000000
      3FFFF03F000000000000000000000000FFFFFFFEFFFF8FFEFFFFFFFEFFFFFFFE
      FFFFFFFFFFFF03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFE01FFFFFFFFFFFFFFFFFF
      F3FFFFFFE7FE01FFFFFFFFFFFFFFFFFFF3FFFFFF80FF80FFFF0F81FFF81FFFFF
      F3FFFFFF807080FFFE0F00FFF80FFFFFF3FFFFFF807040FFFC06183FF00F0FFF
      F3FFFFFFC020207FFC603C3FF00703FFF3FFFFFFE020107FFFF0463FF80603FF
      F3FFFFFFE020107FFF9081FFFC0403FFF3FFFFFFF030087FFE0F00FFFE0601FF
      F3FFFFFFF0100C7FFC06187FFF0601FFF3FFFFFFFC1C083FFCF0663FFF8380FF
      F3FFFFFFFE1E001FFFF0C3FFFFC24087F3FFFFFFFF1F000FFF0B80FFE1002003
      F1FFFFFFE21F000FFC0E007FC0000001E00FFFFFFC0F800FFC04183F80004001
      EC000003F807C807FCE03E3F00000000CE600003F8008007FFF0433F80000000
      CF30C613F8030207FF0181FF80000000CF30420FFE030183FC06183FF8804008
      CF30420FFE000003FC603C3FFC000001CF30401FFC000001FFF0433FFC000111
      CF30407FF8000000FF8081FFF8000100CF3043FFF8000000FE0F00FFFC020100
      CE700FFFFC000000FC06187FFE002104EE603FFFFF000000FC603C3FFF881020
      E401FFFFFFE00001FEF07E3FFFE20041F1FFFFFFFFFC0007FFFFFFFFFFFE0083
      FFFFFFFFFFFE000FFFFFFFFFFFFF0487FFFFFFFFFFFF801FFFFFFFFFFFFF801F
      7FFFFFFF7FFFF03F7FFFFFFF3FFFF03FFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFE
      FFFFFFFFFFFFF8FFFFFCCFFFFFFFFFFFFFFFFFFFFFFFF01FFFEC0FFFFFFFFFFF
      FFFFFFFFFFFFF01FFFE00FFFFFFFFFFFF81FF1FFF81FF00FFC000003FC3FC07F
      F80F903FF80FF00FFC000001F00F815FF00F001FF00F080FF0000001F00F0FCF
      F007003FF007040FF0000001F18F1FEFF807001FF806000FC0000003F7E431FF
      FC07C07FFC04020F00000007FFF5E0FFFE07001FFE06010700000003F81F807F
      FF07803FFF06018780000003F00F07DFFF83F1FFFF8380E7E0000007F3E51FFF
      FFC21107FFC24083E0000001FFF5F0FFE1000003E1002003C0000003FC3FC07F
      C0000001C0000001C0000003F00F815F8000400180004001C0000003F00F0FCF
      0000000000000000C0000007F18F1FEF8000000080000000C0000003FFE431FF
      800000008000000080000003FFFFE0FFF8804008F8804008C0000007F00F0FCF
      FC000001FC000001E000000FF00F0FCFFC000111FC000111E000000FF7E519FF
      F8000100F8000100E000000FFFF5E0FFFC020100FC020100F800000FF81FC07F
      FE002104FE002104F000000FF00F075FFF881020FF881020FC00007FF00F0FCF
      FFE20041FFE20041FE00007FF3CF1FEFFFFE0083FFFE0083FFC001FFFFFFFFFF
      FFFF0487FFFF0487FFF51FFFFFFFFFFFFFFF801FFFFF801FFFFFBFFFFFFFFFFF
      3FFFF03F3FFFF03F7FFFFFFF7FFFFFFFFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFE
      FFFFFFFFFFFFF07FFFFFFFFFFFFFFFFFFFFFFFFFEE7FF01FFFFFFFFFFFFFFCFF
      FFFFF07FF63FF00FFFFFFFFFFFFFF83FF03FCF8FF39FF00FFF83FFFFFFFFE00F
      E39F9FCFF1CFF00FFF00FFFFFFFFE00FFFEE3FF7F0CFFC0FFF00FFFFFFFFF00F
      FFE0FFF7F8CFFC0FFF007FFFFFFFF00FFFF1F07FC06FFE07FF807FFFFFEFE00F
      FC7FE23FC02F0F07FFC07FFFFFC7E00FF01FCF8FC00E0F87FFE07FFFFC00700F
      E38F1FCFE00C07C7FFF07FFFFC00F87FFFF0F9FFE0CC03F7FFF83FFFFE00FFFF
      FFF1F07FF04E0073FFC82107FE008107F87FE61FF00F01FFE1080003E0000003
      F01F8F8FF01F01FFC0000001C0000001E7CF1FE7F01FC1FF8002000180404001
      FFEC7FF7F01FE0FF0000000000000000FFF0F07FFF1FE0FF8000000080200000
      F87BC01FFF9FF0FF8000000080000000E00F0F07FFFFD8FFF8804008F8804008
      E10C0FC3FE000003FC000001FC000001EFC019E3FC000001FC000111FC000111
      FFE07033F8000000F8000100F8000100F831C01FF8000000FC020100FC020100
      F01F800FFC000000FE002104FE002104E00E0F03FF000000FF881020FF881020
      E3040FC3FFE00001FFE20041FFE20041FFE07FF3FFFC0007FFFE0083FFFE0083
      FFF1FFFFFFFE000FFFFF0487FFFF0487FFFFFFFFFFFF801FFFFF801FFFFF801F
      7FFFFFFF7FFFF03F3FFFF03F3FFFF03FFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFE
      FFFCCFFFFFFCCFFFFFFFFFFFFFFF0FFFFFEC0FFFFCE000C7FFFFFFFFFFFC07FF
      FFE00FFFF0000003FFFFFFFFF87C07FFFC0000FFE0000000FE000003F01803FF
      FC00007FC0000000FE000001F00C07FFF000003F80000000FE000001F00C077F
      F000001F80000001FF800001F00F0C0FF000000780000001C0000003F01FF80F
      E0000007C000000700000007F03FF007E000000FE000000700000003FFFFF007
      E000000FE000000F80000003FFF87007E0000007E0000007F0000007FFF01C0F
      E0000001E0000001E0000007FFE00FFFC0000003C0000003E0000003FFE00FFF
      C0000003C0000003E0000007FFF01C7FC0000003C0000003F000000FFFF0101F
      C0000007C0000007FF00011FFFF8700FC0000003C0000003FFE033FFFFFFF00F
      8000000380000003FFF1FFFFFFFFF00FC0000007C0000007FFFFFFFFFFFFD00F
      E000000FE000000FFFFFFFFFFE000003E000000FE000000FFFFFFFFFFC000001
      E000000FE000000FFFFFFFFFF8000000F800000FF800000FFFFFFFFFF8000000
      F000000FF000000FFFFFFFFFFC000000FC00007FFC00007FFFFFFFFFFF000000
      FE00007FFE00007FFFFFFFFFFFE00001FFC001FFFFC001FFFFFFFFFFFFFC0007
      FFF51FFFFFF51FFFFFFFFFFFFFFE000FFFFFBFFFFFFFBFFFFFFFFFFFFFFF801F
      7FFFFFFF7FFFFFFF7FFFFFFF7FFFF03F00000000000000000000000000000000
      000000000000}
  end
  object XMLDocument1: TXMLDocument
    Left = 313
    Top = 131
    DOMVendorDesc = 'MSXML'
  end
  object IdHTTP1: TIdHTTP
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 156
    Top = 236
  end
  object OpenDialog1: TOpenDialog
    InitialDir = '%USERPROFILE%'
    Left = 475
    Top = 379
  end
  object SaveDialog1: TSaveDialog
    InitialDir = '%USERPROFILE%'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 475
    Top = 427
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Interval = 20
    Left = 792
    Top = 201
  end
  object TabDuyuruListe: TFDQuery
    Connection = Tablo.FDCnn
    Left = 945
    Top = 344
  end
  object DtsDuyuruListe: TDataSource
    DataSet = TabDuyuruListe
    Left = 953
    Top = 394
  end
  object TabKDR: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select TUR=1, AD='#39'Kasa'#39', TUTAR=12000.0'
      'union all'
      'select TUR=2, AD='#39'Banka'#39', TUTAR=14000.0'
      'union all'
      'select TUR=3, AD='#39'Al'#305'nan '#199'ek'#39', TUTAR=2000.0'
      'union all'
      'select TUR=22, AD='#39'Krediler'#39', TUTAR=120000.0'
      'union all'
      'select TUR=33, AD='#39'Verilen '#199'ek'#39', TUTAR=1000.0'
      '')
    Left = 561
    Top = 104
  end
  object DtsKDR: TDataSource
    DataSet = TabKDR
    Left = 377
    Top = 77
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
    Left = 840
    Top = 232
  end
  object SchedulerDataSource: TDataSource
    DataSet = TabTakvim
    Left = 930
    Top = 209
  end
  object TabTakvim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'##T' +
        'AKVIM_53_%'#39')'
      'DROP TABLE ##TAKVIM_53_'
      ''
      'CREATE TABLE ##TAKVIM_53_('
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
      'INSERT INTO ##TAKVIM_53_'
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
      #39'2016-01-01 00:00'#39' and '#39'2017-12-31 23:59'#39' and '
      '  K.TUR in(71,72,73,75)'
      ' Union All '
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
      #39'2016-01-01 00:00'#39' and '#39'2017-12-31 23:59'#39' and '
      '  K.TUR in(61,62,63,65)'
      ''
      ' Union All '
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
        'ar(10), SUM(PLKK.TUTAR),1),'#39'0'#39')+'#39' '#39'+isnull(KK.ADI,'#39#39'),'
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
      #9'SOT between '#39'2016-01-01 00:00'#39
      'and '#39'2017-12-31 23:59'#39
      'group by KK.ID,KK.ADI, SOT,PLKK.KUR,T.AD'
      ' Union All '
      
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
      #9'VADE >= '#39'2016-01-01 00:00'#39' and VADE <= '#39'2017-12-31 23:59'#39
      #9'and CH.ISLEM = 140 and CH.GERIDONUSID is null'
      ' Union All '
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
      #9'VADE >= '#39'2016-01-01 00:00'#39' and VADE <= '#39'2017-12-31 23:59'#39
      #9'and CH.ISLEM = 130 and CH.GERIDONUSID is null'
      ''
      ''
      ' Union All '
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
      '    Dosya='#39'SENETLER'#39', '
      '    ID2=C.ID,'
      '               REHBERID=R.ID,'
      '    C.TUR, TURAD=T.AD,'
      '    -1*TUTAR,KUR,'
      #9' YON='#39#214'deme'#39', '
      #9' SIRA=2,'
      #9' AIKLAMA='#39'Senet'#39' '
      #9' '
      'from SENETLER C'
      'inner join ISLEMTURLERI T on C.TUR=T.TUR'
      'inner join REHBER R on R.ID=C.REHBERID'
      'where '
      #9'VADE >= '#39'2016-01-01 00:00'#39' '
      'and VADE <= '#39'2017-12-31 23:59'#39
      #9'and C.TUR in (34)'
      ' Union All '
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
      '    Dosya='#39'SENETLER'#39', '
      '    ID2=C.ID,'
      '               REHBERID=R.ID,'
      '    C.TUR, TURAD=T.AD,'
      '    TUTAR,KUR,'
      #9' YON='#39'Tahsilat'#39' , '
      #9' SIRA=2,'
      #9' AIKLAMA='#39'Senet'#39' '
      #9' '
      'from SENETLER C'
      'inner join ISLEMTURLERI T on C.TUR=T.TUR'
      'inner join REHBER R on R.ID=C.REHBERID'
      'where '
      #9'VADE >= '#39'2016-01-01 00:00'#39' '
      'and VADE <= '#39'2017-12-31 23:59'#39
      #9'and C.TUR in (24)'
      ' Union All '
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
      #9'TARIH >= '#39'2016-01-01 00:00'#39' '
      'and TARIH <= '#39'2017-12-31 23:59'#39
      
        'and (select count(*) from REHBERAYAR RA where RA.ETIKET=PM.ETIKE' +
        'T and RA.VARSAYILAN=36)>0'#9
      'group by TARIH, KUR, T.AD'
      'having sum(TUTAR)>0'
      ''
      ' Union All '
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
      #9'TARIH >= '#39'2016-01-01 00:00'#39' and  '
      #9'TARIH <= '#39'2017-12-31 23:59'#39' and '
      #9'ODENMIS=0 '
      ' Union All '
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
      'where B.GOR=1 and M.GELIRMI=0'
      
        'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
        'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>='#39'2016-01-' +
        '01 00:00'#39' '
      
        'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
        'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))<='#39'2012-01-' +
        '01 00:00'#39
      
        'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
        'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>GETDATE()'#9 +
        ' '
      ' Union All '
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
      
        'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
        'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>='#39'2016-01-' +
        '01 00:00'#39' '
      
        'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
        'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))<='#39'2012-01-' +
        '01 00:00'#39
      
        'and convert(datetime,(CONVERT(Varchar(4),B.YIL)+'#39'-'#39'+CONVERT(Varc' +
        'har(2),B.AY)+'#39'-'#39'+CONVERT(Varchar(2),B.GUN)+'#39' 00:00'#39'))>GETDATE()'#9 +
        ' '
      ' Union All '
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
      #39'2016-01-01 00:00'#39' and '#39'2017-12-31 23:59'#39' and '
      '  K.TUR in(25) and HESAPTURU='#39'P'#39
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
      #9'ISLEMTARIHI between '#39'2016-01-01 00:00'#39' and '#39'2017-12-31 23:59'#39
      
        #9'and K.TUR not in(1,2,40,41,42,43,44,45,46,47,48,49,61,62,63,65,' +
        '67,68,71,72,73,75)'
      ''
      ''
      ''
      ''
      ' ORDER BY 2 '
      ' select * from ##TAKVIM_53_')
    Left = 525
    Top = 105
  end
  object PopupMenu1: TPopupMenu
    OwnerDraw = True
    Left = 631
    Top = 104
    object Gizle1: TMenuItem
      Caption = 'Gizle'
      Visible = False
      OnClick = Gizle1Click
    end
    object BilgileriDegisMenu: TMenuItem
      Caption = 'bilgilerini g'#246'r / de'#287'i'#351'tir'
    end
    object SilMenu: TMenuItem
      Caption = 'Sil'
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object BuguneaksiyonekleMenu: TMenuItem
      Caption = 'Bu tarihe aksiyon ekle'
      OnClick = BuguneaksiyonekleMenuClick
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
  end
  object PopupMenuYaz: TPopupMenu
    Left = 227
    Top = 191
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
      end
      object MenuItem4: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object MenuItem5: TMenuItem
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
    Left = 506
    Top = 120
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
    Left = 378
    Top = 264
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
    Left = 648
    Top = 205
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
    Left = 643
    Top = 164
  end
  object pmPivot: TPopupMenu
    Left = 176
    Top = 152
    object ExcelPivot1: TMenuItem
      Caption = 'Excel Pivot...'
      OnClick = ExcelPivot1Click
    end
  end
  object DtsListe: TDataSource
    DataSet = TabListe
    Left = 193
    Top = 307
  end
  object TabListe: TFDQuery
    Connection = Tablo.FDCnn
    Left = 148
    Top = 322
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
  object cxGridPopupMenu1: TcxGridPopupMenu
    PopupMenus = <
      item
        HitTypes = [gvhtGridNone, gvhtNone, gvhtCell, gvhtRecord, gvhtRowCaption]
        Index = 0
        PopupMenu = PopupMenuGrafik
      end>
    Left = 848
    Top = 360
  end
  object TabKDRStok: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select TUR=1, AD='#39'Kasa'#39', TUTAR=12000.0'
      'union all'
      'select TUR=2, AD='#39'Banka'#39', TUTAR=14000.0'
      'union all'
      'select TUR=3, AD='#39'Al'#305'nan '#199'ek'#39', TUTAR=2000.0'
      'union all'
      'select TUR=22, AD='#39'Krediler'#39', TUTAR=120000.0'
      'union all'
      'select TUR=33, AD='#39'Verilen '#199'ek'#39', TUTAR=1000.0'
      '')
    Left = 537
    Top = 536
  end
  object DtsKDRStok: TDataSource
    DataSet = TabKDRStok
    Left = 425
    Top = 549
  end
end
