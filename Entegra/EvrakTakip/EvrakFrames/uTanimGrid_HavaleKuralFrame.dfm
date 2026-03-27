inherited EvrakTanimHavaleKuralFrame: TEvrakTanimHavaleKuralFrame
  Width = 750
  Height = 588
  ExplicitWidth = 750
  ExplicitHeight = 588
  inherited PanelTop: TPanel
    Width = 744
  end
  inherited PanelMain: TPanel
    Width = 744
    Height = 538
    inherited GridTanim: TcxGrid
      Height = 538
      LookAndFeel.SkinName = ''
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        object ViewTanimID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimKURAL_ADI: TcxGridDBColumn
          Caption = 'Kural'
          DataBinding.FieldName = 'KURAL_ADI'
          Width = 100
        end
        object ViewTanimEVRAK_BIRIMI_REF: TcxGridDBColumn
          DataBinding.FieldName = 'EVRAK_BIRIMI_REF'
          Visible = False
        end
        object ViewTanimGECERLILIK_BASLANGIC: TcxGridDBColumn
          Caption = 'Ba'#351'lang'#305#231
          DataBinding.FieldName = 'GECERLILIK_BASLANGIC'
          Width = 68
        end
        object ViewTanimGECERLILIK_BITIS: TcxGridDBColumn
          Caption = 'Biti'#351
          DataBinding.FieldName = 'GECERLILIK_BITIS'
          Width = 68
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      Height = 538
    end
    object PanelRight: TPanel [2]
      Left = 258
      Top = 0
      Width = 486
      Height = 538
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      ExplicitLeft = 184
      ExplicitTop = 232
      ExplicitWidth = 185
      ExplicitHeight = 161
      object Panel1: TPanel
        Left = 0
        Top = 329
        Width = 486
        Height = 209
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 289
        ExplicitWidth = 482
        ExplicitHeight = 246
        object PanelAlanLeft: TPanel
          Left = 0
          Top = 0
          Width = 185
          Height = 209
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitLeft = 41
          ExplicitTop = 40
          ExplicitHeight = 145
          object Label1: TLabel
            AlignWithMargins = True
            Left = 3
            Top = 36
            Width = 179
            Height = 18
            Align = alTop
            Caption = 'Alan'
            Layout = tlCenter
            ExplicitLeft = 1
            ExplicitTop = 34
            ExplicitWidth = 23
          end
          object Label8: TLabel
            Left = 0
            Top = 83
            Width = 185
            Height = 18
            Align = alTop
            Caption = #304#351'le'#231
            ExplicitWidth = 25
          end
          object Label9: TLabel
            Left = 0
            Top = 127
            Width = 185
            Height = 18
            Align = alTop
            Caption = 'De'#287'er'
            ExplicitWidth = 32
          end
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 185
            Height = 33
            Align = alTop
            BevelEdges = [beBottom]
            TabOrder = 0
            ExplicitTop = 8
            object SpeedButton1: TSpeedButton
              AlignWithMargins = True
              Left = 98
              Top = 4
              Width = 83
              Height = 25
              Align = alRight
              Caption = 'Ekle'
              ImageIndex = 62
              Images = dmEvrakModule.ImagesEvrak
              OnClick = SpeedButton1Click
              ExplicitLeft = 96
            end
          end
          object comboAlan: TcxComboBox
            Left = 0
            Top = 57
            Align = alTop
            Properties.DropDownListStyle = lsFixedList
            TabOrder = 1
            ExplicitLeft = -2
            ExplicitTop = 60
            ExplicitWidth = 121
            Width = 185
          end
          object comboIslec: TcxComboBox
            Left = 0
            Top = 101
            Align = alTop
            Properties.DropDownListStyle = lsFixedList
            TabOrder = 2
            ExplicitLeft = 8
            ExplicitTop = 112
            ExplicitWidth = 121
            Width = 185
          end
          object comboDeger: TcxComboBox
            Left = 0
            Top = 145
            Align = alTop
            Properties.DropDownListStyle = lsFixedList
            TabOrder = 3
            ExplicitLeft = 48
            ExplicitTop = 160
            ExplicitWidth = 121
            Width = 185
          end
        end
        object PanelAlanRgiht: TPanel
          Left = 185
          Top = 0
          Width = 301
          Height = 209
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitLeft = 193
          ExplicitTop = 48
          ExplicitWidth = 185
          ExplicitHeight = 145
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 301
            Height = 33
            Align = alTop
            BevelEdges = [beBottom]
            TabOrder = 0
            ExplicitTop = 8
            ExplicitWidth = 185
            object SpeedButton2: TSpeedButton
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 85
              Height = 25
              Align = alLeft
              Caption = #199#305'kart'
              ImageIndex = 63
              Images = dmEvrakModule.ImagesEvrak
            end
          end
          object GridKosul: TcxGrid
            AlignWithMargins = True
            Left = 3
            Top = 36
            Width = 295
            Height = 170
            Align = alClient
            TabOrder = 1
            ExplicitLeft = 56
            ExplicitTop = 39
            ExplicitWidth = 250
            ExplicitHeight = 200
            object ViewKosul: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dsKosul
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              object ViewKosulID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Width = 31
              end
              object ViewKosulALAN: TcxGridDBColumn
                DataBinding.FieldName = 'ALAN'
                Width = 50
              end
              object ViewKosulALAN_REF: TcxGridDBColumn
                DataBinding.FieldName = 'ALAN_REF'
                Width = 50
              end
              object ViewKosulOPERATOR: TcxGridDBColumn
                DataBinding.FieldName = 'OPERATOR'
                Width = 50
              end
              object ViewKosulKOSUL_DEGER: TcxGridDBColumn
                DataBinding.FieldName = 'KOSUL_DEGER'
                Width = 50
              end
              object ViewKosulKOSUL_DEGER_REF: TcxGridDBColumn
                DataBinding.FieldName = 'KOSUL_DEGER_REF'
                Width = 50
              end
              object ViewKosulHAVALE_KURAL_REF: TcxGridDBColumn
                DataBinding.FieldName = 'HAVALE_KURAL_REF'
                Width = 50
              end
              object ViewKosulONCELIK_SIRASI: TcxGridDBColumn
                DataBinding.FieldName = 'ONCELIK_SIRASI'
                Width = 50
              end
            end
            object LevelKosul1: TcxGridLevel
              GridView = ViewKosul
            end
          end
        end
      end
      object GridPanel2: TGridPanel
        Left = 0
        Top = 0
        Width = 486
        Height = 329
        Align = alTop
        BevelOuter = bvNone
        ColumnCollection = <
          item
            SizeStyle = ssAbsolute
            Value = 120.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 300.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = Label2
            Row = 0
          end
          item
            Column = 0
            Control = Label3
            Row = 1
          end
          item
            Column = 1
            Control = editHavaleKuralAdi
            Row = 1
          end
          item
            Column = 0
            Control = Label4
            Row = 2
          end
          item
            Column = 1
            Control = PanelTarih
            Row = 2
          end
          item
            Column = 0
            Control = Label6
            Row = 3
          end
          item
            Column = 1
            Control = GridPanelGeregiIcin
            Row = 3
          end
          item
            Column = 0
            Control = Label7
            Row = 4
          end
          item
            Column = 1
            Control = GridPanelBilgiIcin
            Row = 4
          end
          item
            Column = 1
            Control = lookupEvrakBirimi
            Row = 0
          end>
        RowCollection = <
          item
            SizeStyle = ssAbsolute
            Value = 28.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 28.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 28.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 120.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 120.000000000000000000
          end>
        TabOrder = 1
        ExplicitWidth = 484
        object Label2: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 77
          Height = 22
          Align = alLeft
          Caption = 'Evrak Birimi :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitHeight = 18
        end
        object Label3: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 31
          Width = 100
          Height = 22
          Align = alLeft
          Caption = 'Havale Kural Ad'#305' :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          ExplicitLeft = 0
          ExplicitTop = 28
          ExplicitHeight = 18
        end
        object editHavaleKuralAdi: TcxDBTextEdit
          Left = 120
          Top = 28
          Align = alLeft
          DataBinding.DataField = 'KURAL_ADI'
          DataBinding.DataSource = dsEvrak
          TabOrder = 1
          Width = 257
        end
        object Label4: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 59
          Width = 100
          Height = 22
          Align = alLeft
          Caption = 'Ge'#231'erlilik Tarihi :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          Layout = tlCenter
          ExplicitLeft = 0
          ExplicitTop = 56
          ExplicitHeight = 18
        end
        object PanelTarih: TPanel
          Left = 120
          Top = 56
          Width = 300
          Height = 28
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 2
          object Label5: TLabel
            Left = 121
            Top = 0
            Width = 14
            Height = 28
            Align = alLeft
            Caption = ' - '
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            ParentFont = False
            Layout = tlCenter
          end
          object editBaslangicTarihi: TcxDBDateEdit
            Left = 0
            Top = 0
            Align = alLeft
            DataBinding.DataField = 'GECERLILIK_BASLANGIC'
            DataBinding.DataSource = dsEvrak
            TabOrder = 0
            ExplicitLeft = 16
            ExplicitHeight = 26
            Width = 121
          end
          object editBitisTarihi: TcxDBDateEdit
            Left = 135
            Top = 0
            Align = alLeft
            DataBinding.DataField = 'GECERLILIK_BITIS'
            DataBinding.DataSource = dsEvrak
            TabOrder = 1
            ExplicitLeft = 260
            Width = 121
          end
        end
        object Label6: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 90
          Width = 69
          Height = 111
          Margins.Top = 6
          Align = alLeft
          Caption = 'Gere'#287'i '#304#231'in :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          ExplicitLeft = 0
          ExplicitTop = 84
          ExplicitHeight = 18
        end
        object GridPanelGeregiIcin: TGridPanel
          Left = 120
          Top = 84
          Width = 300
          Height = 120
          Align = alClient
          ColumnCollection = <
            item
              SizeStyle = ssAbsolute
              Value = 254.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 32.000000000000000000
            end>
          ControlCollection = <
            item
              Column = 1
              Control = Panel7
              Row = 0
            end
            item
              Column = 0
              Control = GridGeregi
              Row = 0
            end>
          RowCollection = <
            item
              Value = 100.000000000000000000
            end>
          TabOrder = 3
          ExplicitTop = 82
          object Panel7: TPanel
            Left = 255
            Top = 1
            Width = 28
            Height = 118
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 1
            object buttonGeregiEkle: TSpeedButton
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 22
              Height = 30
              Align = alTop
              ImageIndex = 20
              Images = dmEvrakModule.ImagesEvrak
              ExplicitWidth = 26
            end
          end
          object GridGeregi: TcxGrid
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 248
            Height = 112
            Align = alClient
            TabOrder = 0
            ExplicitLeft = 12
            ExplicitTop = 8
            object ViewGeregi: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dsGeregi
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              object ViewGeregiPERSON_REF: TcxGridDBColumn
                Caption = #304'lgili'
                DataBinding.FieldName = 'PERSON_REF'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.KeyFieldNames = 'ID'
                Properties.ListColumns = <
                  item
                    FieldName = 'FIRMA'
                  end>
                Properties.ListOptions.ShowHeader = False
                Properties.ListSource = dsLookupPerson
                Width = 200
              end
              object ViewGeregiGEREGI_VEYA_BILGI: TcxGridDBColumn
                DataBinding.FieldName = 'GEREGI_VEYA_BILGI'
                DataBinding.IsNullValueType = True
                Visible = False
                Options.Editing = False
                Options.Filtering = False
                Options.FilteringAddValueItems = False
                Options.ExpressionEditing = False
                Width = 23
              end
              object ViewGeregiHAVALE_KURAL_REF: TcxGridDBColumn
                DataBinding.FieldName = 'HAVALE_KURAL_REF'
                DataBinding.IsNullValueType = True
                Visible = False
                VisibleForCustomization = False
                Width = 73
              end
              object ViewGeregiColumnKaldir: TcxGridDBColumn
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    ImageIndex = 119
                    Glyph.SourceDPI = 96
                    Glyph.Data = {
                      89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
                      61000002AF49444154785EA5925B48545B1CC6879A3D7BF6DE7343CC4B264297
                      635A074D6D26B538A6354E6299E6A5330E39929A8E664A8E3992860347B31823
                      A51B68133DC8143D08611A9AE23D1CCC1B5ED2D0A2A85E7B08B3D4AFB53B5B1F
                      82ECA105BF87FDC1FFF7B1F67F8900FC11AB6723414260042821A3094A822BC1
                      85C0F2F9CF022A2AA5C014AD3FDFA535142F44269DEBDD17633493DC3DE490DE
                      127634D3792021EF8B4697FE6277F831AB205B9388A292F3732FDF68FCD6D13B
                      8477EF3FA2BDDB898A1AFB92FA485A4BF9D5FAA527ED7D7835F71A8F9F76A3E4
                      BF9BCB3B35BA2A2250AC09B4A4B9A36F08D63A07F48536249FAD46A2A912C733
                      2B109B5E06DD290B0EFD5B841C8B0D4D2D9D0838983241045E6B82C37AF302DF
                      9C9C5F8D86FB0EC46759C19F89E9190C8F8E419B6A46B5AD0EA147B330393D8B
                      105DDA57220822287F08FE3991D7DFD63588D22B76A1B10487496344623E4263
                      4F43EFAFC6191F5F9CCC34A3F1513376046BE74D2C3B90C6320DB3419C48A48E
                      36145FB2DD5D6AEDECC7DC9BB7686EEF4169D5EDE55DE171034591BA9567812E
                      B06F51A13C588D2463EE8A51E5F2E18E9B1CAD5B395859AE90DF82223022F1A2
                      26C638141697BD18AC358CF869622A49BED7B4C963FE9EB70A53FB55A8F754A0
                      58265FE487270264B8E5CAA18C61EDBC60038115D6E3457027C885ECEF5C4EE6
                      6C20C3536A051EF8C83119F8FFB091960ECFF84945BF7B651C21D2C2C93E3D24
                      C3B3413238367328A099CF248F9FF98BFEB540788DBE390C3B78C74D419A3938
                      BC388CFB33A8554A914A49465F6E93AC2B70CD63B91EFECE93C29D0BA4CCE7EB
                      4A06E3DB695C93D328A224F67505D92CDBD6B2955BBDF308C91252296AAC860C
                      37B951B820A16AD71348087E198CB42383963E2741004141D863108B9D7A31D5
                      3DED2DFEED4F94085BF120D04246133C79F8EFEF6BABDB90CF7763F500000000
                      49454E44AE426082}
                    Hint = 'Personel '#304'li'#351'kisini Siler'
                    Kind = bkGlyph
                  end>
                Properties.ClickKey = 0
                Properties.ViewStyle = vsButtonsOnly
                Options.Filtering = False
                Options.FilteringAddValueItems = False
                Options.ShowEditButtons = isebAlways
                Options.ExpressionEditing = False
                Options.Grouping = False
                Options.Sorting = False
                Width = 47
                IsCaptionAssigned = True
              end
            end
            object LevelGeregi: TcxGridLevel
              GridView = ViewGeregi
            end
          end
        end
        object Label7: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 210
          Width = 57
          Height = 111
          Margins.Top = 6
          Align = alLeft
          Caption = 'Bilgi '#304#231'in :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          ExplicitTop = 250
          ExplicitHeight = 18
        end
        object GridPanelBilgiIcin: TGridPanel
          Left = 120
          Top = 204
          Width = 300
          Height = 120
          Align = alClient
          ColumnCollection = <
            item
              SizeStyle = ssAbsolute
              Value = 254.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 32.000000000000000000
            end>
          ControlCollection = <
            item
              Column = 1
              Control = Panel8
              Row = 0
            end
            item
              Column = 0
              Control = GridBilgi
              Row = 0
            end>
          RowCollection = <
            item
              Value = 100.000000000000000000
            end>
          TabOrder = 4
          ExplicitTop = 200
          ExplicitHeight = 160
          object Panel8: TPanel
            Left = 255
            Top = 1
            Width = 28
            Height = 118
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 1
            object buttonBilgiEkle: TSpeedButton
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 22
              Height = 30
              Align = alTop
              ImageIndex = 20
              Images = dmEvrakModule.ImagesEvrak
              ExplicitWidth = 26
            end
          end
          object GridBilgi: TcxGrid
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 248
            Height = 112
            Align = alClient
            TabOrder = 0
            ExplicitLeft = 12
            ExplicitTop = 8
            object ViwBilgi: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dsBilgi
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              object ViwBilgiPERSON_REF: TcxGridDBColumn
                Caption = #304'lgili'
                DataBinding.FieldName = 'PERSON_REF'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.KeyFieldNames = 'ID'
                Properties.ListColumns = <
                  item
                    FieldName = 'FIRMA'
                  end>
                Properties.ListSource = dsLookupPerson
                Width = 200
              end
              object ViwBilgiGEREGI_VEYA_BILGI: TcxGridDBColumn
                DataBinding.FieldName = 'GEREGI_VEYA_BILGI'
                DataBinding.IsNullValueType = True
                Visible = False
                VisibleForCustomization = False
              end
              object ViwBilgiHAVALE_KURAL_REF: TcxGridDBColumn
                DataBinding.FieldName = 'HAVALE_KURAL_REF'
                DataBinding.IsNullValueType = True
                Visible = False
                VisibleForCustomization = False
              end
              object ViwBilgiColumn1: TcxGridDBColumn
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Glyph.SourceDPI = 96
                    Glyph.Data = {
                      89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
                      61000002AF49444154785EA5925B48545B1CC6879A3D7BF6DE7343CC4B264297
                      635A074D6D26B538A6354E6299E6A5330E39929A8E664A8E3992860347B31823
                      A51B68133DC8143D08611A9AE23D1CCC1B5ED2D0A2A85E7B08B3D4AFB53B5B1F
                      82ECA105BF87FDC1FFF7B1F67F8900FC11AB6723414260042821A3094A822BC1
                      85C0F2F9CF022A2AA5C014AD3FDFA535142F44269DEBDD17633493DC3DE490DE
                      127634D3792021EF8B4697FE6277F831AB205B9388A292F3732FDF68FCD6D13B
                      8477EF3FA2BDDB898A1AFB92FA485A4BF9D5FAA527ED7D7835F71A8F9F76A3E4
                      BF9BCB3B35BA2A2250AC09B4A4B9A36F08D63A07F48536249FAD46A2A912C733
                      2B109B5E06DD290B0EFD5B841C8B0D4D2D9D0838983241045E6B82C37AF302DF
                      9C9C5F8D86FB0EC46759C19F89E9190C8F8E419B6A46B5AD0EA147B330393D8B
                      105DDA57220822287F08FE3991D7DFD63588D22B76A1B10487496344623E4263
                      4F43EFAFC6191F5F9CCC34A3F1513376046BE74D2C3B90C6320DB3419C48A48E
                      36145FB2DD5D6AEDECC7DC9BB7686EEF4169D5EDE55DE171034591BA9567812E
                      B06F51A13C588D2463EE8A51E5F2E18E9B1CAD5B395859AE90DF82223022F1A2
                      26C638141697BD18AC358CF869622A49BED7B4C963FE9EB70A53FB55A8F754A0
                      58265FE487270264B8E5CAA18C61EDBC60038115D6E3457027C885ECEF5C4EE6
                      6C20C3536A051EF8C83119F8FFB091960ECFF84945BF7B651C21D2C2C93E3D24
                      C3B3413238367328A099CF248F9FF98BFEB540788DBE390C3B78C74D419A3938
                      BC388CFB33A8554A914A49465F6E93AC2B70CD63B91EFECE93C29D0BA4CCE7EB
                      4A06E3DB695C93D328A224F67505D92CDBD6B2955BBDF308C91252296AAC860C
                      37B951B820A16AD71348087E198CB42383963E2741004141D863108B9D7A31D5
                      3DED2DFEED4F94085BF120D04246133C79F8EFEF6BABDB90CF7763F500000000
                      49454E44AE426082}
                    Kind = bkGlyph
                  end>
                VisibleForCustomization = False
              end
            end
            object LevelBilgi: TcxGridLevel
              GridView = ViwBilgi
            end
          end
        end
        object lookupEvrakBirimi: TcxDBLookupComboBox
          AlignWithMargins = True
          Left = 123
          Top = 3
          Align = alLeft
          DataBinding.DataField = 'EVRAK_BIRIMI_REF'
          DataBinding.DataSource = dsEvrak
          Properties.KeyFieldNames = 'ID'
          Properties.ListColumns = <
            item
              FieldName = 'BIRIM_ADI'
            end>
          Properties.ListSource = dsEvrakBirim
          TabOrder = 0
          ExplicitLeft = 197
          ExplicitHeight = 21
          Width = 253
        end
      end
    end
    inherited GridPanel1: TGridPanel
      Left = 1
      Width = 1
      Height = 288
      Align = alNone
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 160.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 160.000000000000000000
        end>
      TabOrder = 3
      Visible = False
      ExplicitLeft = 1
      ExplicitTop = 0
      ExplicitWidth = 1
      ExplicitHeight = 288
    end
  end
  inherited ActionListFrame: TActionList
    Left = 96
    Top = 120
  end
  inherited qryEvrak: TFDQuery
    Active = True
    AfterScroll = qryEvrakAfterScroll
    SQL.Strings = (
      'SELECT * FROM EVRAK_HAVALE_KURAL')
  end
  object qryEvrakBirim: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM EVRAK_BIRIMI ORDER BY BIRIM_ADI')
    Left = 128
    Top = 272
  end
  object dsEvrakBirim: TDataSource
    DataSet = qryEvrakBirim
    Left = 128
    Top = 336
  end
  object qryGeregi: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = qryGeregiBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM EVRAK_HAVALE_KURAL_GEREGI_BILGI'
      'WHERE GEREGI_VEYA_BILGI='#39'G'#39' AND HAVALE_KURAL_REF=:KuralRef')
    Left = 209
    Top = 221
  end
  object dsGeregi: TDataSource
    DataSet = qryGeregi
    Left = 208
    Top = 288
  end
  object dsBilgi: TDataSource
    DataSet = qryBilgi
    Left = 200
    Top = 424
  end
  object qryBilgi: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = qryBilgiBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM EVRAK_HAVALE_KURAL_GEREGI_BILGI'
      'WHERE GEREGI_VEYA_BILGI='#39'B'#39' AND HAVALE_KURAL_REF=:KuralRef')
    Left = 201
    Top = 357
  end
  object qryKosul: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = qryKosulBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM EVRAK_HAVALE_KURAL_KOSUL '
      'WHERE HAVALE_KURAL_REF = :KuralID')
    Left = 301
    Top = 343
  end
  object dsKosul: TDataSource
    DataSet = qryKosul
    Left = 293
    Top = 400
  end
  object dsLookupPerson: TDataSource
    DataSet = qryLookupPerson
    Left = 299
    Top = 239
  end
  object qryLookupPerson: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM REHBER where GRUP = 335 AND DURUM=1 ORDER BY FIRMA')
    Left = 302
    Top = 168
  end
end
