object UretDlg: TUretDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #220'retim '
  ClientHeight = 222
  ClientWidth = 609
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
  object Panel3: TPanel
    Left = 0
    Top = 35
    Width = 609
    Height = 187
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 3
    ExplicitTop = 38
    object cxLabel4: TcxLabel
      Left = 218
      Top = 112
      Caption = 'S'#305'ra Numaras'#305' Ba'#351'lang'#305#231
    end
    object EdtUrunSiraNoBaslangic: TcxTextEdit
      Left = 218
      Top = 129
      TabOrder = 1
      Text = '1030237'
      Width = 127
    end
    object cxLabel5: TcxLabel
      Left = 218
      Top = 4
      Caption = 'Lot Numaras'#305
    end
    object EdtUrunLotNo: TcxTextEdit
      Left = 216
      Top = 22
      TabOrder = 3
      OnExit = EdtUrunLotNoExit
      OnKeyPress = EdtUrunLotNoKeyPress
      Width = 150
    end
    object cxLabel6: TcxLabel
      Left = 372
      Top = 58
      Caption = 'Son Kullanma Tarihi'
    end
    object DtUrunSonKullanim: TcxDateEdit
      Left = 372
      Top = 73
      Properties.OnChange = DtUrunSonKullanimPropertiesChange
      TabOrder = 5
      Width = 152
    end
    object cxLabel7: TcxLabel
      Left = 163
      Top = 4
      Caption = 'Adet'
    end
    object cxLabel8: TcxLabel
      Left = 11
      Top = 6
      Caption = 'Barkod Numaras'#305' (GTIN)'
    end
    object cxLabel12: TcxLabel
      Left = 11
      Top = 57
      Caption = #220'retim Tipi'
    end
    object cxLabel13: TcxLabel
      Left = 216
      Top = 57
      Caption = #220'r'#252'n Cinsi'
    end
    object CmbUrunUrunCinsi: TcxImageComboBox
      Left = 216
      Top = 72
      EditValue = 'PP'
      Properties.DefaultImageIndex = 0
      Properties.Items = <
        item
          Description = #304'la'#231
          ImageIndex = 0
          Value = 'PP'
        end
        item
          Description = 'Ara '#220'r'#252'n'
          Value = 'BP'
        end
        item
          Description = 'Besleme '#220'r'#252'n'
          Value = 'FP'
        end>
      TabOrder = 10
      Width = 150
    end
    object CmbUrunUretimTipi: TcxImageComboBox
      Left = 11
      Top = 72
      EditValue = 'M'
      Properties.DefaultImageIndex = 0
      Properties.Items = <
        item
          Description = #220'retim'
          ImageIndex = 0
          Value = 'M'
        end
        item
          Description = #304'thalat'
          Value = #304
        end>
      TabOrder = 11
      Width = 202
    end
    object DtUrunUretimTarihi: TcxDateEdit
      Left = 372
      Top = 22
      Properties.OnChange = DtUrunUretimTarihiPropertiesChange
      TabOrder = 12
      Width = 152
    end
    object cxLabel14: TcxLabel
      Left = 372
      Top = 3
      Caption = #220'retim Tarihi Tarihi'
    end
    object cxLabel19: TcxLabel
      Left = 163
      Top = 112
      Caption = 'Sabit'
    end
    object cxLabel20: TcxLabel
      Left = 532
      Top = 114
      Caption = 'Hane'
      Visible = False
    end
    object EdtUrunSabit: TcxTextEdit
      Left = 163
      Top = 129
      TabOrder = 16
      Text = '90'
      Width = 48
    end
    object CmbUrunHane: TcxComboBox
      Left = 532
      Top = 129
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
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
        '18'
        '19'
        '20')
      TabOrder = 17
      Text = '9'
      Visible = False
      Width = 58
    end
    object cxLabel21: TcxLabel
      Left = 3
      Top = 113
      Caption = 'En son S'#305'ra Numaras'#305
    end
    object LblEnSonSira: TcxLabel
      Left = 3
      Top = 129
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clNavy
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object EdtUrunAdet: TcxDBTextEdit
      Left = 163
      Top = 22
      DataBinding.DataField = 'URETIMADET'
      DataBinding.DataSource = ITSBildirimDlg.DtsUretimListesi
      Enabled = False
      TabOrder = 20
      Width = 49
    end
    object EdtUrunBarkodNumarası: TcxDBTextEdit
      Left = 11
      Top = 22
      DataBinding.DataField = 'BARKOD'
      DataBinding.DataSource = ITSBildirimDlg.DtsUretimListesi
      Enabled = False
      TabOrder = 21
      Width = 150
    end
    object EditUrunNo: TcxTextEdit
      Left = 372
      Top = 129
      TabOrder = 22
      Width = 152
    end
    object cxLabel1: TcxLabel
      Left = 372
      Top = 112
      Caption = #220'r'#252'n No'
    end
  end
  object TbAletCubugu: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 603
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 71
    Caption = 'TbAletCubugu'
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object BtnUret: TToolButton
      Left = 0
      Top = 0
      Caption = #220'ret'
      ImageIndex = 7
      Style = tbsTextButton
      OnClick = BtnUretClick
    end
    object ToolButton10: TToolButton
      Left = 71
      Top = 0
      Width = 8
      Caption = 'ToolButton10'
      ImageIndex = 20
      Style = tbsSeparator
    end
    object BtnVazgec: TToolButton
      Left = 79
      Top = 0
      Caption = 'Vazge'#231
      ImageIndex = 17
      OnClick = BtnVazgecClick
    end
  end
end
