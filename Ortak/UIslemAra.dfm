object IslemAraDlg: TIslemAraDlg
  Left = 426
  Top = 161
  ActiveControl = Edit1
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Arama Ekran'#305
  ClientHeight = 368
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 449
    Height = 321
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 234
    Height = 13
    Caption = 'Arad'#305#287#305'n'#305'z i'#351'lemin ilk bir ka'#231' harfini yaz'#305'n.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 27
    Top = 35
    Width = 23
    Height = 13
    Caption = 'Kod'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 184
    Top = 34
    Width = 52
    Height = 13
    Caption = #304#351'lem Ad'#305
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 105
    Top = 35
    Width = 63
    Height = 13
    Caption = 'B'#252't'#231'eKodu'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 183
    Top = 47
    Width = 266
    Height = 21
    TabOrder = 0
    OnKeyUp = Edit2KeyUp
  end
  object DBGrid1: TDBGrid
    Left = 16
    Top = 79
    Width = 436
    Height = 242
    DataSource = DtsIslem
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = [fsBold]
    OnDblClick = DBGrid1DblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'KOD'
        Title.Caption = 'Kod'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clBlue
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = [fsBold]
        Width = 73
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'BUTCEKODU'
        Title.Caption = 'B'#252't'#231'eKodu'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clBlue
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = [fsBold]
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ISLEMADI'
        Title.Caption = #304#351'lem Ad'#305
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clBlue
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = [fsBold]
        Width = 247
        Visible = True
      end>
  end
  object Edit2: TEdit
    Left = 27
    Top = 47
    Width = 70
    Height = 21
    TabOrder = 2
    OnKeyUp = Edit2KeyUp
  end
  object Edit3: TEdit
    Left = 104
    Top = 47
    Width = 78
    Height = 21
    TabOrder = 3
    OnKeyUp = Edit2KeyUp
  end
  object OKBtn: TBitBtn
    Left = 381
    Top = 336
    Width = 75
    Height = 25
    Caption = 'Tamam'
    TabOrder = 4
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 301
    Top = 336
    Width = 75
    Height = 25
    Caption = #304'ptal'
    TabOrder = 5
    Kind = bkCancel
  end
  object DtsIslem: TDataSource
    DataSet = TabIslem
    Left = 152
    Top = 183
  end
  object TabIslem: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT * FROM ISLEMLER')
    Left = 120
    Top = 183
  end
end
