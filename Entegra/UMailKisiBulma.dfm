object MailKisiEkleme: TMailKisiEkleme
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mail Adresi Ekleme'
  ClientHeight = 527
  ClientWidth = 570
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 360
    Width = 570
    Height = 167
    Align = alBottom
    TabOrder = 0
    object KimeTus: TcxButton
      Left = 28
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Kime ->'
      TabOrder = 0
      OnClick = KimeTusClick
    end
    object BilgiTus: TcxButton
      Left = 28
      Top = 42
      Width = 75
      Height = 25
      Caption = 'Bilgi ->'
      TabOrder = 1
      OnClick = BilgiTusClick
    end
    object GizliTus: TcxButton
      Left = 28
      Top = 73
      Width = 75
      Height = 25
      Caption = 'Gizli ->'
      TabOrder = 2
      Visible = False
    end
    object KimeEdit: TEdit
      Left = 116
      Top = 11
      Width = 425
      Height = 21
      TabOrder = 3
    end
    object BilgiEdit: TEdit
      Left = 116
      Top = 42
      Width = 425
      Height = 21
      TabOrder = 4
    end
    object GizliEdit: TEdit
      Left = 116
      Top = 73
      Width = 425
      Height = 21
      TabOrder = 5
      Visible = False
    end
    object TamamTus: TcxButton
      Left = 385
      Top = 113
      Width = 75
      Height = 25
      Caption = 'Tamam'
      ModalResult = 1
      TabOrder = 6
      OnClick = TamamTusClick
    end
    object IptalTus: TcxButton
      Left = 466
      Top = 113
      Width = 75
      Height = 25
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 7
    end
  end
  object MailGrid: TcxGrid
    Left = 0
    Top = 49
    Width = 570
    Height = 311
    Align = alClient
    TabOrder = 1
    object MailGridDBTableView1: TcxGridDBTableView
      OnDblClick = MailGridDBTableView1DblClick
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DataMail
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      object MailGridDBTableView1FIRMA: TcxGridDBColumn
        Caption = #220'nvan'
        DataBinding.FieldName = 'FIRMA'
        Width = 156
      end
      object FIRMAMailGridDBTableView1ETIKET: TcxGridDBColumn
        Caption = 'Ad '
        DataBinding.FieldName = 'AD'
        Width = 135
      end
      object FIRMAMailGridDBTableView1BILGI: TcxGridDBColumn
        Caption = 'E-Posta'
        DataBinding.FieldName = 'BILGI'
        Width = 152
      end
    end
    object MailGridLevel1: TcxGridLevel
      GridView = MailGridDBTableView1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 570
    Height = 49
    Align = alTop
    TabOrder = 2
    object cxButton1: TcxButton
      Left = 28
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Ara'
      TabOrder = 0
    end
    object Edit1: TEdit
      Left = 109
      Top = 11
      Width = 425
      Height = 21
      TabOrder = 1
      OnKeyUp = Edit1KeyUp
    end
  end
  object MemoListeSQL: TMemo
    Left = 8
    Top = 196
    Width = 489
    Height = 50
    Lines.Strings = (
      'select R.FIRMA,RI.AD,RB.BILGI from '
      'REHBER R inner join'
      'REHBERILETISIM RI on R.ID=RI.REHBERID inner join'
      'REHBERBILGI RB on RB.YER_ID=RI.ID inner join '
      'REHBERAYAR RA on RA.YERI=RB.YERI and RA.ETIKET=RB.ETIKET'
      
        'where RB.YERI=1 and RA.VARSAYILAN=46 and RB.BILGI like '#39'%@%.%'#39' a' +
        'nd'
      
        '((0=@@REHBERID)or(R.ID=@@REHBERID)or(R.GRUP=334 and R.BAGID=@@RE' +
        'HBERID)) and'
      
        '(R.KOD like '#39'%@@ADSOYAD%'#39'  or  R.FIRMA like '#39'%@@ADSOYAD%'#39' or  RI' +
        '.AD like '
      #39'%@@ADSOYAD%'#39')')
    TabOrder = 3
    Visible = False
  end
  object DataMail: TDataSource
    DataSet = QueryMail
    Left = 382
    Top = 88
  end
  object QueryMail: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 416
    Top = 168
  end
end


