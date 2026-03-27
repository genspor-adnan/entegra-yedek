object HizliGirisKasaOzet: THizliGirisKasaOzet
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'HizliGirisKasaOzet'
  ClientHeight = 893
  ClientWidth = 1541
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 37
    Width = 1541
    Height = 856
    Align = alClient
    TabOrder = 0
    object pnlSag: TPanel
      Left = 1
      Top = 42
      Width = 1539
      Height = 813
      Align = alClient
      TabOrder = 0
      object pnlSagUst: TPanel
        Left = 1
        Top = 1
        Width = 1537
        Height = 811
        Align = alClient
        TabOrder = 0
        object pnlAcBilgi: TPanel
          Left = 1
          Top = 1
          Width = 1535
          Height = 44
          Align = alTop
          TabOrder = 0
          object lblAcilisTarih: TcxLabel
            Left = 22
            Top = 11
            Caption = 'A'#231#305'l'#305#351' Tarihi :'
          end
          object lblAcan: TcxLabel
            Left = 458
            Top = 11
            Caption = 'A'#231'an Ki'#351'i :'
          end
          object cmbAcan: TcxImageComboBox
            Left = 522
            Top = 10
            Properties.Items = <>
            TabOrder = 2
            Width = 139
          end
          object cxLabel2: TcxLabel
            Left = 698
            Top = 12
            Caption = #350'ube :'
          end
          object cxLabel4: TcxLabel
            Left = 832
            Top = -32
            Caption = 'cxLabel4'
          end
          object lblAcilisTutari: TcxLabel
            Left = 275
            Top = 10
            Caption = 'A'#231#305'l'#305#351' Tutar'#305' :'
          end
          object edtAcilisTutar: TcxTextEdit
            Left = 346
            Top = 9
            TabOrder = 6
            Width = 69
          end
          object cmbSubeler: TcxImageComboBox
            Left = 743
            Top = 10
            Properties.Items = <>
            TabOrder = 7
            Width = 156
          end
          object dtpKasaOzetTarih: TcxDateEdit
            Left = 91
            Top = 9
            Enabled = False
            Properties.DisplayFormat = 'dd/mm/yyyy'
            Properties.Kind = ckDateTime
            TabOrder = 8
            Width = 142
          end
          object edtAciklama: TcxTextEdit
            Left = 1196
            Top = 10
            TabOrder = 9
            Width = 123
          end
          object lblAciklama: TcxLabel
            Left = 1133
            Top = 12
            Caption = 'A'#231#305'klama :'
          end
          object cmbDurum: TcxImageComboBox
            Left = 991
            Top = 10
            EditValue = 1
            Properties.Items = <
              item
                Description = 'A'#231#305'k'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Kapal'#305
                Value = 2
              end>
            TabOrder = 11
            Width = 97
          end
          object cxLabel6: TcxLabel
            Left = 937
            Top = 12
            Caption = 'Durum :'
          end
        end
        object pnlGenel: TPanel
          Left = 1
          Top = 45
          Width = 1535
          Height = 765
          Align = alClient
          TabOrder = 1
          object cxButton2: TcxButton
            Left = 312
            Top = -24
            Width = 75
            Height = 25
            Caption = 'cxButton2'
            TabOrder = 0
          end
          object cxLabel1: TcxLabel
            Left = 32
            Top = -24
            Caption = 'cxLabel1'
          end
          object cxDateEdit1: TcxDateEdit
            Left = 200
            Top = -48
            TabOrder = 2
            Width = 121
          end
          object cxDateEdit2: TcxDateEdit
            Left = 168
            Top = -24
            TabOrder = 3
            Width = 121
          end
          object pnlSagg: TPanel
            Left = 170
            Top = 1
            Width = 1364
            Height = 763
            Align = alClient
            TabOrder = 4
            object pnlSagAltGrid: TPanel
              Left = 1
              Top = 1
              Width = 1362
              Height = 761
              Align = alClient
              TabOrder = 0
              object pnlSolGrid2: TPanel
                Left = 1
                Top = 1
                Width = 584
                Height = 759
                Align = alLeft
                TabOrder = 0
                object JvNavPanelHeader3: TJvNavPanelHeader
                  Left = 1
                  Top = 1
                  Width = 582
                  Align = alTop
                  Caption = 'Sistem Bilgisi'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWhite
                  Font.Height = -16
                  Font.Name = 'Arial'
                  Font.Style = [fsBold]
                  ParentFont = False
                  ColorFrom = clGray
                  ColorTo = clBlack
                  ImageIndex = 0
                end
                object GridKasaOzet: TcxGrid
                  Left = 1
                  Top = 28
                  Width = 582
                  Height = 730
                  Align = alClient
                  TabOrder = 1
                  object GridKasaOzetView: TcxGridDBTableView
                    Navigator.Buttons.CustomButtons = <>
                    DataController.DataSource = DtsKasaOzet
                    DataController.Summary.DefaultGroupSummaryItems = <
                      item
                        Format = '###,###,###,##0.00'
                        Kind = skSum
                        Position = spFooter
                        Column = GridKasaOzetViewALACAK
                      end
                      item
                        Format = '###,###,###,##0.00'
                        Kind = skSum
                        Position = spFooter
                        Column = GridKasaOzetViewBORC
                      end
                      item
                        Format = '###,###,###,##0.00'
                        Kind = skSum
                        Position = spFooter
                      end>
                    DataController.Summary.FooterSummaryItems = <
                      item
                        Kind = skSum
                        Column = GridKasaOzetViewBORC
                      end
                      item
                        Kind = skSum
                        Column = GridKasaOzetViewALACAK
                      end
                      item
                        Kind = skSum
                      end>
                    DataController.Summary.SummaryGroups = <>
                    OptionsData.CancelOnExit = False
                    OptionsData.Deleting = False
                    OptionsData.DeletingConfirmation = False
                    OptionsData.Editing = False
                    OptionsData.Inserting = False
                    OptionsView.ColumnAutoWidth = True
                    OptionsView.Footer = True
                    OptionsView.GroupFooters = gfAlwaysVisible
                    OptionsView.Indicator = True
                    object GridKasaOzetViewTIP: TcxGridDBColumn
                      DataBinding.FieldName = 'TIP'
                      Visible = False
                      GroupIndex = 0
                      Width = 187
                    end
                    object GridKasaOzetViewTUR: TcxGridDBColumn
                      DataBinding.FieldName = 'TUR'
                      RepositoryItem = Tablo.RepKasaTurleri
                      Width = 142
                    end
                    object GridKasaOzetViewBORC: TcxGridDBColumn
                      DataBinding.FieldName = 'BORC'
                      Width = 171
                    end
                    object GridKasaOzetViewALACAK: TcxGridDBColumn
                      DataBinding.FieldName = 'ALACAK'
                      Width = 178
                    end
                    object GridKasaOzetViewKUR: TcxGridDBColumn
                      DataBinding.FieldName = 'KUR'
                      Width = 155
                    end
                  end
                  object GridKasaOzetLevel1: TcxGridLevel
                    GridView = GridKasaOzetView
                  end
                end
              end
              object pnlSagPanel: TPanel
                Left = 585
                Top = 1
                Width = 776
                Height = 759
                Align = alClient
                TabOrder = 1
                object pnlSagGrid: TPanel
                  Left = 1
                  Top = 1
                  Width = 774
                  Height = 336
                  Align = alTop
                  TabOrder = 0
                  object JvNavPanelHeader2: TJvNavPanelHeader
                    Left = 1
                    Top = 1
                    Width = 772
                    Align = alTop
                    Caption = 'Say'#305'm Bilgisi'
                    Font.Charset = DEFAULT_CHARSET
                    Font.Color = clWhite
                    Font.Height = -16
                    Font.Name = 'Arial'
                    Font.Style = [fsBold]
                    ParentFont = False
                    ColorFrom = clGray
                    ColorTo = clBlack
                    ImageIndex = 0
                  end
                  object GridSayimBilgisi: TcxGrid
                    Left = 1
                    Top = 28
                    Width = 772
                    Height = 307
                    Align = alClient
                    TabOrder = 1
                    object GridSayimBilgisiView: TcxGridDBTableView
                      Navigator.Buttons.CustomButtons = <>
                      DataController.DataSource = DtsSayimBilgisi
                      DataController.Summary.DefaultGroupSummaryItems = <>
                      DataController.Summary.FooterSummaryItems = <
                        item
                          Format = '###,###,###,##0.00'
                          Kind = skSum
                          Column = GridSayimBilgisiViewTUTAR_KAPANIS
                          DisplayText = 'FIYAT'
                        end>
                      DataController.Summary.SummaryGroups = <>
                      OptionsData.Appending = True
                      OptionsData.CancelOnExit = False
                      OptionsData.Deleting = False
                      OptionsData.DeletingConfirmation = False
                      OptionsView.ColumnAutoWidth = True
                      OptionsView.Footer = True
                      OptionsView.GroupByBox = False
                      object GridSayimBilgisiViewADI: TcxGridDBColumn
                        DataBinding.FieldName = 'ADI'
                      end
                      object GridSayimBilgisiViewTUTAR_KAPANIS: TcxGridDBColumn
                        DataBinding.FieldName = 'TUTAR_KAPANIS'
                        PropertiesClassName = 'TcxTextEditProperties'
                        Properties.Alignment.Horz = taCenter
                      end
                    end
                    object GridSayimBilgisiLevel1: TcxGridLevel
                      GridView = GridSayimBilgisiView
                    end
                  end
                end
                object pnlSolGrid: TPanel
                  Left = 1
                  Top = 337
                  Width = 774
                  Height = 421
                  Align = alClient
                  TabOrder = 1
                  object JvNavPanelHeader1: TJvNavPanelHeader
                    Left = 1
                    Top = 1
                    Width = 772
                    Align = alTop
                    Caption = 'Cihaz Bilgisi'
                    Font.Charset = DEFAULT_CHARSET
                    Font.Color = clWhite
                    Font.Height = -16
                    Font.Name = 'Arial'
                    Font.Style = [fsBold]
                    ParentFont = False
                    ColorFrom = clGray
                    ColorTo = clBlack
                    ImageIndex = 0
                  end
                  object GridCihazBilgileri: TcxGrid
                    Left = 1
                    Top = 28
                    Width = 772
                    Height = 392
                    Align = alClient
                    TabOrder = 1
                    object GridCihazBilgileriView: TcxGridDBTableView
                      Navigator.Buttons.CustomButtons = <>
                      DataController.DataSource = DtsCihazBilgisi
                      DataController.Summary.DefaultGroupSummaryItems = <>
                      DataController.Summary.FooterSummaryItems = <
                        item
                          Format = '###,###,###,##0.00'
                          Kind = skSum
                          Column = GridCihazBilgileriViewTUTAR_KAPANIS
                          DisplayText = 'FIYAT'
                        end>
                      DataController.Summary.SummaryGroups = <>
                      OptionsData.Appending = True
                      OptionsData.CancelOnExit = False
                      OptionsData.Deleting = False
                      OptionsData.DeletingConfirmation = False
                      OptionsView.ColumnAutoWidth = True
                      OptionsView.Footer = True
                      OptionsView.GroupByBox = False
                      object GridCihazBilgileriViewADI: TcxGridDBColumn
                        DataBinding.FieldName = 'ADI'
                        Width = 478
                      end
                      object GridCihazBilgileriViewTUTAR_KAPANIS: TcxGridDBColumn
                        DataBinding.FieldName = 'TUTAR_KAPANIS'
                        PropertiesClassName = 'TcxTextEditProperties'
                        Properties.Alignment.Horz = taCenter
                        Width = 400
                      end
                    end
                    object GridCihazBilgileriLevel1: TcxGridLevel
                      GridView = GridCihazBilgileriView
                    end
                  end
                end
              end
            end
          end
          object cxDateEdit3: TcxDateEdit
            Left = 112
            Top = -64
            TabOrder = 5
            Width = 121
          end
          object pnlSplitter: TPanel
            Left = 1
            Top = 1
            Width = 161
            Height = 763
            Align = alLeft
            TabOrder = 6
            object Panel3: TPanel
              Left = 1
              Top = 704
              Width = 159
              Height = 58
              Align = alBottom
              TabOrder = 0
              object cxLabel5: TcxLabel
                Left = 113
                Top = 21
                Caption = 'g'#252'n'
              end
              object cxLabel3: TcxLabel
                Left = 14
                Top = 21
                Caption = 'Son'
              end
              object cmbSonGunListe: TcxImageComboBox
                Left = 42
                Top = 21
                Properties.Items = <
                  item
                    Description = '10'
                    ImageIndex = 0
                    Value = 1
                  end
                  item
                    Description = '20'
                    Value = 2
                  end
                  item
                    Description = '30'
                    Value = 3
                  end
                  item
                    Description = '60'
                    Value = 4
                  end
                  item
                    Description = '90'
                    Value = 5
                  end>
                Properties.OnChange = cmbSonGunListePropertiesChange
                TabOrder = 2
                Width = 56
              end
            end
            object Panel2: TPanel
              Left = 1
              Top = 1
              Width = 162
              Height = 703
              Align = alLeft
              TabOrder = 1
              object GridKasaAcKapatSuzmeList: TcxGrid
                Left = 1
                Top = 1
                Width = 160
                Height = 701
                Align = alClient
                TabOrder = 0
                object GridKasaAcKapatSuzmeListTableView: TcxGridDBTableView
                  Navigator.Buttons.CustomButtons = <>
                  DataController.DataSource = DtsKasaAcKapatSuzmeList
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <>
                  DataController.Summary.SummaryGroups = <>
                  OptionsData.CancelOnExit = False
                  OptionsData.Deleting = False
                  OptionsData.DeletingConfirmation = False
                  OptionsData.Editing = False
                  OptionsData.Inserting = False
                  OptionsView.GroupByBox = False
                  object GridKasaAcKapatSuzmeListTableViewACILIS_TARIH: TcxGridDBColumn
                    DataBinding.FieldName = 'ACILIS_TARIH'
                    Options.Editing = False
                    Width = 220
                  end
                end
                object GridKasaAcKapatSuzmeListLevel1: TcxGridLevel
                  GridView = GridKasaAcKapatSuzmeListTableView
                end
              end
            end
          end
          object cxSplitter1: TcxSplitter
            Left = 162
            Top = 1
            Width = 8
            Height = 763
            HotZoneClassName = 'TcxSimpleStyle'
            Control = pnlSplitter
            OnAfterOpen = cxSplitter1AfterOpen
            OnAfterClose = cxSplitter1AfterClose
          end
        end
      end
    end
    object pnlUstMenu: TPanel
      Left = 1
      Top = 1
      Width = 1539
      Height = 41
      Align = alTop
      TabOrder = 1
      object btnkasabilgisi: TcxButton
        Left = 4
        Top = -1
        Width = 90
        Height = 42
        Caption = 'Kasa Bilgisi'
        TabOrder = 0
        OnClick = btnkasabilgisiClick
      end
      object btnKasaKapat: TcxButton
        Left = 100
        Top = -1
        Width = 90
        Height = 42
        Caption = 'Kasa Kapat'
        TabOrder = 1
        OnClick = btnKasaKapatClick
      end
    end
  end
  object PanelBaslik: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 1541
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
    object KapatTus: TJvNavPanelButton
      Left = 1461
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
      ExplicitLeft = 1087
      ExplicitTop = 1
    end
    object btnKaydet: TJvNavPanelButton
      Left = 1381
      Top = 0
      Width = 80
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
      WordWrap = True
      Colors.ButtonColorFrom = 10395294
      Colors.ButtonColorTo = clBlack
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = -1
      OnClick = btnKaydetClick
      ExplicitLeft = 1087
      ExplicitTop = 1
    end
    object cxLabel9: TcxLabel
      Left = 3
      Top = 1
      AutoSize = False
      Caption = 'KASA '#214'ZET'
      ParentColor = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -24
      Style.Font.Name = 'Microsoft Sans Serif'
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
      Height = 33
      Width = 415
    end
  end
  object TabKasaOzet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'DECLARE @BaslangicTarih DATETIME'
      'SET @BaslangicTarih= :BaslangicTarih'
      'DECLARE @BitisTarih DATETIME'
      'SET @BitisTarih= :BitisTarih'
      ''
      'Select'
      'TIP=case '
      '    when K.TUR IN(40,45,46,55,56,81) THEN '#39'Transfer'#39'  '
      #9'WHEN K.TUR IN(3,8,10,11,12,13,109)  THEN '#39'Al'#305#351' Belgesi'#39
      #9'WHEN K.TUR IN(4,14,15,16,17,110,119)  THEN '#39'Sat'#305#351' Belgesi'#39
      #9'WHEN K.TUR IN(31,32,33,34,35,36,38,37,39,57,58) THEN '#39#214'deme'#39
      
        #9'WHEN K.TUR IN(21,23,24,25,26,27,28,29,52,54,59,91,95) THEN '#39'Tah' +
        'silat'#39
      
        #9'WHEN K.TUR IN(6,7,20,41,42,43,47,48,49,51,53,121,122) THEN '#39'Tra' +
        'nsfer'#39
      #9'END, '
      ''
      '    K.TUR, '
      '     '
      
        '    BORC = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51' +
        ',52,53,54) and isnull(HESAPTURU,'#39#39')<>'#39#39' then ALACAK '
      '    else '
      '    BORC '
      '    end,'
      
        '    ALACAK = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,' +
        '51,52,53,54) and  isnull(HESAPTURU,'#39#39')<>'#39#39' then BORC else '
      '    ALACAK '
      '    end,'
      '    K.KUR'
      '    FROM KASA K (NOLOCK)'
      '     left outer join REHBER R on R.ID=K.REHBERID'
      '     left outer join MASRAFGELIR MG on MG.ID=K.MASRAFID'
      
        ' Where  K.ISLEMTARIHI >= @BaslangicTarih and K.ISLEMTARIHI <@Bit' +
        'isTarih '
      ' and K.SUBEID in(0,-2,-1)'
      'UNION ALL'
      ''
      'SELECT '
      'TIP=case '
      '    when F.TUR IN(40,45,46,55,56,81) THEN '#39'Transfer'#39'  '
      #9'WHEN F.TUR IN(3,8,10,11,12,13,109)  THEN '#39'Al'#305#351' Belgesi'#39
      #9'WHEN F.TUR IN(4,14,15,16,17,110,119)  THEN '#39'Sat'#305#351' Belgesi'#39
      #9'WHEN F.TUR IN(31,32,33,34,35,36,38,37,39,57,58) THEN '#39#214'deme'#39
      
        #9'WHEN F.TUR IN(21,23,24,25,26,27,28,29,52,54,59,91,95) THEN '#39'Tah' +
        'silat'#39
      
        #9'WHEN F.TUR IN(6,7,20,41,42,43,47,48,49,51,53,121,122) THEN '#39'Tra' +
        'nsfer'#39
      #9'END, '
      #9'F.TUR,'
      
        #9'BORC=case when F.TUR in (15,16,17,110) then FATURA_TUTARI else ' +
        '0.0 end,'
      
        #9'ALACAK=case when F.TUR in (8, 11,12,13) then FATURA_TUTARI else' +
        ' 0.0 end,'
      #9
      #9'F.KUR'
      'FROM '
      #9'FATBASLIK F (NOLOCK)'
      #9'left outer join REHBER R on R.ID = F.REHBERID '
      #9'left outer join MASRAFGELIR MG on MG.ID=F.MASRAFID'
      
        ' Where F.TUR<>20 and  FATURATARIH >= @BaslangicTarih and FATURAT' +
        'ARIH <@BitisTarih'
      ' and F.SUBEID in(0,-2,-1) '
      '--'#231'ek'
      'union all'
      'SELECT '
      'TIP=case '
      '    when C.TUR IN(40,45,46,55,56,81) THEN '#39'Transfer'#39'  '
      #9'WHEN C.TUR IN(3,8,10,11,12,13,109)  THEN '#39'Al'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(4,14,15,16,17,110,119)  THEN '#39'Sat'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(31,32,33,34,35,36,38,37,39,57,58) THEN '#39#214'deme'#39
      
        #9'WHEN C.TUR IN(21,23,24,25,26,27,28,29,52,54,59,91,95) THEN '#39'Tah' +
        'silat'#39
      
        #9'WHEN C.TUR IN(6,7,20,41,42,43,47,48,49,51,53,121,122) THEN '#39'Tra' +
        'nsfer'#39
      #9'END,  '
      '    C.TUR,'
      #9'BORC = case when C.TUR=33  then  C.TUTAR else 0    end,'
      #9'ALACAK = case when C.TUR=23  then C.TUTAR else 0    end,'
      #9
      #9'C.KUR'
      'FROM '
      #9'CEKLER C'
      #9'left outer join REHBER R on R.ID=C.REHBERID'
      
        '                left outer join REHBER Rciro on Rciro.ID=C.CIROR' +
        'EHBERID'
      #9'left outer JOIN BANKASUBELER BS ON BS.ID = C.BANKASUBELERID'
      #9'left outer JOIN BANKALAR B ON B.BANKAKODU = BS.BANKAKODU'
      #9'left outer join MASRAFGELIR M on M.ID=C.MASRAFID'
      ' Where  C.TARIH >=@BaslangicTarih  and C.TARIH <@BitisTarih '
      ' and C.SUBEID in(0,-2,-1) '
      '--'#231'ek'
      'union all'
      'SELECT '
      ' TIP=case '
      '    when C.TUR IN(40,45,46,55,56,81) THEN '#39'Transfer'#39'  '
      #9'WHEN C.TUR IN(3,8,10,11,12,13,109)  THEN '#39'Al'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(4,14,15,16,17,110,119)  THEN '#39'Sat'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(31,32,33,34,35,36,38,37,39,57,58) THEN '#39#214'deme'#39
      
        #9'WHEN C.TUR IN(21,23,24,25,26,27,28,29,52,54,59,91,95) THEN '#39'Tah' +
        'silat'#39
      
        #9'WHEN C.TUR IN(6,7,20,41,42,43,47,48,49,51,53,121,122) THEN '#39'Tra' +
        'nsfer'#39
      #9'END,  '
      '    TUR=33,'
      #9'BORC = C.TUTAR,'
      #9'ALACAK =0.0,'
      #9
      #9'C.KUR'
      'FROM '
      #9'CEKLER C'
      #9'left outer join REHBER R on R.ID=C.REHBERID'
      
        '                left outer join REHBER Rciro on Rciro.ID=C.CIROR' +
        'EHBERID'
      #9'left outer JOIN BANKASUBELER BS ON BS.ID = C.BANKASUBELERID'
      #9'left outer JOIN BANKALAR B ON B.BANKAKODU = BS.BANKAKODU'
      #9'left outer join MASRAFGELIR M on M.ID=C.MASRAFID'
      
        ' Where C.DURUM=4 and  C.CIROTARIH >= @BaslangicTarih and C.CIROT' +
        'ARIH <@BitisTarih '
      ' and C.SUBEID in(0,-2,-1) '
      '---'#231'ek '#246'deme / tahsilat'
      'UNION ALL'
      ''
      'Select '
      'TIP=case '
      '    when C.TUR IN(40,45,46,55,56,81) THEN '#39'Transfer'#39'  '
      #9'WHEN C.TUR IN(3,8,10,11,12,13,109)  THEN '#39'Al'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(4,14,15,16,17,110,119)  THEN '#39'Sat'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(31,32,33,34,35,36,38,37,39,57,58) THEN '#39#214'deme'#39
      
        #9'WHEN C.TUR IN(21,23,24,25,26,27,28,29,52,54,59,91,95) THEN '#39'Tah' +
        'silat'#39
      
        #9'WHEN C.TUR IN(6,7,20,41,42,43,47,48,49,51,53,121,122) THEN '#39'Tra' +
        'nsfer'#39
      #9'END,  '
      '    K.TUR,BORC , ALACAK,'
      #9' '
      #9'K.KUR'
      'FROM CEKLER C(NOLOCK) '
      '     inner join KASA K on C.ID=K.CEKSENETID'
      '     left outer join REHBER R on R.ID=K.REHBERID'
      '     left outer join MASRAFGELIR M on M.ID=K.MASRAFID'
      
        ' Where  K.ISLEMTARIHI >=@BaslangicTarih  and K.ISLEMTARIHI < @Bi' +
        'tisTarih and K.TUR in (51,52,53,54)'
      ' and K.SUBEID in(0,-2,-1) '
      '---senet'
      'UNION ALL'
      'SELECT '
      'TIP=case '
      '    when C.TUR IN(40,45,46,55,56,81) THEN '#39'Transfer'#39'  '
      #9'WHEN C.TUR IN(3,8,10,11,12,13,109)  THEN '#39'Al'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(4,14,15,16,17,110,119)  THEN '#39'Sat'#305#351' Belgesi'#39
      #9'WHEN C.TUR IN(31,32,33,34,35,36,38,37,39,57,58) THEN '#39#214'deme'#39
      
        #9'WHEN C.TUR IN(21,23,24,25,26,27,28,29,52,54,59,91,95) THEN '#39'Tah' +
        'silat'#39
      
        #9'WHEN C.TUR IN(6,7,20,41,42,43,47,48,49,51,53,121,122) THEN '#39'Tra' +
        'nsfer'#39
      #9'END,  '
      #9'C.TUR,'
      #9'BORC = case when C.TUR=34 then  C.TUTAR else 0    end,'
      #9'ALACAK = case when C.TUR=24 then  C.TUTAR else 0    end,'
      #9
      #9'C.KUR '
      'FROM '
      #9'SENETLER C'
      #9'inner join REHBER R on R.ID=C.REHBERID'
      #9'left outer join MASRAFGELIR MG on MG.ID=C.MASRAFID'
      ' Where  C.TARIH >=@BaslangicTarih  and C.TARIH <@BitisTarih '
      ' and C.SUBEID in(0,-2,-1) ')
    Left = 1440
    Top = 344
  end
  object DtsKasaOzet: TDataSource
    DataSet = TabKasaOzet
    Left = 1512
    Top = 344
  end
  object TabGenelSorgu: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 696
    Top = 40
  end
  object TabCihazBilgisi: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabCihazBilgisiBeforePost
    ParamData = <>
    SQL.Strings = (
      
        'IF  EXISTS (SELECT * FROM tempdb.sys.objects WHERE name='#39'##TEMPP' +
        'OS'#39' AND type='#39'u'#39')'
      'DROP TABLE ##TEMPPOS'
      
        'SELECT ID AS KASAACKAPAT_ID,ADI,BANKAHESAPID,KUR INTO ##TEMPPOS ' +
        'FROM dbo.POS'
      'ALTER TABLE ##TEMPPOS ADD TUTAR_KAPANIS MONEY'
      'ALTER TABLE ##TEMPPOS ADD YER INTEGER'
      'UPDATE ##TEMPPOS SET YER=11'
      
        'INSERT INTO ##TEMPPOS (ADI,KUR,TUTAR_KAPANIS,YER) VALUES ('#39'Yazar' +
        ' Kasa Nakit'#39','#39'TL'#39',0,5)'
      
        'INSERT INTO ##TEMPPOS (ADI,KUR,TUTAR_KAPANIS,YER) VALUES ('#39'Yazar' +
        ' Kasa Pos'#39','#39'TL'#39',0,6)'
      'UPDATE ##TEMPPOS SET TUTAR_KAPANIS=0'
      'UPDATE ##TEMPPOS SET BANKAHESAPID=0 WHERE YER=5'
      'UPDATE ##TEMPPOS SET BANKAHESAPID=0 WHERE YER=6'
      'UPDATE ##TEMPPOS SET BANKAHESAPID=0 WHERE YER=7'
      'SELECT * FROM ##TEMPPOS')
    Left = 2024
    Top = 216
  end
  object DtsCihazBilgisi: TDataSource
    DataSet = TabCihazBilgisi
    Left = 2176
    Top = 216
  end
  object TabSayimBilgisi: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabSayimBilgisiBeforePost
    ParamData = <>
    SQL.Strings = (
      
        'IF  EXISTS (SELECT * FROM tempdb.sys.objects WHERE name='#39'##TEMPK' +
        'UP'#39' AND type='#39'u'#39')'
      'DROP TABLE ##TEMPKUP'
      
        'SELECT ID AS KASAACKAPAT_ID,TUR,ADI,KUR INTO ##TEMPKUP FROM dbo.' +
        'PARA_KUPON WHERE TUR=26'
      'ALTER TABLE ##TEMPKUP ADD TUTAR_KAPANIS MONEY'
      'ALTER TABLE ##TEMPKUP ADD HESAPID INTEGER'
      'ALTER TABLE ##TEMPKUP ADD YER INTEGER'
      
        'INSERT INTO ##TEMPKUP (ADI,TUTAR_KAPANIS,YER) VALUES ('#39'Nakit Tut' +
        'ar'#39',0,100)'
      
        'INSERT INTO ##TEMPKUP (ADI,TUTAR_KAPANIS,YER) VALUES ('#39'Hediye '#199'e' +
        'ki Say'#305'm Tutar'#39',0,40)'
      
        'INSERT INTO ##TEMPKUP (ADI,TUTAR_KAPANIS,YER) VALUES ('#39#304'ade Say'#305 +
        'm Tutar'#39',0,50)'
      'UPDATE ##TEMPKUP SET TUTAR_KAPANIS=0'
      'UPDATE ##TEMPKUP SET KUR='#39'TL'#39
      'UPDATE ##TEMPKUP SET YER=30 WHERE TUR=26'
      'SELECT * FROM ##TEMPKUP')
    Left = 2048
    Top = 520
  end
  object DtsSayimBilgisi: TDataSource
    DataSet = TabSayimBilgisi
    Left = 2136
    Top = 520
  end
  object TabFunction: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 768
    Top = 40
  end
  object TabTempCihazIslem: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 2096
    Top = 216
  end
  object TabTempSayimIslem: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 2216
    Top = 520
  end
  object TabGiris: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 832
    Top = 40
  end
  object TabKasaAcKapatSuzmeList: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabKasaAcKapatSuzmeListAfterScroll
    ParamData = <>
    Left = 48
    Top = 288
  end
  object DtsKasaAcKapatSuzmeList: TDataSource
    DataSet = TabKasaAcKapatSuzmeList
    Left = 136
    Top = 288
  end
  object TabAcikKasaBilgi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 896
    Top = 65472
  end
end
