object MutabakatDlg: TMutabakatDlg
  Left = 0
  Top = 0
  Caption = 'Mutabakat Ekran'#305
  ClientHeight = 301
  ClientWidth = 547
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object UstPanel: TJvPanel
    Left = 0
    Top = 0
    Width = 547
    Height = 80
    FlatBorder = True
    Align = alTop
    BorderWidth = 1
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 576
    object LblSube: TcxLabel
      Left = 381
      Top = 19
      Caption = #350'ube'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ComboSube: TcxDBImageComboBox
      Left = 410
      Top = 18
      RepositoryItem = Tablo.RepSubeler
      DataBinding.DataField = 'SUBEID'
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <
        item
          Description = 'Yap'#305'lmad'#305
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'K'#305'smi'
          Value = 1
        end
        item
          Description = #304'ptal'
          Value = 6
        end
        item
          Description = 'Tamamland'#305
          Value = 9
        end>
      Properties.ReadOnly = True
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 0
      Width = 126
    end
    object LabelKod: TcxLabel
      Left = 2
      Top = 0
      Cursor = crHandPoint
      Caption = 'Kodu'
      DragCursor = crDefault
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelAd: TcxLabel
      Left = 2
      Top = 14
      Cursor = crHandPoint
      ParentCustomHint = False
      AutoSize = False
      Caption = 'Ad'#305
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.Shadow = False
      Style.IsFontAssigned = True
      Properties.LabelEffect = cxleCool
      Properties.LabelStyle = cxlsRaised
      Properties.WordWrap = True
      Transparent = True
      Height = 40
      Width = 319
    end
    object BaslikLabel: TcxLabel
      Left = 5
      Top = 59
      Caption = '---'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clGray
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelTarih: TcxLabel
      Left = 379
      Top = 53
      Caption = 'Tarih'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditTarih: TcxDBDateEdit
      Left = 410
      Top = 53
      DataBinding.DataField = 'PLANTARIHI'
      Properties.Kind = ckDateTime
      TabOrder = 7
      Visible = False
      Width = 127
    end
    object EditKayitTarih: TcxDBDateEdit
      Left = 410
      Top = 53
      DataBinding.DataField = 'ISLEMTARIHI'
      Properties.ImmediatePost = True
      Properties.Kind = ckDateTime
      TabOrder = 5
      Width = 126
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 80
    Width = 547
    Height = 180
    Align = alClient
    TabOrder = 1
    ExplicitTop = 112
    ExplicitWidth = 576
    ExplicitHeight = 289
    object Label15: TcxLabel
      Left = 3
      Top = 68
      Caption = 'A'#231#305'klama'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelTutar: TcxLabel
      Left = 4
      Top = 5
      Caption = 'Tutar'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditTutar: TcxDBCurrencyEdit
      Left = 86
      Top = 5
      Properties.DecimalPlaces = 4
      Properties.DisplayFormat = ',0.00 ;-,0.00 '
      Properties.EditFormat = ',0.0000 ;-,0.0000 '
      TabOrder = 2
      Width = 68
    end
    object ComboKur: TcxDBComboBox
      Left = 157
      Top = 5
      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
      DataBinding.DataField = 'KUR'
      Properties.DropDownListStyle = lsFixedList
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.ReadOnly = False
      TabOrder = 3
      Width = 52
    end
    object LabelKarsilik: TcxLabel
      Left = 5
      Top = 33
      Cursor = crHandPoint
      Caption = 'Kar'#351#305'l'#305#287#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clNavy
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.HotTrack = False
      Style.TextColor = clNavy
      Style.TextStyle = [fsUnderline]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditAciklama: TcxDBTextEdit
      Left = 86
      Top = 69
      DataBinding.DataField = 'ACIKLAMA'
      TabOrder = 4
      Width = 440
    end
    object PanelKarsilik: TPanel
      Left = 86
      Top = 32
      Width = 409
      Height = 27
      Align = alCustom
      BevelEdges = []
      BevelOuter = bvNone
      TabOrder = 6
      Visible = False
      object EditDovTutar: TcxDBCurrencyEdit
        Left = 0
        Top = 0
        DataBinding.DataField = 'DOVIZ_TUTARI'
        Properties.DecimalPlaces = 4
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        TabOrder = 0
        Width = 68
      end
      object ComboDovKur: TcxDBComboBox
        Left = 72
        Top = 0
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        DataBinding.DataField = 'DOVIZ_KURU'
        Properties.DropDownListStyle = lsFixedList
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.ReadOnly = False
        TabOrder = 1
        Width = 52
      end
      object EditKulKur: TcxCurrencyEdit
        Left = 129
        Top = 0
        TabStop = False
        RepositoryItem = Tablo.RepCurrencyDovizKuru
        EditValue = 1.000000000000000000
        ParentFont = False
        Properties.DecimalPlaces = 4
        Properties.DisplayFormat = ',0.0000;(,0.0000)'
        Properties.EditFormat = ',0.0000;(,0.0000)'
        Style.Color = clInactiveCaption
        TabOrder = 2
        Width = 49
      end
      object cxDBCheckBox1: TcxDBCheckBox
        Left = 187
        Top = 1
        Caption = 'Ekstrede bunu kullan'
        DataBinding.DataField = 'EKSTREDEKULLAN'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        Style.TransparentBorder = False
        TabOrder = 3
        Transparent = True
      end
    end
    object lblMasrafKod: TcxLabel
      Left = 335
      Top = 94
      Transparent = True
    end
    object lblBankaMasrafKod: TcxLabel
      Left = 277
      Top = 234
      Transparent = True
    end
    object SqlMemoMasrafKalemi: TMemo
      Left = 90
      Top = 105
      Width = 436
      Height = 30
      Lines.Strings = (
        '  select ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '
        #39','#39#39'),CHARINDEX'
        '('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39')'
        '    )-(CHARINDEX('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
        
          ' M.ID,  M.KOD, M.AD,PROJEID,MASRAFID,SUBEID=-1,DURUM=1, GELIRMI=' +
          '0, '
        'BARKOD=0'
        
          ' from PROJEBUTCE PB inner join MASRAFGELIR M on M.ID = PB.MASRAF' +
          'ID ')
      TabOrder = 9
      Visible = False
    end
  end
  object AltPanel: TPanel
    Left = 0
    Top = 260
    Width = 547
    Height = 41
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 400
    ExplicitWidth = 580
    DesignSize = (
      547
      41)
    object tamamButton: TButton
      Left = 374
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Tamam'
      Default = True
      TabOrder = 0
      ExplicitLeft = 407
    end
    object iptalButton: TButton
      Left = 455
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 488
    end
  end
  object TabKasa: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KASA'
      'WHERE ID = :PID ')
    Left = 51
    Top = 204
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    Left = 99
    Top = 225
  end
end

