object ServisHareketDlg: TServisHareketDlg
  Left = 0
  Top = 0
  Caption = 'Servis Hareket Ekleme Ekran'#305
  ClientHeight = 630
  ClientWidth = 518
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 13
  object PanelMusteri: TPanel
    Left = 0
    Top = 0
    Width = 518
    Height = 54
    Align = alTop
    BevelOuter = bvNone
    Color = 16744448
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object LabelMusteri: TcxLabel
      Left = 115
      Top = -5
      AutoSize = False
      Caption = '---'
      Style.TextColor = clYellow
      Style.TextStyle = [fsBold]
      Properties.WordWrap = True
      Height = 53
      Width = 352
    end
    object LabelServisNo: TcxLabel
      Left = 41
      Top = -4
      Caption = '---'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clYellow
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Properties.WordWrap = True
      Width = 19
    end
    object cxLabel5: TcxLabel
      Left = 4
      Top = -3
      Caption = 'S.No'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clYellow
      Style.IsFontAssigned = True
      Properties.WordWrap = True
      Width = 31
    end
    object cxLabel6: TcxLabel
      Left = 4
      Top = 13
      Caption = 'S.Id'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clYellow
      Style.IsFontAssigned = True
      Properties.WordWrap = True
      Width = 23
    end
    object LabelSID: TcxLabel
      Left = 41
      Top = 13
      Caption = '---'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clYellow
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Properties.WordWrap = True
      Width = 16
    end
    object cxLabel8: TcxLabel
      Left = 4
      Top = 28
      Caption = 'H.Id'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clYellow
      Style.IsFontAssigned = True
      Properties.WordWrap = True
      Width = 25
    end
    object LabelHID: TcxLabel
      Left = 41
      Top = 27
      Caption = '---'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clYellow
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Properties.WordWrap = True
      Width = 16
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 54
    Width = 518
    Height = 521
    Align = alClient
    Color = 388542
    ParentBackground = False
    ParentColor = False
    TabOrder = 1
    TabStop = False
    Properties.ActivePage = TabSheetServisEkle
    Properties.CustomButtons.Buttons = <>
    Properties.Style = 10
    Properties.TabSlants.Kind = skCutCorner
    OnChange = cxPageControl1Change
    ClientRectBottom = 521
    ClientRectRight = 518
    ClientRectTop = 19
    object TabSheetServisEkle: TcxTabSheet
      Caption = 'Servis Ekleme'
      Color = 15329769
      ImageIndex = 2
      ParentColor = False
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PanelServis: TPanel
        Left = 0
        Top = 0
        Width = 518
        Height = 265
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvNone
        Color = 15329769
        Ctl3D = False
        ParentBackground = False
        ParentCtl3D = False
        TabOrder = 0
        object PanelProje: TPanel
          Left = 0
          Top = 0
          Width = 514
          Height = 44
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvNone
          Color = 15329769
          ParentBackground = False
          TabOrder = 0
          object cxLabel25: TcxLabel
            Left = 21
            Top = 12
            Caption = 'Proje'
            Properties.WordWrap = True
            Transparent = True
            Width = 29
          end
          object EditProje: TcxButtonEdit
            Left = 110
            Top = 4
            ParentFont = False
            ParentShowHint = False
            Properties.Buttons = <
              item
                Caption = '++'
                Default = True
                Kind = bkText
              end
              item
                Caption = '+'
                Kind = bkText
              end
              item
                Caption = '-'
                Kind = bkText
              end>
            Properties.ReadOnly = False
            Properties.OnButtonClick = EditProjePropertiesButtonClick
            ShowHint = True
            Style.Color = 15329769
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -17
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 339
          end
        end
        object Panel3: TPanel
          Left = 0
          Top = 44
          Width = 514
          Height = 42
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvNone
          Color = 15329769
          ParentBackground = False
          TabOrder = 1
          object cxLabel3: TcxLabel
            Left = 20
            Top = 13
            Caption = 'T'#252'r'#252
            Properties.WordWrap = True
            Width = 26
          end
          object CBServisTuru: TcxImageComboBox
            Left = 110
            Top = 7
            RepositoryItem = Tablo.repServisTuru
            ParentColor = True
            ParentFont = False
            Properties.Items = <>
            Properties.OnEditValueChanged = CBServisTuruPropertiesEditValueChanged
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -15
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.TextStyle = [fsBold]
            Style.TransparentBorder = True
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 165
          end
          object cxLabel1: TcxLabel
            Left = 280
            Top = 11
            Caption = 'Ba'#351'vuru '
            Properties.WordWrap = True
            Width = 46
          end
          object ComboBasvuru: TcxImageComboBox
            Left = 324
            Top = 7
            RepositoryItem = Tablo.repServisKabulSekli
            ParentColor = True
            ParentFont = False
            Properties.Items = <>
            Properties.OnEditValueChanged = CBServisTuruPropertiesEditValueChanged
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -15
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.TextStyle = [fsBold]
            Style.TransparentBorder = True
            Style.IsFontAssigned = True
            TabOrder = 3
            Width = 126
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 86
          Width = 514
          Height = 42
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvNone
          Color = 15329769
          ParentBackground = False
          TabOrder = 2
          object CheckBoxDISSERVIS: TcxCheckBox
            Left = 275
            Top = 8
            Caption = 'D'#305#351' Servis'
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            Style.Color = clSilver
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clNavy
            Style.Font.Height = -13
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            TabOrder = 0
            Transparent = True
          end
          object CheckBoxACIL: TcxCheckBox
            Left = 362
            Top = 8
            Caption = 'AC'#304'L'
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clRed
            Style.Font.Height = -13
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = [fsBold]
            Style.LookAndFeel.Kind = lfOffice11
            Style.LookAndFeel.NativeStyle = True
            Style.TransparentBorder = True
            Style.IsFontAssigned = True
            StyleDisabled.LookAndFeel.Kind = lfOffice11
            StyleDisabled.LookAndFeel.NativeStyle = True
            StyleDisabled.TextColor = clRed
            StyleFocused.LookAndFeel.Kind = lfOffice11
            StyleFocused.LookAndFeel.NativeStyle = True
            StyleHot.LookAndFeel.Kind = lfOffice11
            StyleHot.LookAndFeel.NativeStyle = True
            StyleReadOnly.LookAndFeel.Kind = lfOffice11
            StyleReadOnly.LookAndFeel.NativeStyle = True
            TabOrder = 1
            Transparent = True
          end
          object CheckBoxOnemli: TcxCheckBox
            Left = 422
            Top = 8
            Caption = #214'nemli'
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            Style.Color = clSilver
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clRed
            Style.Font.Height = -13
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = [fsBold]
            Style.LookAndFeel.NativeStyle = True
            Style.IsFontAssigned = True
            StyleDisabled.LookAndFeel.NativeStyle = True
            StyleFocused.LookAndFeel.NativeStyle = True
            StyleHot.LookAndFeel.NativeStyle = True
            StyleReadOnly.LookAndFeel.NativeStyle = True
            TabOrder = 2
            Transparent = True
          end
          object cxLabel2: TcxLabel
            Left = 21
            Top = 12
            Caption = 'Tarih'
            Properties.WordWrap = True
            Width = 28
          end
          object DateTarih: TcxDateEdit
            Left = 110
            Top = 5
            TabStop = False
            ParentFont = False
            ParentShowHint = False
            Properties.ImmediateDropDownWhenActivated = True
            Properties.ImmediateDropDownWhenKeyPressed = True
            Properties.InputKind = ikStandard
            Properties.Kind = ckDateTime
            Properties.ReadOnly = False
            ShowHint = True
            Style.Color = 15329769
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -15
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.Shadow = False
            Style.IsFontAssigned = True
            TabOrder = 4
            Width = 164
          end
        end
        object Panel11: TPanel
          Left = 0
          Top = 128
          Width = 514
          Height = 44
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvNone
          Color = 15329769
          ParentBackground = False
          TabOrder = 3
          object cxLabel22: TcxLabel
            Left = 20
            Top = 15
            Caption = 'Ekipman/'#220'r'#252'n'
            Properties.WordWrap = True
            Width = 70
          end
          object EditEkipman: TcxButtonEdit
            Left = 110
            Top = 6
            ParentFont = False
            ParentShowHint = False
            Properties.Buttons = <
              item
                Caption = '++'
                Default = True
                Kind = bkText
              end
              item
                Caption = '+'
                Hint = 'Temizle'
                Kind = bkText
              end
              item
                Caption = '-'
                Kind = bkText
              end>
            Properties.ReadOnly = False
            Properties.OnButtonClick = EditUrunPropertiesButtonClick
            ShowHint = True
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -17
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.Shadow = False
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 339
          end
        end
        object Panel12: TPanel
          Left = 0
          Top = 172
          Width = 514
          Height = 44
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvNone
          Color = 15329769
          ParentBackground = False
          TabOrder = 4
          object cxLabel23: TcxLabel
            Left = 20
            Top = 15
            Caption = 'Konu'
            Properties.WordWrap = True
            Width = 28
          end
          object EditKonu: TcxButtonEdit
            Left = 111
            Top = 5
            ParentFont = False
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = False
            Properties.OnButtonClick = EditKonuPropertiesButtonClick
            ShowHint = True
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -17
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.Shadow = False
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 339
          end
        end
        object Panel10: TPanel
          Left = 0
          Top = 216
          Width = 514
          Height = 44
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvNone
          Color = 15329769
          ParentBackground = False
          TabOrder = 5
          object cxLabel21: TcxLabel
            Left = 20
            Top = 13
            Caption = 'Bildirim Yapan'
            Properties.WordWrap = True
            Width = 69
          end
          object EditIlgili: TcxButtonEdit
            Left = 110
            Top = 5
            ParentFont = False
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end
              item
                Caption = '-'
                Hint = 'Temizle'
                Kind = bkText
              end>
            Properties.ReadOnly = False
            Properties.OnButtonClick = EditIlgiliPropertiesButtonClick
            ShowHint = True
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -17
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.Shadow = False
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 339
          end
        end
      end
      object cxPageControl2: TcxPageControl
        Left = 0
        Top = 265
        Width = 518
        Height = 237
        Align = alClient
        Color = 388542
        ParentBackground = False
        ParentColor = False
        TabOrder = 1
        Properties.ActivePage = cxTabSheet2
        Properties.CustomButtons.Buttons = <>
        Properties.Style = 10
        ClientRectBottom = 237
        ClientRectRight = 518
        ClientRectTop = 19
        object cxTabSheet2: TcxTabSheet
          Caption = 'Hareket Ekleme'
          Color = 388542
          ImageIndex = 0
          ParentColor = False
          object Panel13: TPanel
            Left = 0
            Top = 0
            Width = 518
            Height = 73
            Align = alTop
            BevelKind = bkSoft
            BevelOuter = bvNone
            Color = 388542
            ParentBackground = False
            TabOrder = 0
            object cxLabel24: TcxLabel
              Left = 20
              Top = 9
              Caption = 'Durum'
              Properties.WordWrap = True
              Width = 35
            end
            object ComboDurum: TcxImageComboBox
              Left = 110
              Top = 1
              ParentFont = False
              Properties.Items = <>
              Style.Color = clWindow
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -15
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.TextStyle = [fsBold]
              Style.TransparentBorder = True
              Style.IsFontAssigned = True
              TabOrder = 1
              Width = 339
            end
            object cxLabel28: TcxLabel
              Left = 21
              Top = 42
              Caption = 'A'#231#305'klama'
              Transparent = True
            end
            object EditAciklama: TcxButtonEdit
              Left = 110
              Top = 34
              ParentFont = False
              ParentShowHint = False
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.ReadOnly = False
              Properties.OnButtonClick = EditAciklamaPropertiesButtonClick
              ShowHint = True
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -17
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.Shadow = False
              Style.IsFontAssigned = True
              TabOrder = 3
              Width = 339
            end
          end
          object Panel15: TPanel
            Left = 0
            Top = 73
            Width = 518
            Height = 43
            Align = alTop
            BevelKind = bkSoft
            BevelOuter = bvNone
            Color = 388542
            ParentBackground = False
            TabOrder = 1
            object CheckBasla: TcxCheckBox
              Left = 20
              Top = 10
              Caption = 'Ba'#351'lama'
              ParentBackground = False
              ParentColor = False
              ParentFont = False
              Properties.ReadOnly = False
              Style.Color = clSilver
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Tahoma'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
              TabOrder = 0
              Transparent = True
              OnClick = CheckBaslaClick
            end
            object PanelBaslaSag: TPanel
              Left = 110
              Top = 0
              Width = 635
              Height = 40
              Align = alCustom
              BevelOuter = bvNone
              Color = 388542
              ParentBackground = False
              TabOrder = 1
              Visible = False
              object ComboSureDak: TcxComboBox
                Left = 353
                Top = 5
                ParentFont = False
                Properties.DropDownRows = 24
                Properties.Items.Strings = (
                  '00'
                  '05'
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
                Properties.OnChange = ComboSureGunPropertiesChange
                Style.Color = clWindow
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -17
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 0
                Text = '00'
                Width = 45
              end
              object ComboSureSaat: TcxComboBox
                Left = 307
                Top = 5
                ParentFont = False
                Properties.DropDownRows = 24
                Properties.Items.Strings = (
                  '00'
                  '01'
                  '02'
                  '03'
                  '04'
                  '05'
                  '06'
                  '07'
                  '08'
                  '09'
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
                Properties.OnChange = ComboSureGunPropertiesChange
                Style.Color = clWindow
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -17
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 1
                Text = '00'
                Width = 45
              end
              object cxLabel4: TcxLabel
                Left = 230
                Top = 9
                Caption = 'S'#252're'
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clNavy
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object DateBaslaDak: TcxComboBox
                Left = 170
                Top = 4
                ParentFont = False
                Properties.DropDownRows = 24
                Properties.Items.Strings = (
                  '00'
                  '05'
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
                Style.Color = clWindow
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -17
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 3
                Text = '00'
                Width = 45
              end
              object DateBaslaSaat: TcxComboBox
                Left = 122
                Top = 4
                ParentFont = False
                Properties.DropDownRows = 24
                Properties.Items.Strings = (
                  '00'
                  '01'
                  '02'
                  '03'
                  '04'
                  '05'
                  '06'
                  '07'
                  '08'
                  '09'
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
                Style.Color = clWindow
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -17
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 4
                Text = '00'
                Width = 45
              end
              object DateBasla: TcxDateEdit
                Left = -2
                Top = 4
                TabStop = False
                ParentFont = False
                ParentShowHint = False
                Properties.DateButtons = [btnClear, btnNow, btnToday]
                Properties.ImmediateDropDownWhenActivated = True
                Properties.ImmediateDropDownWhenKeyPressed = True
                Properties.InputKind = ikMask
                Properties.ReadOnly = False
                Properties.SaveTime = False
                Properties.ShowTime = False
                ShowHint = True
                Style.Color = clWindow
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -17
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = [fsBold]
                Style.Shadow = False
                Style.IsFontAssigned = True
                TabOrder = 5
                Width = 118
              end
              object ComboSureGun: TcxComboBox
                Left = 261
                Top = 5
                ParentFont = False
                Properties.DropDownRows = 24
                Properties.Items.Strings = (
                  '00'
                  '01'
                  '02'
                  '03'
                  '04'
                  '05'
                  '06'
                  '07'
                  '08'
                  '09'
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
                  '23'
                  '24'
                  '25'
                  '26'
                  '27'
                  '28'
                  '29'
                  '30')
                Properties.OnChange = ComboSureGunPropertiesChange
                Style.Color = clWindow
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -17
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 6
                Text = '00'
                Width = 45
              end
            end
          end
          object Panel16: TPanel
            Left = 0
            Top = 116
            Width = 518
            Height = 44
            Align = alTop
            BevelKind = bkSoft
            BevelOuter = bvNone
            Color = 388542
            ParentBackground = False
            TabOrder = 2
            object DateBitis: TcxDateEdit
              Left = 110
              Top = 4
              TabStop = False
              ParentFont = False
              ParentShowHint = False
              Properties.DateButtons = [btnClear, btnNow, btnToday]
              Properties.ImmediateDropDownWhenActivated = True
              Properties.ImmediateDropDownWhenKeyPressed = True
              Properties.InputKind = ikMask
              Properties.ReadOnly = False
              Properties.SaveTime = False
              Properties.ShowTime = False
              Properties.OnChange = DateBitisPropertiesChange
              ShowHint = True
              Style.Color = clWindow
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -17
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.Shadow = False
              Style.IsFontAssigned = True
              TabOrder = 0
              Visible = False
              Width = 118
            end
            object DateBitisDak: TcxComboBox
              Left = 279
              Top = 4
              ParentFont = False
              Properties.DropDownRows = 24
              Properties.Items.Strings = (
                '00'
                '05'
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
              Properties.OnChange = DateBitisPropertiesChange
              Style.Color = clWindow
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -17
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 1
              Text = '00'
              Visible = False
              Width = 45
            end
            object DateBitisSaat: TcxComboBox
              Left = 231
              Top = 4
              ParentFont = False
              Properties.DropDownRows = 24
              Properties.Items.Strings = (
                '00'
                '01'
                '02'
                '03'
                '04'
                '05'
                '06'
                '07'
                '08'
                '09'
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
              Properties.OnChange = DateBitisPropertiesChange
              Style.Color = clWindow
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -17
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 2
              Text = '00'
              Visible = False
              Width = 45
            end
            object CheckBitis: TcxCheckBox
              Left = 21
              Top = 6
              Caption = 'Biti'#351
              ParentBackground = False
              ParentColor = False
              ParentFont = False
              Properties.ReadOnly = False
              Style.Color = clSilver
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Tahoma'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
              TabOrder = 3
              Transparent = True
              OnClick = CheckBitisClick
            end
          end
          object Panel1: TPanel
            Left = 0
            Top = 160
            Width = 518
            Height = 44
            Align = alTop
            BevelKind = bkSoft
            BevelOuter = bvNone
            Color = 388542
            ParentBackground = False
            TabOrder = 3
            object EditPersonel: TcxButtonEdit
              Left = 110
              Top = 4
              TabStop = False
              ParentFont = False
              ParentShowHint = False
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Hint = 'Temizle'
                  Kind = bkText
                end>
              Properties.ReadOnly = False
              Properties.OnButtonClick = BeditPersonelPropertiesButtonClick
              ShowHint = True
              Style.Color = clWindow
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -17
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.Shadow = False
              Style.IsFontAssigned = True
              TabOrder = 0
              Width = 291
            end
            object LabelSorumlu: TcxLabel
              Left = 21
              Top = 10
              Caption = 'Sorumlu'
              Properties.WordWrap = True
              Transparent = True
              Width = 42
            end
            object CheckKapali: TcxCheckBox
              Left = 407
              Top = 10
              Caption = 'Servis Kapal'#305
              ParentBackground = False
              ParentColor = False
              ParentFont = False
              Properties.ReadOnly = False
              Properties.OnChange = CheckKapaliPropertiesChange
              Style.Color = clSilver
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clRed
              Style.Font.Height = -13
              Style.Font.Name = 'Tahoma'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
              TabOrder = 2
              Transparent = True
            end
          end
        end
      end
    end
    object TabSheetYorumMedya: TcxTabSheet
      Caption = 'Yorum/Medya'
      Color = 388542
      ImageIndex = 1
      ParentColor = False
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBarYorum: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 512
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 100
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
        object YorumEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yorum Ekle'
          ImageIndex = 4
          Style = tbsTextButton
          OnClick = YorumEkleTusClick
        end
        object YorumSil: TToolButton
          Left = 100
          Top = 0
          Caption = 'Yorum Sil'
          ImageIndex = 5
          Style = tbsTextButton
          OnClick = YorumSilClick
        end
        object YorumDuzenle: TToolButton
          Tag = 3
          Left = 200
          Top = 0
          Caption = 'Yorum D'#252'zenle'
          ImageIndex = 7
          Style = tbsTextButton
          OnClick = YorumDuzenleClick
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 461
        Width = 518
        Height = 41
        Align = alBottom
        TabOrder = 1
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 1
          Height = 39
          Width = 370
        end
        object BtnMesajGonder: TcxButton
          Left = 371
          Top = 1
          Width = 85
          Height = 39
          Align = alRight
          OptionsImage.ImageIndex = 39
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 0
          OnClick = BtnMesajGonderClick
        end
        object BtnDosyaGonder: TcxButton
          Left = 456
          Top = 1
          Width = 61
          Height = 39
          Align = alRight
          DropDownMenu = YorumAtacMenu
          Kind = cxbkDropDown
          OptionsImage.ImageIndex = 38
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 2
        end
      end
      object labelFileName: TcxLabel
        Left = 0
        Top = 441
        ParentCustomHint = False
        Align = alBottom
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        Style.Edges = [bLeft, bRight]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.Shadow = False
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taRightJustify
        Transparent = True
        Visible = False
        ExplicitTop = 440
        AnchorX = 518
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 27
        Width = 518
        Height = 414
        Align = alClient
        PopupMenu = PopupYorumlar
        TabOrder = 3
        ExplicitHeight = 385
        object GridYorumDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsYorum
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 2
          OptionsView.CardWidth = 900
          OptionsView.CategoryIndent = 1
          OptionsView.CategorySeparatorWidth = 1
          OptionsView.CellAutoHeight = True
          OptionsView.CellTextMaxLineCount = 5
          Styles.Content = Tablo.cxStyle6
          Styles.CardBorder = Tablo.cxStyle19
          object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 120
          end
          object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YAZAN'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
          end
          object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
            DataBinding.FieldName = 'ATAC'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repFileExtensionList
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 25
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
            DataBinding.FieldName = 'DOKUMANAD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 300
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YORUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxRichEditProperties'
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Styles.Content = Tablo.cxStyle12
            Styles.CategoryRow = Tablo.cxStyle4
          end
        end
        object GridYorumLevel1: TcxGridLevel
          GridView = GridYorumDBCardView1
        end
      end
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 575
    Width = 518
    Height = 55
    Align = alBottom
    BevelOuter = bvNone
    Color = 16744448
    ParentBackground = False
    TabOrder = 2
    TabStop = True
    object ButtonKaydet: TcxButton
      Left = 337
      Top = 6
      Width = 112
      Height = 38
      Caption = 'Kaydet'
      Colors.Default = clGreen
      Colors.Normal = clGreen
      Default = True
      LookAndFeel.Kind = lfFlat
      LookAndFeel.SkinName = 'LondonLiquidSky'
      OptionsImage.ImageIndex = 2
      OptionsImage.Images = Tablo.PNGImageList2
      OptionsImage.Spacing = 1
      PaintStyle = bpsCaption
      SpeedButtonOptions.Flat = True
      TabOrder = 0
      OnClick = ButtonKaydetClick
    end
    object ButtonKapat: TcxButton
      Left = 450
      Top = 6
      Width = 63
      Height = 38
      Caption = 'Kapat'
      Default = True
      LookAndFeel.Kind = lfFlat
      LookAndFeel.SkinName = 'LondonLiquidSky'
      ModalResult = 2
      OptionsImage.ImageIndex = 14
      OptionsImage.Images = Tablo.PNGImageList2
      OptionsImage.Spacing = 1
      PaintStyle = bpsCaption
      SpeedButtonOptions.Flat = True
      TabOrder = 1
      OnClick = ButtonKapatClick
    end
    object ButtonAtama: TcxButton
      Left = 225
      Top = 6
      Width = 112
      Height = 38
      Caption = 'Kaydet/Ata'
      Colors.Default = clGreen
      Colors.Normal = clGreen
      Default = True
      LookAndFeel.Kind = lfFlat
      LookAndFeel.SkinName = 'LondonLiquidSky'
      OptionsImage.ImageIndex = 2
      OptionsImage.Images = Tablo.PNGImageList2
      OptionsImage.Spacing = 1
      PaintStyle = bpsCaption
      SpeedButtonOptions.Flat = True
      TabOrder = 2
      OnClick = ButtonAtamaClick
    end
    object ButtonYeniHareket: TcxButton
      Left = 113
      Top = 6
      Width = 112
      Height = 38
      Caption = 'Kaydet/Yeni Hareket'
      Colors.Default = clGreen
      Colors.Normal = clGreen
      Default = True
      LookAndFeel.Kind = lfFlat
      LookAndFeel.SkinName = 'LondonLiquidSky'
      OptionsImage.ImageIndex = 2
      OptionsImage.Images = Tablo.PNGImageList2
      OptionsImage.Spacing = 1
      PaintStyle = bpsCaption
      SpeedButtonOptions.Flat = True
      TabOrder = 3
      OnClick = ButtonYeniHareketClick
    end
    object ButtonYeniServis: TcxButton
      Left = 1
      Top = 6
      Width = 112
      Height = 38
      Caption = 'Kaydet/Yeni Servis'
      Colors.Default = clGreen
      Colors.Normal = clGreen
      Default = True
      LookAndFeel.Kind = lfFlat
      LookAndFeel.SkinName = 'LondonLiquidSky'
      OptionsImage.ImageIndex = 2
      OptionsImage.Images = Tablo.PNGImageList2
      OptionsImage.Spacing = 1
      PaintStyle = bpsCaption
      SpeedButtonOptions.Flat = True
      TabOrder = 4
      OnClick = ButtonYeniServisClick
    end
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 445
    Top = 337
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 445
    Top = 228
  end
  object cxGridPopupYorumlar: TcxGridPopupMenu
    PopupMenus = <
      item
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 333
    Top = 216
  end
  object PopupYorumlar: TPopupMenu
    Left = 189
    Top = 16
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      OnClick = DkmanSil1Click
    end
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    appearance.Gradient1Start = 15722724
    appearance.Gradient1End = 14599608
    appearance.Gradient2Start = 14203563
    appearance.Gradient2End = 15722724
    appearance.MarginX = 4
    appearance.MarginY = 2
    appearance.SeparatorLeading = 6
    appearance.GutterWidth = 26
    appearance.SeparatorBackgroundColor = 15656925
    appearance.SeparatorLineColor = 12961221
    appearance.GutterColor = 15658729
    appearance.ItemBackgroundColor = 16448250
    appearance.ItemSelectedColor = 15128011
    appearance.FontColor = 7214336
    appearance.FontDisabledColor = 14599640
    style = msDefault
    Left = 144
    Top = 188
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object MainMenu1: TMainMenu
    Left = 280
    Top = 16
  end
  object TabHareket: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from vServisHareket S where ID=:PID')
    Left = 397
    Top = 33
  end
end
