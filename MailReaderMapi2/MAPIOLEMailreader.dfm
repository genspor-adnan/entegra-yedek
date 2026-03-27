object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 527
  ClientWidth = 1196
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 35
    Height = 13
    Caption = 'Folders'
  end
  object Memo1: TMemo
    Left = 8
    Top = 27
    Width = 193
    Height = 478
    Lines.Strings = (
      ' ')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 630
    Top = 66
    Width = 75
    Height = 25
    Caption = 'all'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 711
    Top = 24
    Width = 75
    Height = 25
    Caption = 'From Company'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 816
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    Visible = False
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 630
    Top = 24
    Width = 75
    Height = 25
    Caption = 'After date'
    TabOrder = 4
    OnClick = Button4Click
  end
  object ListView1: TListView
    Left = 207
    Top = 97
    Width = 698
    Height = 409
    HelpType = htKeyword
    Columns = <
      item
        Caption = 'Sender Name'
        Width = 300
      end
      item
        Caption = 'Sender Email'
        Width = 300
      end
      item
        Caption = 'Create Date'
        Width = 300
      end
      item
        Caption = 'SendOn'
        Width = 300
      end
      item
        Caption = 'Receice Time'
        Width = 300
      end
      item
        Caption = 'Importance'
        Width = 300
      end
      item
        Caption = 'Subject'
        Width = 300
      end
      item
        Caption = 'Sensitivity'
        Width = 300
      end
      item
        Caption = 'Size'
        Width = 300
      end
      item
        Caption = 'UnRead'
        Width = 300
      end
      item
        Caption = 'To'
        Width = 300
      end
      item
        Caption = 'BCC'
        Width = 300
      end
      item
        Caption = 'CC'
        Width = 300
      end
      item
        Caption = 'Attachments'
        Width = 300
      end
      item
        Caption = 'Class'
        Width = 300
      end
      item
        Caption = 'Format'
        Width = 300
      end>
    HideSelection = False
    Items.ItemData = {
      03340000000200000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF000000
      000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000000}
    ReadOnly = True
    RowSelect = True
    TabOrder = 5
    ViewStyle = vsReport
  end
  object Edit1: TEdit
    Left = 256
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 256
    Top = 70
    Width = 121
    Height = 21
    TabOrder = 7
    Text = 'Edit1'
  end
  object Button5: TButton
    Left = 448
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Company After'
    TabOrder = 8
    OnClick = Button5Click
  end
  object FolderDeletedItems: TRadioButton
    Left = 928
    Top = 32
    Width = 113
    Height = 17
    Caption = 'Folder Deleted Items'
    TabOrder = 9
  end
  object FolderOutbox: TRadioButton
    Left = 928
    Top = 64
    Width = 113
    Height = 17
    Caption = 'Folder Outbox'
    TabOrder = 10
  end
  object FolderSentMail: TRadioButton
    Left = 928
    Top = 97
    Width = 113
    Height = 17
    Caption = 'Folder Sent Mail'
    TabOrder = 11
  end
  object FolderInbox: TRadioButton
    Left = 928
    Top = 136
    Width = 113
    Height = 17
    Caption = 'Folder Inbox'
    Checked = True
    TabOrder = 12
    TabStop = True
  end
  object FolderDrafts: TRadioButton
    Left = 928
    Top = 170
    Width = 113
    Height = 17
    Caption = 'Folder Drafts'
    TabOrder = 13
  end
end
