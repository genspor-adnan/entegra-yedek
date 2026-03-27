object RehberAyarDlg: TRehberAyarDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Rehber Giri'#351' Alanlar'#305' Ayarlama Ekran'#305
  ClientHeight = 622
  ClientWidth = 1010
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1004
    Height = 29
    Margins.Bottom = 0
    ButtonHeight = 30
    ButtonWidth = 70
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
    HotTrackColor = clNone
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    ExplicitWidth = 1000
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 70
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 140
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object KaydetTus: TToolButton
      Left = 148
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 218
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton4: TToolButton
      Left = 288
      Top = 0
      Width = 260
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      ImageName = 'PngImage0'
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 548
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      ImageName = 'PngImage17'
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object GridAyar: TcxGrid
    Left = 0
    Top = 32
    Width = 1010
    Height = 590
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    ExplicitWidth = 1006
    ExplicitHeight = 589
    object GridAyarView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DtsAyar
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnTab = True
      OptionsSelection.HideSelection = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object GridAyarViewYERI: TcxGridDBColumn
        Caption = 'Yeri'
        DataBinding.FieldName = 'YERI'
        Visible = False
      end
      object GridAyarViewSIRA: TcxGridDBColumn
        Caption = 'S'#305'ra'
        DataBinding.FieldName = 'SIRA'
        Width = 32
      end
      object GridAyarViewETIKET: TcxGridDBColumn
        Caption = 'Etiket'
        DataBinding.FieldName = 'ETIKET'
        Width = 127
      end
      object GridAyarViewGIRIS: TcxGridDBColumn
        Caption = 'Giri'#351
        DataBinding.FieldName = 'GIRIS'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Yaz'#305
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Rakam'
            Value = 2
          end
          item
            Description = 'Tarih'
            Value = 3
          end
          item
            Description = 'Liste (Combo)'
            Value = 4
          end
          item
            Description = 'Sec (Check)'
            Value = 5
          end
          item
            Description = 'Liste (Img Combo)'
            Value = 6
          end
          item
            Description = 'Btn Edit'
            Value = 7
          end
          item
            Description = 'Check Combo'
            Value = 8
          end
          item
            Description = 'Check Group'
            Value = 9
          end
          item
            Description = 'Mask Edit'
            Value = 10
          end
          item
            Description = 'Ba'#351'l'#305'k (Label)'
            Value = 11
          end
          item
            Description = 'Bilgi (Label)'
            Value = 12
          end
          item
            Description = 'Virg'#252'll'#252' Rakam'
            Value = 13
          end>
        Properties.ReadOnly = False
        Properties.OnCloseUp = GridAyarViewGIRISPropertiesCloseUp
      end
      object GridAyarViewKAYNAK: TcxGridDBColumn
        Caption = 'Kaynak'
        DataBinding.FieldName = 'KAYNAK'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.BeepOnError = True
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ClearKey = 46
        Properties.OnButtonClick = GridAyarViewKAYNAKPropertiesButtonClick
        Width = 200
      end
      object GridAyarViewVARSAYILAN: TcxGridDBColumn
        Caption = 'Varsay'#305'lan'
        DataBinding.FieldName = 'VARSAYILAN'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        OnGetPropertiesForEdit = GridAyarViewVARSAYILANGetPropertiesForEdit
        Width = 111
      end
      object GridAyarViewZORUNLU: TcxGridDBColumn
        Caption = 'Zorunlu'
        DataBinding.FieldName = 'ZORUNLU'
        PropertiesClassName = 'TcxCheckBoxProperties'
      end
      object GridAyarViewLIMIT: TcxGridDBColumn
        Caption = 'Limit'
        DataBinding.FieldName = 'LIMIT'
        Width = 80
      end
      object GridAyarViewLIMITALT: TcxGridDBColumn
        Caption = 'Limit Alt'
        DataBinding.FieldName = 'LIMITALT'
      end
      object GridAyarViewLIMITUST: TcxGridDBColumn
        Caption = 'Limit '#220'st'
        DataBinding.FieldName = 'LIMITUST'
      end
      object GridAyarViewLIMITBIRIM: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'LIMITBIRIM'
        Width = 65
      end
      object GridAyarViewLIMITNOT: TcxGridDBColumn
        Caption = 'Notlar'
        DataBinding.FieldName = 'LIMITNOT'
        Width = 80
      end
    end
    object GridAyarLevel1: TcxGridLevel
      GridView = GridAyarView
    end
  end
  object TabAyar: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabAyarBeforePost
    BeforeDelete = TabAyarBeforeDelete
    AfterScroll = TabAyarAfterScroll
    OnNewRecord = TabAyarNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * '
      'from REHBERAYAR'
      'where YERI=:YERI  and'
      'isnull(BOLUM,'#39#39')=:Bolum'
      'order by 2   ')
    Left = 215
    Top = 93
  end
  object DtsAyar: TDataSource
    DataSet = TabAyar
    OnStateChange = DtsAyarStateChange
    Left = 351
    Top = 91
  end
end

