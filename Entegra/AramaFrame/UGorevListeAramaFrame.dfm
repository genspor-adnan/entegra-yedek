object GorevListeAramaFrame: TGorevListeAramaFrame
  Left = 0
  Top = 0
  Width = 369
  Height = 448
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object PageListeler: TcxPageControl
    Left = 0
    Top = 0
    Width = 369
    Height = 448
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Properties.ActivePage = TabSheetListe
    Properties.CustomButtons.Buttons = <>
    Properties.Images = Tablo.imgScheduler
    OnChange = PageListelerChange
    ClientRectBottom = 444
    ClientRectLeft = 4
    ClientRectRight = 365
    ClientRectTop = 29
    object TabSheetListe: TcxTabSheet
      Caption = #304#351'ler '
      ImageIndex = 46
      object JvNavPanelHeader1: TJvNavPanelHeader
        Left = 0
        Top = 0
        Width = 361
        Height = 32
        Align = alTop
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        ColorFrom = 14540253
        ColorTo = 11776947
        ImageIndex = 0
        object EditAraIsler: TcxTextEdit
          Left = 39
          Top = 0
          Align = alClient
          Style.Color = clSilver
          TabOrder = 0
          TextHint = 'Liste Ara'
          OnKeyUp = EditAraIslerKeyUp
          Width = 322
        end
        object LabelAra: TJvNavPanelHeader
          Left = 0
          Top = 0
          Width = 39
          Height = 32
          Align = alLeft
          Caption = 'Ara'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -15
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          ColorFrom = 14540253
          ColorTo = 11776947
          ImageIndex = 17
          OnClick = LabelAraClick
        end
      end
      object TreeListeler: TcxDBTreeList
        Left = 0
        Top = 32
        Width = 361
        Height = 351
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsListe
        DataController.ImageIndexField = 'RESIM'
        DataController.ParentField = 'USTID'
        DataController.KeyField = 'ID'
        DefaultRowHeight = 25
        DragMode = dmAutomatic
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        Images = Tablo.KlasorResimleri
        LookAndFeel.NativeStyle = True
        Navigator.Buttons.CustomButtons = <>
        OptionsBehavior.CopyCaptionsToClipboard = False
        OptionsBehavior.DragDropText = True
        OptionsBehavior.DragFocusing = True
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsSelection.CellSelect = False
        OptionsView.ScrollBars = ssVertical
        OptionsView.Headers = False
        OptionsView.TreeLineStyle = tllsNone
        ParentFont = False
        PopupMenu = ListeMenu
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        Styles.Background = Tablo.cxStyle13
        Styles.Content = Tablo.cxStyle12
        TabOrder = 1
        OnDblClick = TreeListelerDblClick
        OnDragDrop = TreeListelerDragDrop
        OnDragOver = TreeListelerDragOver
        OnMoveTo = TreeListelerMoveTo
        object TreeListRollercxDBTreeListColumn1: TcxDBTreeListColumn
          Visible = False
          Caption.AlignVert = vaTop
          DataBinding.FieldName = 'ID'
          Width = 150
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeListRollercxDBTreeListColumn2: TcxDBTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Caption.AlignVert = vaTop
          DataBinding.FieldName = 'ADI'
          MinWidth = 200
          Width = 400
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object MemoKontrol: TcxMemo
        Left = 16
        Top = 56
        Align = alCustom
        Lines.Strings = (
          'MemoKontrol')
        TabOrder = 2
        Visible = False
        Height = 49
        Width = 377
      end
      object ListeEkleTus: TcxButton
        Left = 0
        Top = 383
        Width = 361
        Height = 32
        Hint = 'Yeni Liste Olu'#351'tur'
        Align = alBottom
        Caption = 'Liste Olu'#351'tur'
        OptionsImage.ImageIndex = 12
        OptionsImage.Images = Tablo.imgScheduler
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnClick = ListeEkleTusClick
      end
      object MemoListe: TcxMemo
        Left = 24
        Top = 126
        Align = alCustom
        Lines.Strings = (
          'select  distinct * from ('
          'SELECT GL.ID, '
          'GL.USTID,GL.ADI,GL.RESIM,PROJEID=0,EKLEYEN=0,GL.HERKESEACIK'
          ' FROM GOREVLISTE GL '
          '  WHERE GL.ID < 0'
          '  --Opsiyon'
          '-----'
          'union all'
          '-----'
          'SELECT '
          #9'GL.ID, '
          'GL.USTID,GL.ADI,GL.RESIM,GL.PROJEID,'
          'GL.EKLEYEN,GL.HERKESEACIK'
          'FROM GOREVLISTE GL '
          #9'left join GOREVKULLANICI GK on GL.ID=GK.LISTGOREVID '
          'AND GK.TUR<=5'
          'WHERE '
          #9'GL.DURUM=1 AND '
          #9'(GL.HERKESEACIK=1 OR GL.EKLEYEN=:Kul1 OR '
          #9'1=case  when GK.TUR=1 and GK.REHBERID =:Kul2 then 1'
          #9'when GK.TUR=2 and GK.REHBERID=:Gorev then 1'
          #9'when GK.TUR=3 and GK.REHBERID=:Dep then 1'
          #9'when GK.TUR=4 and GK.REHBERID=:Sube then 1'
          #9'end'
          ')'
          ')as List')
        TabOrder = 4
        Visible = False
        Height = 134
        Width = 377
      end
    end
    object TabSheetProje: TcxTabSheet
      Caption = 'Projeler'
      ImageIndex = 39
      object TreeProjeler: TcxDBTreeList
        Left = 0
        Top = 32
        Width = 361
        Height = 351
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsListe
        DataController.ImageIndexField = 'RESIM'
        DataController.ParentField = 'USTID'
        DataController.KeyField = 'ID'
        DefaultRowHeight = 25
        DragMode = dmAutomatic
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        Images = Tablo.KlasorResimleri
        LookAndFeel.NativeStyle = True
        Navigator.Buttons.CustomButtons = <>
        OptionsBehavior.CopyCaptionsToClipboard = False
        OptionsBehavior.DragDropText = True
        OptionsBehavior.DragFocusing = True
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsSelection.CellSelect = False
        OptionsView.ScrollBars = ssVertical
        OptionsView.Headers = False
        OptionsView.TreeLineStyle = tllsNone
        ParentFont = False
        PopupMenu = ListeMenu
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        Styles.Background = Tablo.cxStyle13
        Styles.Content = Tablo.cxStyle12
        TabOrder = 0
        OnDblClick = TreeListelerDblClick
        OnDragDrop = TreeListelerDragDrop
        OnDragOver = TreeListelerDragOver
        OnMoveTo = TreeListelerMoveTo
        object cxDBTreeListColumn1: TcxDBTreeListColumn
          Visible = False
          Caption.AlignVert = vaTop
          DataBinding.FieldName = 'ID'
          Width = 150
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeListColumn2: TcxDBTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Caption.AlignVert = vaTop
          DataBinding.FieldName = 'ADI'
          MinWidth = 200
          Width = 400
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object cxButton1: TcxButton
        Tag = 1
        Left = 0
        Top = 383
        Width = 361
        Height = 32
        Hint = 'Yeni Liste Olu'#351'tur'
        Align = alBottom
        Caption = 'Proje Olu'#351'tur'
        OptionsImage.ImageIndex = 12
        OptionsImage.Images = Tablo.imgScheduler
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = cxButton1Click
      end
      object MemoProjeler: TcxMemo
        Left = 16
        Top = 72
        Align = alCustom
        Lines.Strings = (
          'select ID=-1*DEGER, USTID=-1*DEGER, ADI=ANAHTAR, RESIM=1, '
          #9'PROJEID=DEGER, EKLEYEN=NULL,REHBERID=NULL  '
          'from GENINI '
          'where BOLUM=-2113 and DIL=-1'
          'UNION ALL'
          'SELECT P.ID, USTID=-1*P.ASAMA, ADI=P.PROJEKODU, RESIM=0, '
          #9'PROJEID=P.ID, P.EKLEYEN, P.REHBERID  '
          'FROM [PROJELER] P '
          'WHERE P.DURUM=1 ')
        TabOrder = 2
        Visible = False
        Height = 49
        Width = 377
      end
      object JvNavPanelHeader2: TJvNavPanelHeader
        Left = 0
        Top = 0
        Width = 361
        Height = 32
        Align = alTop
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        ColorFrom = 14540253
        ColorTo = 11776947
        ImageIndex = 0
        object EditAraProje: TcxTextEdit
          Left = 39
          Top = 0
          Align = alClient
          Style.Color = clSilver
          TabOrder = 0
          TextHint = 'Liste Ara'
          OnKeyUp = EditAraIslerKeyUp
          Width = 322
        end
        object JvNavPanelHeader3: TJvNavPanelHeader
          Left = 0
          Top = 0
          Width = 39
          Height = 32
          Align = alLeft
          Caption = 'Ara'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -15
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          ColorFrom = 14540253
          ColorTo = 11776947
          ImageIndex = 17
          OnClick = LabelAraClick
        end
      end
    end
    object TabSheetArama: TcxTabSheet
      Caption = 'Ara'
      Color = clWhite
      ImageIndex = 29
      ParentColor = False
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 361
        Height = 415
        Align = alClient
        Color = clSilver
        ParentBackground = False
        TabOrder = 0
        object lblPNO: TcxLabel
          Left = 5
          Top = 39
          Caption = 'M'#252#351'teri'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object lbl4: TcxLabel
          Left = 5
          Top = 10
          Caption = 'Konu/Notlar'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object lbl6: TcxLabel
          Left = 5
          Top = 179
          Caption = 'Atanan'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LabelAtayan: TcxLabel
          Left = 5
          Top = 151
          Caption = 'Olu'#351'turan'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object dateAktBitis: TcxDateEdit
          Left = 77
          Top = 120
          Enabled = False
          Properties.ClearKey = 46
          Properties.ImmediatePost = True
          Properties.ShowTime = False
          TabOrder = 4
          Width = 115
        end
        object dateAktBaslangic: TcxDateEdit
          Left = 77
          Top = 92
          Enabled = False
          Properties.ClearKey = 46
          Properties.ImmediatePost = True
          Properties.ShowTime = False
          TabOrder = 8
          Width = 115
        end
        object ComboKonusu: TcxTextEdit
          Left = 77
          Top = 8
          TabOrder = 5
          Width = 115
        end
        object AraFirma: TcxButtonEdit
          Left = 77
          Top = 36
          HelpContext = -1
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = AraFirmaPropertiesButtonClick
          ShowHint = True
          TabOrder = 6
          Width = 115
        end
        object EditAtanan: TcxButtonEdit
          Left = 77
          Top = 176
          HelpContext = 335
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = AraFirmaPropertiesButtonClick
          ShowHint = True
          TabOrder = 9
          Width = 115
        end
        object checkTarih: TcxCheckBox
          Left = 5
          Top = 107
          Caption = 'Tarih'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Properties.OnEditValueChanged = checkTarihPropertiesEditValueChanged
          TabOrder = 10
          Transparent = True
        end
        object cxLabel1: TcxLabel
          Left = 29
          Top = 337
          Caption = 'Proje'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
          Visible = False
        end
        object EditProje: TcxButtonEdit
          Left = 101
          Top = 333
          Hint = 'Proje ekran'#305'n'#305' a'#231'mak i'#231'in '#231'ift t'#305'klay'#305'n'#305'z.'
          ParentShowHint = False
          Properties.Buttons = <
            item
              Caption = '++'
              Default = True
              Kind = bkText
            end
            item
              Caption = '+'
              Hint = 'Temizle'
              Kind = bkText
            end
            item
              Caption = '-'
              Kind = bkText
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = True
          ShowHint = True
          TabOrder = 12
          Visible = False
          Width = 115
        end
        object EditOlusturan: TcxButtonEdit
          Left = 77
          Top = 148
          HelpContext = 335
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = AraFirmaPropertiesButtonClick
          ShowHint = True
          TabOrder = 13
          Width = 115
        end
        object CheckTemas: TcxCheckBox
          Left = 69
          Top = 238
          Caption = 'Temas Kurulacaklar'
          Properties.NullStyle = nssUnchecked
          TabOrder = 14
          Transparent = True
          Visible = False
          OnClick = CheckTemasClick
        end
        object EditID: TcxTextEdit
          Left = 77
          Top = 64
          TabOrder = 7
          Width = 115
        end
        object cxLabel2: TcxLabel
          Left = 5
          Top = 66
          Caption = #304#351' ID'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
      end
    end
  end
  object DtsListe: TDataSource
    DataSet = TabListe
    Left = 113
    Top = 308
  end
  object TabListe: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 50
    Top = 305
  end
  object ListeMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OnPopup = ListeMenuPopup
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 176
    Top = 104
    object YeniListeOlutur1: TMenuItem
      Caption = 'Yeni Liste Olu'#351'tur'
      ImageIndex = 0
      ImageName = 'PngImage0'
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object ListeyiDuzenleMenu: TMenuItem
      Tag = 1
      Caption = 'Liste Ad'#305'n'#305' De'#287'i'#351'tir'
      ImageIndex = 7
      ImageName = 'PngImage7'
      OnClick = ListeyiDuzenleMenuClick
    end
    object ListeyeKisiEkle1: TMenuItem
      Tag = 1
      Caption = 'Listeye Ki'#351'i Ekle/Sil'
      OnClick = ListeyiDuzenleMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExceldenBilgiAl1: TMenuItem
      Caption = 'Excelden Bilgi Al (Import)'
      OnClick = ExceldenBilgiAl1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object ListeyiEPostaileGnder1: TMenuItem
      Caption = 'Listeyi E-Posta ile G'#246'nder'
    end
    object ListyiYazdr1: TMenuItem
      Caption = 'Listeyi Yazd'#305'r'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object ListeyiKopyala1: TMenuItem
      Caption = 'Listeyi Kopyala'
      OnClick = ListeyiKopyala1Click
    end
    object ListeyiSilMenu: TMenuItem
      Caption = 'Listeyi Sil'
      ImageIndex = 1
      ImageName = 'PngImage1'
      OnClick = ListeyiSilMenuClick
    end
  end
end



