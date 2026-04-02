object MailForm: TMailForm
  Left = 166
  Top = 144
  Caption = 'E-Posta Hesaplar'#305
  ClientHeight = 295
  ClientWidth = 694
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IFALSE: TImage
    Left = 320
    Top = 0
    Width = 13
    Height = 13
    AutoSize = True
    Picture.Data = {
      07544269746D61703E020000424D3E0200000000000036000000280000000D00
      00000D0000000100180000000000080200000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
      0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
      0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000}
    Visible = False
  end
  object ITRUE: TImage
    Left = 344
    Top = 0
    Width = 13
    Height = 13
    AutoSize = True
    Picture.Data = {
      07544269746D61703E020000424D3E0200000000000036000000280000000D00
      00000D0000000100180000000000080200000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000
      FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
      0000000000000000FFFFFFFFFFFF000000000000000000FFFFFFFFFFFFFFFFFF
      FFFFFF00000000000000000000000000FFFFFF00000000000000000000000000
      0000FFFFFFFFFFFFFFFFFF00000000000000000000000000FFFFFF0000000000
      00FFFFFF000000000000000000FFFFFFFFFFFF00000000000000000000000000
      FFFFFF000000FFFFFFFFFFFFFFFFFF000000000000000000FFFFFF0000000000
      0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
      FFFFFF00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFF000000FFFFFF00000000000000000000000000FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000}
    Visible = False
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 40
    Width = 689
    Height = 257
    Caption = 'E-POSTA HESAPLARI'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object DBGrid1: TDBGrid
      Left = 8
      Top = 16
      Width = 673
      Height = 233
      DataSource = Tablo.DtsMail
      PopupMenu = PopupMenu1
      TabOrder = 0
      TitleFont.Charset = TURKISH_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = [fsBold]
      OnCellClick = DBGrid1CellClick
      OnDrawColumnCell = DBGrid1DrawColumnCell
      OnDblClick = DBGrid1DblClick
      Columns = <
        item
          Expanded = False
          FieldName = 'UNVAN'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Alignment = taCenter
          Title.Caption = #220'NVANI'
          Width = 147
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MAILADRES'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Alignment = taCenter
          Title.Caption = 'E-POSTA ADRES'#304
          Width = 140
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'KULADI'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Title.Alignment = taCenter
          Title.Caption = 'KULLANICI ADI'
          Width = 124
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'SERVERADRES'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          PickList.Strings = (
            'HYFGH'
            'GFGHG')
          Title.Alignment = taCenter
          Title.Caption = 'E-POSTA SUNUCUSU'
          Width = 142
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'KIMLIKDOG'
          ReadOnly = True
          Title.Alignment = taCenter
          Title.Caption = 'K'#304'ML'#304'K DO'#286'.'
          Visible = True
        end>
    end
  end
  object MailNavigator: TDBNavigator
    Left = 8
    Top = 5
    Width = 206
    Height = 25
    DataSource = Tablo.DtsMail
    VisibleButtons = [nbInsert, nbDelete]
    TabOrder = 1
  end
  object PopupMenu1: TPopupMenu
    Left = 248
    Top = 8
    object MNParola: TMenuItem
      Caption = 'Parola Belirle'
      OnClick = MNParolaClick
    end
  end
end
