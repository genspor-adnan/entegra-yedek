object SeriNoDlg: TSeriNoDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Seri Numaras'#305' '#304#351'lemleri'
  ClientHeight = 503
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object pgSeriNo: TcxPageControl
    Left = 0
    Top = 88
    Width = 535
    Height = 415
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = shtSeriNoGiris
    Properties.CustomButtons.Buttons = <>
    OnChange = pgSeriNoChange
    ClientRectBottom = 415
    ClientRectRight = 535
    ClientRectTop = 27
    object shtSeriNoGiris: TcxTabSheet
      Caption = 'Seri No Giri'#351
      ImageIndex = 0
      ExplicitLeft = 2
      ExplicitTop = 28
      ExplicitWidth = 531
      ExplicitHeight = 385
      object memoSeriNolar: TcxMemo
        Left = 11
        Top = 20
        Properties.ScrollBars = ssVertical
        Properties.WordWrap = False
        Properties.OnChange = memoSeriNolarPropertiesEditValueChanged
        Properties.OnEditValueChanged = memoSeriNolarPropertiesEditValueChanged
        TabOrder = 0
        Height = 328
        Width = 265
      end
      object cxLabel1: TcxLabel
        Left = 11
        Top = 1
        Caption = '**Seri Numaralar'#305'n'#305' sat'#305'r sat'#305'r olacak '#351'ekilde giriniz.'
        Properties.WordWrap = True
        Transparent = True
        Width = 262
      end
      object memoHataliSeriNo: TcxMemo
        Left = 282
        Top = 19
        Properties.ScrollBars = ssVertical
        Properties.WordWrap = False
        Properties.OnEditValueChanged = memoSeriNolarPropertiesEditValueChanged
        Style.Color = 8421631
        TabOrder = 2
        Visible = False
        Height = 328
        Width = 246
      end
      object lblHataliSeriNo: TcxLabel
        Left = 283
        Top = 1
        Caption = 'Hatal'#305' Seri Numaralar'#305
      end
    end
    object shtSeriNoDuzeltSil: TcxTabSheet
      Caption = 'Seri No D'#252'zeltme-Silme'
      ImageIndex = 1
      ExplicitLeft = 2
      ExplicitTop = 28
      ExplicitWidth = 531
      ExplicitHeight = 385
      object gridSeriNoListesi: TcxGrid
        Left = 0
        Top = 36
        Width = 535
        Height = 352
        Align = alClient
        TabOrder = 0
        object tvSeriNoListesi: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = dtsSeriNoListesi
          DataController.KeyFieldNames = 'ID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          Styles.OnGetContentStyle = tvSeriNoListesiStylesGetContentStyle
          object clmSeriNoSec: TcxGridDBColumn
            Caption = 'Se'#231
            DataBinding.ValueType = 'Boolean'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ImmediatePost = True
            Properties.NullStyle = nssUnchecked
            Properties.OnChange = clmSeriNoSecPropertiesChange
            Properties.OnEditValueChanged = clmSeriNoSecPropertiesEditValueChanged
            Width = 40
          end
          object clmSeriNo: TcxGridDBColumn
            Caption = 'Seri No'
            DataBinding.FieldName = 'SERINO'
            Width = 110
          end
          object clmGarantiBitis: TcxGridDBColumn
            Caption = 'Garanti Biti'#351
            DataBinding.FieldName = 'GARANTIBITIS'
            Width = 82
          end
          object clmSeriNoCikFaturaId: TcxGridDBColumn
            DataBinding.FieldName = 'CIKFATURAID'
            Visible = False
            Options.Editing = False
          end
        end
        object gridSeriNoListesiLevel1: TcxGridLevel
          GridView = tvSeriNoListesi
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 535
        Height = 36
        Align = alTop
        TabOrder = 1
        ExplicitWidth = 531
        object editSeriNo: TcxTextEdit
          Left = 122
          Top = 6
          TabOrder = 0
          OnKeyUp = editSeriNoKeyUp
          Width = 121
        end
        object cxLabel2: TcxLabel
          Left = 77
          Top = 11
          Caption = 'Seri No'
          Transparent = True
        end
      end
    end
  end
  object pnlAlt: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 88
    Align = alTop
    TabOrder = 1
    object lbKayitSay: TcxLabel
      Left = 395
      Top = 59
      Caption = 'Se'#231'ilen Kay'#305't Say'#305's'#305
      Transparent = True
    end
    object lblKayitSayisi: TcxLabel
      Left = 503
      Top = 60
      Caption = '0'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblHataMesaj: TcxLabel
      Left = 11
      Top = 43
      AutoSize = False
      Caption = 'lblHataMesaj'
      Style.TextColor = clRed
      Properties.WordWrap = True
      Transparent = True
      Height = 38
      Width = 375
    end
    object cxLabel3: TcxLabel
      Left = 395
      Top = 42
      Caption = 'Gerekli Kay'#305't Say'#305's'#305
      Transparent = True
    end
    object lblGerekliSayi: TcxLabel
      Left = 503
      Top = 43
      Caption = '0'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 527
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 108
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
      Images = AnaForm.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 5
      Transparent = True
      object btnKaydet: TToolButton
        Left = 0
        Top = 0
        Caption = #304#351'lemi Tamamla'
        ImageIndex = 11
        Style = tbsTextButton
        OnClick = btnSerinoKaydetClick
      end
      object ToolButton10: TToolButton
        Left = 108
        Top = 0
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 20
        Style = tbsSeparator
      end
      object btnIptal: TToolButton
        Left = 116
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 17
      end
      object ToolButton1: TToolButton
        Left = 224
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 18
        OnClick = ToolButton1Click
      end
    end
  end
  object lblGarantiSure: TcxLabel
    Left = 355
    Top = 92
    Caption = 'Garanti                    Ay'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Properties.WordWrap = True
    Transparent = True
    Width = 114
  end
  object edGarantiSure: TcxSpinEdit
    Left = 397
    Top = 90
    TabOrder = 3
    Width = 53
  end
  object dtsSeriNoListesi: TDataSource
    DataSet = tabSeriNoListesi
    OnStateChange = dtsSeriNoListesiStateChange
    Left = 268
    Top = 256
  end
  object tabSeriNoListesi: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = tabSeriNoListesiBeforeEdit
    BeforePost = tabSeriNoListesiBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM SERINO')
    Left = 365
    Top = 258
  end
end

