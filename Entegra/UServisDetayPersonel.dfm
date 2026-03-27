object ServisDetayPersonelDlg: TServisDetayPersonelDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #304#351'lem Detay'#305
  ClientHeight = 292
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxLabel3: TcxLabel
    Left = 0
    Top = 135
    Caption = 'Personel'
  end
  object cxLabel4: TcxLabel
    Left = 304
    Top = 29
    Caption = 'Puan'
  end
  object ToolBarProblem: TToolBar
    Left = 0
    Top = 0
    Width = 447
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
    object BtnProblemKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      OnClick = BtnProblemKaydetClick
    end
    object BtnProblemIptal: TToolButton
      Left = 62
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      OnClick = BtnProblemIptalClick
    end
  end
  object BEPersonel: TcxButtonEdit
    Left = 84
    Top = 134
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.ReadOnly = True
    Properties.OnButtonClick = BEPersonelPropertiesButtonClick
    TabOrder = 3
    Width = 343
  end
  object cxLabel6: TcxLabel
    Left = 0
    Top = 207
    Caption = 'A'#231#305'klama'
  end
  object CheckTamamlanma: TcxDBCheckBox
    Left = 304
    Top = 56
    Caption = 'Tamamlanma'
    DataBinding.DataField = 'TAMAMLANMA'
    Properties.ImmediatePost = True
    TabOrder = 5
    Width = 89
  end
  object SpinPuan: TcxDBSpinEdit
    Left = 340
    Top = 28
    DataBinding.DataField = 'PUAN'
    Properties.ImmediatePost = True
    TabOrder = 6
    Width = 85
  end
  object EditAciklama: TcxDBTextEdit
    Left = 84
    Top = 205
    AutoSize = False
    DataBinding.DataField = 'ACIKLAMA'
    TabOrder = 7
    Height = 49
    Width = 343
  end
  object cxLabel5: TcxLabel
    Left = 0
    Top = 159
    Caption = 'Kod'
  end
  object BEKod: TcxDBButtonEdit
    Left = 84
    Top = 158
    DataBinding.DataField = 'KOD'
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.ReadOnly = True
    Properties.OnButtonClick = BEKodPropertiesButtonClick
    TabOrder = 9
    Width = 343
  end
  object cxLabel8: TcxLabel
    Left = 0
    Top = 182
    Caption = 'Ad'
  end
  object EditAd: TcxDBTextEdit
    Left = 84
    Top = 181
    DataBinding.DataField = 'AD'
    Properties.ReadOnly = False
    TabOrder = 11
    Width = 343
  end
  object LabelSureFarki: TcxLabel
    Left = 0
    Top = 109
    AutoSize = False
    Style.TextColor = clRed
    Properties.Alignment.Horz = taRightJustify
    Properties.WordWrap = True
    Transparent = True
    Height = 16
    Width = 218
    AnchorX = 218
  end
  object cxLabel7: TcxLabel
    Left = 1
    Top = 86
    Caption = 'S'#252're'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.TextColor = clPurple
    Style.IsFontAssigned = True
  end
  object SpinSure: TcxDBSpinEdit
    Left = 84
    Top = 82
    DataBinding.DataField = 'SURE'
    ParentFont = False
    Properties.DisplayFormat = '########0.00'
    Properties.EditFormat = '########0.00'
    Properties.ImmediatePost = True
    Properties.UseDisplayFormatWhenEditing = True
    Properties.ValueType = vtFloat
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clPurple
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 14
    Width = 82
  end
  object ComboSUREBIRIMI: TcxDBImageComboBox
    Left = 174
    Top = 81
    RepositoryItem = Tablo.repZamanBirimleri
    DataBinding.DataField = 'SUREBIRIMI'
    ParentFont = False
    Properties.ImmediatePost = True
    Properties.Items = <>
    Properties.PostPopupValueOnTab = True
    Properties.ReadOnly = True
    Properties.OnCloseUp = ComboSUREBIRIMIPropertiesCloseUp
    Properties.OnEditValueChanged = ComboSUREBIRIMIPropertiesEditValueChanged
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clPurple
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 15
    Width = 88
  end
  object cxLabel1: TcxLabel
    Left = 0
    Top = 29
    Caption = 'Ba'#351'lama'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.TextColor = clGreen
    Style.IsFontAssigned = True
  end
  object cxLabel2: TcxLabel
    Left = 0
    Top = 53
    Caption = 'Biti'#351
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.TextColor = clRed
    Style.IsFontAssigned = True
  end
  object DateBasTar: TcxDBDateEdit
    Left = 83
    Top = 28
    DataBinding.DataField = 'BASTAR'
    ParentFont = False
    Properties.DateButtons = [btnClear, btnNow, btnToday]
    Properties.ImmediatePost = True
    Properties.PostPopupValueOnTab = True
    Properties.ShowTime = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 18
    Width = 82
  end
  object DateBitTar: TcxDBDateEdit
    Left = 83
    Top = 52
    DataBinding.DataField = 'BITTAR'
    ParentFont = False
    Properties.DateButtons = [btnClear, btnNow, btnToday]
    Properties.ImmediatePost = True
    Properties.PostPopupValueOnTab = True
    Properties.ShowTime = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 19
    Width = 82
  end
  object CbBasSaat: TcxComboBox
    Left = 173
    Top = 28
    ParentFont = False
    Properties.ImmediatePost = True
    Properties.ImmediateUpdateText = True
    Properties.Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15'
      '16'
      '17'
      '18'
      '19'
      '20'
      '21'
      '22'
      '23')
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 20
    Width = 42
  end
  object CbBasDk: TcxComboBox
    Left = 218
    Top = 28
    ParentFont = False
    Properties.ImmediatePost = True
    Properties.ImmediateUpdateText = True
    Properties.Items.Strings = (
      '0'
      '5'
      '10'
      '15'
      '20'
      '25'
      '30'
      '35'
      '40'
      '45'
      '50'
      '55')
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 21
    Width = 42
  end
  object CbBitSaat: TcxComboBox
    Left = 174
    Top = 52
    ParentFont = False
    Properties.ImmediatePost = True
    Properties.ImmediateUpdateText = True
    Properties.Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15'
      '16'
      '17'
      '18'
      '19'
      '20'
      '21'
      '22'
      '23')
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 22
    Width = 42
  end
  object CbBitDk: TcxComboBox
    Left = 221
    Top = 54
    ParentFont = False
    Properties.ImmediatePost = True
    Properties.ImmediateUpdateText = True
    Properties.Items.Strings = (
      '0'
      '5'
      '10'
      '15'
      '20'
      '25'
      '30'
      '35'
      '40'
      '45'
      '50'
      '55')
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 23
    Width = 42
  end
end
