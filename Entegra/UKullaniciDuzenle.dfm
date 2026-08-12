object KullaniciDuzenleDlg: TKullaniciDuzenleDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Kullan'#305'c'#305' Ayarlar'#305
  ClientHeight = 360
  ClientWidth = 308
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object btnKaydet: TcxButton
    Left = 147
    Top = 323
    Width = 75
    Height = 25
    Caption = 'Tamam'
    ModalResult = 1
    TabOrder = 3
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    OnClick = btnKaydetClick
  end
  object btnIptal: TcxButton
    Left = 230
    Top = 323
    Width = 75
    Height = 25
    Caption = #304'ptal'
    ModalResult = 2
    TabOrder = 6
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    OnClick = btnIptalClick
  end
  object cxLabel3: TcxLabel
    Left = 6
    Top = 254
    Caption = #350'ifre'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel4: TcxLabel
    Left = 6
    Top = 281
    Caption = #350'ifre(Tekrar)'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditSifre2: TcxTextEdit
    Left = 101
    Top = 280
    ParentFont = False
    Properties.EchoMode = eemPassword
    Properties.IncrementalSearch = False
    Properties.PasswordChar = '*'
    Properties.ReadOnly = False
    Properties.OnChange = cxTextEdit1PropertiesChange
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 2
    Width = 121
  end
  object EditSifre1: TcxTextEdit
    Left = 101
    Top = 253
    ParentFont = False
    Properties.EchoMode = eemPassword
    Properties.PasswordChar = '*'
    Properties.OnChange = cxTextEdit1PropertiesChange
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 1
    Width = 121
  end
  object cxImage1: TcxImage
    Left = 229
    Top = 247
    Picture.Data = {
      0954474946496D6167654749463839613B003600F70000000000FFFFFFFFF7FF
      FFFAFFFFFDFFFCFBFEF5F4FCFEFEFFF8FBFFFBFFFFFCFFFFF7FFFCEFFFF5F8FF
      FAFCFEFCE6F7E4F6FEF5D2F1C7DBFAD034960A399D0D44AA18A3D98BC4E1B737
      9B073E9E1144A715429B1546A21B4EA62456AC2EB1E499ABD896E2F4D9369B02
      3596033A9A053CA0073C960B44AC0D3D9B0C44AA1054A62A5EAC3389C768CDE5
      C03998013A9D023998033FA7043C9A043A98043E9B053C98053F9C063C9A0640
      9D07419E083F9A0842A50A41A00A46A30E40960E48A6104CAF1449A3154CAA16
      4FAD194EA51C54A4235CB328549D2759A72B68B63970BB4598CE79B6DAA1F2FC
      EC3E9D003C9A0040A301409E0143A804409F043D950443A2053F9C0546A50645
      A306429F063E98064CB40845A10747A60946A20B52B90E469E0C60AD2C63AB34
      C0E4A9449F0147A60449A5064AA509469B084CAA0B4DA40D59B2185BAC2373C4
      3747A00041970048A3014AA8024FAA05499E054CA7064AA20653AC0B4B9E0C5F
      B81758AA1666BB226EC4295EA5257DC644B3DC94D3EAC14DA30257B80351A604
      55B10553AE065CB90956B10A5AB60B52A60B65A729ABEA755DBA025CB3065FBE
      0862BC0D5AA5106BC31458AB0163BC0465C105509C0462BA0968C40B6BC40D66
      C00C6DC60E69C00E60B10E68BA116EBA1B5C9C1794D2557BA94BA5C683DDEDCD
      6BC4036ECC066AC1096FC90A6DC60A6DC10B70C30C71C60D69B70C6EC21073CA
      1361A415699E2AACE26E70C4046BBF0560AB055EA60670C50872C30977CA0A73
      C80A77C70D76CA0E78C8107CD1127BCB1275C31279C715A8E05FA6D46DB5E37B
      66B10075C9047FD4067ACD0676C70974C3097ACB0B86D90E7ECE0D7CCC0D79CA
      0D75C30D84D81282CF1283D0197DC51B7CCA047ECE0986D30A82D10A83D40B87
      D40C84D20C85D10C83D10C86D20D7FCA0C85D30E81CE0D84D00E87D40F89D610
      8CDA1286D3128BD41691DA1D8AD0239BD938A4DC50B4E46B84D30489D60787D4
      0989D20A8BD80C88D20D8AD30F8DD6118DD80289D3058DD1098ED60B8BCF1094
      D02291D40BFCFEF5FEFFF9F4F4F1FFFFFDFDFAF9FFFFFF21F904010000FF002C
      000000003B00360087000000FFFFFFFFF7FFFFFAFFFFFDFFFCFBFEF5F4FCFEFE
      FFF8FBFFFBFFFFFCFFFFF7FFFCEFFFF5F8FFFAFCFEFCE6F7E4F6FEF5D2F1C7DB
      FAD034960A399D0D44AA18A3D98BC4E1B7379B073E9E1144A715429B1546A21B
      4EA62456AC2EB1E499ABD896E2F4D9369B023596033A9A053CA0073C960B44AC
      0D3D9B0C44AA1054A62A5EAC3389C768CDE5C03998013A9D023998033FA7043C
      9A043A98043E9B053C98053F9C063C9A06409D07419E083F9A0842A50A41A00A
      46A30E40960E48A6104CAF1449A3154CAA164FAD194EA51C54A4235CB328549D
      2759A72B68B63970BB4598CE79B6DAA1F2FCEC3E9D003C9A0040A301409E0143
      A804409F043D950443A2053F9C0546A50645A306429F063E98064CB40845A107
      47A60946A20B52B90E469E0C60AD2C63AB34C0E4A9449F0147A60449A5064AA5
      09469B084CAA0B4DA40D59B2185BAC2373C43747A00041970048A3014AA8024F
      AA05499E054CA7064AA20653AC0B4B9E0C5FB81758AA1666BB226EC4295EA525
      7DC644B3DC94D3EAC14DA30257B80351A60455B10553AE065CB90956B10A5AB6
      0B52A60B65A729ABEA755DBA025CB3065FBE0862BC0D5AA5106BC31458AB0163
      BC0465C105509C0462BA0968C40B6BC40D66C00C6DC60E69C00E60B10E68BA11
      6EBA1B5C9C1794D2557BA94BA5C683DDEDCD6BC4036ECC066AC1096FC90A6DC6
      0A6DC10B70C30C71C60D69B70C6EC21073CA1361A415699E2AACE26E70C4046B
      BF0560AB055EA60670C50872C30977CA0A73C80A77C70D76CA0E78C8107CD112
      7BCB1275C31279C715A8E05FA6D46DB5E37B66B10075C9047FD4067ACD0676C7
      0974C3097ACB0B86D90E7ECE0D7CCC0D79CA0D75C30D84D81282CF1283D0197D
      C51B7CCA047ECE0986D30A82D10A83D40B87D40C84D20C85D10C83D10C86D20D
      7FCA0C85D30E81CE0D84D00E87D40F89D6108CDA1286D3128BD41691DA1D8AD0
      239BD938A4DC50B4E46B84D30489D60787D40989D20A8BD80C88D20D8AD30F8D
      D6118DD80289D3058DD1098ED60B8BCF1094D02291D40BFCFEF5FEFFF9F4F4F1
      FFFFFDFDFAF9FFFFFF08FF00FF091C48B0A0C18308132A5CC8B0A1C38710234A
      9C48B1A2C58B18274208F1E7021326114240389091E2BE1016DA0811A247CF9E
      366CD60849624194BE920E0B8C49B2A6CD2760B0820655070CD8A7365F8C8060
      8053E185247A3EC112469568BA7445D5510D7A74C805084D0B3258A2A7CF5475
      E9CC958B172F5C386ED5B4713B870E68B04F7A943C082BF081923EC08401C3E7
      4E9C3CB66DB971CBB60CDAB76EDDCEA58315AC8F110961258469034B1DBE7AF2
      B8D183E7CEDD5B6DDBB6152BB66C19B35CBB7EA50BD606480B9C0FD8F411864E
      DCBB77ECDC952B8D2DEEB66FDF78513396EC572B5CC47C9D13D60748848CFC92
      F45187EE5E3165DCDCBDFF5BD7AE1D36D4DF5AF7EAC52CD92D5CAA54C52A25AD
      3291101859B451848FDE3C76E490C30E3BE554530D37C7B5B60C35CC34730C31
      C7E082CA28A84CC20A6D498055D11F78A8338E3DE1D0634F39D13C23CE3DDAA0
      A76083C918434C2CB5A4920A2AA53822892C9F28B18445627C62CE3DCA3C1322
      68E458330F3848A6B78C7BBAE0524B7CA994520A269CC82249239D7C32043F14
      7DB0073AF994530F5BE214D78E35D6ACD34D34C924D3CC2EB7E4E24C33A3A462
      8B2C9A48E288238D2C52881E3E51A4C427E594B38E3CF0B4854D38DE7C030E35
      D0F4428C31B734430C31B894A28A249634524A257B16B2082378B451C45E11FD
      61043ECF5CE30E3DE188FF135738C845AA0B33D44C834C2EC7F802C924AEBCB2
      49238E5452C92187141288216B18E187444BEC310D2FC594D34EACD964B30D35
      8FF172CB32C720F38B2FAAB082C923A134010A238B485208B2870C12071C6B28
      215112AD74630C29DF50D31A9AD450638D8B2E1EB38B2AA39C32CA2CA1E8B38F
      BAC3F879881D72C45106165308C114441510D38B31AD3473CB2DC7904C4C9BC9
      B4178B2EB58C428C2CB4844200011028000128830C22071D57605105173BA471
      DB43A26C714B2FB5F0628B294ED6220B2AA854C28A2CB294A2C924B1ACE24A28
      01085040020E2CE047C57060C18517394C51821A2040744120A4FCA28B29BA90
      62CA299994020927826CFF8209A88754B289274B24B04F00FA1030801F88A871
      C61975709143166ADFB1E3434C7C11E731A3E092892DF341B2C82B0FAC8B87B2
      8C78128A0301F8D38F0209F821C81966F49C450E39E06003184EB00011135B10
      B34B2CA6D492C925AC8CD2C82BFC30A00F28B3041208BA1010E0CF3E0310C0B8
      1A8060E1F3EDBAD3A0C314BE631E3CCBA6C47289267F2762C03E33AB1B09BAF0
      2B00BFF6765C51761559806F030D32700114CAE790CC91223EA5B04529A63689
      3F286000FD80C000D4150A0510401F0B4880F604810533F4A07F59C081156800
      401288A0049773C81FB6608A4BA80213A99884953AE18B101C601F1AECC7F502
      50007D1C207676C0421DFFBC50823BE0EE7F34B8010948F082123001224DF8C1
      292E810A4C5448138D08C49E2450800134007E880B80E218770533F0400A6440
      43EE92A8C425C28007437B481234A109ABC962129568C4E9FE248A7EEC03010E
      73400499A08620B8A1072F20C31C4A80031DB491043398010A8820914F700213
      53BA92248E352A43ECC10103084002BA58003FA8A10775A8C214EE80861250C0
      91908CE40C6010842448E4026B9804277469AC4230E2108C20444F20E08099E9
      C30F77880117F8973B1B3852076F100106A8A00513E820066D938811F620896E
      9E0E5E8C18841DF29084071C8E097748C31CF83785F029910A14A08209448002
      1110210898918805F000FF095F26EB1086300421062A07442442024CA0441AA6
      4006CA89B0849274810FB420820904E1070494481EF68087430422670125841C
      460A8721E4410D737083176290BB11CA209623F0C108A4998323A4E03A146142
      4F0A3188700ED40E69A0431CBA10072878A10B53B04114C2F7D258CA60024F10
      8109D8A0868C4AE47978E8C41A422A8734A4E10C69280314BAD0031444810C60
      F85F5363E90219A0C0076CE8811830F28044002A0F7610291D1E678639A0CD09
      6000C3134C70831AC8529612CD00128840C98CFC210D4668431E0421083AD4C1
      0C7080031A02EB8417A080063580240C601049186881032B1082137132863C6C
      C60877304315BC70872AD444210A56B0820C94F8062D5001064F78820B508084
      30046103D9C449048C50842424C1086A88420873C0031CC820B84FC080343130
      810DA860051EA8401EC6C017812801086B1043125630841FA0C00426F0017CE7
      09830D14210C614002123810069C96F71F206003108CB0022388410C61600363
      3BE081441C78056240421052B08426FCB7204B10C219F8C007FCAE0009071683
      07C02B04A3B2209F1736C818FA30040D64A0021A10420FBCA006289C40094C40
      558A15220A268060092C5882054010C71D1BF9C8484EB29297CCE42697242000
      3B}
    Properties.FitMode = ifmProportionalStretch
    Style.BorderStyle = ebsNone
    Style.Shadow = False
    Style.TransparentBorder = False
    TabOrder = 0
    Transparent = True
    Visible = False
    Height = 54
    Width = 61
  end
  object cxLabel7: TcxLabel
    Left = 6
    Top = 150
    Caption = 'G'#252'venlik Sorusu'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel8: TcxLabel
    Left = 6
    Top = 179
    Caption = 'Cevap'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditCevap: TcxTextEdit
    Left = 101
    Top = 178
    ParentFont = False
    Properties.EchoMode = eemPassword
    Properties.PasswordChar = '*'
    Properties.OnChange = cxTextEdit1PropertiesChange
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    TabOrder = 9
    Width = 204
  end
  object cxLabel10: TcxLabel
    Left = 6
    Top = 207
    Caption = 'G'#246'r'#252'n'#252'm'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object ComboSkin: TcxDBImageComboBox
    Left = 101
    Top = 205
    DataBinding.DataSource = DtsKullanici1
    ParentFont = False
    Properties.DropDownRows = 16
    Properties.Items = <
      item
        Description = 'Mevcut g'#246'r'#252'n'#252'm'
        Value = Null
      end
      item
        Description = 'Blue'
        Value = 'Blue'
      end
      item
        Description = 'Blueprint'
        Value = 'Blueprint'
      end
      item
        Description = 'DevExpress Style'
        Value = 'DevExpressStyle'
      end
      item
        Description = 'DevExpress Dark Style'
        Value = 'DevExpressDarkStyle'
      end
      item
        Description = 'High Contrast'
        Value = 'HighContrast'
      end
      item
        Description = 'Metropolis'
        Value = 'Metropolis'
      end
      item
        Description = 'Metropolis Dark'
        Value = 'MetropolisDark'
      end
      item
        Description = 'Office 2010 Black'
        Value = 'Office2010Black'
      end
      item
        Description = 'Office 2010 Blue'
        Value = 'Office2010Blue'
      end
      item
        Description = 'Office 2010 Silver'
        Value = 'Office2010Silver'
      end
      item
        Description = 'Office 2013 Dark Gray'
        Value = 'Office2013DarkGray'
      end
      item
        Description = 'Office 2013 Light Gray'
        Value = 'Office2013LightGray'
      end
      item
        Description = 'Office 2013 White'
        Value = 'Office2013White'
      end
      item
        Description = 'Office 2016 Colorful'
        Value = 'Office2016Colorful'
      end
      item
        Description = 'Office 2016 Dark'
        Value = 'Office2016Dark'
      end
      item
        Description = 'Visual Studio 2013 Blue'
        Value = 'VisualStudio2013Blue'
      end
      item
        Description = 'Visual Studio 2013 Dark'
        Value = 'VisualStudio2013Dark'
      end
      item
        Description = 'Visual Studio 2013 Light'
        Value = 'VisualStudio2013Light'
      end
      item
        Description = 'VS 2010'
        Value = 'VS2010'
      end>
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 12
    Width = 204
  end
  object Panel1: TPanel
    Left = 3
    Top = 2
    Width = 307
    Height = 121
    TabOrder = 10
    object cxDBTextEdit2: TcxDBTextEdit
      Left = 100
      Top = 35
      DataBinding.DataField = 'KOD'
      DataBinding.DataSource = DtsKullanici1
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 0
      Width = 121
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 9
      Caption = 'Kullan'#305'c'#305' Ad'#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 5
      Top = 36
      Caption = 'Kullan'#305'c'#305' Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel6: TcxLabel
      Left = 5
      Top = 91
      Caption = 'Kullan'#305'c'#305' Durumu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ComboRol: TcxDBImageComboBox
      Left = 100
      Top = 62
      DataBinding.DataField = 'ROLID'
      DataBinding.DataSource = DtsKullanici1
      Enabled = False
      ParentFont = False
      Properties.Items = <>
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 4
      Visible = False
      Width = 121
    end
    object ComboDurum: TcxDBImageComboBox
      Left = 100
      Top = 89
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsKullanici1
      ParentFont = False
      Properties.Items = <
        item
          Description = 'Pasif'
          ImageIndex = 0
          Value = False
        end
        item
          Description = 'Aktif'
          ImageIndex = 0
          Tag = 1
          Value = True
        end>
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 5
      Width = 121
    end
    object BEditRehber: TcxTextEdit
      Left = 100
      Top = 8
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      Width = 205
    end
    object cxLabel5: TcxLabel
      Left = 5
      Top = 64
      Caption = 'Rol'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object LabelREHBERID: TcxDBLabel
      Left = 259
      Top = 37
      DataBinding.DataField = 'REHBERID'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Transparent = True
      Height = 19
      Width = 38
    end
    object cxLabel9: TcxLabel
      Left = 243
      Top = 37
      Caption = 'ID'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
  end
  object ComboSoru: TcxImageComboBox
    Left = 101
    Top = 148
    ParentFont = False
    Properties.Items = <>
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 11
    Width = 204
  end
  object TabKullanici1: TFDQuery
    BeforeEdit = TabKullanici1BeforeEdit
    BeforePost = TabKullanici1BeforePost
    AfterPost = TabKullanici1AfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from KULLANICI '
      'where ID = :Prm1')
    Left = 60
    Top = 91
  end
  object DtsKullanici1: TDataSource
    DataSet = TabKullanici1
    Left = 247
    Top = 328
  end
end
