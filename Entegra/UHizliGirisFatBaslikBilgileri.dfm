object HizliGirisFatBaslikBilgileriDlg: THizliGirisFatBaslikBilgileriDlg
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Fatura Bilgileri'
  ClientHeight = 277
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object PanelHizliGirisFatDetay: TPanel
    Left = 0
    Top = 0
    Width = 419
    Height = 277
    Align = alClient
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 0
    object Panel2: TPanel
      Left = 2
      Top = 227
      Width = 411
      Height = 44
      Align = alBottom
      TabOrder = 14
      object BtnTamam: TJvNavPanelButton
        Left = 1
        Top = 1
        Width = 189
        Height = 42
        Align = alLeft
        AllowAllUp = True
        Caption = 'Ekle'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        WordWrap = True
        Colors.ButtonColorFrom = 15395562
        Colors.ButtonColorTo = 12566463
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnTamamClick
        ExplicitLeft = 3
        ExplicitTop = 31
        ExplicitHeight = 40
      end
      object BtnIptal: TJvNavPanelButton
        Left = 190
        Top = 1
        Width = 177
        Height = 42
        Align = alLeft
        AllowAllUp = True
        Caption = #304'ptal'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        GroupIndex = 2
        HotTrack = False
        HotTrackFont.Charset = TURKISH_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = -13
        HotTrackFont.Name = 'Trebuchet MS'
        HotTrackFont.Style = [fsBold]
        ParentFont = False
        WordWrap = True
        Colors.ButtonColorFrom = 15395562
        Colors.ButtonColorTo = 12566463
        Colors.ButtonHotColorFrom = 14256961
        Colors.ButtonHotColorTo = 11694645
        Colors.ButtonSelectedColorFrom = 14256961
        Colors.ButtonSelectedColorTo = 11694645
        ParentStyleManager = False
        ImageIndex = 1
        OnClick = BtnIptalClick
        ExplicitLeft = 192
        ExplicitTop = 31
        ExplicitHeight = 40
      end
      object JvNavPanelButton1: TJvNavPanelButton
        Left = 367
        Top = 1
        Width = 43
        Height = 42
        Align = alLeft
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        ImageIndex = 0
        Images = PngImageList1
        OnClick = JvNavPanelButton1Click
        ExplicitLeft = 369
        ExplicitTop = 31
        ExplicitHeight = 40
      end
    end
    object Label22: TcxLabel
      Left = 5
      Top = 23
      Caption = 'Ba'#351'l'#305'k'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label24: TcxLabel
      Left = 5
      Top = 48
      Caption = 'Adres'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label2: TcxLabel
      Left = 5
      Top = 84
      Caption = #304'l'#231'e'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label25: TcxLabel
      Left = 5
      Top = 109
      Caption = 'VD'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label3: TcxLabel
      Left = 193
      Top = 84
      Caption = #304'l'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label26: TcxLabel
      Left = 193
      Top = 109
      Caption = 'V/TC No'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditBASLIK: TcxTextEdit
      Left = 65
      Top = 23
      TabOrder = 0
      Width = 320
    end
    object MemoFatAdres: TcxMemo
      Left = 65
      Top = 48
      TabOrder = 1
      Height = 31
      Width = 320
    end
    object EditILCE: TcxTextEdit
      Left = 65
      Top = 84
      TabOrder = 2
      Width = 124
    end
    object EditVD: TcxTextEdit
      Left = 65
      Top = 109
      TabOrder = 4
      Width = 124
    end
    object EditVNo: TcxTextEdit
      Left = 255
      Top = 109
      TabOrder = 5
      Width = 131
    end
    object EditIl: TcxTextEdit
      Left = 255
      Top = 84
      TabOrder = 3
      Width = 130
    end
    object MemoAciklama: TcxMemo
      Left = 65
      Top = 134
      TabOrder = 8
      Height = 31
      Width = 321
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 134
      Caption = 'A'#231#305'klama'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
  end
  object PngImageList1: TPngImageList
    Height = 32
    Width = 32
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7A
          F40000002B744558744372656174696F6E2054696D650046722031392044657A
          20323030332030313A34333A3439202B303130300F84E1980000000774494D45
          07D30304141E0FCF6D0044000000097048597300000AF000000AF00142AC3498
          0000040E4944415478DAED555B48945B14FE66BC8F97C91B5ED1073507AFA809
          6A7292408530321053A2277B107A117B8AE0BC1C14C287C48781C6071FE418C3
          F1213D909092E22DC50B188A17C49752F13666DE6746A76F6D9AA848B20E725E
          66C366EF7FCFDEEBFBD65ADF5AA3C1FF3C342E022E022E021760531B1919A95B
          5959B1717F7CA104E2E2E22E71B9A2D168AE9C9E9E66D8EDF6CB0E87238EDF3A
          9BCDC64FFB28CF9FBBB9B9FDBDBEBEBEFB9F09646767071E1C1C5CE3F6FAC9C9
          C91F349EECEDEDEDEEE5E5051F1F1F787A7A8267E01DF05CED171616707C7CFC
          81C44C24F6647B7BDBF22B04B4696969197C7C93F3060D64FAF9F9B9E9743A08
          A8AC898989D0EBF5E8EEEEC6FEFE3E92939351535383A4A42465A0A5A5058D8D
          8D6004849885761EEFEEEE3EE34F8EB30868683487EB5DCEDBFEFEFE11212121
          9A808000051A111181D4D45444474783DE60646404CC3732333311161606A3D1
          08777777D4D6D6A2B0B0101E1E1E2A220D0D0D686F6FC7C6C686E3F0F0F01F9E
          DDA37DEBD704BCE2E3E3EF335C0F8283830DB1B1B11A31181818A8BC6124E0EB
          EB8B999919F4F6F682D150A0797979080F0F97308339075383D6D656984C2618
          0C0694959561707010E3E3E38A88DCD9DADA92F54F12F94B11A06A43189AD70C
          5FAA184D494911818124C04B181D1DC5C4C484F29E3A404E4E8E8AC6D1D1919A
          56AB5519969C6BB55A95FFC9C949D4D5D561696949919573F97D6F6F0F14A8BC
          E922E91B8A40686868735555D57D015D5E5E86845B1EADADAD21212101595959
          484F4F576122D12FDE3A416550E9585C5C445F5F1F3A3B3B951DB92B53EE38C9
          4A8438ED9CB748E2A522C03C2FF4F4F424C8A3E1E161F54848949494A8300B63
          01730EF95D08CA14710D0D0DA1A3A303535353C8CDCD45545414BABABA60B158
          D45B67E88508DFBEE3BE9A4EBCFC2242AAF8457D7DFDAD828202CCCDCD616C6C
          0C54AA7A24822B2F2F578454593094124601EBEFEFC7C0C0005819A8A8A84051
          51918A4073733366676755FA243DE235C13F723E2599069AD9FFA60C2922A999
          374D4D4D01313131D8DCDCC4F4F4B4CA9F1810F0D2D2520524B9154189F2A50A
          8A8B8B515D5D8DB6B63698CD66157AF154C88BF7DC4B0F30325A4F77767636CF
          6C442CB50C3E78CED249ACACAC5467ABABAB989F9F5784A4C9C8601939F3A800
          9C5ECA2AC0B27ECEF57B8236310D263EDB39ABD17CDF077C28C84734544B22BE
          F9F9F90A44BC15CFC4B8537C4EE58B20E59CDE49AE1D041E22B091A4DB69CFF6
          B3EEFAC34EC86844727948225554BF5E2A415AADD4AFE45F800554BE250DD2E1
          086C26F0339E4D9DA3AB9FAF15070505E9D9D52A0878871DED2AC5EA29CA17AF
          4944FE5C5E719AE9EDBF5C8F7E05F85C04BE1B3A764603531244521F587E6F79
          66FD1DD0DF257021C345C045C045C045E013435D743F3694734E000000004945
          4E44AE426082}
        Name = 'PngImage0'
        Background = clWindow
      end>
    Left = 378
    Top = 170
    Bitmap = {}
  end
end
