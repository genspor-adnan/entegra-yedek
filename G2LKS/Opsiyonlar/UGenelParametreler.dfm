object GenelParametrelerForm: TGenelParametrelerForm
  Left = 0
  Top = 0
  Width = 650
  Height = 545
  TabOrder = 0
  DesignSize = (
    650
    545)
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 131
    Height = 13
    Caption = 'Referansla '#231'al'#305#351'an kurumlar'
  end
  object kurumListesiCheckListBox: TCheckListBox
    Left = 8
    Top = 24
    Width = 225
    Height = 512
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 240
    Top = 24
    Width = 217
    Height = 105
    Caption = 'Nakit Faturalar'
    TabOrder = 1
    object Label2: TLabel
      Left = 8
      Top = 16
      Width = 50
      Height = 13
      Caption = 'Kasa Kodu'
    end
    object Label3: TLabel
      Left = 8
      Top = 56
      Width = 102
      Height = 13
      Caption = 'Kasa Muhasebe Kodu'
      Enabled = False
    end
    object kasaKoduEdit: TEdit
      Left = 8
      Top = 32
      Width = 161
      Height = 21
      TabOrder = 0
    end
    object kasaKoduGetirButton: TButton
      Left = 172
      Top = 31
      Width = 25
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = kasaKoduGetirButtonClick
    end
    object kasaMuhasebeKoduEdit: TEdit
      Left = 8
      Top = 72
      Width = 161
      Height = 21
      Color = clSilver
      Enabled = False
      TabOrder = 2
    end
  end
  object faturalamaModeliRadioGroup: TRadioGroup
    Left = 240
    Top = 136
    Width = 217
    Height = 65
    Caption = 'Faturalama Modeli'
    ItemIndex = 1
    Items.Strings = (
      'Hastaya'
      'Geli'#351'lerdeki Kurum'#39'a')
    TabOrder = 2
  end
  object hastaIcinKodOlusturGroupBox: TJvGroupBox
    Left = 240
    Top = 208
    Width = 217
    Height = 177
    Caption = 'Hasta i'#231'in yeni kay'#305't olu'#351'tur'
    TabOrder = 3
    Checkable = True
    PropagateEnable = True
    object Label4: TLabel
      Left = 8
      Top = 16
      Width = 83
      Height = 13
      Caption = 'Dosya No '#214'nEki :'
    end
    object dosyaNoOnEkiEdit: TEdit
      Left = 8
      Top = 32
      Width = 185
      Height = 21
      TabOrder = 0
    end
    object GroupBox3: TJvGroupBox
      Left = 8
      Top = 56
      Width = 201
      Height = 113
      Caption = 'Hesap Plan'#305
      TabOrder = 1
      object Label5: TLabel
        Left = 8
        Top = 15
        Width = 85
        Height = 13
        Caption = 'Hesap Plan'#305' '#214'nEki'
      end
      object Label6: TLabel
        Left = 8
        Top = 56
        Width = 55
        Height = 13
        Caption = 'S'#305'f'#305'r Say'#305's'#305' :'
      end
      object hesapPlaniOnEkiEdit: TEdit
        Left = 8
        Top = 29
        Width = 177
        Height = 21
        TabOrder = 0
      end
      object hastaAdiIlkHarfKullanCheckBox: TCheckBox
        Left = 8
        Top = 80
        Width = 177
        Height = 17
        Caption = 'Hasta Ad'#305'n'#305'n '#304'lk Harfini Kullan'
        TabOrder = 2
      end
      object OnEkSonrasiSifirSayisiSpinEdit: TSpinEdit
        Left = 66
        Top = 53
        Width = 39
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 4
      end
    end
  end
  object faturaKalemleriniDonusturmeGroupBox: TJvGroupBox
    Left = 240
    Top = 392
    Width = 217
    Height = 97
    Caption = 'Fatura kalemlerini d'#246'n'#252#351't'#252'rme'
    TabOrder = 4
    Checkable = True
    PropagateEnable = True
    object Label7: TLabel
      Left = 8
      Top = 24
      Width = 173
      Height = 13
      Caption = 'D'#246'n'#252#351't'#252'rme i'#231'in sabit kodlar kullan'#305'l'#305'r'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label8: TLabel
      Left = 8
      Top = 48
      Width = 18
      Height = 13
      Caption = 'Kod'
      Enabled = False
    end
    object Label9: TLabel
      Left = 8
      Top = 72
      Width = 42
      Height = 13
      Caption = 'Muh.Kod'
      Enabled = False
    end
    object faturaKalemKodEdit: TEdit
      Left = 64
      Top = 44
      Width = 137
      Height = 21
      Enabled = False
      TabOrder = 1
    end
    object faturaKalemMuhKodEdit: TEdit
      Left = 64
      Top = 68
      Width = 137
      Height = 21
      Enabled = False
      TabOrder = 2
    end
  end
  object checkStokOnayliAktarim: TCheckBox
    Left = 241
    Top = 492
    Width = 216
    Height = 17
    Caption = 'Stok Faturalar'#305'n'#305' Onaylan'#305'nca Aktar'
    TabOrder = 5
  end
end
