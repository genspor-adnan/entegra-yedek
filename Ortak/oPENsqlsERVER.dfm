object OpenSQLServerForm: TOpenSQLServerForm
  Left = 342
  Top = 202
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Sunucu Ba'#287'lant'#305' Yap'#305'land'#305'rmas'#305
  ClientHeight = 352
  ClientWidth = 390
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
  object Bevel1: TBevel
    Left = 27
    Top = 232
    Width = 346
    Height = 17
    Shape = bsTopLine
  end
  object Panel2: TPanel
    Left = 0
    Top = 309
    Width = 390
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object btnOk: TBitBtn
      Left = 138
      Top = 11
      Width = 101
      Height = 25
      Caption = 'Ba'#287'lan'
      Default = True
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TBitBtn
      Left = 256
      Top = 10
      Width = 93
      Height = 25
      Cancel = True
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 0
      OnClick = btnCancelClick
    end
  end
  object EditTimeOut: TEdit
    Left = 160
    Top = 273
    Width = 63
    Height = 21
    TabOrder = 10
    Text = '15'
  end
  object TestConButton: TBitBtn
    Left = 327
    Top = 88
    Width = 47
    Height = 23
    Caption = 'S'#305'na'
    TabOrder = 4
    TabStop = False
    OnClick = TestConButtonClick
  end
  object cboDatabases: TComboBox
    Left = 160
    Top = 249
    Width = 160
    Height = 21
    TabOrder = 9
    OnDropDown = cboDatabasesDropDown
  end
  object cboServers: TComboBox
    Left = 160
    Top = 90
    Width = 159
    Height = 21
    TabOrder = 3
    Text = 'localhost'
    OnChange = cboServersChange
    OnDropDown = cboServersDropDown
  end
  object ledPassword: TEdit
    Left = 160
    Top = 204
    Width = 142
    Height = 21
    PasswordChar = '*'
    TabOrder = 8
  end
  object ledUserName: TEdit
    Left = 160
    Top = 178
    Width = 142
    Height = 21
    TabOrder = 7
    Text = 'sa'
  end
  object yetkilendirmeComboBox: TComboBox
    Left = 160
    Top = 117
    Width = 213
    Height = 21
    Style = csDropDownList
    TabOrder = 5
    OnChange = yetkilendirmeComboBoxChange
    Items.Strings = (
      'Windows Yetkilendirmesi'
      'Sql Server Yetkilendirmesi')
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 390
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 11
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
  object saglayiciComboBox: TComboBox
    Left = 161
    Top = 144
    Width = 213
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 6
    Text = 'OleDb Provider'
    Items.Strings = (
      'OleDb Provider'
      'Sql Native Client'
      'Sql Native Client 10')
  end
  object EditRemoteServer: TEdit
    Left = 160
    Top = 63
    Width = 160
    Height = 21
    TabOrder = 1
    Visible = False
  end
  object TestRemoteCon: TBitBtn
    Tag = 1
    Left = 327
    Top = 62
    Width = 47
    Height = 23
    Caption = 'S'#305'na'
    TabOrder = 2
    TabStop = False
    Visible = False
    OnClick = TestConButtonClick
  end
  object LabelRemoteServer: TcxLabel
    Left = 1
    Top = 67
    Caption = 'Sunucu Ad'#305'(Uzak):'
    Transparent = True
    Visible = False
  end
  object cxLabel2: TcxLabel
    Left = 1
    Top = 94
    Caption = 'Sunucu Ad'#305'(Yak'#305'n):'
    Transparent = True
  end
  object cxLabel4: TcxLabel
    Left = 1
    Top = 121
    Caption = 'Yetkilendirme:'
    Transparent = True
  end
  object cxLabel3: TcxLabel
    Left = 2
    Top = 148
    Caption = 'Sa'#287'lay'#305'c'#305':'
    Transparent = True
  end
  object cxLabel7: TcxLabel
    Left = 1
    Top = 253
    Caption = 'Veritaban'#305':'
    Transparent = True
  end
  object cxLabel8: TcxLabel
    Left = 1
    Top = 277
    Caption = 'Zaman A'#351#305'm'#305':'
    Transparent = True
  end
  object cxLabel1: TcxLabel
    Left = 1
    Top = 182
    Caption = 'Kullan'#305'c'#305' Ad'#305':'
    Transparent = True
  end
  object cxLabel5: TcxLabel
    Left = 1
    Top = 208
    Caption = #350'ifre'
    Transparent = True
  end
  object ADOConnection1: TFDConnection
    LoginPrompt = False
    Left = 344
    Top = 8
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 256
    Top = 8
  end
end
