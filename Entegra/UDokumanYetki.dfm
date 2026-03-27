object DokumanYetki: TDokumanYetki
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Klas'#246'r Yetkilendirme Ekran'#305
  ClientHeight = 439
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object PanelSecim: TPanel
    Left = 0
    Top = 0
    Width = 633
    Height = 33
    Align = alTop
    TabOrder = 0
    object CheckAltKlasor: TCheckBox
      Left = 16
      Top = 10
      Width = 326
      Height = 17
      Caption = 'Alt klas'#246'rlere ve Klas'#246'rdeki dosyalara da uygula'
      TabOrder = 0
    end
    object cxButton1: TcxButton
      Left = 452
      Top = 5
      Width = 78
      Height = 25
      Caption = 'Uygula'
      TabOrder = 1
      OnClick = cxButton1Click
    end
    object cxButton2: TcxButton
      Left = 545
      Top = 5
      Width = 80
      Height = 24
      Caption = 'Kapat'
      TabOrder = 2
      OnClick = cxButton2Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 33
    Width = 633
    Height = 406
    Align = alClient
    TabOrder = 1
    object GridYetki: TcxGrid
      Left = 1
      Top = 25
      Width = 631
      Height = 380
      Align = alClient
      TabOrder = 0
      object GridYetkiDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsYetki
        DataController.KeyFieldNames = 'ID'
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        object GridYetkiDBTableView1Tur: TcxGridDBColumn
          Caption = 'T'#252'r'
          DataBinding.FieldName = 'TURU'
          DataBinding.IsNullValueType = True
        end
        object GridYetkiDBTableView1KULLANICI: TcxGridDBColumn
          Caption = 'Kullan'#305'c'#305' Ad'#305
          DataBinding.FieldName = 'FIRMA'
          DataBinding.IsNullValueType = True
          Options.Editing = False
          Width = 109
        end
        object GridYetkiDBTableView1GOR: TcxGridDBColumn
          Caption = 'G'#246'rme'
          DataBinding.FieldName = 'GOR'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCheckBoxProperties'
          Width = 95
        end
        object GridYetkiDBTableView1EKLE: TcxGridDBColumn
          Caption = 'Ekleme'
          DataBinding.FieldName = 'EKLE'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCheckBoxProperties'
          Width = 95
        end
        object GridYetkiDBTableView1DEGISTIR: TcxGridDBColumn
          Caption = 'De'#287'i'#351'tirme'
          DataBinding.FieldName = 'DEGISTIR'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCheckBoxProperties'
          Width = 95
        end
        object GridYetkiDBTableView1SIL: TcxGridDBColumn
          Caption = 'Silme'
          DataBinding.FieldName = 'SIL'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCheckBoxProperties'
          Width = 95
        end
      end
      object GridYetkiLevel1: TcxGridLevel
        GridView = GridYetkiDBTableView1
      end
    end
    object ToolBar1: TToolBar
      Left = 1
      Top = 1
      Width = 631
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 74
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
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 1
      Transparent = True
      object YeniYetkiTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni Yetki'
        DropdownMenu = PopupMenuYetki
        ImageIndex = 0
        ImageName = 'PngImage0'
      end
      object YetkiSilTus: TToolButton
        Left = 74
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        ImageName = 'PngImage1'
        OnClick = YetkiSilTusClick
      end
      object YetkiKaydet: TToolButton
        Left = 148
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        ImageName = 'PngImage2'
        OnClick = YetkiKaydetClick
      end
      object YetkiIptal: TToolButton
        Left = 222
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        ImageName = 'PngImage3'
        OnClick = YetkiIptalClick
      end
      object ToolButton3: TToolButton
        Left = 296
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 4
        ImageName = 'PngImage4'
        Style = tbsSeparator
      end
    end
  end
  object DtsYetki: TDataSource
    DataSet = TabYetki
    OnStateChange = DtsYetkiStateChange
    Left = 16
    Top = 85
  end
  object TabYetki: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabYetkiAfterScroll
    OnNewRecord = TabYetkiNewRecord
    ParamData = <
      item
        Name = 'YERI'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'YERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'declare @yeri int,@yerid int'
      'set @yeri=:YERI'
      'set @yerid=:YERID '
      ''
      'select         '
      '       TURU=case '
      #9'   when TUR=5 THEN '#39'Kurum'#39'  '
      #9'   when TUR=4 THEN '#39#350'ube'#39'  '
      #9'   when TUR=3 THEN '#39'Departman'#39'  '
      #9'   when TUR=2 THEN '#39'G'#246'rev'#39'  '
      #9'   when TUR=1 THEN '#39'Ki'#351'i'#39'  '
      #9'   end,'
      '       DY.*,'
      #9'   FIRMA=CASE '
      #9'   --T'#252'm'
      #9'   WHEN TUR=5 THEN '#39'T'#252'm Kullan'#305'c'#305'lar'#39' '
      #9'   --ki'#351'i/'#351'ube'
      
        #9'   WHEN TUR in (1,4) THEN (SELECT FIRMA FROM REHBER WHERE ID=DY' +
        '.REHBERID)'
      '       --departman'
      
        #9'  WHEN TUR=3 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BOL' +
        'UM=-2251 AND DEGER = DY.REHBERID AND DIL=-1 )'
      '       --g'#246'rev'
      
        #9'   WHEN TUR=2 THEN  ( SELECT G.ANAHTAR from GENINI G where G.BO' +
        'LUM=-2252 AND DEGER = DY.REHBERID AND DIL=-1 )'
      #9'   END'
      ' from '
      '       DOKUMANYETKI DY '
      '       where'
      '      YERI=@yeri and'
      '       yerID=@yerid '
      ' order by DY.TUR, DY.REHBERID desc')
    Left = 40
    Top = 221
  end
  object TabAltKlasor: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'UstID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'WITH Liste (ID,USTID) AS'
      '('#9'SELECT'
      #9#9'ID,'
      #9#9'USTID'
      #9'FROM DOKUMANKLASOR DK'
      #9#9'where DK.ID= :UstID'
      'UNION ALL'
      #9'SELECT'
      #9#9'ID=DK.ID,'
      #9#9'USTID=P.ID'
      #9'From Liste p INNER JOIN DOKUMANKLASOR DK ON DK.USTID=p.ID'
      ')'
      'SELECT DK.ID,DK.USTID,DK.AD'
      'FROM'
      #9'DOKUMANKLASOR DK inner join'
      #9'Liste p on p.ID=DK.USTID')
    Left = 120
    Top = 85
  end
  object PopupMenuYetki: TPopupMenu
    Left = 149
    Top = 238
    object TumKullanicilarMenu: TMenuItem
      Tag = 5
      Caption = 'T'#252'm Kullan'#305'c'#305'lar'
      OnClick = TumKullanicilarMenuClick
    end
    object SubeMenu: TMenuItem
      Tag = 4
      Caption = #350'ube'
      OnClick = SubeMenuClick
    end
    object DepartmanMenu: TMenuItem
      Tag = 3
      Caption = 'Departman'
      OnClick = SubeMenuClick
    end
    object GorevMenu: TMenuItem
      Tag = 2
      Caption = 'G'#246'rev'
      OnClick = SubeMenuClick
    end
    object KisiMenu: TMenuItem
      Tag = 1
      Caption = 'Ki'#351'i'
      OnClick = SubeMenuClick
    end
  end
end

