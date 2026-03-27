object UrunListeDlg: TUrunListeDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #220'r'#252'n Listele'
  ClientHeight = 552
  ClientWidth = 912
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 201
    Height = 451
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object BtnUrunListe: TJvNavPanelButton
      Tag = 8
      Left = 0
      Top = 0
      Width = 201
      Height = 52
      Align = alTop
      Caption = 'Listele'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 11
      Images = Tablo.PngMenu
      OnClick = BtnUrunListeClick
      ExplicitLeft = -6
      ExplicitTop = 223
    end
    object BtnPaketeEkle: TJvNavPanelButton
      Tag = 8
      Left = 0
      Top = 52
      Width = 201
      Height = 52
      Align = alTop
      Caption = 'Pakete Ekle'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 24
      Images = Tablo.PngMenu
      OnClick = BtnPaketeEkleClick
      ExplicitLeft = -6
      ExplicitTop = 58
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 912
    Height = 41
    Align = alTop
    TabOrder = 1
    object CmbStokAdi: TcxImageComboBox
      Left = 62
      Top = 6
      ParentFont = False
      Properties.Items = <>
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 0
      Width = 323
    end
    object cxLabel1: TcxLabel
      Left = 7
      Top = 8
      Caption = 'Stok Ad'#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object cxLabel2: TcxLabel
      Left = 391
      Top = 7
      Caption = 'Durumu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object CmbDurumu: TcxImageComboBox
      Left = 443
      Top = 6
      ParentFont = False
      Properties.Items = <
        item
          Description = 'Sat'#305'lan'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'Elde Bulunan'
          Value = 1
        end
        item
          Description = #304'ade'
          Value = 2
        end
        item
          Description = 'Hepsi'
          Value = 3
        end>
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 3
      Width = 110
    end
    object DateTar1: TcxDateEdit
      Left = 650
      Top = 6
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 4
      Width = 121
    end
    object DateTar2: TcxDateEdit
      Left = 777
      Top = 6
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 5
      Width = 121
    end
    object cxLabel3: TcxLabel
      Left = 614
      Top = 8
      Caption = 'Tarih'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 492
    Width = 912
    Height = 60
    Align = alBottom
    TabOrder = 2
  end
  object Panel4: TPanel
    Left = 201
    Top = 41
    Width = 711
    Height = 451
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object GridListele: TcxGrid
      Left = 0
      Top = 0
      Width = 711
      Height = 416
      Align = alClient
      PopupMenu = PopupMenu1
      TabOrder = 0
      OnContextPopup = GridListeleContextPopup
      object DbTvListele: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        OnCellDblClick = DbTvListeleCellDblClick
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsUrunler
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            FieldName = 'GIRENFIRMA'
            Column = ColSecUrun
            DisplayText = 'Toplam :'
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.Footer = True
        object ColSecUrun: TcxGridDBColumn
          Caption = 'Se'#231
          DataBinding.ValueType = 'Boolean'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Width = 60
        end
        object DbTvListeleColumn1: TcxGridDBColumn
          Caption = 'Giri'#351' yap'#305'lan firma'
          DataBinding.FieldName = 'GIRENFIRMA'
          Options.Editing = False
          Width = 250
        end
        object DbTvListeleColumn3: TcxGridDBColumn
          Caption = 'Giri'#351' Tarih'
          DataBinding.FieldName = 'GIRENTARIH'
          Options.Editing = False
        end
        object DbTvListeleURUNBARKOD: TcxGridDBColumn
          Caption = #220'r'#252'n Barkodu'
          DataBinding.FieldName = 'URUNBARKOD'
          Options.Editing = False
        end
        object DbTvListeleSIRANO: TcxGridDBColumn
          Caption = 'Sira No'
          DataBinding.FieldName = 'SIRANO'
          Options.Editing = False
        end
        object DbTvListeleSONKULLANIM: TcxGridDBColumn
          Caption = 'Son Kullan'#305'm'
          DataBinding.FieldName = 'SONKULLANIM'
          Options.Editing = False
        end
        object DbTvListeleLOTNO: TcxGridDBColumn
          Caption = 'Lot No'
          DataBinding.FieldName = 'LOTNO'
          Options.Editing = False
        end
        object DbTvListeleColumn2: TcxGridDBColumn
          Caption = #199#305'kan Firma'
          DataBinding.FieldName = 'CIKANFIRMA'
          Options.Editing = False
          Width = 250
        end
        object DbTvListeleColumn4: TcxGridDBColumn
          Caption = #199#305'k'#305#351' Tarih'
          DataBinding.FieldName = 'CIKANTARIH'
          Options.Editing = False
        end
      end
      object GlListele: TcxGridLevel
        GridView = DbTvListele
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 416
      Width = 711
      Height = 35
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
    end
  end
  object TabUrunler: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select *,'
      
        '      (SELECT R.FIRMA FROM FATBASLIK FB INNER JOIN REHBER R ON R' +
        '.ID =FB.REHBERID WHERE FB.ID=GIRFATBASID) AS GIRENFIRMA, '
      
        '(SELECT FB.TARIH FROM FATBASLIK FB  WHERE FB.ID=GIRFATBASID) AS ' +
        'GIRENTARIH,'
      
        '       (SELECT R.FIRMA FROM FATBASLIK FB INNER JOIN REHBER R ON ' +
        'R.ID =FB.REHBERID WHERE FB.ID=CIKFATBASID) AS CIKANFIRMA  ,'
      
        '(SELECT FB.TARIH FROM FATBASLIK FB  WHERE FB.ID=CIKFATBASID) AS ' +
        'CIKANTARIH'
      ' from STOKID')
    Left = 664
    Top = 80
    object TabUrunlerID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabUrunlerGIRFATURAID: TIntegerField
      FieldName = 'GIRFATURAID'
    end
    object TabUrunlerURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabUrunlerSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabUrunlerCIKFATURAID: TIntegerField
      FieldName = 'CIKFATURAID'
    end
    object TabUrunlerSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object TabUrunlerLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabUrunlerGIRENFIRMA: TWideStringField
      FieldName = 'GIRENFIRMA'
      ReadOnly = True
      Size = 120
    end
    object TabUrunlerCIKANFIRMA: TWideStringField
      FieldName = 'CIKANFIRMA'
      ReadOnly = True
      Size = 120
    end
    object TabUrunlerGIRENTARIH: TDateTimeField
      FieldName = 'GIRENTARIH'
      ReadOnly = True
    end
    object TabUrunlerCIKANTARIH: TDateTimeField
      FieldName = 'CIKANTARIH'
      ReadOnly = True
    end
  end
  object DtsUrunler: TDataSource
    DataSet = TabUrunler
    Left = 656
    Top = 128
  end
  object PopupMenu1: TPopupMenu
    Left = 378
    Top = 106
    object pmHepsiSec: TMenuItem
      Tag = 1
      Caption = 'Hepsini Se'#231
      OnClick = pmHepsiSecClick
    end
    object pmTumunuKaldir: TMenuItem
      Tag = 2
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      OnClick = pmHepsiSecClick
    end
    object pmSecimiTersCevir: TMenuItem
      Tag = 3
      Caption = 'Se'#231'imi Ters '#199'evir'
      OnClick = pmHepsiSecClick
    end
  end
end
