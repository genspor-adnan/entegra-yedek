object VardiyaTanimlariDlg: TVardiyaTanimlariDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Vardiya Tan'#305'mlar'#305
  ClientHeight = 544
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object VardiyaTanim: TcxGrid
    Left = 0
    Top = 27
    Width = 439
    Height = 517
    Align = alClient
    PopupMenu = PmSagClick
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    ExplicitWidth = 399
    object VardiyaTanimTV: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = dtsTabVardiya
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skSum
          FieldName = 'HAK'
        end
        item
          Kind = skSum
          FieldName = 'IZINLIGUNSAYISI'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object VardiyaTanimTVAY: TcxGridDBColumn
        Caption = 'Ay'
        DataBinding.FieldName = 'AY'
        Visible = False
        Options.Editing = False
        Width = 70
      end
      object VardiyaTanimTVGUN: TcxGridDBColumn
        DataBinding.FieldName = 'GUN'
        Options.Editing = False
        Width = 33
        IsCaptionAssigned = True
      end
      object VardiyaTanimTVGUNADI: TcxGridDBColumn
        Caption = 'G'#252'nler'
        DataBinding.FieldName = 'GUNADI'
        Options.Editing = False
        Width = 88
      end
      object VardiyaTanimTVISGUNU: TcxGridDBColumn
        Caption = #304#351' G'#252'n'#252
        DataBinding.FieldName = 'ISGUNU'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.DisplayGrayed = 'False'
        Width = 121
      end
      object VardiyaTanimTVGIRIS: TcxGridDBColumn
        Caption = 'Giri'#351
        DataBinding.FieldName = 'GIRIS'
        PropertiesClassName = 'TcxTimeEditProperties'
        Properties.ImmediatePost = True
        Properties.TimeFormat = tfHourMin
        Width = 80
      end
      object VardiyaTanimTVCIKIS: TcxGridDBColumn
        Caption = #199#305'k'#305#351
        DataBinding.FieldName = 'CIKIS'
        PropertiesClassName = 'TcxTimeEditProperties'
        Properties.ImmediatePost = True
        Properties.TimeFormat = tfHourMin
        Width = 75
      end
    end
    object cxGridLevel9: TcxGridLevel
      GridView = VardiyaTanimTV
    end
  end
  object ToolBar9: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 433
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 62
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
    Font.Name = 'Trebuchet MS'
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
    ExplicitWidth = 393
    object ComboAy: TcxImageComboBox
      Left = 0
      Top = 0
      Properties.Items = <
        item
          Description = 'Ocak'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = #350'ubat'
          Value = 2
        end
        item
          Description = 'Mart'
          Value = 3
        end
        item
          Description = 'Nisan'
          Value = 4
        end
        item
          Description = 'May'#305's'
          Value = 5
        end
        item
          Description = 'Haziran'
          Value = 6
        end
        item
          Description = 'Temmuz'
          Value = 7
        end
        item
          Description = 'A'#287'ustos'
          Value = 8
        end
        item
          Description = 'Eyl'#252'l'
          Value = 9
        end
        item
          Description = 'Ekim'
          Value = 10
        end
        item
          Description = 'Kas'#305'm'
          Value = 11
        end
        item
          Description = 'Aral'#305'k'
          Value = 12
        end>
      Properties.OnChange = ComboAyPropertiesChange
      Properties.OnCloseUp = ComboAyPropertiesCloseUp
      TabOrder = 1
      Width = 90
    end
    object ToolButton2: TToolButton
      Left = 90
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 15
      Style = tbsSeparator
    end
    object ComboYil: TcxSpinEdit
      Left = 98
      Top = 0
      Properties.LargeIncrement = 1.000000000000000000
      Properties.MaxValue = 2020.000000000000000000
      Properties.MinValue = 2000.000000000000000000
      TabOrder = 0
      Value = 2012
      OnClick = ComboYilClick
      Width = 46
    end
    object BtnKaydet: TToolButton
      Left = 144
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = BtnKaydetClick
    end
    object BtnIptal: TToolButton
      Left = 206
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
      OnClick = BtnIptalClick
    end
    object ToolButton1: TToolButton
      Left = 268
      Top = 0
      Width = 45
      ImageIndex = 0
      Style = tbsSeparator
    end
    object BtnKapat: TToolButton
      Left = 313
      Top = 0
      Caption = 'Kapat '
      ImageIndex = 14
      OnClick = BtnKapatClick
    end
  end
  object TabVardiya: TFDQuery
    Connection = Tablo.FDCnn
    AfterRefresh = TabVardiyaAfterRefresh
    OnNewRecord = TabVardiyaNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select * from PERS_VARDIYATANIM')
    Left = 328
    Top = 88
  end
  object dtsTabVardiya: TDataSource
    DataSet = TabVardiya
    OnStateChange = dtsTabVardiyaStateChange
    Left = 264
    Top = 80
  end
  object PmSagClick: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PmSagClickPopup
    Left = 168
    Top = 96
    object PmTabloyuOlustur: TMenuItem
      Caption = 'Tabloyu Olu'#351'tur'
      ImageIndex = 0
      OnClick = PmTabloyuOlusturClick
    end
  end
end


