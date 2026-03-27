object RehberPersonelHareket: TRehberPersonelHareket
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Personel Hareketi'
  ClientHeight = 298
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 13
  object cxLabel1: TcxLabel
    Left = 8
    Top = 24
    AutoSize = False
    Caption = 'Tarih:'
    Properties.Alignment.Horz = taRightJustify
    Transparent = True
    Height = 17
    Width = 70
    AnchorX = 78
  end
  object DateEditHareketTarih: TcxDBDateEdit
    Tag = 1
    Left = 84
    Top = 23
    DataBinding.DataField = 'TARIH'
    DataBinding.DataSource = DtsHareketler
    TabOrder = 1
    Width = 205
  end
  object cxLabel2: TcxLabel
    Left = 8
    Top = 50
    AutoSize = False
    Caption = 'T'#252'r:'
    Properties.Alignment.Horz = taRightJustify
    Transparent = True
    Height = 17
    Width = 70
    AnchorX = 78
  end
  object ComboHareketTur: TcxDBImageComboBox
    Tag = 1
    Left = 84
    Top = 50
    DataBinding.DataField = 'TUR'
    DataBinding.DataSource = DtsHareketler
    Properties.Alignment.Horz = taLeftJustify
    Properties.ImmediateDropDownWhenKeyPressed = False
    Properties.Items = <>
    Properties.OnEditValueChanged = ComboTurPropertiesEditValueChanged
    TabOrder = 3
    Width = 205
  end
  object lblPoziyon: TcxLabel
    Left = 8
    Top = 77
    AutoSize = False
    Caption = 'Pozisyon:'
    Properties.Alignment.Horz = taRightJustify
    Transparent = True
    Height = 17
    Width = 70
    AnchorX = 78
  end
  object CombohareketPozisyon: TcxDBImageComboBox
    Left = 84
    Top = 77
    DataBinding.DataField = 'POZISYON'
    DataBinding.DataSource = DtsHareketler
    Properties.Alignment.Horz = taLeftJustify
    Properties.Items = <>
    TabOrder = 5
    Width = 205
  end
  object Panel1: TPanel
    Left = 0
    Top = 257
    Width = 418
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 6
    object BitBtnKaydet: TBitBtn
      Left = 252
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Kaydet'
      Kind = bkOK
      NumGlyphs = 2
      Style = bsWin31
      TabOrder = 0
      OnClick = BitBtnKaydetClick
    end
    object BitBtnIptal: TBitBtn
      Left = 333
      Top = 8
      Width = 75
      Height = 25
      Caption = #304'ptal'
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333333333333333333333000033338833333333333333333F333333333333
        0000333911833333983333333388F333333F3333000033391118333911833333
        38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
        911118111118333338F3338F833338F3000033333911111111833333338F3338
        3333F8330000333333911111183333333338F333333F83330000333333311111
        8333333333338F3333383333000033333339111183333333333338F333833333
        00003333339111118333333333333833338F3333000033333911181118333333
        33338333338F333300003333911183911183333333383338F338F33300003333
        9118333911183333338F33838F338F33000033333913333391113333338FF833
        38F338F300003333333333333919333333388333338FFF830000333333333333
        3333333333333333333888330000333333333333333333333333333333333333
        0000}
      ModalResult = 2
      NumGlyphs = 2
      Style = bsWin31
      TabOrder = 1
    end
  end
  object MemoHareketAciklama: TcxDBMemo
    Left = 84
    Top = 158
    DataBinding.DataField = 'ACIKLAMA'
    DataBinding.DataSource = DtsHareketler
    TabOrder = 7
    Height = 94
    Width = 324
  end
  object cxLabel3: TcxLabel
    Left = 8
    Top = 158
    AutoSize = False
    Caption = 'A'#231#305'klama'
    Properties.Alignment.Horz = taRightJustify
    Transparent = True
    Height = 17
    Width = 70
    AnchorX = 78
  end
  object cxLabel5: TcxLabel
    Left = 291
    Top = 24
    AutoSize = False
    Caption = '*'
    Properties.Alignment.Horz = taLeftJustify
    Transparent = True
    Height = 17
    Width = 70
  end
  object cxLabel6: TcxLabel
    Left = 291
    Top = 50
    AutoSize = False
    Caption = '*'
    Properties.Alignment.Horz = taLeftJustify
    Transparent = True
    Height = 17
    Width = 70
  end
  object Memo1: TMemo
    Left = 3
    Top = 215
    Width = 407
    Height = 24
    Lines.Strings = (
      'SELECT * FROM PERS_HAREKET WHERE REHBERID=:REHBERID')
    TabOrder = 11
    Visible = False
  end
  object cxLabel8: TcxLabel
    Left = 291
    Top = 77
    AutoSize = False
    Caption = '*'
    Properties.Alignment.Horz = taLeftJustify
    Transparent = True
    Height = 17
    Width = 70
  end
  object cxLabel9: TcxLabel
    Left = 8
    Top = 132
    AutoSize = False
    Caption = 'Meslek:'
    Properties.Alignment.Horz = taRightJustify
    Transparent = True
    Height = 17
    Width = 70
    AnchorX = 78
  end
  object ButtonEditHareketMeslek: TcxButtonEdit
    Left = 84
    Top = 131
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
    TabOrder = 14
    Width = 205
  end
  object pnlSube: TPanel
    Left = 8
    Top = 104
    Width = 402
    Height = 22
    BevelOuter = bvNone
    Caption = 'pnlSube'
    TabOrder = 15
    object cxLabel4: TcxLabel
      Left = 0
      Top = 2
      AutoSize = False
      Caption = #350'ube:'
      Properties.Alignment.Horz = taRightJustify
      Transparent = True
      Height = 17
      Width = 70
      AnchorX = 70
    end
    object ComboHareketSube: TcxDBImageComboBox
      Tag = 1
      Left = 76
      Top = 0
      DataBinding.DataField = 'SUBEID'
      DataBinding.DataSource = DtsHareketler
      Properties.Alignment.Horz = taLeftJustify
      Properties.Items = <>
      TabOrder = 1
      Width = 205
    end
    object cxLabel7: TcxLabel
      Left = 283
      Top = 4
      AutoSize = False
      Caption = '*'
      Properties.Alignment.Horz = taLeftJustify
      Transparent = True
      Height = 17
      Width = 70
    end
  end
  object lblMeslekZorunluGosterge: TcxLabel
    Left = 291
    Top = 132
    AutoSize = False
    Caption = '*'
    Properties.Alignment.Horz = taLeftJustify
    Visible = False
    Height = 17
    Width = 70
  end
  object TabHareket: TFDQuery
    AfterOpen = TabHareketAfterOpen
    BeforeEdit = TabHareketBeforeEdit
    BeforePost = TabHareketBeforePost
    AfterPost = TabHareketAfterPost
    OnNewRecord = TabHareketNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT TOP 1 * FROM PERS_HAREKET WHERE REHBERID= :REHBERID AND I' +
        'D=:ID'
      '')
    Left = 376
    Top = 16
  end
  object DtsHareketler: TDataSource
    DataSet = TabHareket
    Left = 376
    Top = 64
  end
end
