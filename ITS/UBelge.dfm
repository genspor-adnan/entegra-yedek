object BelgeListeDlg: TBelgeListeDlg
  Left = 0
  Top = 0
  Caption = 'Belge Listesi'
  ClientHeight = 415
  ClientWidth = 762
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 762
    Height = 44
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 120
      Top = 2
      Width = 44
      Height = 16
      Caption = '&BelgeNo'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelAdi: TLabel
      Left = 202
      Top = 2
      Width = 29
      Height = 16
      Caption = '&Firma'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 611
      Top = 2
      Width = 26
      Height = 16
      Caption = 'Adet'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object BtnKapat: TJvNavPanelButton
      Left = 672
      Top = 1
      Width = 89
      Height = 42
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
      ExplicitLeft = 771
      ExplicitHeight = 40
    end
    object BtnSec: TJvNavPanelButton
      Left = 581
      Top = 1
      Width = 89
      Height = 42
      Align = alRight
      AllowAllUp = True
      Caption = 'Kaydet'
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
      ExplicitLeft = 687
      ExplicitTop = 2
      ExplicitHeight = 38
    end
    object EdtBelgeNo: TcxTextEdit
      Left = 120
      Top = 19
      TabOrder = 0
      OnKeyUp = EdtBelgeNoKeyUp
      Width = 81
    end
    object EdtFirmaAdi: TcxTextEdit
      Left = 202
      Top = 19
      TabOrder = 1
      OnKeyUp = EdtBelgeNoKeyUp
      Width = 208
    end
    object Panel3: TPanel
      Left = 670
      Top = 1
      Width = 2
      Height = 42
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
    end
    object RadioBaslayan: TcxRadioButton
      Left = 10
      Top = 4
      Width = 88
      Height = 17
      Caption = 'Ba'#351'layan'
      Checked = True
      TabOrder = 3
      TabStop = True
    end
    object RadioIcindeGecen: TcxRadioButton
      Left = 10
      Top = 19
      Width = 88
      Height = 17
      Caption = #304#231'inde Ge'#231'en'
      TabOrder = 4
    end
  end
  object GridBelgeListesi: TcxGrid
    Left = 0
    Top = 44
    Width = 762
    Height = 371
    Align = alClient
    TabOrder = 1
    object TvBelgeListesi: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = Tablo.DtsAlisBelgeListesi
      DataController.DetailKeyFieldNames = 'ID'
      DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skCount
          FieldName = 'SIRANO'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsData.Appending = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.Footer = True
      OptionsView.FooterAutoHeight = True
      OptionsView.FooterMultiSummaries = True
      OptionsView.GroupByBox = False
      object vBelgeListesiColumn1: TcxGridDBColumn
        Caption = 'ID'
        DataBinding.FieldName = 'FID'
      end
      object TvBelgeListesiTARIH: TcxGridDBColumn
        Caption = 'Belge Tarih'
        DataBinding.FieldName = 'TARIH'
        Options.Editing = False
        Width = 58
      end
      object TvBelgeListesiBELGETIPI: TcxGridDBColumn
        Caption = 'Belge Tipi'
        DataBinding.FieldName = 'BELGETIPI'
        Options.Editing = False
        Width = 95
      end
      object TvBelgeListesiFATURANO: TcxGridDBColumn
        Caption = 'Belge No'
        DataBinding.FieldName = 'FATURANO'
        Options.Editing = False
        Width = 60
      end
      object TvBelgeListesiFIRMA: TcxGridDBColumn
        Caption = 'Firma'
        DataBinding.FieldName = 'FIRMA'
        Options.Editing = False
        Width = 280
      end
      object TvBelgeListesiAD: TcxGridDBColumn
        Caption = #220'r'#252'n'
        DataBinding.FieldName = 'STOKADI'
        Options.Editing = False
        Width = 193
      end
      object TvBelgeListesiADET: TcxGridDBColumn
        Caption = 'Adet'
        DataBinding.FieldName = 'ADET'
        Options.Editing = False
        Width = 74
      end
    end
    object GlBelgeListesi: TcxGridLevel
      GridView = TvBelgeListesi
    end
  end
end
