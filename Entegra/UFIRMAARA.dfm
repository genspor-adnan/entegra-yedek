object FIRMAARAFORM: TFIRMAARAFORM
  Left = 82
  Top = 110
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'ARAMA ÝÞLEMLERÝ'
  ClientHeight = 348
  ClientWidth = 695
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 348
    Align = alLeft
    Color = 8454143
    TabOrder = 0
    object Label1: TLabel
      Left = 58
      Top = 8
      Width = 92
      Height = 16
      Caption = 'FÝRMA ARAMA'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold, fsUnderline]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 4
      Top = 40
      Width = 59
      Height = 15
      Caption = 'Firma Adý :'
    end
    object Label3: TLabel
      Left = 4
      Top = 68
      Width = 40
      Height = 15
      Caption = 'Yetkili :'
    end
    object Label4: TLabel
      Left = 4
      Top = 96
      Width = 41
      Height = 15
      Caption = 'Ünvan :'
    end
    object Label5: TLabel
      Left = 4
      Top = 124
      Width = 40
      Height = 15
      Caption = 'Grubu :'
    end
    object Label6: TLabel
      Left = 4
      Top = 152
      Width = 69
      Height = 15
      Caption = 'Özel Taným :'
    end
    object Edit1: TEdit
      Left = 76
      Top = 38
      Width = 128
      Height = 23
      TabOrder = 0
    end
    object Edit2: TEdit
      Left = 76
      Top = 66
      Width = 128
      Height = 23
      TabOrder = 1
    end
    object BitBtn1: TBitBtn
      Left = 8
      Top = 188
      Width = 90
      Height = 25
      Caption = 'Arama'
      TabOrder = 2
      OnClick = BitBtn1Click
      Glyph.Data = {
        36020000424D3602000000000000360000002800000010000000100000000100
        10000000000000020000000000000000000000000000000000001F7CFF7FFF7F
        FF7FE07F1F7CFF7F1F7CFF7F1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7CFF7F
        FF7FFF7FE07FFF7FFF7F1F7CEF3DEF3D1F7C1F7C1F7C1F7C1F7C1F7C1F7CE07F
        FF7FFF7FFF7FFF7FEF3DEF3D0000EF3DEF3D1F7C1F7C1F7C1F7C1F7CFF7F1F7C
        FF7FFF7FFF7F1F7CFF7FFF7FEF3D0000EF3D1F7C1F7C1F7C1F7C1F7C1F7CFF7F
        FF7FFF7F1F7CFF7FFF7FE07F1F7C0000EF3DEF3D1F7C1F7C1F7C1F7CFF7F1F7C
        E07FEF3DFF7FFF7FFF7FFF7FEF3D0000EF3DEF3D1F7C1F7C1F7CFF7F1F7CFF7F
        1F7CEF3DFF7FE07FFF7F1F7C0000EF3D0000EF3D1F7C1F7C1F7C1F7C1F7C1F7C
        1F7C0000EF3D1F7CEF3D00001F7CEF3D0000EF3DEF3D1F7C1F7C1F7C1F7C1F7C
        1F7C1F7C000000000000FF7F1F7C0000EF3D0000EF3DEF3D1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C00000000FF7F1F7CEF3D0000EF3DEF3D1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7CEF3D0000EF3D1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7CEF3D00001F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7CEF3D1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C000000001F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C}
    end
    object BitBtn2: TBitBtn
      Left = 104
      Top = 188
      Width = 90
      Height = 25
      Caption = 'Eþleþtir'
      TabOrder = 3
      OnClick = BitBtn2Click
      Glyph.Data = {
        36020000424D3602000000000000360000002800000010000000100000000100
        10000000000000020000000000000000000000000000000000001F7CFF7FFF7F
        FF7FE07F1F7CFF7F1F7CFF7F1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7CFF7F
        FF7FFF7FE07FFF7FFF7F1F7CEF3DEF3D1F7C1F7C1F7C1F7C1F7C1F7C1F7CE07F
        FF7FFF7FFF7FFF7FEF3DEF3D0000EF3DEF3D1F7C1F7C1F7C1F7C1F7CFF7F1F7C
        FF7FFF7FFF7F1F7CFF7FFF7FEF3D0000EF3D1F7C1F7C1F7C1F7C1F7C1F7CFF7F
        FF7FFF7F1F7CFF7FFF7FE07F1F7C0000EF3DEF3D1F7C1F7C1F7C1F7CFF7F1F7C
        E07FEF3DFF7FFF7FFF7FFF7FEF3D0000EF3DEF3D1F7C1F7C1F7CFF7F1F7CFF7F
        1F7CEF3DFF7FE07FFF7F1F7C0000EF3D0000EF3D1F7C1F7C1F7C1F7C1F7C1F7C
        1F7C0000EF3D1F7CEF3D00001F7CEF3D0000EF3DEF3D1F7C1F7C1F7C1F7C1F7C
        1F7C1F7C000000000000FF7F1F7C0000EF3D0000EF3DEF3D1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C00000000FF7F1F7CEF3D0000EF3DEF3D1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7CEF3D0000EF3D1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7CEF3D00001F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7CEF3D1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C0000FF7F1F7C1F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C000000001F7C1F7C1F7C
        1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C1F7C}
    end
    object ComboBox1: TComboBox
      Left = 75
      Top = 95
      Width = 129
      Height = 23
      ItemHeight = 15
      TabOrder = 4
    end
    object ComboBox2: TComboBox
      Left = 75
      Top = 123
      Width = 129
      Height = 23
      ItemHeight = 15
      TabOrder = 5
    end
    object ComboBox3: TComboBox
      Left = 75
      Top = 151
      Width = 129
      Height = 23
      ItemHeight = 15
      TabOrder = 6
    end
  end
  object DBGrid1: TDBGrid
    Left = 209
    Top = 0
    Width = 486
    Height = 348
    Align = alClient
    DataSource = DM.DSFIRARA
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 1
    TitleFont.Charset = TURKISH_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Arial'
    TitleFont.Style = [fsBold]
    Columns = <
      item
        Expanded = False
        FieldName = 'FIRMAKODU'
        Title.Caption = 'Kodu'
        Width = 41
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FIRMAADI'
        Title.Caption = 'Firma Adý'
        Width = 187
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'YETKILIADISOY'
        Title.Caption = 'Adý Soyadý'
        Width = 206
        Visible = True
      end>
  end
end
