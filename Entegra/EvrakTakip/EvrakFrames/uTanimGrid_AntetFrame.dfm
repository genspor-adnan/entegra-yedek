inherited EvrakTanimAntetFrame: TEvrakTanimAntetFrame
  inherited PanelMain: TPanel
    inherited GridTanim: TcxGrid
      LookAndFeel.SkinName = ''
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitHeight = 430
      inherited ViewTanim: TcxGridDBTableView
        DataController.DataSource = dsEvrak
        object ViewTanimID: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'ID'
          Visible = False
          VisibleForCustomization = False
          Width = 47
        end
        object ViewTanimBIRIM_ID: TcxGridDBColumn
          Caption = 'Birim ID'
          DataBinding.FieldName = 'BIRIM_ID'
          Width = 58
        end
        object ViewTanimANTET_METIN: TcxGridDBColumn
          Caption = 'Antet'
          DataBinding.FieldName = 'ANTET_METIN'
          Width = 128
        end
        object ViewTanimANTET_RESIM_IMAGE: TcxGridDBColumn
          DataBinding.FieldName = 'ANTET_RESIM_IMAGE'
          Visible = False
          VisibleForCustomization = False
        end
        object ViewTanimALT_ANTET_RESIM_DOSYA: TcxGridDBColumn
          Caption = 'Alt Resim'
          DataBinding.FieldName = 'ALT_ANTET_RESIM_DOSYA'
          Width = 200
        end
      end
    end
    inherited cxSplitter1: TcxSplitter
      ExplicitLeft = 250
      ExplicitTop = 0
      ExplicitHeight = 430
    end
    inherited GridPanel1: TGridPanel
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 120.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 130.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = lookupBirimKodu
          Row = 0
        end
        item
          Column = 0
          Control = Label3
          Row = 2
        end
        item
          Column = 1
          Control = editBaslik
          Row = 1
        end
        item
          Column = 1
          Control = editResimDosya
          Row = 2
        end
        item
          Column = 0
          Control = Label2
          Row = 1
        end
        item
          Column = 1
          Control = ImageResim
          Row = 3
        end
        item
          Column = 0
          Control = Label5
          Row = 4
        end
        item
          Column = 1
          Control = editAltResimDosya
          Row = 4
        end
        item
          Column = 0
          Control = Label6
          Row = 5
        end
        item
          Column = 1
          Control = ImageAltResim
          Row = 5
        end
        item
          Column = 0
          Control = Label4
          Row = 3
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 90.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 90.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 28.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 90.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      ExplicitLeft = 258
      ExplicitTop = 0
      ExplicitWidth = 376
      ExplicitHeight = 430
      object Label1: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 62
        Height = 22
        Align = alLeft
        Caption = 'Evrak Birimi'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object lookupBirimKodu: TcxDBLookupComboBox
        AlignWithMargins = True
        Left = 123
        Top = 3
        Align = alLeft
        DataBinding.DataField = 'BIRIM_ID'
        DataBinding.DataSource = dsEvrak
        Properties.KeyFieldNames = 'ID'
        Properties.ListColumns = <
          item
            FieldName = 'BIRIM_ADI'
          end>
        Properties.ListSource = dsBirimKodu
        TabOrder = 0
        Width = 229
      end
      object Label3: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 121
        Width = 66
        Height = 22
        Align = alLeft
        Caption = 'Antet Resim'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editBaslik: TcxDBRichEdit
        AlignWithMargins = True
        Left = 123
        Top = 31
        Align = alLeft
        DataBinding.DataField = 'ANTET_METIN'
        DataBinding.DataSource = dsEvrak
        Properties.HideScrollBars = False
        Properties.PlainText = True
        Properties.ScrollBars = ssBoth
        TabOrder = 1
        Height = 84
        Width = 221
      end
      object editResimDosya: TcxDBButtonEdit
        AlignWithMargins = True
        Left = 123
        Top = 121
        Align = alLeft
        DataBinding.DataField = 'ANTET_RESIM_DOSYA'
        DataBinding.DataSource = dsEvrak
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end
          item
            Glyph.SourceDPI = 96
            Glyph.Data = {
              89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
              610000001D744558745469746C6500436C6F73653B457869743B426172733B52
              6962626F6E3B4603B9E8000002AD49444154785E85934B4C546714C77FF73232
              0C041DC2237644C368F109868D98A0290BDA60E2DE9526921856C3C2A08C2E1A
              A336A64DB48D81A8892D6E241A7CA20B1530261849DA4D47596818082F015118
              0698B973DFB7773EB1333BEE97FFCD3927DFF97DE77B1CE9E3AF17293FF3B30C
              48426B7D9939765A1290337AE1DC4B8F2CD73B0E802306C24CEB9BE7ACFA6206
              86650FECFCE55283079025DBAE2F3D5CB79A94B58E206692C5CF1606933DAF7F
              006451BA69986099A8C3C38C3C7846D791D3BCB97413351A151AFCADD38D8589
              DE7F412A3A426A388AC801D92300A689E36A2A1225129923D8D1C9FC9387FCDD
              D587244BC4037BDC581B91AB97716C93F2AA6D989A004802A0AF28382EF19F3B
              FD34F4F7515852C4E2AE20FFFED10140CDC9101B0ABD54B4FFCEAB1F7F62D3F9
              0AB4643203589E9C469F9926B8BF8AF947DD94B5849072246A5A43E040913F9F
              BC75394C3DEE2658BB9BD4F07BE2E3B35915A83AFAA719766CCDE7C3403F43C8
              6C6D6EC65FE8C391C0B660E8FA359203BD546EF7A34E4C60A49C2C8066602514
              B4D94F98F12596150DDB721043DC84CC4A3A168FA14FA75CA085A17D05885B30
              D280548AE8FB39947D8D048E3661D936DE5C99BC5C8FB0BF3BD684527B88D1D1
              18B6AAE22E9A5D8186954C105B50680C87503D3EF2BDEE9E6FFD0940F9F11380
              8FFA700BBD4FEEB2A94842D73D990A74DDC45C49B2A37A336FDB4E5122AB8C5F
              6FE7CBBDDB7C763571A39D328FCEBB702BDF6F2FC352750C4DCFBC0343750189
              243E3381131BE369DD018A4BD71328CE136730D7D3CDD3CEBFD8B2A518AF99C0
              4C030CFEDF82EBE802602C2CE22DC8676F7500633981E2DE0C1694FAFD6C2C29
              419D8FA12515B06C4C43461080822B6595CF7D927410475A3DF9ACA6B0859FDD
              50C2566C7BF0ECD258A3E846200FF066B5AAB4462B3B800628FF0122CC6063F4
              5F96130000000049454E44AE426082}
            Kind = bkGlyph
          end>
        Properties.OnButtonClick = editResimDosyaPropertiesButtonClick
        TabOrder = 2
        Width = 221
      end
      object Label2: TLabel
        Left = 42
        Top = 64
        Width = 35
        Height = 18
        Anchors = []
        Caption = 'Label2'
        Transparent = False
        Visible = False
        ExplicitLeft = 43
        ExplicitTop = 65
      end
      object ImageResim: TcxDBImage
        AlignWithMargins = True
        Left = 123
        Top = 149
        Align = alLeft
        DataBinding.DataField = 'ANTET_RESIM_IMAGE'
        DataBinding.DataSource = dsEvrak
        Properties.GraphicClassName = 'TdxSmartImage'
        TabOrder = 3
        OnDblClick = ImageResimDblClick
        Height = 84
        Width = 221
      end
      object Label5: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 239
        Width = 75
        Height = 22
        Align = alLeft
        Caption = 'Alt Bilgi Antet'
        Layout = tlCenter
        ExplicitHeight = 18
      end
      object editAltResimDosya: TcxDBButtonEdit
        AlignWithMargins = True
        Left = 123
        Top = 239
        Align = alLeft
        DataBinding.DataField = 'ALT_ANTET_RESIM_DOSYA'
        DataBinding.DataSource = dsEvrak
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end
          item
            Glyph.SourceDPI = 96
            Glyph.Data = {
              89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
              610000001D744558745469746C6500436C6F73653B457869743B426172733B52
              6962626F6E3B4603B9E8000002AD49444154785E85934B4C546714C77FF73232
              0C041DC2237644C368F109868D98A0290BDA60E2DE9526921856C3C2A08C2E1A
              A336A64DB48D81A8892D6E241A7CA20B1530261849DA4D47596818082F015118
              0698B973DFB7773EB1333BEE97FFCD3927DFF97DE77B1CE9E3AF17293FF3B30C
              48426B7D9939765A1290337AE1DC4B8F2CD73B0E802306C24CEB9BE7ACFA6206
              86650FECFCE55283079025DBAE2F3D5CB79A94B58E206692C5CF1606933DAF7F
              006451BA69986099A8C3C38C3C7846D791D3BCB97413351A151AFCADD38D8589
              DE7F412A3A426A388AC801D92300A689E36A2A1225129923D8D1C9FC9387FCDD
              D587244BC4037BDC581B91AB97716C93F2AA6D989A004802A0AF28382EF19F3B
              FD34F4F7515852C4E2AE20FFFED10140CDC9101B0ABD54B4FFCEAB1F7F62D3F9
              0AB4643203589E9C469F9926B8BF8AF947DD94B5849072246A5A43E040913F9F
              BC75394C3DEE2658BB9BD4F07BE2E3B35915A83AFAA719766CCDE7C3403F43C8
              6C6D6EC65FE8C391C0B660E8FA359203BD546EF7A34E4C60A49C2C8066602514
              B4D94F98F12596150DDB721043DC84CC4A3A168FA14FA75CA085A17D05885B30
              D280548AE8FB39947D8D048E3661D936DE5C99BC5C8FB0BF3BD684527B88D1D1
              18B6AAE22E9A5D8186954C105B50680C87503D3EF2BDEE9E6FFD0940F9F11380
              8FFA700BBD4FEEB2A94842D73D990A74DDC45C49B2A37A336FDB4E5122AB8C5F
              6FE7CBBDDB7C763571A39D328FCEBB702BDF6F2FC352750C4DCFBC0343750189
              243E3381131BE369DD018A4BD71328CE136730D7D3CDD3CEBFD8B2A518AF99C0
              4C030CFEDF82EBE802602C2CE22DC8676F7500633981E2DE0C1694FAFD6C2C29
              419D8FA12515B06C4C43461080822B6595CF7D927410475A3DF9ACA6B0859FDD
              50C2566C7BF0ECD258A3E846200FF066B5AAB4462B3B800628FF0122CC6063F4
              5F96130000000049454E44AE426082}
            Kind = bkGlyph
          end>
        Properties.OnButtonClick = editAltResimDosyaPropertiesButtonClick
        TabOrder = 4
        Width = 221
      end
      object Label6: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 267
        Width = 114
        Height = 84
        Align = alClient
        AutoSize = False
        Caption = 'Geni'#351'lik 770px Y'#252'kseklik 58px'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        Visible = False
        WordWrap = True
        StyleElements = [seClient, seBorder]
        ExplicitLeft = 28
        ExplicitTop = 298
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
      object ImageAltResim: TcxDBImage
        AlignWithMargins = True
        Left = 123
        Top = 267
        Align = alLeft
        DataBinding.DataField = 'ALT_ANTET_RESIM_IMAGE'
        DataBinding.DataSource = dsEvrak
        Properties.GraphicClassName = 'TdxSmartImage'
        TabOrder = 5
        OnDblClick = ImageAltResimDblClick
        Height = 84
        Width = 221
      end
      object Label4: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 149
        Width = 114
        Height = 84
        Align = alClient
        AutoSize = False
        Caption = 'Geni'#351'lik 770px Y'#252'kseklik 180px'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        Visible = False
        WordWrap = True
        StyleElements = [seClient, seBorder]
        ExplicitLeft = 28
        ExplicitTop = 298
        ExplicitWidth = 65
        ExplicitHeight = 17
      end
    end
  end
  inherited qryEvrak: TFDQuery
    SQL.Strings = (
      'SELECT * FROM EVRAK_ANTET')
  end
  inherited dsEvrak: TDataSource
    Left = 195
  end
  object qryLookupBirimKodu: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT ID,*'
      'FROM EVRAK_BIRIMI'
      'Order by BIRIM_KODU')
    Left = 88
    Top = 200
  end
  object dsBirimKodu: TDataSource
    AutoEdit = False
    DataSet = qryLookupBirimKodu
    Left = 80
    Top = 272
  end
  object OpenDialog1: TOpenDialog
    Left = 104
    Top = 88
  end
end



