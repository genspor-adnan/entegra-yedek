object RichEditDlg: TRichEditDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Bilgi Giri'#351' Ekran'#305
  ClientHeight = 514
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 449
    Width = 720
    Height = 65
    Align = alBottom
    TabOrder = 0
    object cxButton1: TcxButton
      Left = 432
      Top = 14
      Width = 167
      Height = 41
      Caption = 'Kaydet'
      ModalResult = 1
      OptionsImage.ImageIndex = 2
      OptionsImage.Images = Tablo.PNGImageList2
      TabOrder = 0
      OnClick = cxButton1Click
    end
    object cxButton2: TcxButton
      Left = 600
      Top = 14
      Width = 81
      Height = 41
      Caption = 'Kapat'
      ModalResult = 2
      OptionsImage.ImageIndex = 14
      OptionsImage.Images = Tablo.PNGImageList2
      TabOrder = 1
    end
  end
  object RichEdit: TcxRichEdit
    Left = 0
    Top = 65
    Align = alClient
    Properties.ScrollBars = ssBoth
    TabOrder = 1
    Height = 384
    Width = 720
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 65
    Align = alTop
    TabOrder = 2
  end
end
