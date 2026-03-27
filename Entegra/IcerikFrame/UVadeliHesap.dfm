object VadeliHesapDlg: TVadeliHesapDlg
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  OnResize = FrameResize
  object Panel5: TPanel
    Left = 0
    Top = 32
    Width = 451
    Height = 70
    Align = alTop
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 0
    object Label3: TcxLabel
      Left = 820
      Top = 39
      Caption = 'Ad'#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object Label8: TcxLabel
      Left = 623
      Top = 14
      Caption = #214'zel Kod'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label9: TcxLabel
      Left = 623
      Top = 39
      Caption = 'Yetki Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label29: TcxLabel
      Left = 322
      Top = 14
      Caption = 'Hesap Ad'#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label30: TcxLabel
      Left = 6
      Top = 14
      Caption = 'Vadesiz Hesap Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label14: TcxLabel
      Left = 322
      Top = 39
      Caption = 'Vadeli Hesap Ad'#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label15: TcxLabel
      Left = 6
      Top = 39
      Caption = 'Vadeli Hesap Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label1: TcxLabel
      Left = 820
      Top = 14
      Caption = 'Referans No'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditADI: TcxDBTextEdit
      Left = 850
      Top = 39
      DataBinding.DataField = 'ADI'
      DataBinding.DataSource = DtsVadeliHesap
      TabOrder = 0
      Visible = False
      Width = 121
    end
    object EditOZELKOD: TcxDBTextEdit
      Left = 689
      Top = 14
      DataBinding.DataField = 'OZELKOD'
      DataBinding.DataSource = DtsVadeliHesap
      TabOrder = 1
      Width = 78
    end
    object EditYETKIKODU: TcxDBTextEdit
      Left = 689
      Top = 39
      DataBinding.DataField = 'YETKIKODU'
      DataBinding.DataSource = DtsVadeliHesap
      TabOrder = 2
      Width = 78
    end
    object EditHESAPKODU: TcxButtonEdit
      Left = 119
      Top = 14
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditHESAPKODUPropertiesButtonClick
      TabOrder = 3
      Width = 132
    end
    object EditVADESIZHESAPID: TcxDBTextEdit
      Left = 252
      Top = 14
      TabStop = False
      DataBinding.DataField = 'VADESIZHESAPID'
      DataBinding.DataSource = DtsVadeliHesap
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 4
      Visible = False
      Width = 28
    end
    object EditHESAPADI: TcxTextEdit
      Left = 415
      Top = 14
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 5
      Width = 173
    end
    object EditVadeliHesapKodu: TcxButtonEdit
      Left = 119
      Top = 39
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cxDBButtonEdit1PropertiesButtonClick
      TabOrder = 6
      Width = 132
    end
    object EditVADELIHESAPID: TcxDBTextEdit
      Left = 252
      Top = 39
      TabStop = False
      DataBinding.DataField = 'VADELIHESAPID'
      DataBinding.DataSource = DtsVadeliHesap
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 7
      Visible = False
      Width = 28
    end
    object EditVadeliHesapAdi: TcxTextEdit
      Left = 415
      Top = 39
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 8
      Width = 173
    end
    object EditRefNo: TcxDBTextEdit
      Left = 893
      Top = 14
      DataBinding.DataField = 'REFERANS'
      DataBinding.DataSource = DtsVadeliHesap
      TabOrder = 9
      Width = 78
    end
  end
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 69
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Ekle'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 69
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 138
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 207
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton4: TToolButton
      Left = 276
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 284
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 102
    Width = 451
    Height = 202
    Align = alClient
    TabOrder = 2
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 443
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 61
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
      TabOrder = 0
      Transparent = True
      object VadeEkleTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Ekle'
        ImageIndex = 0
        OnClick = VadeEkleTusClick
      end
      object VadeSilTus: TToolButton
        Left = 61
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = VadeSilTusClick
      end
      object VadeKaydetTus: TToolButton
        Left = 122
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Style = tbsTextButton
        Visible = False
        OnClick = VadeKaydetTusClick
      end
      object VadeIptalTus: TToolButton
        Left = 183
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Style = tbsTextButton
        Visible = False
        OnClick = VadeIptalTusClick
      end
    end
    object GridTakvim: TcxGrid
      Left = 1
      Top = 162
      Width = 449
      Height = 39
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      ExplicitHeight = 36
      object TakvimView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsHareket
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.GroupByBox = False
        object TakvimViewDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              Description = 'Yeni'
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Aktif'
              ImageIndex = 0
              Value = 1
            end
            item
              Description = 'Yenilendi'
              Value = 2
            end
            item
              Description = 'Vade Bitti'
              Value = 3
            end
            item
              Description = 'Bozuldu'
              Value = 4
            end>
          Width = 39
        end
        object TakvimViewTARIH: TcxGridDBColumn
          Caption = 'Ba'#351'.Tarih'
          DataBinding.FieldName = 'BASLAMATARIHI'
          Width = 68
        end
        object TakvimViewSURESAY: TcxGridDBColumn
          Caption = 'S'#252're'
          DataBinding.FieldName = 'SURESAY'
          Width = 31
        end
        object TakvimViewSUREBIRIM: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'SUREBIRIM'
          Width = 32
        end
        object TakvimViewBITISTARIHI: TcxGridDBColumn
          Caption = 'Bit.Tarihi'
          DataBinding.FieldName = 'BITISTARIHI'
          Width = 67
        end
        object TakvimViewYATANTUTAR: TcxGridDBColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'YATANTUTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Width = 63
        end
        object TakvimViewTEMDIT: TcxGridDBColumn
          Caption = 'Temdit'
          DataBinding.FieldName = 'TEMDIT'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Width = 40
        end
        object TakvimViewEKLEYEN: TcxGridDBColumn
          Caption = 'Kul.'
          DataBinding.FieldName = 'EKLEYEN'
          Width = 29
        end
      end
      object cxGridLevel4: TcxGridLevel
        GridView = TakvimView
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 28
      Width = 449
      Height = 134
      Align = alTop
      TabOrder = 2
      object lblrisk: TcxLabel
        Left = 321
        Top = 6
        Caption = 'Yat'#305'r'#305'lan Tutar'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label5: TcxLabel
        Left = 321
        Top = 32
        Caption = 'Faiz Oran'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label10: TcxLabel
        Left = 321
        Top = 56
        Caption = 'Stopaj Oran'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label7: TcxLabel
        Left = 622
        Top = 7
        Caption = 'Durum'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label33: TcxLabel
        Left = 5
        Top = 7
        Caption = 'Ba'#351'lama Tarihi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label36: TcxLabel
        Left = 5
        Top = 32
        Caption = 'S'#252'resi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label4: TcxLabel
        Left = 5
        Top = 56
        Caption = 'Biti'#351' Tarihi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label11: TcxLabel
        Left = 622
        Top = 32
        Caption = 'Vade Sonu Tutar'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label12: TcxLabel
        Left = 622
        Top = 56
        Caption = 'Kesinti'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label13: TcxLabel
        Left = 622
        Top = 80
        Caption = 'Net Tutar'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label17: TcxLabel
        Left = 126
        Top = 104
        Caption = 'Vade Sonunda Vadesiz Hesaba Aktar'#305'm'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelBitTarih: TcxLabel
        Left = 5
        Top = 80
        Caption = 'Normal Biti'#351' Tarihi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TextColor = clRed
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
      end
      object EditYATANTUTAR: TcxDBCurrencyEdit
        Left = 420
        Top = 7
        DataBinding.DataField = 'YATANTUTAR'
        DataBinding.DataSource = DtsHareket
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseLeftAlignmentOnEditing = False
        Properties.UseThousandSeparator = True
        Properties.OnChange = cxDBSpinEdit1PropertiesChange
        Style.BorderStyle = ebs3D
        TabOrder = 0
        Width = 74
      end
      object EditFAIZORANI: TcxDBCurrencyEdit
        Left = 420
        Top = 32
        DataBinding.DataField = 'FAIZORANI'
        DataBinding.DataSource = DtsHareket
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseLeftAlignmentOnEditing = False
        Properties.UseThousandSeparator = True
        Properties.OnChange = cxDBSpinEdit1PropertiesChange
        Style.BorderStyle = ebs3D
        TabOrder = 1
        Width = 74
      end
      object EditSTOPAJORANI: TcxDBCurrencyEdit
        Left = 420
        Top = 56
        DataBinding.DataField = 'STOPAJORANI'
        DataBinding.DataSource = DtsHareket
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseLeftAlignmentOnEditing = False
        Properties.UseThousandSeparator = True
        Properties.OnChange = cxDBSpinEdit1PropertiesChange
        Style.BorderStyle = ebs3D
        TabOrder = 2
        Width = 74
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 714
        Top = 6
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsHareket
        Properties.Items = <
          item
            Description = 'Yeni'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Yenilendi'
            Value = 2
          end
          item
            Description = 'Vade Bitti'
            Value = 3
          end
          item
            Description = 'Bozuldu'
            Value = 4
          end
          item
            Description = 'Bloke'
            Value = 5
          end>
        TabOrder = 3
        Width = 78
      end
      object DateBas: TcxDBDateEdit
        Left = 129
        Top = 7
        DataBinding.DataField = 'BASLAMATARIHI'
        DataBinding.DataSource = DtsHareket
        TabOrder = 4
        Width = 121
      end
      object DateBit: TcxDBTextEdit
        Left = 129
        Top = 56
        DataBinding.DataField = 'BITISTARIHI'
        DataBinding.DataSource = DtsHareket
        ParentColor = True
        Properties.ReadOnly = True
        Style.BorderColor = clGrayText
        Style.BorderStyle = ebsUltraFlat
        Style.Edges = []
        TabOrder = 5
        Width = 121
      end
      object SpinSay: TcxDBSpinEdit
        Left = 129
        Top = 32
        DataBinding.DataField = 'SURESAY'
        DataBinding.DataSource = DtsHareket
        Properties.MinValue = 1.000000000000000000
        Properties.OnChange = cxDBSpinEdit1PropertiesChange
        TabOrder = 6
        Width = 62
      end
      object ComboSureBirim: TcxDBComboBox
        Left = 192
        Top = 31
        DataBinding.DataField = 'SUREBIRIM'
        DataBinding.DataSource = DtsHareket
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          'G'#252'n'
          'Ay'
          'Y'#305'l')
        Properties.OnChange = cxDBSpinEdit1PropertiesChange
        TabOrder = 7
        Width = 56
      end
      object EditVADESONUTUTARI: TcxDBCurrencyEdit
        Left = 714
        Top = 32
        DataBinding.DataField = 'VADESONUTUTARI'
        DataBinding.DataSource = DtsHareket
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.ReadOnly = True
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseLeftAlignmentOnEditing = False
        Properties.UseThousandSeparator = True
        Style.BorderStyle = ebs3D
        TabOrder = 8
        Width = 78
      end
      object EditKESINTITUTARI: TcxDBCurrencyEdit
        Left = 714
        Top = 56
        DataBinding.DataField = 'KESINTITUTARI'
        DataBinding.DataSource = DtsHareket
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.ReadOnly = True
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseLeftAlignmentOnEditing = False
        Properties.UseThousandSeparator = True
        Style.BorderStyle = ebs3D
        TabOrder = 9
        Width = 78
      end
      object EditNETTUTAR: TcxDBCurrencyEdit
        Left = 714
        Top = 80
        DataBinding.DataField = 'NETTUTAR'
        DataBinding.DataSource = DtsHareket
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.ReadOnly = True
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseLeftAlignmentOnEditing = False
        Properties.UseThousandSeparator = True
        Style.BorderStyle = ebs3D
        TabOrder = 10
        Width = 78
      end
      object cxDBCheckBox1: TcxDBCheckBox
        Left = 5
        Top = 103
        Caption = 'Temditli'
        DataBinding.DataField = 'TEMDIT'
        DataBinding.DataSource = DtsHareket
        TabOrder = 11
        Transparent = True
      end
      object cxDBImageComboBox1: TcxDBImageComboBox
        Left = 338
        Top = 103
        DataBinding.DataField = 'SURESONUNDA'
        DataBinding.DataSource = DtsHareket
        Properties.Items = <
          item
            Description = 'Aktar'#305'lmas'#305'n'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Sadece Faiz Aktar'#305'ls'#305'n'
            Value = 1
          end
          item
            Description = 'Anapara + Faiz Aktar'#305'ls'#305'n'
            Value = 2
          end>
        TabOrder = 12
        Width = 156
      end
      object AletCubugu: TToolBar
        Left = 5
        Top = -143
        Width = 43
        Height = 22
        Align = alNone
        AutoSize = True
        ButtonWidth = 43
        Caption = #304#351'lemler'
        DockSite = True
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        List = True
        ParentFont = False
        ShowCaptions = True
        TabOrder = 13
      end
      object NormalBitTarihi: TcxTextEdit
        Left = 128
        Top = 80
        ParentColor = True
        Style.Edges = []
        TabOrder = 14
        Text = 'NormalBitTarihi'
        Visible = False
        Width = 122
      end
    end
  end
  object DtsVadeliHesap: TDataSource
    DataSet = TabVadeliHesap
    OnStateChange = DtsVadeliHesapStateChange
    Left = 796
    Top = 276
  end
  object TabVadeliHesap: TFDQuery
    BeforePost = TabVadeliHesapBeforePost
    BeforeDelete = TabVadeliHesapBeforeDelete
    AfterScroll = TabVadeliHesapAfterScroll
    OnNewRecord = TabVadeliHesapNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from VADELIHESAP order by ID desc')
    Left = 596
    Top = 290
  end
  object PopupMenu1: TPopupMenu
    Left = 376
    Top = 363
    object BaslatMenu: TMenuItem
      Caption = 'Vadesiz hesaptan vadeli hesaba aktar ve vadeyi ba'#351'lat'
      OnClick = BaslatMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object IslemBittiMenu: TMenuItem
      Caption = 
        'Vade sona erdi; i'#351'lemi durdur, toplam paray'#305' vadesiz hesaba akta' +
        'r'
      OnClick = IslemBittiMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object TemditliYenileMenu: TMenuItem
      Caption = #304#351'lem temditli; yenileyerek devam ettir'
      OnClick = TemditliYenileMenuClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object VadeBozMenu: TMenuItem
      Caption = 'Vadeyi bozdur; anaparay'#305' vadesiz hesaba aktar'
      OnClick = VadeBozMenuClick
    end
  end
  object TabHareket: TFDQuery
    BeforePost = TabHareketBeforePost
    AfterPost = TabHareketAfterPost
    BeforeDelete = TabHareketBeforeDelete
    OnNewRecord = TabHareketNewRecord
    ParamData = <
      item
        Name = 'PID'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end>
    SQL.Strings = (
      
        'select * from VADELIHESAPHAR where VADELIHSID=:PID order by ID d' +
        'esc')
    Left = 643
    Top = 273
  end
  object DtsHareket: TDataSource
    DataSet = TabHareket
    OnStateChange = DtsHareketStateChange
    Left = 727
    Top = 273
  end
end

