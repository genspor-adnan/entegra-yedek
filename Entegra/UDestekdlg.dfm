object Destekdlg: TDestekdlg
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Destek Talebi'
  ClientHeight = 219
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    660
    219)
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 654
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 63
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
    TabOrder = 0
    Transparent = True
    object Gonder: TToolButton
      Left = 0
      Top = 0
      Caption = 'G'#246'nder'
      ImageIndex = 9
      Style = tbsTextButton
      OnClick = GonderClick
    end
  end
  object cxLabel6: TcxLabel
    Left = 252
    Top = 68
    AutoSize = False
    Caption = 'Tipi *'
    Height = 17
    Width = 63
  end
  object ComboTipi: TcxImageComboBox
    Left = 321
    Top = 68
    Properties.Items = <>
    TabOrder = 2
    Width = 120
  end
  object cxLabel5: TcxLabel
    Left = 8
    Top = 201
    AutoSize = False
    Caption = 'T'#252'r'#252' *'
    Visible = False
    Height = 17
    Width = 80
  end
  object cxRadioGroup1: TcxRadioGroup
    Left = 94
    Top = 185
    Anchors = []
    Ctl3D = True
    ParentCtl3D = False
    Properties.Columns = 2
    Properties.Items = <
      item
        Caption = 'Aktivite'
      end
      item
        Caption = 'G'#246'rev'
      end>
    ItemIndex = 1
    Style.BorderStyle = ebsNone
    Style.Edges = []
    StyleDisabled.BorderStyle = ebsUltraFlat
    TabOrder = 4
    Visible = False
    ExplicitTop = 183
    Height = 28
    Width = 142
  end
  object cxLabel1: TcxLabel
    Left = 9
    Top = 36
    AutoSize = False
    Caption = 'Firma *'
    Height = 17
    Width = 80
  end
  object cxLabel4: TcxLabel
    Left = 9
    Top = 104
    AutoSize = False
    Caption = 'Konu *'
    Height = 17
    Width = 80
  end
  object ComboSorumluKisi: TcxImageComboBox
    Left = 95
    Top = 68
    Properties.Items = <>
    TabOrder = 7
    Width = 142
  end
  object MemoAciklama: TcxMemo
    Left = 95
    Top = 135
    TabOrder = 8
    Height = 71
    Width = 557
  end
  object cxLabel3: TcxLabel
    Left = 9
    Top = 138
    AutoSize = False
    Caption = 'A'#231#305'klama'
    Height = 17
    Width = 80
  end
  object cxLabel7: TcxLabel
    Left = 252
    Top = 36
    AutoSize = False
    Caption = 'Ba'#351'lama *'
    Height = 17
    Width = 63
  end
  object BaslamaTarih: TcxDateEdit
    Left = 321
    Top = 35
    Properties.Kind = ckDateTime
    TabOrder = 11
    Width = 120
  end
  object cxLabel8: TcxLabel
    Left = 447
    Top = 36
    AutoSize = False
    Caption = 'Biti'#351' *'
    Height = 17
    Width = 60
  end
  object BitisTarih: TcxDateEdit
    Left = 494
    Top = 35
    Properties.Kind = ckDateTime
    TabOrder = 13
    Width = 158
  end
  object ComboFirma: TcxImageComboBox
    Left = 95
    Top = 35
    Properties.Items = <>
    Properties.ReadOnly = True
    TabOrder = 14
    Width = 142
  end
  object CheckBox1: TCheckBox
    Left = 555
    Top = 203
    Width = 97
    Height = 17
    Caption = 'E-Posta'
    Checked = True
    State = cbChecked
    TabOrder = 15
    Visible = False
  end
  object cxLabel2: TcxLabel
    Left = 447
    Top = 72
    AutoSize = False
    Caption = 'Durum *'
    Visible = False
    Height = 17
    Width = 63
  end
  object ComboDurum: TcxImageComboBox
    Left = 494
    Top = 68
    Properties.Items = <>
    TabOrder = 17
    Visible = False
    Width = 159
  end
  object cxLabel9: TcxLabel
    Left = 9
    Top = 68
    AutoSize = False
    Caption = 'Sorumlu Ki'#351'i *'
    Height = 17
    Width = 80
  end
  object ComboKonu: TcxImageComboBox
    Left = 95
    Top = 102
    Properties.Items = <>
    TabOrder = 19
    Width = 142
  end
  object TabDestek: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM ')
    Left = 480
    Top = 111
  end
  object DtsDestek: TDataSource
    DataSet = TabDestek
    Left = 600
    Top = 107
  end
  object HTTPRIO1: THTTPRIO
    WSDLLocation = 'http://localhost:16815/Destek.asmx?WSDL'
    Service = 'TalimatEkle'
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 544
    Top = 109
  end
end


