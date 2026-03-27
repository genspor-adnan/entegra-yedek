object TakvimGelenFaturaDlg: TTakvimGelenFaturaDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Gelen Fatura Bilgileri'
  ClientHeight = 545
  ClientWidth = 588
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 18
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 582
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 69
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = AnaForm.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object KaydetTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 69
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      OnClick = IptalTusClick
    end
    object SilTus: TToolButton
      Left = 138
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton2: TToolButton
      Left = 207
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object BelgeTus: TToolButton
      Left = 215
      Top = 0
      Caption = 'Belge'
      ImageIndex = 28
      OnClick = BelgeTusClick
    end
    object ToolButton1: TToolButton
      Left = 284
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object btnIptal: TToolButton
      Left = 292
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnIptalClick
    end
  end
  object ToolBarAlt: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 523
    Width = 582
    Height = 22
    Margins.Bottom = 0
    Align = alBottom
    AutoSize = True
    ButtonHeight = 20
    ButtonWidth = 66
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object NakitTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Nakit'
      ImageIndex = 8
    end
    object HavaleTus: TToolButton
      Left = 66
      Top = 0
      Caption = 'Havale/EFT'
      ImageIndex = 10
      Style = tbsTextButton
    end
    object CekTus: TToolButton
      Left = 132
      Top = 0
      Caption = #199'ek'
      ImageIndex = 18
      Style = tbsTextButton
    end
    object SenetTus: TToolButton
      Left = 198
      Top = 0
      Caption = 'Senet'
      ImageIndex = 19
    end
  end
  object GridPlan: TcxGrid
    Left = 0
    Top = 406
    Width = 588
    Height = 114
    Align = alBottom
    TabOrder = 2
    Visible = False
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    object GridPlanView: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnTab = True
      OptionsSelection.HideSelection = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
    end
    object GridPlanLevel1: TcxGridLevel
      GridView = GridPlanView
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 35
    Width = 588
    Height = 371
    Align = alClient
    TabOrder = 3
    object pnl1: TPanel
      Left = 1
      Top = 1
      Width = 586
      Height = 369
      Align = alClient
      ParentBackground = False
      TabOrder = 0
      DesignSize = (
        586
        369)
      object imgMALIYE: TImage
        Left = 262
        Top = 19
        Width = 59
        Height = 58
        Anchors = [akTop]
        Picture.Data = {
          0954474946496D6167654749463839613A003C00F70000000000FFFFFFFEFEFE
          FDFDFDFCFCFCFBFBFBFAFAFAF9F9F9F8F8F8F7F7F7F6F6F6F5F5F5F4F4F4F3F3
          F3F2F2F2F1F1F1F0F0F0EFEFEFEEEEEEEDEDEDECECECEAEAEAE9E9E9E8E8E8E7
          E7E7E5E5E5E4E4E4E3E3E3E2E2E2E1E1E1E0E0E0DFDFDFDEDEDEDDDDDDDCDCDC
          DBDBDBDADADAD9D9D9D7D7D7D4D4D4D3D3D3D2D2D2D1D1D1D0D0D0CFCFCFCECE
          CECDCDCDCCCCCCCBCBCBCACACAC9C9C9C7C7C7C5C5C5C4C4C4C3C3C3C2C2C2C1
          C1C1C0C0C0BFBFBFBEBEBEBDBDBDBCBCBCBBBBBBBABABAB9B9B9B8B8B8B4B4B4
          B3B3B3B2B2B2B1B1B1B0B0B0AFAFAFAEAEAEADADADACACACABABABAAAAAAA7A7
          A7A5A5A5A3A3A3A2A2A2A1A1A1A0A0A09F9F9F9E9E9E9D9D9D9C9C9C9B9B9B9A
          9A9A9999999494949393939292929191919090908F8F8F8E8E8E8D8D8D8C8C8C
          8B8B8B8686868585858484848383838282828181818080807F7F7F7E7E7E7D7D
          7D7C7C7C7B7B7B7A7A7A7979797575757373737272727171717070706F6F6F6E
          6E6E6D6D6D6C6C6C6B6B6B696969666666656565646464636363626262616161
          6060605F5F5F5E5E5E5D5D5D5C5C5C5B5B5B5A5A5A5555555454545353535252
          525151515050504F4F4F4E4E4E4C4C4C4B4B4B49494948484846464645454544
          44444343434242424141414040403F3F3F3E3E3E3D3D3D3C3C3C3B3B3B3A3A3A
          3737373636363434343333333232323131313030302F2F2F2E2E2E2D2D2D2C2C
          2C2B2B2B2A2A2A2828282525252323232222222121212020201F1F1F1E1E1E1D
          1D1D1C1C1C1A1A1A191919171717151515141414131313121212111111101010
          0F0F0F0E0E0E0D0D0D0C0C0C0B0B0B0A0A0A0909090707070606060505050404
          04030303020202010101FFFFFF00000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000021F904010000D1002C
          000000003A003C0087000000FFFFFFFEFEFEFDFDFDFCFCFCFBFBFBFAFAFAF9F9
          F9F8F8F8F7F7F7F6F6F6F5F5F5F4F4F4F3F3F3F2F2F2F1F1F1F0F0F0EFEFEFEE
          EEEEEDEDEDECECECEAEAEAE9E9E9E8E8E8E7E7E7E5E5E5E4E4E4E3E3E3E2E2E2
          E1E1E1E0E0E0DFDFDFDEDEDEDDDDDDDCDCDCDBDBDBDADADAD9D9D9D7D7D7D4D4
          D4D3D3D3D2D2D2D1D1D1D0D0D0CFCFCFCECECECDCDCDCCCCCCCBCBCBCACACAC9
          C9C9C7C7C7C5C5C5C4C4C4C3C3C3C2C2C2C1C1C1C0C0C0BFBFBFBEBEBEBDBDBD
          BCBCBCBBBBBBBABABAB9B9B9B8B8B8B4B4B4B3B3B3B2B2B2B1B1B1B0B0B0AFAF
          AFAEAEAEADADADACACACABABABAAAAAAA7A7A7A5A5A5A3A3A3A2A2A2A1A1A1A0
          A0A09F9F9F9E9E9E9D9D9D9C9C9C9B9B9B9A9A9A999999949494939393929292
          9191919090908F8F8F8E8E8E8D8D8D8C8C8C8B8B8B8686868585858484848383
          838282828181818080807F7F7F7E7E7E7D7D7D7C7C7C7B7B7B7A7A7A79797975
          75757373737272727171717070706F6F6F6E6E6E6D6D6D6C6C6C6B6B6B696969
          6666666565656464646363636262626161616060605F5F5F5E5E5E5D5D5D5C5C
          5C5B5B5B5A5A5A5555555454545353535252525151515050504F4F4F4E4E4E4C
          4C4C4B4B4B494949484848464646454545444444434343424242414141404040
          3F3F3F3E3E3E3D3D3D3C3C3C3B3B3B3A3A3A3737373636363434343333333232
          323131313030302F2F2F2E2E2E2D2D2D2C2C2C2B2B2B2A2A2A28282825252523
          23232222222121212020201F1F1F1E1E1E1D1D1D1C1C1C1A1A1A191919171717
          1515151414141313131212121111111010100F0F0F0E0E0E0D0D0D0C0C0C0B0B
          0B0A0A0A090909070707060606050505040404030303020202010101FFFFFF00
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000008FF00A3091C48B0A0C18308132A5CC850C5174CC66689
          FA83A6CD1A35752CE502A0294F8E0003188A64380BD71D220F0C802420804081
          00024C6CA8612795B1391F028CDC491040A11B0260820CA0324001020402740A
          436040800E77846DD2A193A7C2086400E42111004180AF08160408A5C32B4C01
          9C387C1DE014C29963843E5845982317A40E4E19701004A340D00399D87C55E9
          018007021F6C05405A00C29D5D630ACC25F8E65791A15E7100E8F5C068004F68
          908214222CE900003B16AF7D610BD284C9111CA5DA10D4A900013936997205E1
          6BA6354205ACD9E434002E1B038CD8A2F27242A054731DB082D4F94198B3036C
          70A220EB5180039BD208FF28FE88CE4B019DD20C8296E6AB5036C2784A701588
          E80044CDD00CDD512BD03300878CE5465047C922856A730060CA0A2C05D0C012
          304181CC48057CE2C7000704900014000040054C351493460844406385221D02
          D08C00A87996CB1F03A844C003AA3C6385514DD0C25000749442C14B0904650B
          271E06C08326490990440A25AC150005517C258012CAE4A4D205AEB4D205341F
          1E3048290B19518C0501E8808B190D0CD085271C1A714327439D55C051026468
          40505F081294001790E20C0E044401409405ACC247420F0C03044C5338038030
          6A50208C0E680443426F193E70C4199164C28923684891C1789E09F04029AD80
          710C0A03447148521FFCFFD2C3410114328700066428050081D4624B2A7E1CA0
          C2604F4402407A6EF2A0431B8F10938A160F6418C020C444108014C3A8105452
          015021CB413810D3D9B602EC9AC314B21803130138D0720B1412DCE6997B030C
          D18930532C06412A83B4F40411EE25550027601414C0266BDC16144C05E0E10B
          0C021CC623325010E5DEC55F3515400FA97092E6BE8448B956014EE5101F412E
          0CD380672F1D1054218A0520012AB03080F1CD4E2190E421B5AC10C003ABA4E1
          17AE7BDE66C915041D62C6002F0DE01258067060C000ACD4F7D29D37673CD44B
          0154310C08052C20814AE72559400E3A0A8401001D34B5F0013A3B956121970C
          505B4B59430D135B01DCFFB10A03A669681452491D60CB40594432940047C968
          940149D412415245E53D1876DC6AB2476D08D4D9959374E021501F53DCC9B753
          7EA914C12F37B8E7178679E7BCB06716088302B797E3AA520C8747634C084611
          58AA4A6B7C729BDD30559EB553480DE095536C40A27552CD0BF56D34B9946AF7
          B619DB82C3EC45298FB1D37B0B150004C278B0567149DE294913D178D76071B3
          A7504BC6CC3BB5FD4B5C7760030F0CC01BF29C32882D9C256F6B40C34516361E
          EEB1050EB74A0A1B00E0286840A3199FF84A0122108814F9020BA5F28C113E41
          BEBCE5E01368E0C2789067B103384513451058077EC083423C63073A78C150EC
          F08C2E14C00187300CAEFF3C8380093CE33C79B341253C4103D70D2501C9C345
          4E60E21502A001004229408600A007F740A013071A0FC9BE020C9215E7660838
          C62676E042BF88EC25048046D1BE938033004077DFE9010000C596A30CE62F2F
          E9840D2CF7956470822A02338A6D547247CF204F0DCF705299984195E01C2043
          B08B51277630C6BC1DEB062E4B92504C038DC5908B00135C5C0154008020B0E4
          2869C0415758D2A04CE890900070C447F674160350EF132BE0DE57D4E08C8039
          E5171984C90D002005247A2692847C002DD4D00629E98F6F4171441518F79700
          A4720028E8040A0210865CCE800AC1388553EC1025A780001717B3DB79824283
          4FA8610EDF61898C1270FF841604800B82F8CA0290070550042506C01C0F186C
          01806520E201B7A943BE9C16854838450C525B4B8398B0081C7CA26901A8411A
          4601006044216AC3A893BC18B7128D8ACC4949E2D6243E9484FF300209B82A5C
          1AD6E0806210450AC500402AE23048D368620A81DB1BF50A30B5AED8CD252D59
          185B3E400C051CC0117AB8812300F00B3BF8732C4488462D6220001B10C15A5F
          F101264220002BD08285892C80CD16A3BF97740E242025441A0C000168D0C60F
          84402723A6860C0C44C30E6708CA9D08208142A8480A490185165C46142842B1
          4E7E6189FE16839485F5C0180E08800FA03100F4F92C17470880115E41008190
          628C0370C1149A618421FF1CA33D2F184630BD2255E6B9676A4E5B184B2A308B
          27302D00C4D8442A00F0001CCC623183D0C2406C9102BB7940182950451A0E60
          836164680AB398C0E0E4651B9860D289494145205852873674400D5F68C43084
          C186A00CA3030359839E02F085540460079108CA1EFD320854A8A5B74339230B
          4BBB094E0C650AC508E0001E40050811400A9B28C81E8B20055A1465005E1006
          5A0B800663E4C0348A3D00B79CC6E200AC001501C55A00689186C281C429B5C8
          414100818A3C9C62188308C008EAC04C021CA10A8B218230088181BF24527913
          58C333C480AB0724450AC4808606A0A892014001150721C60D9EA1025A00001A
          B830420058E00B404860FF311120B2208E705CBC1D540FC510C406B8668C5BD8
          01002CE844900FE0CB06DC02216848851182A20218C064054B2E402C40B181AF
          3C400BAC80C6250CC18632E06113C2D0851C34B03030C4610367A0C533FAC0A1
          11AC050F8B48882AD0C0966DB90018EB0DC00508D10C3688D72B17D8C111DCB0
          8629F040BC0700E90E9EF1810C1D0111D078C67A05C00361844021C250417164
          E08B4E6468615178C61442A0812A6AADCE36200407A0C809506870000EA84207
          02B03A233024185223802054115A198BC213DE7C860782B20307E42002417100
          00C0900A68702207A880860EA0582A089C4274226145002160ADE20CA008801E
          C02600D0050148001A28FF10C61BBE92039F0E20079EE890265681604434A2B5
          224984292010B8040C2002B5B8550090D187FBD9A0345FF04518F0600B240965
          0DA6F04030AA80BA001082145681D909746616330CE302020001DB00D0823468
          C26EB3C8851A6A51DF853DE20EFC0503141D908A4F4C260AC600180110F00000
          38C128CA098020FC0009E014E008029F85129CA29267E080692A61012E063119
          81E0C01786086DD8499506EF20A118B44002F5386188674080B2497037EADC30
          8CCA1304029100C614AA6EF56A06A01600E08A5F72000D5E7CC58518E0EC0E48
          9161D7130437A6B80552CB3727305022782099026449E5B21C58C2165530FE41
          5AD5095B78354E2AC11B5065AB2E022F9CA21652D0BE4202F0023DC4A2167690
          020B6E9C94CB8E40083EC6BCFA47629416680112A7C05598D009A29009B2D00C
          B5E009650004FB3717E6130037600336F00393D380167881021110003B}
        Stretch = True
        Transparent = True
        ExplicitLeft = 266
      end
      object shp1: TShape
        Left = 8
        Top = 109
        Width = 278
        Height = 149
        Brush.Color = 16378589
      end
      object shp2: TShape
        Left = 292
        Top = 109
        Width = 284
        Height = 149
        Brush.Color = 16378589
      end
      object LabelMasrafKod1: TcxLabel
        Left = 407
        Top = 44
        Caption = 'Durum:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsItalic]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelDURUM: TcxDBLabel
        Left = 1172
        Top = 44
        AutoSize = True
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsKasa
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
      end
      object LabelFTARIH: TcxDBLabel
        Tag = 2
        Left = 454
        Top = 119
        DataBinding.DataField = 'FATURATARIH'
        DataBinding.DataSource = DtsKasa
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        OnClick = LabelFTARIHClick
        Height = 22
        Width = 71
      end
      object LabelTARIH: TcxDBLabel
        Tag = 2
        Left = 454
        Top = 63
        DataBinding.DataField = 'TARIH'
        DataBinding.DataSource = DtsKasa
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelFTARIHClick
        Height = 17
        Width = 106
      end
      object LabelMasrafKod2: TcxLabel
        Left = 380
        Top = 63
        Caption = 'Kay'#305't Tarihi:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsItalic]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelACIKLAMA: TcxDBLabel
        Left = 17
        Top = 271
        DataBinding.DataField = 'ACIKLAMA'
        ParentFont = False
        Style.Shadow = False
        StyleHot.TextColor = clWindowText
        Height = 38
        Width = 252
      end
      object LabelFaturaTarihi: TcxLabel
        Left = 373
        Top = 119
        Caption = 'Fatura Tarihi:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsItalic]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelMasrafKod3: TcxLabel
        Left = 404
        Top = 189
        Caption = 'Toplam:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsItalic]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelKur: TcxDBLabel
        Left = 510
        Top = 231
        DataBinding.DataField = 'KUR'
        DataBinding.DataSource = DtsKasa
        Transparent = True
        Height = 21
        Width = 28
      end
      object LabelMasrafAd: TcxLabel
        Tag = 1
        Left = 442
        Top = 286
        Caption = '---'
        Transparent = True
      end
      object LabelREHBERID: TcxDBLabel
        Left = 26
        Top = 142
        DataBinding.DataField = 'REHBERID'
        Visible = False
        Height = 23
        Width = 58
      end
      object CariSecTus: TcxButton
        Left = 456
        Top = 309
        Width = 120
        Height = 26
        Caption = 'Tahsilat Plan'#305
        TabOrder = 11
        OnClick = CariSecTusClick
      end
      object LabelPlansiz: TcxLabel
        Left = 296
        Top = 312
        Caption = 'Tahsilat Takvimi bulunamad'#305'!'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelPlanli: TcxLabel
        Left = 296
        Top = 318
        Caption = 'Tahsilat Takvimi Planlanm'#305#351
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelMasrafKodLabelCariAd: TcxLabel
        Left = 10
        Top = 486
        Caption = '-----'
        Transparent = True
      end
      object cxTextEdit1: TcxTextEdit
        Left = 438
        Top = 5
        Enabled = False
        ParentFont = False
        Style.Color = clSilver
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.Shadow = False
        Style.IsFontAssigned = True
        StyleDisabled.BorderColor = clBackground
        StyleDisabled.Color = clSilver
        StyleDisabled.TextColor = clBackground
        TabOrder = 15
        Text = 'Gelen Fatura'
        Width = 96
      end
      object LabelADRES: TcxDBLabel
        Tag = 1
        Left = 20
        Top = 171
        DataBinding.DataField = 'ADRES'
        DataBinding.DataSource = Tablo.DtsBizim
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Height = 43
        Width = 172
      end
      object LabelFATURABASLIK: TcxDBLabel
        Tag = 1
        Left = 20
        Top = 155
        DataBinding.DataField = 'FATURABASLIK'
        DataBinding.DataSource = Tablo.DtsBizim
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Height = 21
        Width = 172
      end
      object LabelILCE: TcxDBLabel
        Tag = 1
        Left = 20
        Top = 216
        DataBinding.DataField = 'ILCE'
        DataBinding.DataSource = Tablo.DtsBizim
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Height = 21
        Width = 104
      end
      object LabelVERGIDAI: TcxDBLabel
        Tag = 1
        Left = 20
        Top = 235
        DataBinding.DataField = 'VERGIDAI'
        DataBinding.DataSource = Tablo.DtsBizim
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Height = 21
        Width = 104
      end
      object LabelVERGINO: TcxDBLabel
        Tag = 1
        Left = 124
        Top = 235
        DataBinding.DataField = 'VERGINO'
        DataBinding.DataSource = Tablo.DtsBizim
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Height = 21
        Width = 118
      end
      object LabelIL: TcxDBLabel
        Tag = 1
        Left = 123
        Top = 216
        DataBinding.DataField = 'IL'
        DataBinding.DataSource = Tablo.DtsBizim
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Height = 21
        Width = 118
      end
      object LabelMasrafKod4: TcxLabel
        Left = 411
        Top = 210
        Caption = 'K.D.V.:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsItalic]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelMasrafKod5: TcxLabel
        Left = 369
        Top = 231
        Caption = 'Genel Toplam:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsItalic]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelFATURA_MATRAHI: TcxDBLabel
        Tag = 1
        Left = 454
        Top = 189
        DataBinding.DataField = 'FATURA_MATRAHI'
        DataBinding.DataSource = DtsKasa
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelFTARIHClick
        Height = 17
        Width = 54
      end
      object LabelKDV_TUTARI: TcxDBLabel
        Tag = 1
        Left = 454
        Top = 210
        DataBinding.DataField = 'KDV_TUTARI'
        DataBinding.DataSource = DtsKasa
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelFTARIHClick
        Height = 17
        Width = 54
      end
      object LabelFATURA_TUTARI: TcxDBLabel
        Tag = 1
        Left = 454
        Top = 231
        DataBinding.DataField = 'FATURA_TUTARI'
        DataBinding.DataSource = DtsKasa
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelFTARIHClick
        Height = 17
        Width = 54
      end
      object LabelMASRAFID: TcxLabel
        Tag = 1
        Left = 467
        Top = 269
        Caption = 'LabelMASRAFID'
        Transparent = True
        Visible = False
      end
      object LabelCariKod: TcxLabel
        Tag = 1
        Left = 124
        Top = 114
        AutoSize = False
        Caption = '--'
        Transparent = True
        Height = 20
        Width = 158
      end
      object LabelMasrafKod: TcxLabel
        Tag = 1
        Left = 442
        Top = 269
        Caption = '---'
        Transparent = True
      end
      object LabelMasrafKod6: TcxLabel
        Left = 392
        Top = 140
        Caption = 'Fatura No:'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsItalic]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelFNO: TcxDBLabel
        Tag = 1
        Left = 454
        Top = 140
        DataBinding.DataField = 'FATURANO'
        DataBinding.DataSource = DtsKasa
        ParentColor = False
        ParentFont = False
        Style.Color = 16378589
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        OnClick = LabelFTARIHClick
        Height = 22
        Width = 84
      end
      object LabelCariAd: TcxLabel
        Tag = 1
        Left = 124
        Top = 135
        AutoSize = False
        Caption = '--'
        Transparent = True
        Height = 20
        Width = 158
      end
      object Logo: TJvDBImage
        Left = 10
        Top = 11
        Width = 150
        Height = 66
        BorderStyle = bsNone
        Color = clBtnFace
        DataField = 'LOGO'
        DataSource = DtsKasa
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHighlightText
        Font.Height = -1
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        Stretch = True
        TabOrder = 33
        TabStop = False
        BevelInner = bvNone
        BevelOuter = bvNone
        Transparent = True
      end
      object cxDBImage1: TJvDBImage
        Left = 20
        Top = 117
        Width = 98
        Height = 40
        BorderStyle = bsNone
        Color = clBtnFace
        DataField = 'LOGO'
        DataSource = Tablo.DtsBizim
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHighlightText
        Font.Height = -1
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        Stretch = True
        TabOrder = 34
        TabStop = False
        BevelInner = bvNone
        BevelOuter = bvNone
        Transparent = True
      end
    end
  end
  object TabKasa: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabKasaAfterOpen
    ParamData = <
      item
        Name = 'Prm'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
    SQL.Strings = (
      'select  '
      #9'R.FIRMA,'
      
        #9'ADRES= isnull((SELECT BILGI FROM REHBERBILGI WHERE YERI=1 AND Y' +
        'ER_ID=R.ID AND ETIKET='#39'Adres'#39'),'#39#39')  ,'
      
        #9'ILCE= (SELECT BILGI FROM REHBERBILGI WHERE YERI=1 AND YER_ID=R.' +
        'ID AND ETIKET='#39#304'l'#231'e'#39'),'
      
        #9'IL= (SELECT BILGI FROM REHBERBILGI WHERE YERI=1 AND YER_ID=R.ID' +
        ' AND ETIKET='#39#304'l'#39'),'
      
        #9'VERGIDAI= (SELECT BILGI FROM REHBERBILGI WHERE YERI=1 AND YER_I' +
        'D=R.ID AND ETIKET='#39'Vergi Dairesi'#39'),'
      
        #9'VERGINO= (SELECT BILGI FROM REHBERBILGI WHERE YERI=1 AND YER_ID' +
        '=R.ID AND ETIKET='#39'Vergi No'#39'),'
      
        #9'FATURABASLIK= (SELECT BILGI FROM REHBERBILGI WHERE YERI=1 AND Y' +
        'ER_ID=R.ID AND ETIKET='#39'Fatura Ba'#351'l'#305#287#305#39'),'
      
        #9'LOGO= (SELECT BELGE FROM IMAJ WHERE VARSAYILAN=1 AND YER_ID=R.I' +
        'D AND YERI=1),'
      #9'F.ID, '
      #9'TUR, '
      #9'F.DURUM,'
      #9'ODEMEPLANI, '
      #9'F.TARIH, '
      #9'FATURATARIH, '
      #9'FATURANO, '
      #9'REHBERID, '
      #9'ACIKLAMA,'
      #9'FATURA_MATRAHI,'
      #9'KDV_TUTARI,'
      #9'FATURA_TUTARI, '
      #9'KUR,F.MASRAFID, '
      #9'F.EKLEYEN,'
      #9'F.DEGISTIREN'
      'from '
      #9'FATBASLIK F INNER JOIN '
      #9'REHBER R ON'
      #9#9'R.ID=F.REHBERID'
      'where '
      #9'F.ID = :Prm')
    Left = 209
    Top = 44
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    OnStateChange = DtsKasaStateChange
    Left = 167
    Top = 42
  end
end

