object HesapHareketleriAktarimAyarlariDlg: THesapHareketleriAktarimAyarlariDlg
  Left = 0
  Top = 0
  Caption = 'Hesap Hareketleri Aktarim Ayarlari'
  ClientHeight = 399
  ClientWidth = 750
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
  object ToolBar2: TToolBar
    Left = 0
    Top = 0
    Width = 750
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 61
    Caption = 'AletCubugu'
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = AnaForm.PNGImageList2
    List = True
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    Wrapable = False
    object BtnKaydet: TToolButton
      Left = 0
      Top = 0
      AutoSize = True
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = BtnKaydetClick
    end
    object BtnIptal: TToolButton
      Left = 65
      Top = 0
      AutoSize = True
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
      OnClick = BtnIptalClick
    end
    object BtnYeni: TToolButton
      Left = 118
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 4
      OnClick = BtnYeniClick
    end
    object BtnSil: TToolButton
      Left = 179
      Top = 0
      Caption = 'Sil'
      ImageIndex = 5
      OnClick = BtnSilClick
    end
  end
  object GridHesapHareketleri: TcxGrid
    Left = 0
    Top = 24
    Width = 750
    Height = 375
    Align = alClient
    TabOrder = 1
    object TableViewHesapHareketAyarlari: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DtsHesapHareketAyarlari
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Appending = True
      OptionsSelection.InvertSelect = False
      OptionsSelection.UnselectFocusedRecordOnExit = False
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      OptionsView.IndicatorWidth = 20
      object TableViewHesapHareketAyarlariPROGRAMKOD: TcxGridDBColumn
        Caption = #304#351'lem Kodu'
        DataBinding.FieldName = 'PROGRAMKOD'
        PropertiesClassName = 'TcxComboBoxProperties'
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Width = 66
      end
      object TableViewHesapHareketAyarlariGELIR: TcxGridDBColumn
        Caption = '+/-'
        DataBinding.FieldName = 'GELIR'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = '+'
            ImageIndex = 0
            Value = True
          end
          item
            Description = '-'
            Value = False
          end>
        Width = 22
      end
      object TableViewHesapHareketAyarlariKASATUR: TcxGridDBColumn
        Caption = 'Kasa T'#252'r'#252
        DataBinding.FieldName = 'KASATUR'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.ImmediatePost = True
        Properties.Items = <>
        RepositoryItem = Tablo.RepKasaTurleri
        Width = 72
      end
      object TableViewHesapHareketAyarlariREHBERESLES: TcxGridDBColumn
        Caption = 'Rehber E'#351'le'#351'tirme'
        DataBinding.FieldName = 'REHBERISLEMTURU'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Varsay'#305'lan Kullan'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'ING Cari Kod ile e'#351'le'#351'tir'
            Tag = 99
            Value = 99001
          end
          item
            Description = 'ING TC-VK No ile e'#351'le'#351'tir'
            Tag = 99
            Value = 99002
          end
          item
            Description = 'ING Hesap No ile e'#351'le'#351'tir'
            Tag = 99
            Value = 99003
          end
          item
            Description = 'TEB VK No ile e'#351'le'#351'tir'
            Tag = 32
            Value = 32001
          end
          item
            Description = 'TEB M'#252#351'teri Ref ile e'#351'le'#351'tir'
            Tag = 32
            Value = 32002
          end>
        Width = 118
      end
      object TableViewHesapHareketAyarlariVARSAYILANREHID: TcxGridDBColumn
        Caption = 'Varsay'#305'lan Rehber Kayd'#305
        DataBinding.FieldName = 'VARSAYILANREHID'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = TableViewHesapHareketAyarlariVARSAYILANREHIDPropertiesButtonClick
        OnGetDisplayText = TableViewHesapHareketAyarlariVARSAYILANREHIDGetDisplayText
        Width = 129
      end
      object ableViewHesapHareketAyarlariMASRAFESLES: TcxGridDBColumn
        Caption = 'Masraf Merkezi E'#351'le'#351'tirme'
        DataBinding.FieldName = 'MASRAFISLEMTURU'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Varsay'#305'lan'#305' Kullan'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Cari Kay'#305'ttan Al'
            Value = 1
          end>
        Width = 133
      end
      object TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZI: TcxGridDBColumn
        Caption = 'Varsay'#305'lan Masraf Merkezi'
        DataBinding.FieldName = 'VARSAYILANMASRAFMERKEZI'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZIPropertiesButtonClick
        OnGetDisplayText = TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZIGetDisplayText
        Width = 137
      end
    end
    object GridLevelHesapHareketleri: TcxGridLevel
      GridView = TableViewHesapHareketAyarlari
    end
  end
  object TabHesapHareketAyarlari: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabHesapHareketAyarlariNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from BANKAHAREKETESLESTIRME'
      'where '
      'BANKAKODU=:PBankaKodu'
      ''
      'order by 2')
    Left = 95
    Top = 82
  end
  object DtsHesapHareketAyarlari: TDataSource
    DataSet = TabHesapHareketAyarlari
    OnStateChange = DtsHesapHareketAyarlariStateChange
    Left = 96
    Top = 128
  end
end

