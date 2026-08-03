object OpenSQLServerForm: TOpenSQLServerForm
  Left = 342
  Top = 202
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Sunucu Ba'#287'lant'#305' Yap'#305'land'#305'rmas'#305
  ClientHeight = 384
  ClientWidth = 389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 341
    Width = 389
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object btnOk: TBitBtn
      Left = 272
      Top = 7
      Width = 54
      Height = 25
      Caption = 'Ba'#287'lan'
      Default = True
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TBitBtn
      Left = 331
      Top = 7
      Width = 54
      Height = 25
      Cancel = True
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object ComboSQL: TcxComboBox
      Left = 37
      Top = 9
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'MSSQL'
        'PostgreSQL')
      Properties.OnChange = ComboSQLPropertiesChange
      TabOrder = 2
      Width = 100
    end
    object cxLabel6: TcxLabel
      Left = 4
      Top = 12
      Caption = 'Se'#231
    end
    object BtnTest: TBitBtn
      Left = 143
      Top = 7
      Width = 62
      Height = 25
      Caption = 'Test'
      TabOrder = 4
      OnClick = btnTestClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 389
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 1
    object Label5: TLabel
      Left = 8
      Top = 8
      Width = 179
      Height = 18
      Caption = 'Veritaban'#305' Ba'#287'lant'#305's'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 8
      Top = 32
      Width = 292
      Height = 13
      Caption = 'Veritaban'#305' sunucusuna ba'#287'lanman'#305'za yard'#305'mc'#305' olur.'
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 57
    Width = 389
    Height = 284
    Align = alClient
    TabOrder = 2
    Properties.ActivePage = TabSheetSQL
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 280
    ClientRectLeft = 4
    ClientRectRight = 385
    ClientRectTop = 24
    object TabSheetSQL: TcxTabSheet
      Caption = 'MSSQL'
      ImageIndex = 0
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Bevel1: TBevel
        Left = 27
        Top = 172
        Width = 346
        Height = 17
        Shape = bsTopLine
      end
      object EditTimeOut: TEdit
        Left = 160
        Top = 213
        Width = 63
        Height = 21
        TabOrder = 0
        Text = '15'
      end
      object TestConButton: TBitBtn
        Left = 327
        Top = 28
        Width = 47
        Height = 23
        Caption = 'S'#305'na'
        TabOrder = 1
        TabStop = False
        Visible = False
        OnClick = TestConButtonClick
      end
      object cboDatabases: TComboBox
        Left = 160
        Top = 189
        Width = 160
        Height = 21
        TabOrder = 2
        OnDropDown = cboDatabasesDropDown
      end
      object cboServers: TComboBox
        Left = 160
        Top = 30
        Width = 159
        Height = 21
        TabOrder = 3
        Text = 'localhost'
        OnChange = cboServersChange
        OnDropDown = cboServersDropDown
      end
      object ledPassword: TEdit
        Left = 160
        Top = 144
        Width = 142
        Height = 21
        PasswordChar = '*'
        TabOrder = 4
      end
      object ledUserName: TEdit
        Left = 160
        Top = 118
        Width = 142
        Height = 21
        TabOrder = 5
        Text = 'sa'
      end
      object yetkilendirmeComboBox: TComboBox
        Left = 160
        Top = 57
        Width = 213
        Height = 21
        Style = csDropDownList
        TabOrder = 6
        OnChange = yetkilendirmeComboBoxChange
        Items.Strings = (
          'Windows Yetkilendirmesi'
          'Sql Server Yetkilendirmesi')
      end
      object saglayiciComboBox: TComboBox
        Left = 161
        Top = 84
        Width = 213
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 7
        Text = 'OleDb Provider'
        Items.Strings = (
          'OleDb Provider'
          'Sql Native Client'
          'Sql Native Client 10')
      end
      object EditRemoteServer: TEdit
        Left = 160
        Top = 3
        Width = 160
        Height = 21
        TabOrder = 8
        Visible = False
      end
      object TestRemoteCon: TBitBtn
        Tag = 1
        Left = 327
        Top = 2
        Width = 47
        Height = 23
        Caption = 'S'#305'na'
        TabOrder = 9
        TabStop = False
        Visible = False
        OnClick = TestConButtonClick
      end
      object LabelRemoteServer: TcxLabel
        Left = 1
        Top = 7
        Caption = 'Sunucu Ad'#305'(Uzak):'
        Transparent = True
        Visible = False
      end
      object cxLabel2: TcxLabel
        Left = 1
        Top = 34
        Caption = 'Sunucu Ad'#305'(Yak'#305'n):'
        Transparent = True
      end
      object cxLabel4: TcxLabel
        Left = 1
        Top = 61
        Caption = 'Yetkilendirme:'
        Transparent = True
      end
      object cxLabel3: TcxLabel
        Left = 2
        Top = 88
        Caption = 'Sa'#287'lay'#305'c'#305':'
        Transparent = True
      end
      object cxLabel7: TcxLabel
        Left = 1
        Top = 193
        Caption = 'Veritaban'#305':'
        Transparent = True
      end
      object cxLabel8: TcxLabel
        Left = 1
        Top = 217
        Caption = 'Zaman A'#351#305'm'#305':'
        Transparent = True
      end
      object cxLabel1: TcxLabel
        Left = 1
        Top = 122
        Caption = 'Kullan'#305'c'#305' Ad'#305':'
        Transparent = True
      end
      object cxLabel5: TcxLabel
        Left = 1
        Top = 148
        Caption = #350'ifre'
        Transparent = True
      end
    end
    object TabSheetPG: TcxTabSheet
      Caption = 'PostrgreSQL'
      ImageIndex = 1
      object cxLabelPgSunucu: TcxLabel
        Left = 8
        Top = 20
        Caption = 'Sunucu:'
        Transparent = True
      end
      object cxLabelPgPort: TcxLabel
        Left = 8
        Top = 50
        Caption = 'Port:'
        Transparent = True
      end
      object cxLabelPgKullanici: TcxLabel
        Left = 8
        Top = 80
        Caption = 'Kullan'#305'c'#305':'
        Transparent = True
      end
      object cxLabelPgSifre: TcxLabel
        Left = 8
        Top = 110
        Caption = #350'ifre:'
        Transparent = True
      end
      object cxLabelPgVeritabani: TcxLabel
        Left = 8
        Top = 140
        Caption = 'Veritaban'#305':'
        Transparent = True
      end
      object EditPgSunucu: TEdit
        Left = 130
        Top = 17
        Width = 200
        Height = 21
        TabOrder = 0
        Text = 'localhost'
      end
      object EditPgPort: TEdit
        Left = 130
        Top = 47
        Width = 80
        Height = 21
        TabOrder = 1
        Text = '5432'
      end
      object EditPgKullanici: TEdit
        Left = 130
        Top = 77
        Width = 200
        Height = 21
        TabOrder = 2
        Text = 'postgres'
      end
      object EditPgSifre: TEdit
        Left = 130
        Top = 107
        Width = 200
        Height = 21
        PasswordChar = '*'
        TabOrder = 3
      end
      object EditPgVeritabani: TComboBox
        Left = 130
        Top = 137
        Width = 200
        Height = 21
        TabOrder = 4
        Text = 'gentegre'
        OnDropDown = EditPgVeritabaniDropDown
      end
    end
  end
  object ADOConnection1: TFDConnection
    LoginPrompt = False
    Left = 160
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 24
    Top = 8
  end
end
