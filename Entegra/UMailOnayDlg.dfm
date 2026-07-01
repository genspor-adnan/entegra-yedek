object MailOnayDlg: TMailOnayDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'e-Ar'#351'iv Mail Onay'#305
  ClientHeight = 220
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 13
  object PanelUst: TPanel
    Left = 0
    Top = 0
    Width = 560
    Height = 175
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LblBaslik: TcxLabel
      Left = 16
      Top = 16
      Caption = 'Al'#305'c'#305' E-Posta Adresi'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -16
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
    end
    object LblCariAdi: TcxLabel
      Left = 16
      Top = 50
      Caption = '-'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clNavy
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
    end
    object LblMailAciklama: TcxLabel
      Left = 16
      Top = 80
      Caption = 'Mevcut mail adres(ler)i:'
    end
    object EditMail: TcxTextEdit
      Left = 16
      Top = 130
      TabOrder = 0
      Width = 528
    end
    object cxLabel1: TcxLabel
      Left = 16
      Top = 99
      Caption = ' (birden fazla i'#231'in virg'#252'lle)'
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 175
    Width = 560
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BtnOnayla: TcxButton
      Left = 360
      Top = 8
      Width = 90
      Height = 30
      Caption = 'Onayla'
      Default = True
      TabOrder = 0
      OnClick = BtnOnaylaClick
    end
    object BtnIptal: TcxButton
      Left = 456
      Top = 8
      Width = 90
      Height = 30
      Cancel = True
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 1
      OnClick = BtnIptalClick
    end
  end
end
