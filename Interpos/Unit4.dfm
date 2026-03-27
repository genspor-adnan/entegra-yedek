object KampanyaForm: TKampanyaForm
  Left = 0
  Top = 0
  Caption = 'KampanyaForm'
  ClientHeight = 298
  ClientWidth = 744
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 144
    Top = 16
    Width = 48
    Height = 13
    Caption = #220'r'#252'n Ad'#305
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 0
    Top = 16
    Width = 40
    Height = 13
    Caption = 'Barkod'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 680
    Top = 14
    Width = 54
    Height = 13
    Caption = #304'ndirim (%)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 392
    Top = 14
    Width = 44
    Height = 13
    Caption = 'Ba'#351'lang'#305#231
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 496
    Top = 14
    Width = 19
    Height = 13
    Caption = 'Biti'#351
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object cxGridListele: TcxGrid
    Left = 0
    Top = 56
    Width = 385
    Height = 234
    Align = alCustom
    TabOrder = 0
    object cxGridListeleDBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DataSourceListele
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object cxGridListeleLevel1: TcxGridLevel
      GridView = cxGridListeleDBTableView1
    end
  end
  object cxListBoxPROMO: TcxListBox
    Left = 391
    Top = 54
    Width = 349
    Height = 236
    ItemHeight = 13
    Sorted = True
    TabOrder = 4
    OnClick = cxListBoxPROMOClick
  end
  object cxTextEdit1: TcxTextEdit
    Left = 144
    Top = 32
    Properties.OnChange = cxTextEdit1PropertiesChange
    TabOrder = 1
    Width = 241
  end
  object cxTextEdit2: TcxTextEdit
    Left = 0
    Top = 32
    Properties.OnChange = cxTextEdit2PropertiesChange
    TabOrder = 2
    Width = 121
  end
  object cxButton1: TcxButton
    Left = 584
    Top = 256
    Width = 114
    Height = 30
    Caption = 'Kampanya Aktar'
    TabOrder = 3
    OnClick = cxButton1Click
  end
  object cxTextEdit3: TcxTextEdit
    Left = 696
    Top = 30
    TabOrder = 5
    OnKeyPress = cxTextEdit3KeyPress
    Width = 44
  end
  object DateTimePickerBASLANGIC: TDateTimePicker
    Left = 392
    Top = 30
    Width = 98
    Height = 21
    CalColors.BackColor = clGradientInactiveCaption
    CalColors.TextColor = clRed
    Date = 41436.496740370370000000
    Time = 41436.496740370370000000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnChange = DateTimePickerBASLANGICChange
  end
  object DateTimePickerBITIS: TDateTimePicker
    Left = 496
    Top = 30
    Width = 98
    Height = 21
    Date = 41436.498125798610000000
    Time = 41436.498125798610000000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnChange = DateTimePickerBITISChange
  end
  object cxButton2: TcxButton
    Left = 360
    Top = 256
    Width = 57
    Height = 30
    Caption = '>>>'
    TabOrder = 8
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = cxButton2Click
  end
  object cxButton3: TcxButton
    Left = 704
    Top = 256
    Width = 25
    Height = 30
    Caption = 'Sil'
    Enabled = False
    TabOrder = 9
    OnClick = cxButton3Click
  end
  object ADOQueryListele: TADOQuery
    Connection = AnaForm.ADOConnection1
    Parameters = <>
    Left = 176
    Top = 112
  end
  object DataSourceListele: TDataSource
    DataSet = ADOQueryListele
    Left = 256
    Top = 120
  end
  object cxShellBrowserDialog1: TcxShellBrowserDialog
    Left = 312
    Top = 136
  end
end
