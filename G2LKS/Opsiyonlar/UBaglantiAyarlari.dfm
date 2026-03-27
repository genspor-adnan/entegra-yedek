object BaglantiAyarlariForm: TBaglantiAyarlariForm
  Left = 0
  Top = 0
  Width = 545
  Height = 361
  TabOrder = 0
  object PageControlBaglantilar: TcxPageControl
    Left = 0
    Top = 43
    Width = 545
    Height = 318
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = TabSheetLogo
    Properties.CustomButtons.Buttons = <>
    LookAndFeel.Kind = lfUltraFlat
    ExplicitWidth = 534
    ExplicitHeight = 238
    ClientRectBottom = 314
    ClientRectLeft = 4
    ClientRectRight = 541
    ClientRectTop = 24
    object TabSheetLogo: TcxTabSheet
      Caption = 'Logo Ba'#287'lant'#305' Bilgileri'
      ImageIndex = 0
      ExplicitWidth = 526
      ExplicitHeight = 210
      object cxGroupBox1: TcxGroupBox
        Left = 16
        Top = 16
        Caption = 'SQL Ba'#287'lant'#305' Bilgileri'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        TabOrder = 0
        Transparent = True
        Height = 149
        Width = 249
        object cxLabel1: TcxLabel
          Left = 3
          Top = 24
          Caption = 'Server'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel2: TcxLabel
          Left = 3
          Top = 48
          Caption = 'Kullan'#305'c'#305
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel3: TcxLabel
          Left = 3
          Top = 70
          Caption = #350'ifre'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel4: TcxLabel
          Left = 3
          Top = 93
          Caption = 'Veri Taban'#305
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object EditServer: TcxTextEdit
          Left = 107
          Top = 22
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 4
          Width = 135
        end
        object EditKullanici: TcxTextEdit
          Left = 107
          Top = 46
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 5
          Width = 135
        end
        object EditSifre: TcxTextEdit
          Left = 107
          Top = 69
          ParentFont = False
          Properties.EchoMode = eemPassword
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 6
          Width = 135
        end
        object EditVariTabani: TcxTextEdit
          Left = 107
          Top = 91
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 7
          Width = 135
        end
        object BaglantiSina: TcxButton
          Left = 182
          Top = 117
          Width = 57
          Height = 23
          Caption = 'S'#305'na'
          TabOrder = 8
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = BaglantiSinaClick
        end
      end
      object cxGroupBox2: TcxGroupBox
        Left = 288
        Top = 16
        Caption = 'Firma Bilgileri'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        TabOrder = 1
        Transparent = True
        Height = 149
        Width = 185
        object cxLabel5: TcxLabel
          Left = 3
          Top = 24
          Caption = 'Logo Firma No'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object cxLabel6: TcxLabel
          Left = 3
          Top = 48
          Caption = 'D'#246'nem No'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object BEFirmaNo: TcxButtonEdit
          Tag = 1
          Left = 84
          Top = 21
          ParentFont = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = BEDonemNOPropertiesButtonClick
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 2
          Width = 84
        end
        object BEDonemNO: TcxButtonEdit
          Tag = 2
          Left = 84
          Top = 46
          ParentFont = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = BEDonemNOPropertiesButtonClick
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 3
          Width = 84
        end
      end
    end
    object TabSheetOrka: TcxTabSheet
      Caption = 'Orka Ba'#287'lant'#305' Bilgileri'
      ImageIndex = 1
      ExplicitLeft = 5
      ExplicitTop = 25
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 545
    Height = 43
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 534
    object TcxLabel
      Left = 23
      Top = 16
      Caption = 'Muhasebe Program'#305
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object ComboMuhasebeProg: TcxImageComboBox
      Left = 127
      Top = 16
      EditValue = 0
      Properties.ImmediateUpdateText = True
      Properties.Items = <
        item
          Description = 'LOGO'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'ORKA'
          Value = 2
        end>
      Properties.MultiLineText = True
      Properties.OnCloseUp = ComboMuhasebeProgPropertiesCloseUp
      TabOrder = 1
      Width = 135
    end
  end
  object browseForFolder: TBrowseForFolder
    StatusText = 'Plase select folder'
    FolderName = 'C:\'
    Flags = []
    Root = bl_STANDART
    Caption = 'Klas'#246'r se'#231'in'
    Left = 310
  end
end
