object OlaylarDlg: TOlaylarDlg
  Left = 0
  Top = 0
  Caption = 'Olaylar Ekran'#305
  ClientHeight = 482
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 727
    Height = 358
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    Caption = 'Panel2'
    TabOrder = 0
    object GridTakvim: TcxGrid
      Left = 6
      Top = 6
      Width = 715
      Height = 346
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      object TakvimView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsOlaylar
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        object cxgrdbclmnTakvimViewTUR: TcxGridDBColumn
          Caption = 'T'#252'r'
          DataBinding.FieldName = 'TUR'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              Description = 'Bilgi'
              ImageIndex = 0
              Value = 1
            end
            item
              Description = 'Uyar'#305
              Value = 2
            end
            item
              Description = 'Hata'
              Value = 3
            end>
          Options.Editing = False
        end
        object cxgrdbclmnTakvimViewEKLEMETARIHI: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'EKLEMETARIHI'
          Options.Editing = False
          Width = 69
        end
        object cxgrdbclmnTakvimViewKAYNAK: TcxGridDBColumn
          Caption = 'Kaynak'
          DataBinding.FieldName = 'KAYNAK'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              Description = 'Sistem'
              ImageIndex = 0
              Value = 1
            end>
          Options.Editing = False
          Width = 56
        end
        object akvimViewColumnKATEGORI: TcxGridDBColumn
          Caption = 'Kategori'
          DataBinding.FieldName = 'KATEGORI'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              Description = 'Cari'
              ImageIndex = 0
              Value = 1
            end
            item
              Description = 'Kasa'
              Value = 2
            end
            item
              Description = 'Banka'
              Value = 3
            end
            item
              Description = 'Fatura'
              Value = 4
            end
            item
              Description = #199'eksenet'
              Value = 5
            end
            item
              Description = 'Stok'
              Value = 6
            end
            item
              Description = 'Teklif'
              Value = 7
            end>
        end
        object cxgrdbclmnTakvimViewMESAJ: TcxGridDBColumn
          Caption = 'Mesaj'
          DataBinding.FieldName = 'MESAJ'
          Options.Editing = False
          Width = 59
        end
        object cxgrdbclmnTakvimViewDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Aktif'
              ImageIndex = 0
              Value = 1
            end
            item
              Description = 'Giderildi'
              Value = 2
            end
            item
              Description = 'Bekleniyor'
              Value = '3'
            end>
          Width = 63
        end
        object cxgrdbclmnTakvimViewEKLEYEN: TcxGridDBColumn
          Caption = 'Ekleyen'
          DataBinding.FieldName = 'EKLEYEN'
          Options.Editing = False
          Width = 41
        end
        object cxgrdbclmnTakvimViewDEGISTIREN: TcxGridDBColumn
          Caption = 'De'#287'i'#351'tiren'
          DataBinding.FieldName = 'DEGISTIREN'
          Options.Editing = False
          Width = 52
        end
        object cxgrdbclmnTakvimViewDEGISTIRMETARIHI: TcxGridDBColumn
          Caption = 'De'#287'.Tarihi'
          DataBinding.FieldName = 'DEGISTIRMETARIHI'
          Options.Editing = False
          Width = 59
        end
      end
      object cxGridLevel4: TcxGridLevel
        GridView = TakvimView
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 727
    Height = 41
    Align = alTop
    TabOrder = 1
    object KapatTus: TSpeedButton
      Left = 553
      Top = 13
      Width = 60
      Height = 22
      Caption = 'Kapat'
      Flat = True
      Glyph.Data = {
        66010000424D6601000000000000760000002800000013000000140000000100
        040000000000F000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777777600007777777777777777777000007777777777777777777000007777
        777777777777777000007777777777777770F77C0000777770F7777777777776
        00007777000F7777770F777000007777000F777770F77770000077777000F777
        00F7777E0000777777000F700F7777700000777777700000F777777F00007777
        7777000F777777760000777777700000F77777700000777777000F70F7777770
        000077770000F77700F7777000007770000F7777700F7770000077700F777777
        7700F77400007777777777777777777600007777777777777777777000007777
        77777777777777700000}
      OnClick = KapatTusClick
    end
    object DBNavigator1: TDBNavigator
      Left = 421
      Top = 12
      Width = 126
      Height = 23
      DataSource = DtsOlaylar
      VisibleButtons = [nbInsert, nbDelete]
      Flat = True
      Ctl3D = False
      Hints.Strings = (
        #304'lk F5'
        #214'nceki F6'
        'Sonraki F7'
        'Son F8'
        'Yeni F9'
        'Sil F10'
        'De'#287'i'#351'tir'
        'Kaydet F11'
        #304'ptal F12')
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object cxCheckBox1: TcxCheckBox
      Left = 16
      Top = 14
      Caption = 'Aktif Olmayanlar'#305' da G'#246'ster'
      Properties.OnChange = cxCheckBox1PropertiesChange
      TabOrder = 1
      Width = 161
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 399
    Width = 727
    Height = 83
    Align = alBottom
    TabOrder = 2
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 64
      Height = 81
      Align = alLeft
      TabOrder = 0
      object Label1: TcxLabel
        Left = 5
        Top = 1
        Caption = 'Mesaj'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label2: TcxLabel
        Left = 5
        Top = 40
        Caption = 'Bilgi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object Panel5: TPanel
      Left = 65
      Top = 1
      Width = 661
      Height = 81
      Align = alClient
      TabOrder = 1
      object cxMemo1: TcxDBMemo
        Left = 1
        Top = 1
        Align = alClient
        DataBinding.DataField = 'MESAJ'
        DataBinding.DataSource = DtsMesaj
        TabOrder = 0
        Height = 39
        Width = 659
      end
      object cxDBMemo1: TcxDBMemo
        Left = 1
        Top = 40
        Align = alBottom
        DataBinding.DataField = 'BILGI'
        DataBinding.DataSource = DtsOlaylar
        TabOrder = 1
        Height = 40
        Width = 659
      end
    end
  end
  object DtsOlaylar: TDataSource
    DataSet = TabOlaylar
    OnStateChange = DtsOlaylarStateChange
    Left = 320
    Top = 1
  end
  object TabOlaylar: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabOlaylarAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select * from OLAYLAR where DURUM=1 order by ID desc')
    Left = 256
    Top = 9
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 576
    Top = 320
    object BaslatMenu: TMenuItem
      Caption = 'Vadesiz hesaptan vadeli hesaba aktar ve vadeyi ba'#351'lat'
      ImageIndex = 21
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object IslemBittiMenu: TMenuItem
      Caption = 
        'Vade sona erdi; i'#351'lemi durdur, toplam paray'#305' vadesiz hesaba akta' +
        'r'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object TemditliYenileMenu: TMenuItem
      Caption = #304#351'lem temditli; yenileyerek devam ettir'
      ImageIndex = 9
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object VadeBozMenu: TMenuItem
      Caption = 'Vadeyi bozdur; anaparay'#305' vadesiz hesaba aktar'
      ImageIndex = 21
    end
  end
  object TabMesaj: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from OLAYLARMESAJ where ID=:ID')
    Left = 320
    Top = 193
  end
  object DtsMesaj: TDataSource
    DataSet = TabMesaj
    Left = 352
    Top = 193
  end
end
