object UTSDlg: TUTSDlg
  Left = 0
  Top = 0
  Caption = #220'TS Bildirim Ekran'#305
  ClientHeight = 595
  ClientWidth = 1370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 13
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 0
    Width = 1370
    Height = 33
    Align = alTop
    TabOrder = 0
    Properties.ActivePage = cxTabSheet2
    Properties.CustomButtons.Buttons = <>
    LookAndFeel.Kind = lfFlat
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'VS2010'
    OnChange = cxPageControl1Change
    ClientRectBottom = 31
    ClientRectLeft = 2
    ClientRectRight = 1368
    ClientRectTop = 31
    object cxTabSheet2: TcxTabSheet
      Caption = 'Sorgula / G'#246'nder'
      ImageIndex = 1
    end
    object cxTabSheet6: TcxTabSheet
      Caption = 'Ba'#351'ar'#305'l'#305'lar'
      ImageIndex = 4
    end
    object cxTabSheet5: TcxTabSheet
      Caption = 'Hatal'#305'lar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ImageIndex = 3
      ParentFont = False
    end
    object cxTabSheet1: TcxTabSheet
      Caption = #304'ptaller'
      ImageIndex = 4
    end
  end
  object PanelKategori: TJvNavPaneToolPanel
    Left = 0
    Top = 33
    Width = 188
    Height = 562
    Align = alLeft
    Background.Stretch = False
    Background.Proportional = False
    Background.Center = False
    Background.Tile = False
    Background.Transparent = False
    Buttons = <>
    ButtonWidth = 0
    ButtonHeight = 0
    Images = Tablo.PngImageListTicari
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    ExplicitLeft = -2
    ExplicitTop = 190
    ExplicitHeight = 280
    object HeaderBildirimler: TJvNavPanelHeader
      Left = 2
      Top = 40
      Width = 184
      Align = alTop
      Caption = 'Bildirimler'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = clGray
      ColorTo = clBlack
      Images = Tablo.cxImageList3
      ImageIndex = 0
    end
    object HeaderSorgular: TJvNavPanelHeader
      Left = 2
      Top = 67
      Width = 184
      Align = alTop
      Caption = #220'TS'#39'den Sorgular'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = clGray
      ColorTo = clBlack
      Images = Tablo.cxImageList3
      ImageIndex = 0
      OnClick = HeaderSorgularClick
    end
  end
  object Panel2: TPanel
    Left = 196
    Top = 33
    Width = 1174
    Height = 562
    Align = alClient
    TabOrder = 2
    object PageControlListe: TcxPageControl
      Left = 1
      Top = 184
      Width = 1172
      Height = 304
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = TabSheetSorgu
      Properties.CustomButtons.Buttons = <>
      ClientRectBottom = 300
      ClientRectLeft = 4
      ClientRectRight = 1168
      ClientRectTop = 24
      object TabSheetSorgu: TcxTabSheet
        Caption = 'Sorgu Listesi'
        ImageIndex = 1
        object GridSorgu: TcxGrid
          Left = 0
          Top = 0
          Width = 1164
          Height = 276
          Align = alClient
          TabOrder = 0
          object GridSorguView: TcxGridDBTableView
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
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridSorguViewCanFocusRecord
            DataController.DataSource = DtsSorgu
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.MultiSelect = True
            OptionsSelection.HideFocusRectOnExit = False
            OptionsSelection.UnselectFocusedRecordOnExit = False
            OptionsView.CellAutoHeight = True
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.FooterMultiSummaries = True
            OptionsView.Indicator = True
          end
          object cxGridLevel1: TcxGridLevel
            GridView = GridSorguView
          end
        end
        object sqlMemo1: TcxMemo
          Left = 96
          Top = 48
          Lines.Strings = (
            'SELECT '
            
              '    SUM(SDI.KALAN) + ISNULL(IRS.ACIK_IRSALIYE, 0) AS [STOK_ARTI_' +
              'IRSALIYE]'
            'FROM '
            '    STOKLAR S'
            '    INNER JOIN STOKSERILOT SL ON SL.STOKID = S.ID'
            
              '    INNER JOIN STOKDURUMIZLEME SDI ON SDI.STOKID = S.ID AND SDI.' +
              'SERILOTID = SL.ID'
            '    OUTER APPLY ('
            '        SELECT SUM(KALAN) AS ACIK_IRSALIYE '
            '        FROM STOKIZLEME '
            '        WHERE STOKID = S.ID '
            '          AND SERILOTID = SL.ID '
            '          AND BELGETUR = 14'
            '    ) IRS'
            'WHERE '
            '    ( S.URUNNO = :PRM1 or S.URUNNO = :PRM2 )'
            '    AND SL.LOTNO = :PRM3'
            '    AND S.IZLEME > 0 -- ISNULL yerine do'#287'rudan kontrol'
            'GROUP BY '
            '    S.KOD, '
            '    S.URUNNO, '
            '    SL.ID, '
            '    SL.LOTNO, '
            '    IRS.ACIK_IRSALIYE;')
          TabOrder = 1
          Visible = False
          Height = 33
          Width = 458
        end
      end
      object TabSheetBildirim: TcxTabSheet
        Caption = 'Bildirim Listesi'
        ImageIndex = 0
        object GridUTS: TcxGrid
          Left = 0
          Top = 0
          Width = 1164
          Height = 276
          Align = alClient
          TabOrder = 0
          object GridUTSView: TcxGridDBTableView
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
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridUTSViewCanFocusRecord
            DataController.DataSource = DtsBasari
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skCount
                Column = GridComboTur
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.MultiSelect = True
            OptionsSelection.CellMultiSelect = True
            OptionsSelection.HideFocusRectOnExit = False
            OptionsSelection.InvertSelect = False
            OptionsSelection.UnselectFocusedRecordOnExit = False
            OptionsView.CellAutoHeight = True
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.FooterMultiSummaries = True
            OptionsView.Indicator = True
            object GridUTSViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object cxGridDBColumn19: TcxGridDBColumn
              DataBinding.FieldName = 'YER'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object cxGridDBColumn20: TcxGridDBColumn
              DataBinding.FieldName = 'YERID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridComboTur: TcxGridDBColumn
              Caption = 'T'#220'R'
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
            end
            object GridUTSViewEKLEMETARIHI: TcxGridDBColumn
              Caption = 'B'#304'LD'#304'R'#304'M TAR'#304'H'#304
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Width = 95
            end
            object GridUTSViewKURUMNO: TcxGridDBColumn
              Caption = 'KURUM NO'
              DataBinding.FieldName = 'KURUMNO'
              DataBinding.IsNullValueType = True
            end
            object GridUTSViewFIRMA: TcxGridDBColumn
              Caption = 'KURUM ADI'
              DataBinding.FieldName = 'FIRMA'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxTextEditProperties'
              Width = 120
            end
            object GridUTSViewBELGENO: TcxGridDBColumn
              Caption = 'BELGE NO'
              DataBinding.FieldName = 'BELGENO'
              DataBinding.IsNullValueType = True
              Width = 73
            end
            object cxGridDBTARIH: TcxGridDBColumn
              Caption = 'BELGE TAR'#304'H'#304
              DataBinding.FieldName = 'TARIH'
              DataBinding.IsNullValueType = True
              Width = 82
            end
            object cxGridDBColumn24: TcxGridDBColumn
              DataBinding.FieldName = 'ADET'
              DataBinding.IsNullValueType = True
              Width = 50
            end
            object cxGridDBColumn25: TcxGridDBColumn
              DataBinding.FieldName = 'ID_1'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object cxGridDBColumn27: TcxGridDBColumn
              DataBinding.FieldName = 'URUNNO'
              DataBinding.IsNullValueType = True
              Width = 62
            end
            object GridUTSViewSTOKKODU: TcxGridDBColumn
              Caption = 'STOK KODU'
              DataBinding.FieldName = 'STOKKODU'
              DataBinding.IsNullValueType = True
            end
            object GridUTSViewSTOKADI: TcxGridDBColumn
              Caption = #220'R'#220'N ADI'
              DataBinding.FieldName = 'STOKADI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxTextEditProperties'
              Width = 100
            end
            object cxGridDBColumn28: TcxGridDBColumn
              DataBinding.FieldName = 'SERINO'
              DataBinding.IsNullValueType = True
              Width = 56
            end
            object cxGridDBColumn29: TcxGridDBColumn
              DataBinding.FieldName = 'LOTNO'
              DataBinding.IsNullValueType = True
              Width = 73
            end
            object GridUTSViewURT: TcxGridDBColumn
              DataBinding.FieldName = 'URT'
              DataBinding.IsNullValueType = True
            end
            object GridUTSViewSKT: TcxGridDBColumn
              DataBinding.FieldName = 'SKT'
              DataBinding.IsNullValueType = True
            end
            object cxGridDBColumn30: TcxGridDBColumn
              DataBinding.FieldName = 'JSON'
              DataBinding.IsNullValueType = True
            end
            object cxGridDBColumn31: TcxGridDBColumn
              DataBinding.FieldName = 'SONUCKODU'
              DataBinding.IsNullValueType = True
            end
            object cxGridDBColumn32: TcxGridDBColumn
              DataBinding.FieldName = 'SONUCMESAJI'
              DataBinding.IsNullValueType = True
            end
            object cxGridDBColumn33: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEYEN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object cxGridDBColumn34: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridUTSViewONAYLAYAN: TcxGridDBColumn
              DataBinding.FieldName = 'ONAYLAYAN'
              DataBinding.IsNullValueType = True
            end
          end
          object cxGridLevel3: TcxGridLevel
            GridView = GridUTSView
          end
        end
      end
    end
    object Panel4: TPanel
      Left = 1
      Top = 42
      Width = 1172
      Height = 142
      Align = alTop
      TabOrder = 1
      object Panel3: TPanel
        Left = 393
        Top = 1
        Width = 352
        Height = 140
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object ButtonYenile: TJvTransparentButton
          Left = 6
          Top = 30
          Width = 53
          Height = 79
          Caption = 'Listele'
          TextAlign = ttaBottom
          OnClick = ButtonYenileClick
          Images.ActiveImage = Tablo.cxImageList1
          Images.ActiveIndex = 28
          Images.GrayImage = Tablo.cxImageList1
          Images.GrayIndex = 28
        end
        object ButtonTumSec: TJvTransparentButton
          Left = 65
          Top = 31
          Width = 100
          Height = 23
          Caption = 'T'#252'm'#252'n'#252' Se'#231
          TextAlign = ttaRight
          OnClick = JvTransparentButton2Click
          Images.ActiveImage = Tablo.cxImageListPDKS
          Images.ActiveIndex = 1
          Images.GrayImage = Tablo.cxImageListPDKS
          Images.GrayIndex = 1
        end
        object ButtonTumKaldir: TJvTransparentButton
          Left = 65
          Top = 58
          Width = 100
          Height = 23
          Caption = 'Se'#231'imi Kald'#305'r'
          TextAlign = ttaRight
          OnClick = ButtonTumKaldirClick
          Images.ActiveImage = Tablo.cxImageListPDKS
          Images.ActiveIndex = 2
          Images.GrayImage = Tablo.cxImageListPDKS
          Images.GrayIndex = 2
        end
        object ButtonSecimiCevir: TJvTransparentButton
          Left = 65
          Top = 84
          Width = 100
          Height = 25
          Caption = 'Se'#231'imi '#199'evir'
          TextAlign = ttaRight
          OnClick = JvTransparentButton4Click
          Images.ActiveImage = Tablo.cxImageListPDKS
          Images.ActiveIndex = 5
          Images.GrayImage = Tablo.cxImageListPDKS
          Images.GrayIndex = 5
        end
        object PanelButton: TPanel
          Left = 170
          Top = 32
          Width = 303
          Height = 79
          BevelOuter = bvNone
          TabOrder = 0
          object ButtonBildirimIptal: TJvTransparentButton
            Left = 53
            Top = 0
            Width = 53
            Height = 79
            Align = alLeft
            Caption = 'Bildirimi '#304'ptal Et'
            TextAlign = ttaBottom
            Visible = False
            WordWrap = True
            OnClick = ButtonBildirimIptalClick
            Images.ActiveImage = Tablo.cxImageList1
            Images.ActiveIndex = 1
            Images.GrayImage = Tablo.cxImageList1
            Images.GrayIndex = 1
            Images.DisabledImage = Tablo.cximage
            ExplicitLeft = 47
          end
          object ButtonGonder: TJvTransparentButton
            Left = 0
            Top = 0
            Width = 53
            Height = 79
            Align = alLeft
            Caption = #220'TS ye Bildir'
            TextAlign = ttaBottom
            Visible = False
            WordWrap = True
            OnClick = ButtonGonderClick
            Images.ActiveImage = Tablo.cxImageList1
            Images.ActiveIndex = 39
            Images.GrayImage = Tablo.cxImageList1
            Images.DisabledImage = Tablo.cximage
            ExplicitLeft = 1
            ExplicitTop = -3
          end
          object ButtonSil: TJvTransparentButton
            Left = 106
            Top = 0
            Width = 53
            Height = 79
            Align = alLeft
            Caption = 'sil'
            TextAlign = ttaBottom
            Visible = False
            WordWrap = True
            OnClick = ButtonSilClick
            Images.ActiveImage = Tablo.cxImageList1
            Images.ActiveIndex = 2
            Images.GrayImage = Tablo.cxImageList1
            Images.GrayIndex = 2
            Images.DisabledImage = Tablo.cximage
            ExplicitLeft = 218
          end
        end
        object CheckSKTGonderme: TcxCheckBox
          Left = 171
          Top = 114
          Caption = 'SKT G'#246'nderme'
          TabOrder = 1
          Visible = False
          OnClick = CheckBitisTarihClick
        end
      end
      object PanelFisOlus: TPanel
        Left = 1
        Top = 1
        Width = 392
        Height = 140
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        Visible = False
        object LabelUTSAdetSorgula: TcxLabel
          Left = -2
          Top = 14
          Cursor = crHandPoint
          Caption = #220'TS'#39'den Adet Sorgula'
          Style.Shadow = False
          Style.TextColor = clNavy
          Style.TextStyle = [fsBold, fsUnderline]
          Style.TransparentBorder = True
          Properties.PenWidth = 2
          Transparent = True
          OnClick = LabelUTSAdetSorgulaClick
        end
        object PanelFisSol: TPanel
          Left = 108
          Top = 31
          Width = 108
          Height = 98
          BevelOuter = bvNone
          TabOrder = 1
          object LabelUTSBildirimSorgula: TcxLabel
            Left = 4
            Top = 6
            Cursor = crHandPoint
            Caption = #220'TS'#39'den Bildirim Sorgula'
            Style.Shadow = False
            Style.TextColor = clNavy
            Style.TextStyle = [fsBold, fsUnderline]
            Style.TransparentBorder = True
            Properties.PenWidth = 2
            Properties.WordWrap = True
            Transparent = True
            OnClick = LabelUTSBildirimSorgulaClick
            Width = 98
          end
          object LabelGirisFisiOlustur: TcxLabel
            Tag = 3
            Left = 0
            Top = 48
            Cursor = crHandPoint
            Caption = 'Belge Olu'#351'tur'
            Style.Shadow = False
            Style.TextColor = clNavy
            Style.TextStyle = [fsBold, fsUnderline]
            Style.TransparentBorder = True
            Properties.PenWidth = 2
            Transparent = True
            OnClick = LabelGirisFisiOlusturClick
          end
          object LabelKonsinyeOlustur: TcxLabel
            Tag = 119
            Left = 0
            Top = 72
            Cursor = crHandPoint
            Caption = 'Konsinye Olu'#351'tur'
            ParentFont = False
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = [fsUnderline]
            Style.Shadow = False
            Style.TextColor = clNavy
            Style.TextStyle = [fsBold, fsUnderline]
            Style.TransparentBorder = True
            Style.IsFontAssigned = True
            Properties.PenWidth = 2
            Transparent = True
            OnClick = LabelGirisFisiOlusturClick
          end
          object ComboFisAdet: TcxComboBox
            Left = 111
            Top = 24
            Properties.DropDownListStyle = lsFixedList
            Properties.Items.Strings = (
              'Adet'
              'GelenAdet')
            Properties.ReadOnly = False
            Style.Color = clBtnFace
            TabOrder = 3
            Text = 'GelenAdet'
            Width = 74
          end
        end
        object PanelFisSag: TPanel
          Left = 216
          Top = -1
          Width = 185
          Height = 136
          BevelOuter = bvNone
          TabOrder = 2
          object EditKonsFirma: TcxButtonEdit
            Left = 44
            Top = 101
            Properties.Buttons = <
              item
                Caption = '-'
                Kind = bkText
              end
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = EditKonsFirmaPropertiesButtonClick
            TabOrder = 0
            Width = 133
          end
          object cxLabel4: TcxLabel
            Left = 6
            Top = 103
            Caption = 'Kons.Fir.'
            Style.Shadow = False
            Style.TransparentBorder = True
            Transparent = True
          end
          object EditFisNo: TcxTextEdit
            Left = 43
            Top = 78
            TabOrder = 2
            Width = 134
          end
          object DateFisTarihi: TcxDateEdit
            Left = 43
            Top = 55
            Properties.DateButtons = [btnClear, btnNow, btnToday]
            Properties.Kind = ckDateTime
            Properties.ShowTime = False
            TabOrder = 3
            Width = 134
          end
          object LabelExceldenListeyeEkle: TcxLabel
            Left = 43
            Top = 29
            Cursor = crHandPoint
            Caption = 'Excelden Listeye Ekle'
            Style.Shadow = False
            Style.TextColor = clNavy
            Style.TextStyle = [fsBold, fsUnderline]
            Style.TransparentBorder = True
            Properties.PenWidth = 2
            Transparent = True
            OnClick = LabelExceldenListeyeEkleClick
          end
          object ButtonUrunListesi: TcxLabel
            Left = 42
            Top = 9
            Cursor = crHandPoint
            Caption = #220'r'#252'n Listesi'
            Style.Shadow = False
            Style.TextColor = clNavy
            Style.TextStyle = [fsBold, fsUnderline]
            Style.TransparentBorder = True
            Properties.PenWidth = 2
            Transparent = True
            OnClick = ButtonUrunListesiClick
          end
          object cxLabel2: TcxLabel
            Left = 6
            Top = 80
            Caption = 'No'
            Style.Shadow = False
            Style.TransparentBorder = True
            Transparent = True
          end
          object cxLabel1: TcxLabel
            Left = 6
            Top = 58
            Caption = 'Tarihi'
            Style.Shadow = False
            Style.TransparentBorder = True
            Transparent = True
          end
        end
        object CheckListDepo: TcxCheckListBox
          Left = 3
          Top = 37
          Width = 105
          Height = 97
          Items = <>
          TabOrder = 3
        end
      end
      object PanelUrunLot: TPanel
        Left = 745
        Top = 1
        Width = 416
        Height = 140
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 2
        Visible = False
        object EditAdet: TcxSpinEdit
          Left = 61
          Top = 95
          TabOrder = 3
          Value = 50
          Width = 59
        end
        object LabelAdet: TcxLabel
          Left = 10
          Top = 98
          Caption = 'Adet'
          Style.Shadow = False
          Style.TransparentBorder = True
          Transparent = True
        end
        object cxLabel5: TcxLabel
          Left = 10
          Top = 73
          Caption = 'Seri No'
          Style.Shadow = False
          Style.TransparentBorder = True
          Transparent = True
        end
        object EditSNO: TcxTextEdit
          Left = 61
          Top = 71
          TabOrder = 2
          Width = 140
        end
        object EditLNO: TcxTextEdit
          Left = 61
          Top = 47
          TabOrder = 1
          Width = 141
        end
        object cxLabel6: TcxLabel
          Left = 10
          Top = 50
          Caption = 'Lot No'
          Style.Shadow = False
          Style.TransparentBorder = True
          Transparent = True
        end
        object cxLabel3: TcxLabel
          Left = 10
          Top = 26
          Caption = #220'r'#252'n No'
          Style.Shadow = False
          Style.TransparentBorder = True
          Transparent = True
        end
        object EditUNO: TcxButtonEdit
          Left = 61
          Top = 23
          Properties.Buttons = <
            item
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = EditUNOPropertiesButtonClick
          TabOrder = 0
          Width = 140
        end
        object CheckBaslamaTarih: TcxCheckBox
          Left = 211
          Top = 23
          Caption = 'Ba'#351'lama Tarihi'
          TabOrder = 8
          OnClick = CheckBaslamaTarihClick
        end
        object DateEditBasla: TcxDateEdit
          Left = 305
          Top = 23
          Properties.ShowTime = False
          TabOrder = 9
          Visible = False
          Width = 104
        end
        object CheckBitisTarih: TcxCheckBox
          Left = 211
          Top = 47
          Caption = 'Biiti'#351' Tarihi'
          TabOrder = 10
          OnClick = CheckBitisTarihClick
        end
        object DateEditBitis: TcxDateEdit
          Left = 305
          Top = 47
          Properties.ShowTime = False
          TabOrder = 11
          Visible = False
          Width = 104
        end
        object cxLabel7: TcxLabel
          Left = 216
          Top = 74
          Caption = 'Bildirim'
          Style.Shadow = False
          Style.TransparentBorder = True
          Transparent = True
        end
        object ComboBildirim: TcxImageComboBox
          Left = 306
          Top = 74
          Properties.Items = <>
          TabOrder = 13
          Width = 104
        end
      end
    end
    object Panel1: TPanel
      Left = 1
      Top = 488
      Width = 1172
      Height = 73
      Align = alBottom
      TabOrder = 2
      object MemoLog: TcxMemo
        Left = 1
        Top = 1
        Align = alClient
        TabOrder = 0
        Height = 71
        Width = 1170
      end
    end
    object PanelBaslik: TPanel
      Left = 1
      Top = 1
      Width = 1172
      Height = 41
      Align = alTop
      Caption = '-'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 188
    Top = 33
    Width = 8
    Height = 562
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = PanelKategori
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <>
    StorageName = 'cxPropertiesStore1'
    Left = 432
    Top = 312
  end
  object TabSorgu: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'sp_UTS_Kullanim  '#39'2018-12-01 00:00'#39','#39'2018-12-31 23:59'#39)
    Left = 896
    Top = 88
  end
  object TabBildirimTur: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from UTS_BILDIRIM_TUR '
      'where AKTIF=1'
      'order by ID')
    Left = 1080
    Top = 188
  end
  object DtsSorgu: TDataSource
    DataSet = TabSorgu
    Left = 1000
    Top = 128
  end
  object TabBildirim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from UTSBILDIRIM U left join UTSBILDIRIMMESAJ UM on U.I' +
        'D=UM.ID '
      'where U.ID = :PRM1'
      'order by EKLEMETARIHI desc')
    Left = 544
    Top = 216
    object TabBildirimID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabBildirimYER: TIntegerField
      FieldName = 'YER'
    end
    object TabBildirimYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabBildirimTUR2: TWordField
      FieldName = 'TUR'
    end
    object TabBildirimDURUM: TWordField
      FieldName = 'DURUM'
    end
    object TabBildirimTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabBildirimADET: TIntegerField
      FieldName = 'ADET'
    end
    object TabBildirimURUNNO: TStringField
      FieldName = 'URUNNO'
    end
    object TabBildirimSERINO: TStringField
      FieldName = 'SERINO'
    end
    object TabBildirimLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabBildirimJSON: TStringField
      FieldName = 'JSON'
      Size = 255
    end
    object TabBildirimSONUCKODU: TStringField
      FieldName = 'SONUCKODU'
      Size = 30
    end
    object TabBildirimSONUCMESAJI: TStringField
      FieldName = 'SONUCMESAJI'
      Size = 255
    end
    object TabBildirimEKLEYEN: TStringField
      FieldName = 'EKLEYEN'
      Size = 5
    end
    object TabBildirimEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabBildirimKURUMNO: TStringField
      FieldName = 'KURUMNO'
      Size = 15
    end
    object TabBildirimBELGENO: TStringField
      FieldName = 'BELGENO'
    end
    object TabBildirimURT: TDateTimeField
      FieldName = 'URT'
    end
    object TabBildirimSKT: TDateTimeField
      FieldName = 'SKT'
    end
  end
  object DtsBildirim: TDataSource
    DataSet = TabBildirim
    Left = 608
    Top = 224
  end
  object TabHata: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from UTSBILDIRIM U inner join UTSBILDIRIMMESAJ UM on U.' +
        'ID=UM.ID where DURUM in (0,2)'
      'order by EKLEMETARIHI desc')
    Left = 552
    Top = 288
  end
  object DtsHata: TDataSource
    DataSet = TabHata
    Left = 664
    Top = 232
  end
  object TabBasari: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select top 50 U.*, UM.*, FIRMA=R.FIRMA,STOKADI=S.STOKADI  from U' +
        'TSBILDIRIM U  '
      'inner join UTSBILDIRIMMESAJ UM on U.ID=UM.ID  '
      
        'left join REHBERBILGI RB on UM.KURUMNO=RB.BILGI and YERI=2 AND S' +
        'IRA=40  '
      'left join REHBER R on R.ID=RB.YER_ID  '
      'inner join STOKLAR S on S.URUNNO=UM.URUNNO  where U.DURUM=1 '
      'order by EKLEMETARIHI desc')
    Left = 544
    Top = 336
  end
  object DtsBasari: TDataSource
    DataSet = TabBasari
    Left = 616
    Top = 336
  end
  object cxEditRepository1: TcxEditRepository
    Left = 816
    Top = 249
    PixelsPerInch = 96
    object cxEditRepository1CheckBoxItem1: TcxEditRepositoryCheckBoxItem
      Properties.NullStyle = nssUnchecked
      Properties.ValueGrayed = 'False'
    end
    object cxEditRepository1CheckBoxItem2: TcxEditRepositoryCheckBoxItem
    end
  end
  object idhttp1: TIdHTTP
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 808
    Top = 336
  end
  object MemDataSorgu: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 672
    Top = 8
    object MemDataSorgunumara: TIntegerField
      FieldName = 'numara'
    end
    object MemDataSorguad: TStringField
      FieldName = 'ad'
    end
    object MemDataSorgusoyad: TStringField
      FieldName = 'soyad'
      Size = 25
    end
  end
  object DataSource1: TDataSource
    DataSet = TabSorgu
    Left = 968
    Top = 192
  end
  object TabIptal: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from UTSBILDIRIM U inner join UTSBILDIRIMMESAJ UM on U.' +
        'ID=UM.ID where DURUM=3'
      'order by EKLEMETARIHI desc')
    Left = 552
    Top = 392
  end
  object DtsIptal: TDataSource
    DataSet = TabIptal
    Left = 624
    Top = 392
  end
  object PopupMenuSorgu: TPopupMenu
    Left = 272
    Top = 296
    object menuexcel: TMenuItem
      Caption = 'Excele Kaydet'
      OnClick = menuexcelClick
    end
  end
  object TabDepo: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from DEPOLAR where DURUM=1 order by DEPOADI')
    Left = 232
    Top = 144
  end
  object DtsDepo: TDataSource
    DataSet = TabDepo
    Left = 296
    Top = 152
  end
end
