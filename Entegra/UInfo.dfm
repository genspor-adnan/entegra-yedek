object InfoDlg: TInfoDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'info'
  ClientHeight = 340
  ClientWidth = 679
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 13
    Width = 40
    Height = 15
    Caption = 'Ekleyen'
  end
  object Label2: TLabel
    Left = 232
    Top = 13
    Width = 69
    Height = 15
    Caption = 'Ekleme Tarihi'
  end
  object Label3: TLabel
    Left = 8
    Top = 41
    Width = 53
    Height = 15
    Caption = 'De'#287'i'#351'tiren'
  end
  object Label4: TLabel
    Left = 232
    Top = 41
    Width = 88
    Height = 15
    Caption = 'De'#287'i'#351'tirme Tarihi'
  end
  object LabelGecmis: TLabel
    Left = 8
    Top = 66
    Width = 73
    Height = 15
    Caption = 'Islem Gecmisi'
  end
  object EditEkleyen: TcxTextEdit
    Left = 72
    Top = 10
    Enabled = False
    Properties.ReadOnly = True
    TabOrder = 0
    Width = 154
  end
  object EditEklemeTrh: TcxDateEdit
    Left = 327
    Top = 10
    Enabled = False
    Properties.ReadOnly = True
    TabOrder = 1
    Width = 121
  end
  object EditDegistiren: TcxTextEdit
    Left = 72
    Top = 35
    Enabled = False
    Properties.ReadOnly = True
    TabOrder = 2
    Width = 154
  end
  object EditDegistirmeTrh: TcxDateEdit
    Left = 327
    Top = 35
    Enabled = False
    Properties.ReadOnly = True
    TabOrder = 3
    Width = 121
  end
  object cxButton1: TcxButton
    Left = 573
    Top = 32
    Width = 98
    Height = 29
    Align = alCustom
    Cancel = True
    Caption = 'Tamam'
    ModalResult = 1
    OptionsImage.Glyph.SourceDPI = 96
    OptionsImage.Glyph.Data = {
      3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
      462D38223F3E0D0A3C7376672076657273696F6E3D22312E31222069643D224C
      61796572312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
      323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
      772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
      307078222076696577426F783D2230203020333220333222207374796C653D22
      656E61626C652D6261636B67726F756E643A6E6577203020302033322033323B
      2220786D6C3A73706163653D227072657365727665223E262331333B26233130
      3B20203C7374796C6520747970653D22746578742F6373732220786D6C3A7370
      6163653D227072657365727665223E2E426C61636B262331333B262331303B20
      2020207B262331333B262331303B20202020202066696C6C3A23373237323732
      3B262331333B262331303B202020202020666F6E742D66616D696C793A266170
      6F733B64782D666F6E742D69636F6E732661706F733B3B262331333B26233130
      3B202020202020666F6E742D73697A653A333270783B262331333B262331303B
      202020207D262331333B262331303B20203C2F7374796C653E0D0A3C74657874
      20783D22302220793D2233322220636C6173733D22426C61636B223EEE9C913C
      2F746578743E0D0A3C2F7376673E0D0A}
    OptionsImage.ImageIndex = 0
    PaintStyle = bpsCaption
    TabOrder = 4
  end
  object LstTarihler: TListBox
    Left = 8
    Top = 84
    Width = 180
    Height = 242
    ItemHeight = 15
    TabOrder = 5
    OnClick = LstTarihlerClick
  end
  object LvDetay: TListView
    Left = 194
    Top = 84
    Width = 477
    Height = 242
    Columns = <>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 6
    ViewStyle = vsReport
  end
end
