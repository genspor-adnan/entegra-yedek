object ServisEkipmanSecDlg: TServisEkipmanSecDlg
  Left = 0
  Top = 0
  Caption = 'Ekipman Se'#231'im Ekran'#305
  ClientHeight = 567
  ClientWidth = 1187
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1187
    Height = 50
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 134
      Top = 0
      Width = 28
      Height = 16
      Caption = '&Kodu'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelAdi: TLabel
      Left = 258
      Top = 0
      Width = 18
      Height = 16
      Caption = '&Ad'#305
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelBarkod: TLabel
      Left = 502
      Top = 0
      Width = 35
      Height = 16
      Caption = '&Serino'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object BtnKapat: TJvNavPanelButton
      Left = 1097
      Top = 1
      Width = 89
      Height = 48
      Align = alRight
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
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
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 18
      Images = Tablo.PNGImageList1
      OnClick = BtnKapatClick
      ExplicitLeft = 884
      ExplicitTop = -2
    end
    object BtnSec: TJvNavPanelButton
      Left = 1006
      Top = 1
      Width = 89
      Height = 48
      Align = alRight
      AllowAllUp = True
      Caption = 'Se'#231
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
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
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 1
      Images = Tablo.PNGImageList1
      OnClick = BtnSecClick
      ExplicitLeft = 678
      ExplicitHeight = 38
    end
    object BtnYeni: TJvNavPanelButton
      Left = 1
      Top = 1
      Width = 117
      Height = 48
      Align = alLeft
      AllowAllUp = True
      Caption = 'Yeni Ekipman'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 7
      Images = Tablo.PNGImageList1
      OnClick = BtnYeniClick
      ExplicitHeight = 36
    end
    object EditKodu: TcxTextEdit
      Left = 134
      Top = 17
      TabOrder = 1
      OnKeyUp = EditKoduKeyUp
      Width = 117
    end
    object EditAdi: TcxTextEdit
      Left = 258
      Top = 17
      TabOrder = 2
      OnKeyUp = EditKoduKeyUp
      Width = 235
    end
    object EditSerino: TcxTextEdit
      Left = 502
      Top = 17
      TabOrder = 3
      OnKeyUp = EditKoduKeyUp
      Width = 127
    end
    object Panel3: TPanel
      Left = 1095
      Top = 1
      Width = 2
      Height = 48
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 1013
    Top = 50
    Width = 174
    Height = 517
    Align = alRight
    Caption = 'Panel2'
    TabOrder = 3
    object LogoResim: TcxImage
      Left = 1
      Top = 50
      Align = alClient
      Properties.GraphicClassName = 'TJPEGImage'
      Style.BorderColor = clBtnFace
      Style.Color = clBtnFace
      Style.Edges = []
      StyleDisabled.BorderStyle = ebsNone
      StyleFocused.BorderStyle = ebsNone
      TabOrder = 1
      Height = 466
      Width = 172
    end
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 172
      Height = 49
      Align = alTop
      TabOrder = 0
      object LabelSonEklenen: TcxLabel
        Left = 1
        Top = 1
        Align = alClient
        AutoSize = False
        Properties.WordWrap = True
        Transparent = True
        Height = 47
        Width = 170
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 1006
    Top = 50
    Width = 7
    Height = 517
    AlignSplitter = salRight
    Control = Panel2
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 50
    Width = 1006
    Height = 517
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = SheetTumEkipmanlar
    Properties.CustomButtons.Buttons = <>
    Properties.Images = Tablo.PNGImageList2
    OnChange = cxPageControl1Change
    OnPageChanging = cxPageControl1PageChanging
    ClientRectBottom = 513
    ClientRectLeft = 4
    ClientRectRight = 1002
    ClientRectTop = 25
    object SheetRehberEkipman: TcxTabSheet
      Caption = 'Anla'#351'mal'#305'/Garantili Ekipmanlar'
      ImageIndex = 12
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label2: TLabel
        Left = 720
        Top = 107
        Width = 31
        Height = 13
        Caption = 'Label2'
      end
      object cxDBTreeList1: TcxDBTreeList
        Left = 0
        Top = 0
        Width = 998
        Height = 488
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsListe
        DataController.ParentField = 'USTID'
        DataController.KeyField = 'ALTID'
        Navigator.Buttons.CustomButtons = <>
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRect = False
        OptionsSelection.InvertSelect = False
        OptionsView.CellEndEllipsis = True
        OptionsView.Indicator = True
        RootValue = -1
        TabOrder = 0
        OnCustomDrawDataCell = cxDBTreeList1CustomDrawDataCell
        OnDblClick = BtnSecClick
        object cxDBTreeList1cxDBTreeListColumn3: TcxDBTreeListColumn
          RepositoryItem = Tablo.RepServisEkipmanTur
          Caption.Text = 'T'#252'r'
          DataBinding.FieldName = 'EKIPMANTUR'
          Width = 63
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn
          Caption.Text = 'Kod'
          DataBinding.FieldName = 'KOD'
          Width = 113
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListColumn5: TcxDBTreeListColumn
          Caption.Text = 'Ad'
          DataBinding.FieldName = 'AD'
          Width = 125
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListKATEGORIAD: TcxDBTreeListColumn
          Caption.Text = 'Kategori'
          DataBinding.FieldName = 'KATEGORIAD'
          Width = 84
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListMARKAAD: TcxDBTreeListColumn
          Caption.Text = 'Marka'
          DataBinding.FieldName = 'MARKAAD'
          Width = 100
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListMODELAD: TcxDBTreeListColumn
          Caption.Text = 'Model'
          DataBinding.FieldName = 'MODELAD'
          Width = 100
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListSERINO: TcxDBTreeListColumn
          Caption.Text = 'Serino'
          DataBinding.FieldName = 'SERINO'
          Width = 92
          Position.ColIndex = 6
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListColumnGaranti: TcxDBTreeListColumn
          Caption.Text = 'Garanti Biti'#351
          DataBinding.FieldName = 'GARANTIBITTAR'
          Width = 91
          Position.ColIndex = 7
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListSURE: TcxDBTreeListColumn
          Caption.Text = 'S'#252're'
          DataBinding.FieldName = 'SURE'
          Width = 100
          Position.ColIndex = 8
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListSahibi: TcxDBTreeListColumn
          Caption.Text = 'Sahibi'
          DataBinding.FieldName = 'FIRMA'
          Width = 100
          Position.ColIndex = 9
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListACIKLAMA: TcxDBTreeListColumn
          Caption.Text = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
          Width = 100
          Position.ColIndex = 11
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cxDBTreeListDISLOKASYONADI: TcxDBTreeListColumn
          Caption.Text = 'D'#305#351' Lokasyon'
          DataBinding.FieldName = 'DISLOKASYONADI'
          Width = 80
          Position.ColIndex = 10
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
    object SheetTumEkipmanlar: TcxTabSheet
      Caption = 'T'#252'm Ekipmanlar'
      ImageIndex = 12
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object SQLEkipmanAnlasmali: TcxMemo
        Left = 37
        Top = 25
        Lines.Strings = (
          'select '
          
            #9'E.ID,E.URUNID,E.EKIPMANTUR,E.KOD,E.AD,E.ACIKLAMA,KATEGORIAD=K.A' +
            'D,ER.USTID,ALTID=ER.ID,ER.SERINO,ER.GARANTIBITTAR, '
          
            #9'SURE=dbo.fn_TarihFarkiGunAyYilTextOlarak(GETDATE(),ER.GARANTIBI' +
            'TTAR), '
          #9'EKIPMANREHBERID=ER.ID,FIRMA=null,'
          
            #9'MARKAAD = (case when E.SAHIP=0 then (select top 1 ANAHTAR from ' +
            'GENINI where BOLUM=-2727 and DEGER=E.MARKA and DIL=-1)'
          
            #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and ' +
            'DEGER=E.MARKA and DIL=-1) end) ,'
          
            #9'MODELAD = (case when E.SAHIP=0 then (select top 1 ANAHTAR from ' +
            'GENINI where BOLUM=convert(int,'#39'-2727'#39'+convert(varchar(10),E.MAR' +
            'KA)) and DEGER=E.MODEL and DIL=-1) '
          
            #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=convert(in' +
            't,'#39'-2701'#39'+convert(varchar(10),E.MARKA)) and DEGER=E.MODEL and DI' +
            'L=-1) end),'
          #9'DISLOKASYONADI=RI.AD'
          'from '
          #9'EKIPMANREHBER ER  '
          #9'inner join EKIPMANLAR E on E.ID=ER.EKIPMANID '
          #9'left outer join  KATEGORI K on K.ID=E.KATEGORI '
          
            #9'left outer join REHBERILETISIM RI on RI.REHBERID=ER.REHBERID an' +
            'd RI.ID=ER.DISLOKASYONID'
          'where E.DURUM=1')
        Properties.WordWrap = False
        TabOrder = 0
        Visible = False
        Height = 45
        Width = 588
      end
      object SQLEkipmanGenel: TcxMemo
        Left = 37
        Top = 76
        Lines.Strings = (
          
            'select E.ID,E.URUNID,E.EKIPMANTUR,E.KOD,E.AD,E.ACIKLAMA,KATEGORI' +
            'AD=K.AD,USTID=0,ALTID=E.ID,SERINO=null,'
          'GARANTIBITTAR=null,SURE=null,EKIPMANREHBERID=-1,FIRMA=null,'
          
            #9'MARKAAD = (case when E.SAHIP=0 then (select top 1 ANAHTAR from ' +
            'GENINI where BOLUM=-2727 and DEGER=E.MARKA and DIL=-1)'
          
            #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and ' +
            'DEGER=E.MARKA and DIL=-1) end) ,'
          
            #9'MODELAD = (case when E.SAHIP=0 then (select top 1 ANAHTAR from ' +
            'GENINI where BOLUM=convert(int,'#39'-2727'#39'+convert(varchar(10),E.MAR' +
            'KA)) and DEGER=E.MODEL and DIL=-1) '
          
            #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=convert(in' +
            't,'#39'-2701'#39'+convert(varchar(10),E.MARKA)) and DEGER=E.MODEL and DI' +
            'L=-1) end)'
          'from  '
          #9'EKIPMANLAR E '
          #9'left outer join KATEGORI K on K.ID=E.KATEGORI '
          'where E.DURUM=1')
        Properties.WordWrap = False
        TabOrder = 1
        Visible = False
        Height = 45
        Width = 588
      end
      object SQLDemirbas: TcxMemo
        Left = 37
        Top = 153
        Lines.Strings = (
          
            'select D.ID,URUNID=D.STOKID,EKIPMANTUR=0,KOD=D.DEMIRBASNO,AD=D.D' +
            'EMIRBASADI,ACIKLAMA='#39#39',KATEGORIAD=K.STOKADI,USTID=0,ALTID=D.ID,'
          
            'SERINO,GARANTIBITTAR=null,SURE=null,EKIPMANREHBERID=D.ZIMMETLIPE' +
            'RSONELID, R.FIRMA '
          'from  '
          #9'DEMIRBAS D '
          #9'left outer join [dbo].[DEMIRBAS_URUN] K on K.ID=D.KATEGORIID '
          #9'left outer join REHBER R on R.ID=D.ZIMMETLIPERSONELID '
          'where D.DURUM=1')
        Properties.WordWrap = False
        TabOrder = 2
        Visible = False
        Height = 45
        Width = 588
      end
    end
  end
  object SeriNoTus: TcxButton
    Left = 392
    Top = 49
    Width = 75
    Height = 25
    Caption = 'Seri No Gir'
    TabOrder = 4
    OnClick = SeriNoTusClick
  end
  object GarantiTus: TcxButton
    Left = 473
    Top = 49
    Width = 75
    Height = 25
    Caption = 'Garanti Gir'
    TabOrder = 5
    OnClick = GarantiTusClick
  end
  object TabListe: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabListeAfterOpen
    ParamData = <>
    SQL.Strings = (
      'select '
      #9'E.*,'
      #9'ER.USTID,ALTID=ER.ID,'
      
        #9'MARKAAD = (case when E.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=-2727 and DEGER=E.MARKA and DIL=-1)'
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and ' +
        'DEGER=E.MARKA and DIL=-1) end) ,'
      
        #9'MODELAD = (case when E.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=convert(int,'#39'-2727'#39'+convert(varchar(10),E.MAR' +
        'KA)) and DEGER=E.MODEL and DIL=-1) '
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=convert(in' +
        't,'#39'-2701'#39'+convert(varchar(10),E.MARKA)) and DEGER=E.MODEL and DI' +
        'L=-1) end),'
      #9'ER.SERINO,ER.GARANTIBITTAR,'
      
        #9'SURE=dbo.fn_TarihFarkiGunAyYilTextOlarak(GETDATE(),ER.GARANTIBI' +
        'TTAR),'
      #9'EKIPMANREHBERID=ER.ID '
      'from '
      #9'EKIPMANREHBER ER inner join '
      #9'EKIPMANLAR E on E.ID=ER.EKIPMANID')
    Left = 540
    Top = 162
  end
  object DtsListe: TDataSource
    DataSet = TabListe
    Left = 544
    Top = 220
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 681
    Top = 192
  end
end

