object ExcelKolonAyarDlg: TExcelKolonAyarDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Excel Kolon Ayarlar'#305
  ClientHeight = 506
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ExcelKolon: TcxGrid
    Left = 0
    Top = 68
    Width = 385
    Height = 438
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    ExplicitWidth = 407
    object ExcelKolonTV: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = dtsTabAyarlar
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
      OptionsData.Appending = True
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object ExcelKolonTVSIRA: TcxGridDBColumn
        Caption = 'S'#305'ra'
        DataBinding.FieldName = 'SIRA'
        Width = 51
      end
      object ExcelKolonTVTABLO: TcxGridDBColumn
        Caption = 'Tablo'
        DataBinding.FieldName = 'TABLO'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Alignment.Horz = taLeftJustify
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'FATBASLIK'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'FATURA'
            Tag = 1
            Value = 1
          end>
        Width = 118
      end
      object ExcelKolonTVALAN: TcxGridDBColumn
        Caption = 'Alan'
        DataBinding.FieldName = 'ALAN'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'FIRMA'
            ImageIndex = 0
            Value = 'FIRMA'
          end
          item
            Description = 'BASLIK'
            ImageIndex = 0
            Value = 'BASLIK'
          end
          item
            Description = 'ADRES'
            Value = 'ADRES'
          end
          item
            Description = 'ILCE'
            Value = 'ILCE'
          end
          item
            Description = 'IL'
            Value = 'IL'
          end
          item
            Description = 'VD'
            Value = 'VD'
          end
          item
            Description = 'VNO'
            Value = 'VNO'
          end
          item
            Description = 'TAR'#304'H'
            Value = 'TAR'#304'H'
          end
          item
            Description = 'ACIKLAMA'
            Value = 'ACIKLAMA'
          end
          item
            Description = 'STOKADI'
            Value = 'STOKADI'
          end
          item
            Description = 'BIRIMFIYAT'
            Value = 'BIRIMFIYAT'
          end
          item
            Description = 'ADET'
            Value = 'ADET'
          end>
        Width = 117
      end
      object ExcelKolonTVEXCELKOLON: TcxGridDBColumn
        Caption = 'Excel Kolon'
        DataBinding.FieldName = 'EXCELKOLON'
        Width = 69
      end
    end
    object cxGridLevel9: TcxGridLevel
      GridView = ExcelKolonTV
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 27
    Width = 385
    Height = 41
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 407
    object cxLabel1: TcxLabel
      Left = 27
      Top = 13
      Caption = 'Firma'
      Transparent = True
    end
    object BEditFirma: TcxButtonEdit
      Left = 63
      Top = 12
      Enabled = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 1
      Width = 316
    end
  end
  object ToolBar5: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 379
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
    Images = AnaForm.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 2
    Transparent = True
    ExplicitWidth = 401
    object btnKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 15
      Visible = False
      OnClick = btnKaydetClick
    end
    object ToolButton1: TToolButton
      Left = 62
      Top = 0
      Width = 11
      Caption = 'ToolButton1'
      ImageIndex = 15
      Style = tbsSeparator
    end
    object btnSatirEkle: TToolButton
      Left = 73
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 0
      OnClick = btnSatirEkleClick
    end
    object btnSatirSil: TToolButton
      Left = 135
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = btnSatirSilClick
    end
    object ToolButton10: TToolButton
      Left = 197
      Top = 0
      Width = 92
      Caption = 'ToolButton3'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 289
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 14
      OnClick = btnKapatClick
    end
  end
  object TabAyarlar: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabAyarlarNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select * from SIPARIS_EXCEL '
      'Where REHBERID=:PRehID')
    Left = 360
    Top = 96
  end
  object dtsTabAyarlar: TDataSource
    DataSet = TabAyarlar
    OnStateChange = dtsTabAyarlarStateChange
    Left = 296
    Top = 96
  end
end

