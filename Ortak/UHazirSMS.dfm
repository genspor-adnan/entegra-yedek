object HazirSMSDlg: THazirSMSDlg
  Left = 314
  Top = 225
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Haz'#305'r SMS '#350'ablonu D'#252'zenleme Ekran'#305
  ClientHeight = 213
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 32
    Width = 241
    Height = 181
    Align = alLeft
    BorderStyle = bsNone
    Color = 16777183
    DataSource = DtsHazirSMS
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'BASLIK'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Title.Caption = 'Ba'#351'l'#305'k'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clMaroon
        Title.Font.Height = -12
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = [fsBold]
        Width = 160
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DURUM'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        PickList.Strings = (
          'Aktif'
          'Pasif')
        Title.Caption = 'Durum'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clMaroon
        Title.Font.Height = -12
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = [fsBold]
        Width = 46
        Visible = True
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 513
    Height = 32
    Align = alTop
    TabOrder = 1
    object Navigator: TDBNavigator
      Left = 14
      Top = 6
      Width = 80
      Height = 21
      DataSource = DtsHazirSMS
      VisibleButtons = [nbInsert, nbDelete]
      Flat = True
      ConfirmDelete = False
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 241
    Top = 32
    Width = 272
    Height = 181
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object mMESAJ: TDBMemo
      Left = 0
      Top = 17
      Width = 272
      Height = 134
      Align = alClient
      BevelInner = bvNone
      Color = 16777183
      DataField = 'MESAJ'
      DataSource = DtsHazirSMS
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      MaxLength = 160
      ParentFont = False
      TabOrder = 0
      OnChange = mMESAJChange
    end
    object Panel3: TPanel
      Left = 0
      Top = 151
      Width = 272
      Height = 30
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object lbKalKarakter: TLabel
        Left = 7
        Top = 7
        Width = 37
        Height = 18
        Alignment = taCenter
        AutoSize = False
        Color = clMedGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
      object BitBtn1: TBitBtn
        Left = 194
        Top = 3
        Width = 75
        Height = 25
        Caption = 'Kapat'
        TabOrder = 0
        OnClick = BitBtn1Click
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000E30E0000E30E00000001000000010000104A7B00184A
          840018528C0018529400185A9C00185AA5001863AD001863B500186BBD00186B
          C6001873CE001873D600187BDE00187BE7001884E7001884EF001884F700188C
          F700FF00FF00188CFF001894FF002194FF00299CFF00319CFF0039A5FF004AAD
          FF0052ADFF0063B5FF006BBDFF0084C6FF00ADDEFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00121F1F1F1F1F
          1F1F1F1F1F1F1F1F1F121F1A030404040505040403030201191F1F05080A0A0A
          0A0A0A0A0A090805001F1F060A0C0C0D0E111111110C0906021F1F090C0F1F1D
          111111111D1F0A08031F1F0A0E11131F1D11111D1F0E0B09041F1F0C11131111
          1F1D1D1F110E0B0A051F1F0E13111111111F1D110F0C0A0A061F1F0F13131111
          1D1F1F1D0E0B0A0A061F1F131515131D1F100F1F1D0A0A0A061F1F1318181D1F
          13130F0E1F1D0A0A061F1F151A191F151514110F0E1F0A0A061F1F181C1A1817
          16161513100F0C0A061F1F191D1C1A191817161514110F0A041F1F1E19171513
          1311110F0E0C0A081B1F121F1F1F1F1F1F1F1F1F1F1F1F1F1F12}
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 272
      Height = 17
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      object Label1: TLabel
        Left = 5
        Top = 2
        Width = 35
        Height = 14
        Caption = 'Mesaj'
      end
    end
  end
  object DtsHazirSMS: TDataSource
    DataSet = TabHazirSMS
    OnStateChange = DtsHazirSMSStateChange
    Left = 88
    Top = 152
  end
  object TabHazirSMS: TADOQuery
    Connection = Tablo.cnn
    BeforePost = TabHazirSMSBeforePost
    BeforeDelete = TabHazirSMSBeforeDelete
    AfterScroll = TabHazirSMSAfterScroll
    OnNewRecord = TabHazirSMSNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * FROM SMSPOSTAHAZMESAJ'
      'order BY BASLIK')
    Left = 128
    Top = 152
  end
end
