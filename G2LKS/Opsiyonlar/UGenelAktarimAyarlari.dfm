object aktarimAyarlariForm: TaktarimAyarlariForm
  Left = 0
  Top = 0
  Width = 355
  Height = 68
  TabOrder = 0
  object Label1: TLabel
    Left = 6
    Top = 6
    Width = 59
    Height = 13
    Caption = 'Aktar'#305'm Yolu'
  end
  object aktarimYoluEdit: TEdit
    Left = 6
    Top = 24
    Width = 277
    Height = 21
    TabOrder = 0
  end
  object browseButton: TButton
    Left = 288
    Top = 23
    Width = 31
    Height = 22
    Caption = '...'
    TabOrder = 1
    OnClick = browseButtonClick
  end
  object browseForFolder: TBrowseForFolder
    Caption = 'Klas'#246'r se'#231'in'
    DialogCaption = 'Klas'#246'r se'#231'in'
    BrowseOptions = []
    Left = 310
  end
  object OpenDialog1: TOpenDialog
    Left = 176
    Top = 40
  end
end
