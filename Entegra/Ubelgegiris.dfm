object belgegirisdlg: Tbelgegirisdlg
  Left = 0
  Top = 0
  Caption = 'Belge Giri'#351
  ClientHeight = 562
  ClientWidth = 1331
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 80
    Width = 1331
    Height = 373
    Align = alClient
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      PopupMenu = PopupMenu1
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      Filtering.ColumnAddValueItems = False
      Filtering.ColumnMRUItemsList = False
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1RecId: TcxGridDBColumn
        DataBinding.FieldName = 'RecId'
        Visible = False
      end
      object cxGrid1DBTableView1s_no: TcxGridDBColumn
        Caption = 'S.No'
        DataBinding.FieldName = 's_no'
        Options.Editing = False
        Width = 35
      end
      object cxGrid1DBTableView1cr_kod: TcxGridDBColumn
        Caption = 'M'#252#351'teri Kod'
        DataBinding.FieldName = 'cr_kod'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Options.Editing = False
        Width = 80
      end
      object cxGrid1DBTableView1cr_ad: TcxGridDBColumn
        Caption = 'M'#252#351'teri Ad'
        DataBinding.FieldName = 'cr_ad'
        Options.Editing = False
        Width = 130
      end
      object cxGrid1DBTableView1belge_no: TcxGridDBColumn
        Caption = 'Belge No'
        DataBinding.FieldName = 'belge_no'
        Width = 65
      end
      object cxGrid1DBTableView1belgetip: TcxGridDBColumn
        Caption = 'Belge Tip'
        DataBinding.FieldName = 'belgetip'
        PropertiesClassName = 'TcxComboBoxProperties'
        Properties.Items.Strings = (
          'Fi'#351
          'Fatura')
        Width = 55
      end
      object cxGrid1DBTableView1belgetarih: TcxGridDBColumn
        Caption = 'Belge Tarihi'
        DataBinding.FieldName = 'belgetarih'
        Width = 110
      end
      object cxGrid1DBTableView1mkod: TcxGridDBColumn
        Caption = 'Masraf Kod'
        DataBinding.FieldName = 'mkod'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Width = 80
      end
      object cxGrid1DBTableView1mad: TcxGridDBColumn
        Caption = 'Masraf Ad'
        DataBinding.FieldName = 'mad'
        Options.Editing = False
        Width = 130
      end
      object cxGrid1DBTableView1aciklama: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'aciklama'
        Width = 120
      end
      object cxGrid1DBTableView1adet: TcxGridDBColumn
        Caption = 'Adet'
        DataBinding.FieldName = 'adet'
        Width = 40
      end
      object cxGrid1DBTableView1b_fiyat: TcxGridDBColumn
        Caption = 'B.Fiyat'
        DataBinding.FieldName = 'b_fiyat'
        Width = 60
      end
      object cxGrid1DBTableView1kdv: TcxGridDBColumn
        Caption = 'KDV'
        DataBinding.FieldName = 'kdv'
        PropertiesClassName = 'TcxComboBoxProperties'
        Properties.Items.Strings = (
          '18'
          '8'
          '1')
        Width = 45
      end
      object cxGrid1DBTableView1tutar: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'ctutar'
        Width = 60
      end
      object cxGrid1DBTableView1p_birim: TcxGridDBColumn
        Caption = 'P.Birim'
        DataBinding.FieldName = 'p_birim'
        Width = 50
      end
      object cxGrid1DBTableView1ckdvtut: TcxGridDBColumn
        Caption = 'KDV Tut.'
        DataBinding.FieldName = 'ckdvtut'
        Width = 55
      end
      object cxGrid1DBTableView1ctoplam: TcxGridDBColumn
        Caption = 'Toplam'
        DataBinding.FieldName = 'ctoplam'
        Width = 55
      end
      object cxGrid1DBTableView1kasa_id: TcxGridDBColumn
        Caption = #214'deme'
        DataBinding.FieldName = 'kasa_id'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        Options.Editing = False
        Width = 120
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1331
    Height = 35
    Align = alTop
    TabOrder = 1
    object cxButton2: TcxButton
      Left = 1
      Top = 1
      Width = 120
      Height = 33
      Align = alLeft
      Caption = 'Sat'#305'r Temizle'
      TabOrder = 0
      OnClick = cxButton2Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 35
    Width = 1331
    Height = 45
    Align = alTop
    TabOrder = 2
    object Panel16: TPanel
      Left = 1
      Top = 1
      Width = 90
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object cxLabel25: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'M'#252#351'teri Kod'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 90
        AnchorY = 9
      end
      object cxButtonEdit1: TcxButtonEdit
        Left = 0
        Top = 18
        Align = alTop
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
        TabOrder = 1
        Width = 90
      end
    end
    object Panel4: TPanel
      Left = 91
      Top = 1
      Width = 135
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object cxLabel3: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'M'#252#351'teri Ad'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 135
        AnchorY = 9
      end
      object cxTextEdit2: TcxTextEdit
        Left = 0
        Top = 18
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        ParentFont = False
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.LookAndFeel.Kind = lfFlat
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.Kind = lfFlat
        StyleFocused.LookAndFeel.Kind = lfFlat
        StyleHot.LookAndFeel.Kind = lfFlat
        StyleReadOnly.LookAndFeel.Kind = lfFlat
        TabOrder = 1
        Width = 135
      end
    end
    object Panel5: TPanel
      Left = 226
      Top = 1
      Width = 70
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 2
      object cxLabel4: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'Belge No'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 70
        AnchorY = 9
      end
      object cxTextEdit3: TcxTextEdit
        Left = 0
        Top = 18
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        ParentFont = False
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.LookAndFeel.Kind = lfFlat
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.Kind = lfFlat
        StyleFocused.LookAndFeel.Kind = lfFlat
        StyleHot.LookAndFeel.Kind = lfFlat
        StyleReadOnly.LookAndFeel.Kind = lfFlat
        TabOrder = 1
        Width = 70
      end
    end
    object Panel6: TPanel
      Left = 296
      Top = 1
      Width = 65
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 3
      object cxLabel5: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'Belge Tip'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 65
        AnchorY = 9
      end
      object cxComboBox1: TcxComboBox
        Left = 0
        Top = 18
        Align = alTop
        Properties.Items.Strings = (
          'Fi'#351
          'Fatura'
          'Tahakkuk')
        Properties.OnChange = cxComboBox1PropertiesChange
        TabOrder = 1
        Width = 65
      end
    end
    object Panel7: TPanel
      Left = 361
      Top = 1
      Width = 100
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 4
      object cxLabel6: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'Belge Tarih'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 100
        AnchorY = 9
      end
      object cxDateEdit1: TcxDateEdit
        Left = 0
        Top = 18
        Align = alTop
        TabOrder = 1
        Width = 100
      end
    end
    object Panel8: TPanel
      Left = 461
      Top = 1
      Width = 90
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 5
      object cxLabel7: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'Masraf Kod'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 90
        AnchorY = 9
      end
      object cxButtonEdit2: TcxButtonEdit
        Left = 0
        Top = 18
        Align = alTop
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = cxButtonEdit2PropertiesButtonClick
        TabOrder = 1
        Width = 90
      end
    end
    object Panel9: TPanel
      Left = 551
      Top = 1
      Width = 130
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 6
      object cxLabel8: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'Masraf Ad'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 130
        AnchorY = 9
      end
      object cxTextEdit4: TcxTextEdit
        Left = 0
        Top = 18
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        ParentFont = False
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.LookAndFeel.Kind = lfFlat
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.Kind = lfFlat
        StyleFocused.LookAndFeel.Kind = lfFlat
        StyleHot.LookAndFeel.Kind = lfFlat
        StyleReadOnly.LookAndFeel.Kind = lfFlat
        TabOrder = 1
        Width = 130
      end
    end
    object Panel10: TPanel
      Left = 681
      Top = 1
      Width = 110
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 7
      object cxLabel9: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'A'#231#305'klama'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 110
        AnchorY = 9
      end
      object cxTextEdit5: TcxTextEdit
        Left = 0
        Top = 18
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        ParentFont = False
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.LookAndFeel.Kind = lfFlat
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.Kind = lfFlat
        StyleFocused.LookAndFeel.Kind = lfFlat
        StyleHot.LookAndFeel.Kind = lfFlat
        StyleReadOnly.LookAndFeel.Kind = lfFlat
        TabOrder = 1
        Width = 110
      end
    end
    object Panel11: TPanel
      Left = 846
      Top = 1
      Width = 50
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 9
      object cxLabel10: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'Adet'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 50
        AnchorY = 9
      end
      object cxCurrencyEdit1: TcxCurrencyEdit
        Left = 0
        Top = 18
        Align = alTop
        EditValue = '1'
        Properties.AssignedValues.DisplayFormat = True
        TabOrder = 1
        Width = 50
      end
    end
    object Panel12: TPanel
      Left = 791
      Top = 1
      Width = 55
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 8
      object cxLabel11: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'B.Fiyat'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 55
        AnchorY = 9
      end
      object cxCurrencyEdit2: TcxCurrencyEdit
        Left = 0
        Top = 18
        Align = alTop
        EditValue = '0'
        Properties.AssignedValues.DisplayFormat = True
        TabOrder = 1
        Width = 55
      end
    end
    object Panel13: TPanel
      Left = 896
      Top = 1
      Width = 35
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 10
      object cxLabel12: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'KDV'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 35
        AnchorY = 9
      end
      object ComboKDV: TcxComboBox
        Left = 0
        Top = 18
        Align = alTop
        RepositoryItem = Tablo.repStokKDV
        TabOrder = 1
        Width = 35
      end
    end
    object Panel14: TPanel
      Left = 931
      Top = 1
      Width = 40
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 11
      object cxLabel13: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'P.Birim'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 40
        AnchorY = 9
      end
      object cxComboBox3: TcxComboBox
        Left = 0
        Top = 18
        Align = alTop
        Properties.Items.Strings = (
          'TL')
        TabOrder = 1
        Text = 'TL'
        Width = 40
      end
    end
    object Panel15: TPanel
      Left = 971
      Top = 1
      Width = 50
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 12
      object cxLabel14: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Caption = 'KDV Drm'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 50
        AnchorY = 9
      end
      object cxComboBox4: TcxComboBox
        Left = 0
        Top = 18
        Align = alTop
        Properties.Items.Strings = (
          'Dahil'
          'Hari'#231)
        TabOrder = 1
        Text = 'Dahil'
        Width = 50
      end
    end
    object Panel2: TPanel
      Left = 1021
      Top = 1
      Width = 140
      Height = 43
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 13
      object cxLabel17: TcxLabel
        Left = 0
        Top = 0
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alCustom
        AutoSize = False
        Caption = #214'deme'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 41
        AnchorY = 9
      end
      object ComboOdeme: TcxImageComboBox
        Left = 0
        Top = 18
        Align = alCustom
        Properties.Items = <>
        Properties.OnCloseUp = ComboOdemePropertiesCloseUp
        TabOrder = 1
        Width = 140
      end
      object Labeltaksit: TcxLabel
        Left = 97
        Top = 2
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alCustom
        AutoSize = False
        Caption = '---'
        ParentColor = False
        ParentFont = False
        Style.BorderStyle = ebsNone
        Style.Color = 8404992
        Style.Edges = []
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taLeftJustify
        Properties.Alignment.Vert = taVCenter
        Transparent = True
        Height = 18
        Width = 41
        AnchorY = 11
      end
    end
    object LabelProje: TcxLabel
      Left = 1162
      Top = 2
      Caption = 'Proje Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object BeditProje: TcxButtonEdit
      Left = 1162
      Top = 19
      ParentShowHint = False
      Properties.Buttons = <
        item
          Caption = '++'
          Hint = 'Sil'
          Kind = bkText
        end
        item
          Caption = '+'
          Kind = bkText
        end
        item
          Caption = '-'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = BeditProjePropertiesButtonClick
      ShowHint = True
      Style.BorderStyle = ebsOffice11
      Style.LookAndFeel.Kind = lfStandard
      Style.LookAndFeel.NativeStyle = False
      StyleDisabled.LookAndFeel.Kind = lfStandard
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.Kind = lfStandard
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.Kind = lfStandard
      StyleHot.LookAndFeel.NativeStyle = False
      StyleReadOnly.LookAndFeel.Kind = lfStandard
      StyleReadOnly.LookAndFeel.NativeStyle = False
      TabOrder = 14
      Width = 165
    end
  end
  object Panel28: TPanel
    Left = 0
    Top = 453
    Width = 1331
    Height = 109
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object Panel29: TPanel
      Left = 1151
      Top = 0
      Width = 70
      Height = 109
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object cxLabel23: TcxLabel
        Left = 0
        Top = 0
        Align = alTop
        AutoSize = False
        Caption = 'Toplam'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 21
        Width = 70
      end
      object cxLabel40: TcxLabel
        Left = 0
        Top = 21
        Align = alTop
        AutoSize = False
        Caption = 'KDV %1'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
        Height = 21
        Width = 70
      end
      object cxLabel42: TcxLabel
        Left = 0
        Top = 42
        Align = alTop
        AutoSize = False
        Caption = 'KDV %10'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
        Height = 21
        Width = 70
      end
      object cxLabel15: TcxLabel
        Left = 0
        Top = 63
        Align = alTop
        AutoSize = False
        Caption = 'KDV %20'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 21
        Width = 70
      end
      object cxLabel16: TcxLabel
        Left = 0
        Top = 84
        Align = alTop
        AutoSize = False
        Caption = 'G.Toplam'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 21
        Width = 70
      end
    end
    object Panel30: TPanel
      Left = 1221
      Top = 0
      Width = 80
      Height = 109
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object cxCurrencyEdit9: TcxCurrencyEdit
        Left = 0
        Top = 0
        TabStop = False
        Align = alTop
        EditValue = '0'
        ParentFont = False
        Properties.DecimalPlaces = 2
        Properties.DisplayFormat = '##,##0.00'
        Properties.ReadOnly = True
        Style.Color = 13526784
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        StyleReadOnly.LookAndFeel.NativeStyle = True
        TabOrder = 0
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        Width = 80
      end
      object cxCurrencyEdit10: TcxCurrencyEdit
        Left = 0
        Top = 21
        TabStop = False
        Align = alTop
        EditValue = '0'
        ParentFont = False
        Properties.DecimalPlaces = 2
        Properties.DisplayFormat = '##,##0.00'
        Properties.ReadOnly = True
        Style.Color = 13526784
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        StyleReadOnly.LookAndFeel.NativeStyle = True
        TabOrder = 1
        Visible = False
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        Width = 80
      end
      object cxCurrencyEdit3: TcxCurrencyEdit
        Left = 0
        Top = 42
        TabStop = False
        Align = alTop
        EditValue = '0'
        ParentFont = False
        Properties.DecimalPlaces = 2
        Properties.DisplayFormat = '##,##0.00'
        Properties.ReadOnly = True
        Style.Color = 13526784
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        StyleReadOnly.LookAndFeel.NativeStyle = True
        TabOrder = 2
        Visible = False
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        Width = 80
      end
      object cxCurrencyEdit4: TcxCurrencyEdit
        Left = 0
        Top = 63
        TabStop = False
        Align = alTop
        EditValue = '0'
        ParentFont = False
        Properties.DecimalPlaces = 2
        Properties.DisplayFormat = '##,##0.00'
        Properties.ReadOnly = True
        Style.Color = 13526784
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        StyleReadOnly.LookAndFeel.NativeStyle = True
        TabOrder = 3
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        Width = 80
      end
      object cxCurrencyEdit5: TcxCurrencyEdit
        Left = 0
        Top = 84
        TabStop = False
        Align = alTop
        EditValue = '0'
        ParentFont = False
        Properties.DecimalPlaces = 2
        Properties.DisplayFormat = '##,##0.00'
        Properties.ReadOnly = True
        Style.Color = 13526784
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWhite
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = [fsBold]
        Style.LookAndFeel.NativeStyle = True
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        StyleReadOnly.LookAndFeel.NativeStyle = True
        TabOrder = 4
        BiDiMode = bdRightToLeft
        ParentBiDiMode = False
        Width = 80
      end
    end
    object Panel17: TPanel
      Left = 1301
      Top = 0
      Width = 30
      Height = 109
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
    end
    object cxTextEdit1: TcxTextEdit
      Left = 760
      Top = 80
      TabOrder = 3
      Text = 'cxTextEdit1'
      Visible = False
      Width = 100
    end
    object F5KaydetTus: TcxButton
      Left = 4
      Top = 5
      Width = 140
      Height = 33
      Caption = 'F5 Kaydet'
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        424D360900000000000036000000280000001800000018000000010020000000
        000000000000C40E0000C40E0000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000303
        03050808080C0D0D0D131313131C17171722161616212020202F232323332222
        2232222222322222223222222232232323331A1A1A2617171721171717210F0F
        0F160C0C0C110707070A020202030000000000000000020202034545456C6F6F
        6FAE838383CB8D8D8DDB959595EB9A9A9AEF9C9C9CF3A09F9FFAA4A3A4FDA4A1
        A3FCA3A3A3FDA1A1A1FDA3A3A3FDA0A0A0FC9F9F9FF79A9A9AF0989898EF9292
        92E38A8A8AD77A7A7AC06363639A212121310000000000000000010101020808
        080B0E0E0E141212121B1A1A1A271B1B1B282221223325242438222422382930
        2C4A212121342725263A2727273A2727273A2727273A1E1E1E2C1A1A1A271717
        1722101010180A0A0A0F05050507000000000000000000000000000000000000
        0000000000000000000000000000000000000000000007120C1A299E56E429B2
        5CFF153D25590000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000F4225592EB667FF30B668FF31B6
        69FF2FB667FF124A2A6600000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000001E7847A12EB96EFF2DB96EFE2DBA6EFF2DBA
        6EFF2DBA6EFF2EBA6EFF14553271000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000004110A1525A562DC2CBE71FF2CBD70FD2CBD71FE2CBD70FD2CBD
        70FD2CBD70FD2CBD71FE2CBE71FF16603A7D0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000C3C254A29C077FF29C077FF28C077FF28C077FF28BE76FD26BF75FF27C0
        75FF28C077FF28BE76FD28C077FF29C077FF166A418800000000000000000000
        0000000000000000000000000000000000000000000000000000000000001773
        479027C47BFF27C57BFF27C37AFD27C57BFF26C47AFF1FC176FE48D18FFF34C9
        82FF23C378FF27C37AFD27C57BFF27C37AFD27C47BFF16734793000000000000
        00000000000000000000000000000000000000000000010705091DA668D125C9
        7FFF25C97FFF25C97FFF25C77EFD23C87EFF1FC77BFF5BDB9EFF23764F8D3CA6
        74C43AD08AFF20C57BFD25C97FFF25C77EFD25C97FFF25C97FFF167F509F0000
        000000000000000000000000000000000000000000000A3B26493CD48FFF1EC9
        7FFE23CA80FD23CA80FD1FC97FFE29CE85FF59D99EF90B2C1D34000000000000
        0000339669AF3AD38FFF1EC87EFD23CB80FE23CA80FD23CA80FD23CC81FF1788
        56A80000000000000000000000000000000000000000000000002B875E9C36D5
        90FF1CCD83FF1ACD83FF39D691FF43B985D6030D080E00000000000000000000
        0000000000002F8F64A63DD693FF1BCB82FD21CF86FF21CF86FF21CD85FD21CF
        86FF17925EB200000000000000000000000000000000000000000000000034A1
        71B83CD996FF4BDD9EFF2B8D63A3000000000000000000000000000000000000
        0000000000000000000029885F9B3EDA98FF19CE85FD1ED088FD1ED188FE1ED0
        88FD1ED289FF179B65BB00000000000000000000000000000000000000000000
        0000268E639D145A3E6400000000000000000000000000000000000000000000
        0000000000000000000000000000257D578E40DC9BFF18D289FF1ED28BFD1ED4
        8CFF1ED48CFF1ED48CFF17A36BC3000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000002075528342DE9FFF14D28AFD1DD6
        8EFF1DD68EFF1BD48DFD1DD68EFF15AA71CB0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000001C6B4C7744E0A1FF13D5
        8CFE1AD68FFD1BD78FFE18D58DFD24DA93FF0C60407100000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000001961456B46E2
        A4FF12D78FFF17D68FFD1DD992FF48CE97E60108060900000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000001456
        3D5F4AE3A6FF1EDB95FF48D29AEA020906090000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000114D36533BB786C4030F0B10000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000}
      TabOrder = 4
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      OnClick = F5KaydetTusClick
    end
    object Panel18: TPanel
      Left = 0
      Top = 0
      Width = 15
      Height = 109
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 5
    end
    object F8BelgeyeDevamTus: TcxButton
      Left = 150
      Top = 6
      Width = 140
      Height = 33
      Caption = 'F8 Belgeye Devam'
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        424D360900000000000036000000280000001800000018000000010020000000
        000000000000C40E0000C40E0000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000303
        03050808080C0D0D0D131313131C17171722161616212020202F232323332222
        2232222222322222223222222232232323331A1A1A2617171721171717210F0F
        0F160C0C0C110707070A020202030000000000000000020202034545456C6F6F
        6FAE838383CB8D8D8DDB959595EB9A9A9AEF9C9C9CF3A09F9FFAA4A3A4FDA4A1
        A3FCA3A3A3FDA1A1A1FDA3A3A3FDA0A0A0FC9F9F9FF79A9A9AF0989898EF9292
        92E38A8A8AD77A7A7AC06363639A212121310000000000000000010101020808
        080B0E0E0E141212121B1A1A1A271B1B1B282221223325242438222422382930
        2C4A212121342725263A2727273A2727273A2727273A1E1E1E2C1A1A1A271717
        1722101010180A0A0A0F05050507000000000000000000000000000000000000
        0000000000000000000000000000000000000000000007120C1A299E56E429B2
        5CFF153D25590000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000F4225592EB667FF30B668FF31B6
        69FF2FB667FF124A2A6600000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000001E7847A12EB96EFF2DB96EFE2DBA6EFF2DBA
        6EFF2DBA6EFF2EBA6EFF14553271000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000004110A1525A562DC2CBE71FF2CBD70FD2CBD71FE2CBD70FD2CBD
        70FD2CBD70FD2CBD71FE2CBE71FF16603A7D0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000C3C254A29C077FF29C077FF28C077FF28C077FF28BE76FD26BF75FF27C0
        75FF28C077FF28BE76FD28C077FF29C077FF166A418800000000000000000000
        0000000000000000000000000000000000000000000000000000000000001773
        479027C47BFF27C57BFF27C37AFD27C57BFF26C47AFF1FC176FE48D18FFF34C9
        82FF23C378FF27C37AFD27C57BFF27C37AFD27C47BFF16734793000000000000
        00000000000000000000000000000000000000000000010705091DA668D125C9
        7FFF25C97FFF25C97FFF25C77EFD23C87EFF1FC77BFF5BDB9EFF23764F8D3CA6
        74C43AD08AFF20C57BFD25C97FFF25C77EFD25C97FFF25C97FFF167F509F0000
        000000000000000000000000000000000000000000000A3B26493CD48FFF1EC9
        7FFE23CA80FD23CA80FD1FC97FFE29CE85FF59D99EF90B2C1D34000000000000
        0000339669AF3AD38FFF1EC87EFD23CB80FE23CA80FD23CA80FD23CC81FF1788
        56A80000000000000000000000000000000000000000000000002B875E9C36D5
        90FF1CCD83FF1ACD83FF39D691FF43B985D6030D080E00000000000000000000
        0000000000002F8F64A63DD693FF1BCB82FD21CF86FF21CF86FF21CD85FD21CF
        86FF17925EB200000000000000000000000000000000000000000000000034A1
        71B83CD996FF4BDD9EFF2B8D63A3000000000000000000000000000000000000
        0000000000000000000029885F9B3EDA98FF19CE85FD1ED088FD1ED188FE1ED0
        88FD1ED289FF179B65BB00000000000000000000000000000000000000000000
        0000268E639D145A3E6400000000000000000000000000000000000000000000
        0000000000000000000000000000257D578E40DC9BFF18D289FF1ED28BFD1ED4
        8CFF1ED48CFF1ED48CFF17A36BC3000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000002075528342DE9FFF14D28AFD1DD6
        8EFF1DD68EFF1BD48DFD1DD68EFF15AA71CB0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000001C6B4C7744E0A1FF13D5
        8CFE1AD68FFD1BD78FFE18D58DFD24DA93FF0C60407100000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000001961456B46E2
        A4FF12D78FFF17D68FFD1DD992FF48CE97E60108060900000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000001456
        3D5F4AE3A6FF1EDB95FF48D29AEA020906090000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000114D36533BB786C4030F0B10000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000}
      TabOrder = 6
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      OnClick = F8BelgeyeDevamTusClick
    end
    object cxButton4: TcxButton
      Left = 295
      Top = 5
      Width = 140
      Height = 33
      Caption = 'F9 Yeni Belge'
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        424D360900000000000036000000280000001800000018000000010020000000
        000000000000C40E0000C40E0000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000303
        03050808080C0D0D0D131313131C17171722161616212020202F232323332222
        2232222222322222223222222232232323331A1A1A2617171721171717210F0F
        0F160C0C0C110707070A020202030000000000000000020202034545456C6F6F
        6FAE838383CB8D8D8DDB959595EB9A9A9AEF9C9C9CF3A09F9FFAA4A3A4FDA4A1
        A3FCA3A3A3FDA1A1A1FDA3A3A3FDA0A0A0FC9F9F9FF79A9A9AF0989898EF9292
        92E38A8A8AD77A7A7AC06363639A212121310000000000000000010101020808
        080B0E0E0E141212121B1A1A1A271B1B1B282221223325242438222422382930
        2C4A212121342725263A2727273A2727273A2727273A1E1E1E2C1A1A1A271717
        1722101010180A0A0A0F05050507000000000000000000000000000000000000
        0000000000000000000000000000000000000000000007120C1A299E56E429B2
        5CFF153D25590000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000F4225592EB667FF30B668FF31B6
        69FF2FB667FF124A2A6600000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000001E7847A12EB96EFF2DB96EFE2DBA6EFF2DBA
        6EFF2DBA6EFF2EBA6EFF14553271000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000004110A1525A562DC2CBE71FF2CBD70FD2CBD71FE2CBD70FD2CBD
        70FD2CBD70FD2CBD71FE2CBE71FF16603A7D0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000C3C254A29C077FF29C077FF28C077FF28C077FF28BE76FD26BF75FF27C0
        75FF28C077FF28BE76FD28C077FF29C077FF166A418800000000000000000000
        0000000000000000000000000000000000000000000000000000000000001773
        479027C47BFF27C57BFF27C37AFD27C57BFF26C47AFF1FC176FE48D18FFF34C9
        82FF23C378FF27C37AFD27C57BFF27C37AFD27C47BFF16734793000000000000
        00000000000000000000000000000000000000000000010705091DA668D125C9
        7FFF25C97FFF25C97FFF25C77EFD23C87EFF1FC77BFF5BDB9EFF23764F8D3CA6
        74C43AD08AFF20C57BFD25C97FFF25C77EFD25C97FFF25C97FFF167F509F0000
        000000000000000000000000000000000000000000000A3B26493CD48FFF1EC9
        7FFE23CA80FD23CA80FD1FC97FFE29CE85FF59D99EF90B2C1D34000000000000
        0000339669AF3AD38FFF1EC87EFD23CB80FE23CA80FD23CA80FD23CC81FF1788
        56A80000000000000000000000000000000000000000000000002B875E9C36D5
        90FF1CCD83FF1ACD83FF39D691FF43B985D6030D080E00000000000000000000
        0000000000002F8F64A63DD693FF1BCB82FD21CF86FF21CF86FF21CD85FD21CF
        86FF17925EB200000000000000000000000000000000000000000000000034A1
        71B83CD996FF4BDD9EFF2B8D63A3000000000000000000000000000000000000
        0000000000000000000029885F9B3EDA98FF19CE85FD1ED088FD1ED188FE1ED0
        88FD1ED289FF179B65BB00000000000000000000000000000000000000000000
        0000268E639D145A3E6400000000000000000000000000000000000000000000
        0000000000000000000000000000257D578E40DC9BFF18D289FF1ED28BFD1ED4
        8CFF1ED48CFF1ED48CFF17A36BC3000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000002075528342DE9FFF14D28AFD1DD6
        8EFF1DD68EFF1BD48DFD1DD68EFF15AA71CB0000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000001C6B4C7744E0A1FF13D5
        8CFE1AD68FFD1BD78FFE18D58DFD24DA93FF0C60407100000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000001961456B46E2
        A4FF12D78FFF17D68FFD1DD992FF48CE97E60108060900000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000001456
        3D5F4AE3A6FF1EDB95FF48D29AEA020906090000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000114D36533BB786C4030F0B10000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000}
      TabOrder = 7
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      OnClick = cxButton4Click
    end
  end
  object dxMemData1: TdxMemData
    Indexes = <>
    SortOptions = []
    AfterPost = dxMemData1AfterPost
    OnCalcFields = dxMemData1CalcFields
    Left = 168
    Top = 344
    object dxMemData1s_no: TIntegerField
      FieldName = 's_no'
    end
    object dxMemData1cr_kod: TStringField
      FieldName = 'cr_kod'
      Size = 30
    end
    object dxMemData1cr_ad: TStringField
      FieldName = 'cr_ad'
      Size = 150
    end
    object dxMemData1belge_no: TStringField
      FieldName = 'belge_no'
      Size = 30
    end
    object dxMemData1belgetip: TStringField
      FieldName = 'belgetip'
      Size = 15
    end
    object dxMemData1belgetarih: TDateTimeField
      FieldName = 'belgetarih'
    end
    object dxMemData1mkod: TStringField
      FieldName = 'mkod'
      Size = 30
    end
    object dxMemData1mad: TStringField
      FieldName = 'mad'
    end
    object dxMemData1aciklama: TStringField
      FieldName = 'aciklama'
      Size = 200
    end
    object dxMemData1adet: TFloatField
      FieldName = 'adet'
    end
    object dxMemData1b_fiyat: TCurrencyField
      FieldName = 'b_fiyat'
      DisplayFormat = '##,##0.00'
    end
    object dxMemData1kdv: TIntegerField
      FieldName = 'kdv'
    end
    object dxMemData1p_birim: TStringField
      FieldName = 'p_birim'
      Size = 10
    end
    object dxMemData1kdvdrm: TStringField
      FieldName = 'kdvdrm'
      Size = 10
    end
    object dxMemData1ctutar: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'ctutar'
      DisplayFormat = '##,##0.00'
      Calculated = True
    end
    object dxMemData1baslik: TIntegerField
      FieldName = 'baslik'
    end
    object dxMemData1cr_id: TIntegerField
      FieldName = 'cr_id'
    end
    object dxMemData1m_id: TIntegerField
      FieldName = 'm_id'
    end
    object dxMemData1ckdvtut: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'ckdvtut'
      DisplayFormat = '##,##0.00'
      Calculated = True
    end
    object dxMemData1ctoplam: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'ctoplam'
      DisplayFormat = '##,##0.00'
      Calculated = True
    end
    object dxMemData1kasa_kodu: TStringField
      FieldName = 'kasa_kodu'
    end
    object dxMemData1kasa_id: TIntegerField
      FieldName = 'kasa_id'
    end
    object dxMemData1kasareh_id: TIntegerField
      FieldName = 'kasareh_id'
    end
    object dxMemData1taksit: TSmallintField
      FieldName = 'taksit'
    end
    object dxMemData1ProjeId: TIntegerField
      FieldName = 'ProjeId'
    end
  end
  object DataSource1: TDataSource
    DataSet = dxMemData1
    Left = 272
    Top = 352
  end
  object PopupMenu1: TPopupMenu
    Left = 488
    Top = 288
    object SatrSil1: TMenuItem
      Caption = 'Sat'#305'r Sil'
      OnClick = SatrSil1Click
    end
  end
  object ftbaslik: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from FATBASLIK'
      'where ID =-1')
    Left = 408
    Top = 472
  end
  object fisno: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select max(ID) as ID from FATBASLIK')
    Left = 488
    Top = 472
    object fisnoID: TIntegerField
      FieldName = 'ID'
      ReadOnly = True
    end
  end
  object ftdetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from FATURA')
    Left = 352
    Top = 496
  end
  object dxMemData2: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 88
    Top = 240
    object dxMemData2sno: TIntegerField
      FieldName = 'sno'
    end
    object dxMemData2toplam: TFloatField
      FieldName = 'toplam'
      DisplayFormat = '##,##0.00'
    end
    object dxMemData2kdvtoplam: TFloatField
      FieldName = 'kdvtoplam'
      DisplayFormat = '##,##0.00'
    end
    object dxMemData2geneltoplam: TFloatField
      FieldName = 'geneltoplam'
      DisplayFormat = '##,##0.00'
    end
  end
  object kasakayit: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from KASA where ID=0')
    Left = 632
    Top = 272
  end
  object DataSource2: TDataSource
    DataSet = dxMemData2
    Left = 184
    Top = 256
  end
end
