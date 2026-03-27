object MailSablon: TMailSablon
  Left = 0
  Top = 0
  Align = alCustom
  AutoSize = True
  BorderStyle = bsToolWindow
  Caption = 'Mail '#350'ablonu D'#252'zenleme Ekran'#305
  ClientHeight = 536
  ClientWidth = 777
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 178
    Top = 27
    Width = 599
    Height = 479
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object cxGroupBox1: TcxGroupBox
      Left = 0
      Top = 105
      Margins.Left = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alBottom
      Caption = 'Mesaj '#304#231'eri'#287'i'
      Ctl3D = False
      PanelStyle.OfficeBackgroundKind = pobkGradient
      ParentCtl3D = False
      Style.BorderStyle = ebsUltraFlat
      Style.Edges = [bTop]
      Style.LookAndFeel.NativeStyle = False
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.NativeStyle = False
      TabOrder = 0
      Height = 374
      Width = 599
      object cxDBRichEdit1: TcxDBRichEdit
        Left = 1
        Top = 16
        Align = alClient
        DataBinding.DataField = 'ICERIK'
        DataBinding.DataSource = dtsMailSablonu
        TabOrder = 0
        Height = 352
        Width = 597
      end
      object JvRichEdit1: TJvRichEdit
        Left = 144
        Top = 96
        Width = 185
        Height = 89
        Flat = True
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        SelText = ''
        TabOrder = 1
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 599
      Height = 105
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object cxlblModul: TcxLabel
        Left = 10
        Top = 39
        AutoSize = False
        Caption = 'D'#246'k'#252'm Ad'#305':'
        Properties.Alignment.Horz = taRightJustify
        Height = 17
        Width = 64
        AnchorX = 74
      end
      object txtKonu: TcxDBTextEdit
        Left = 112
        Top = 61
        DataBinding.DataField = 'KONU'
        DataBinding.DataSource = dtsMailSablonu
        TabOrder = 1
        Width = 201
      end
      object cxlbl1: TcxLabel
        Left = 6
        Top = 62
        AutoSize = False
        Caption = 'Mail Konusu:'
        Properties.Alignment.Horz = taRightJustify
        Height = 17
        Width = 74
        AnchorX = 80
      end
      object cxGroupBox2: TcxGroupBox
        Left = 360
        Top = 3
        Caption = 'G'#246'nderim Kanallar'#305
        TabOrder = 3
        Height = 96
        Width = 185
        object cxDBCheckBox1: TcxDBCheckBox
          Left = 16
          Top = 16
          Caption = 'E-Posta'
          DataBinding.DataField = 'EPOSTA'
          DataBinding.DataSource = dtsMailSablonu
          TabOrder = 0
          Transparent = True
          Width = 121
        end
        object cxDBCheckBox2: TcxDBCheckBox
          Left = 16
          Top = 35
          Caption = 'SMS'
          DataBinding.DataField = 'SMS'
          DataBinding.DataSource = dtsMailSablonu
          TabOrder = 1
          Transparent = True
          Width = 121
        end
        object cxDBCheckBox3: TcxDBCheckBox
          Left = 16
          Top = 53
          Caption = 'WhatsApp'
          DataBinding.DataField = 'WHATSAPP'
          DataBinding.DataSource = dtsMailSablonu
          TabOrder = 2
          Transparent = True
          Width = 97
        end
      end
      object ComoDokum: TcxDBImageComboBox
        Left = 112
        Top = 34
        DataBinding.DataField = 'DOKUMID'
        DataBinding.DataSource = dtsMailSablonu
        Properties.Items = <>
        TabOrder = 4
        Width = 201
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 506
    Width = 777
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 771
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
    TabOrder = 2
    Transparent = True
    object MailSablonKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = MailSablonKaydetClick
    end
    object MailSablonIptal: TToolButton
      Left = 62
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
      OnClick = MailSablonIptalClick
    end
    object ToolButton1: TToolButton
      Left = 124
      Top = 0
      Width = 541
      Caption = 'ToolButton1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object KapatTus: TToolButton
      Left = 665
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 14
      OnClick = KapatTusClick
    end
  end
  object SolMenu: TCategoryButtons
    Tag = 1
    Left = 0
    Top = 27
    Width = 178
    Height = 479
    Align = alLeft
    BevelOuter = bvNone
    BorderStyle = bsNone
    ButtonFlow = cbfVertical
    ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boUsePlusMinus]
    Categories = <
      item
        Color = 15400959
        Collapsed = False
        Items = <>
      end>
    Color = clMedGray
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    HotButtonColor = 14525318
    Images = Tablo.PNGImageList2
    RegularButtonColor = clSilver
    SelectedButtonColor = 12303291
    TabOrder = 3
    OnButtonClicked = SolMenuButtonClicked
  end
  object dtsMailSablonu: TDataSource
    DataSet = TabMailSablon
    OnStateChange = dtsMailSablonuStateChange
    Left = 24
    Top = 256
  end
  object TabMailSablon: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabMailSablonBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM MAILSABLON WHERE MODULID=:MODULID'
      'order by ID')
    Left = 88
    Top = 256
  end
end

