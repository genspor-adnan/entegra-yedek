object AnaListe: TAnaListe
  Left = 35
  Top = 94
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Liste'
  ClientHeight = 632
  ClientWidth = 1228
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  Position = poDefault
  Visible = True
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1228
    Height = 145
    Align = alTop
    TabOrder = 0
    object pnlFiltreler: TPanel
      Left = 1
      Top = 1
      Width = 1226
      Height = 142
      Align = alTop
      TabOrder = 0
      object btnOnKontrol: TSpeedButton
        Left = 578
        Top = 23
        Width = 121
        Height = 22
        Caption = #214'n Kontrol'
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000D30E0000D30E00000001000000010000007B00000084
          0000008C00000094000008940800009C0800089C080008A50800008C1000088C
          100008A5100010A5100018731800318C180021941800109C180010A5180018A5
          180010AD1800317B21005A8421001894210018B52100217B2900399429005294
          2900299C29004AA5290052A5290018AD290018B5290021B52900428C3100399C
          310031A5310021B5310031B5310021BD3100218C390018A5390039A5390029C6
          39006B844200188C4200319C4200399C420042B5420029C642005A944A00429C
          4A007B9C4A0073AD4A008CB54A0052BD4A0031CE4A00525252006B63520039CE
          520031D6520039D652005A5A5A007B735A0018A55A0063A55A008CA55A0021AD
          5A004ACE5A0039D65A0063636300736B6300847363008C73630063C6630073C6
          630042D66300214A6B006B6B6B006B736B0063D66B0042DE6B004ADE6B0042E7
          6B004AE76B00295A73004AE77300294A7B00316B7B00426B7B0073737B00B59C
          7B0084BD7B00B5C67B007BCE7B005AE77B0063E77B0052EF7B00104284002952
          84005263840018848400CEAD840073B5840073D6840052EF84005AEF84000042
          8C00295A8C00426B8C008C8C8C00B5A58C00214A940000529400215294002163
          94006BF7940029639C004A849C0073849C009C9C9C009CA59C0031AD9C00C6B5
          9C000063A5000863A500006BA5001873A5004A94A500A5A5A50094E7A500006B
          AD00086BAD001873AD002173AD009CEFAD008CF7AD001073B500007BB500217B
          B500297BB500218CB5003194B50039A5B500C6BDB500ADEFB500007BBD001884
          BD002184BD00188CBD0063ADBD0073ADBD00A5C6BD00008CC600108CC600298C
          C6001094C60042A5C6009CC6C6000894CE001094CE002994CE00009CCE00089C
          CE00109CCE00189CCE00CECECE00CED6CE00089CD60010A5D60018A5D60029A5
          D60021ADD60039ADD6005AADD60063C6D6009CCED600D6D6D600DEDED60018A5
          DE0021A5DE0029A5DE0042A5DE0031ADDE004AADDE0042B5DE0042BDDE00BDD6
          DE00DEDEDE00E7EFDE0029ADE70039ADE70042ADE70031B5E70039B5E70042B5
          E70052B5E70063BDE7006BC6E70039B5EF004AB5EF0042BDEF004ABDEF0052C6
          EF005AC6EF006BC6EF004ABDF7004AC6F70052C6F700FF00FF005AC6FF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CFCFCFCFCFCF
          CFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCF7569CFCFCFCFCFCFCFCFCFCFCF
          8483618AA96A6F7BCFCFCFCFCFCFCFCFB6C17B9FB5829A9ECFCFCFCFCFCFCF70
          99C8C7C1B5B3A89A6962CFCFCFCFCF6EBECEC8C3747D9E9A7C71CFCFCFCFCFC4
          C9C8CBBA4C539A9DA294CFCFCFCFCF268DC8CBBA4C56A8A3A3CFCF3F09001839
          78B7ADAF4457A9A9CFCFCF1A50231D39273E2E7937479BA3CFCFCF0D50544339
          2F25110E2ACFCFCFCFCF2823545466651510100619CFCFCFCFCF80725F50AF7F
          17040A1049CFCFCFCFCFCF4A5050AF7F2D25111BCFCFCFCFCFCFCFCF5D50A46C
          303548CFCFCFCFCFCFCFCFCFCF4A6D45341FCFCFCFCFCFCFCFCF}
        OnClick = btnOnKontrolClick
      end
      object btnXMLolustur: TSpeedButton
        Tag = 1
        Left = 578
        Top = 59
        Width = 121
        Height = 22
        Caption = 'XML Olu'#351'tur'
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000D30E0000D30E00000001000000010000007B00000084
          0000008C00000094000008940800009C0800089C080008A50800008C1000088C
          100008A5100010A5100018731800318C180021941800109C180010A5180018A5
          180010AD1800317B21005A8421001894210018B52100217B2900399429005294
          2900299C29004AA5290052A5290018AD290018B5290021B52900428C3100399C
          310031A5310021B5310031B5310021BD3100218C390018A5390039A5390029C6
          39006B844200188C4200319C4200399C420042B5420029C642005A944A00429C
          4A007B9C4A0073AD4A008CB54A0052BD4A0031CE4A00525252006B63520039CE
          520031D6520039D652005A5A5A007B735A0018A55A0063A55A008CA55A0021AD
          5A004ACE5A0039D65A0063636300736B6300847363008C73630063C6630073C6
          630042D66300214A6B006B6B6B006B736B0063D66B0042DE6B004ADE6B0042E7
          6B004AE76B00295A73004AE77300294A7B00316B7B00426B7B0073737B00B59C
          7B0084BD7B00B5C67B007BCE7B005AE77B0063E77B0052EF7B00104284002952
          84005263840018848400CEAD840073B5840073D6840052EF84005AEF84000042
          8C00295A8C00426B8C008C8C8C00B5A58C00214A940000529400215294002163
          94006BF7940029639C004A849C0073849C009C9C9C009CA59C0031AD9C00C6B5
          9C000063A5000863A500006BA5001873A5004A94A500A5A5A50094E7A500006B
          AD00086BAD001873AD002173AD009CEFAD008CF7AD001073B500007BB500217B
          B500297BB500218CB5003194B50039A5B500C6BDB500ADEFB500007BBD001884
          BD002184BD00188CBD0063ADBD0073ADBD00A5C6BD00008CC600108CC600298C
          C6001094C60042A5C6009CC6C6000894CE001094CE002994CE00009CCE00089C
          CE00109CCE00189CCE00CECECE00CED6CE00089CD60010A5D60018A5D60029A5
          D60021ADD60039ADD6005AADD60063C6D6009CCED600D6D6D600DEDED60018A5
          DE0021A5DE0029A5DE0042A5DE0031ADDE004AADDE0042B5DE0042BDDE00BDD6
          DE00DEDEDE00E7EFDE0029ADE70039ADE70042ADE70031B5E70039B5E70042B5
          E70052B5E70063BDE7006BC6E70039B5EF004AB5EF0042BDEF004ABDEF0052C6
          EF005AC6EF006BC6EF004ABDF7004AC6F70052C6F700FF00FF005AC6FF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CFCFCFCFCFCF
          CFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCF7569CFCFCFCFCFCFCFCFCFCFCF
          8483618AA96A6F7BCFCFCFCFCFCFCFCFB6C17B9FB5829A9ECFCFCFCFCFCFCF70
          99C8C7C1B5B3A89A6962CFCFCFCFCF6EBECEC8C3747D9E9A7C71CFCFCFCFCFC4
          C9C8CBBA4C539A9DA294CFCFCFCFCF268DC8CBBA4C56A8A3A3CFCF3F09001839
          78B7ADAF4457A9A9CFCFCF1A50231D39273E2E7937479BA3CFCFCF0D50544339
          2F25110E2ACFCFCFCFCF2823545466651510100619CFCFCFCFCF80725F50AF7F
          17040A1049CFCFCFCFCFCF4A5050AF7F2D25111BCFCFCFCFCFCFCFCF5D50A46C
          303548CFCFCFCFCFCFCFCFCFCF4A6D45341FCFCFCFCFCFCFCFCF}
        OnClick = btnXMLolusturClick
      end
      object btnSonKontrol: TSpeedButton
        Tag = 2
        Left = 578
        Top = 97
        Width = 121
        Height = 22
        Caption = 'Son Kontrol'
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000D30E0000D30E00000001000000010000007B00000084
          0000008C00000094000008940800009C0800089C080008A50800008C1000088C
          100008A5100010A5100018731800318C180021941800109C180010A5180018A5
          180010AD1800317B21005A8421001894210018B52100217B2900399429005294
          2900299C29004AA5290052A5290018AD290018B5290021B52900428C3100399C
          310031A5310021B5310031B5310021BD3100218C390018A5390039A5390029C6
          39006B844200188C4200319C4200399C420042B5420029C642005A944A00429C
          4A007B9C4A0073AD4A008CB54A0052BD4A0031CE4A00525252006B63520039CE
          520031D6520039D652005A5A5A007B735A0018A55A0063A55A008CA55A0021AD
          5A004ACE5A0039D65A0063636300736B6300847363008C73630063C6630073C6
          630042D66300214A6B006B6B6B006B736B0063D66B0042DE6B004ADE6B0042E7
          6B004AE76B00295A73004AE77300294A7B00316B7B00426B7B0073737B00B59C
          7B0084BD7B00B5C67B007BCE7B005AE77B0063E77B0052EF7B00104284002952
          84005263840018848400CEAD840073B5840073D6840052EF84005AEF84000042
          8C00295A8C00426B8C008C8C8C00B5A58C00214A940000529400215294002163
          94006BF7940029639C004A849C0073849C009C9C9C009CA59C0031AD9C00C6B5
          9C000063A5000863A500006BA5001873A5004A94A500A5A5A50094E7A500006B
          AD00086BAD001873AD002173AD009CEFAD008CF7AD001073B500007BB500217B
          B500297BB500218CB5003194B50039A5B500C6BDB500ADEFB500007BBD001884
          BD002184BD00188CBD0063ADBD0073ADBD00A5C6BD00008CC600108CC600298C
          C6001094C60042A5C6009CC6C6000894CE001094CE002994CE00009CCE00089C
          CE00109CCE00189CCE00CECECE00CED6CE00089CD60010A5D60018A5D60029A5
          D60021ADD60039ADD6005AADD60063C6D6009CCED600D6D6D600DEDED60018A5
          DE0021A5DE0029A5DE0042A5DE0031ADDE004AADDE0042B5DE0042BDDE00BDD6
          DE00DEDEDE00E7EFDE0029ADE70039ADE70042ADE70031B5E70039B5E70042B5
          E70052B5E70063BDE7006BC6E70039B5EF004AB5EF0042BDEF004ABDEF0052C6
          EF005AC6EF006BC6EF004ABDF7004AC6F70052C6F700FF00FF005AC6FF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CFCFCFCFCFCF
          CFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCF7569CFCFCFCFCFCFCFCFCFCFCF
          8483618AA96A6F7BCFCFCFCFCFCFCFCFB6C17B9FB5829A9ECFCFCFCFCFCFCF70
          99C8C7C1B5B3A89A6962CFCFCFCFCF6EBECEC8C3747D9E9A7C71CFCFCFCFCFC4
          C9C8CBBA4C539A9DA294CFCFCFCFCF268DC8CBBA4C56A8A3A3CFCF3F09001839
          78B7ADAF4457A9A9CFCFCF1A50231D39273E2E7937479BA3CFCFCF0D50544339
          2F25110E2ACFCFCFCFCF2823545466651510100619CFCFCFCFCF80725F50AF7F
          17040A1049CFCFCFCFCFCF4A5050AF7F2D25111BCFCFCFCFCFCFCFCF5D50A46C
          303548CFCFCFCFCFCFCFCFCFCF4A6D45341FCFCFCFCFCFCFCFCF}
        OnClick = btnSonKontrolClick
      end
      object CheckFaturaDetay: TCheckBox
        Left = 11
        Top = 86
        Width = 153
        Height = 17
        Caption = 'Fatura Detaylar'#305'n'#305' G'#246'ster'
        TabOrder = 0
        OnClick = CheckFaturaDetayClick
      end
      object DateBaslangic: TcxDateEdit
        Left = 97
        Top = 11
        EditValue = 39407d
        Properties.DateOnError = deToday
        Properties.ImmediatePost = True
        Properties.InputKind = ikMask
        Properties.ShowTime = False
        TabOrder = 1
        Width = 121
      end
      object DateBitis: TcxDateEdit
        Left = 97
        Top = 32
        BeepOnEnter = False
        EditValue = 39407d
        Properties.DateOnError = deToday
        Properties.ImmediatePost = True
        Properties.InputKind = ikMask
        Properties.ShowTime = False
        TabOrder = 2
        Width = 121
      end
      object cxProgressBar1: TcxProgressBar
        Left = 695
        Top = 59
        Properties.BarBevelOuter = cxbvLowered
        Properties.BeginColor = clBlue
        Properties.EndColor = clBlack
        Properties.PeakValue = 100.000000000000000000
        Style.LookAndFeel.Kind = lfOffice11
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        TabOrder = 3
        Visible = False
        Width = 227
      end
      object labelMessage: TcxLabel
        Left = 696
        Top = 81
        AutoSize = False
        Caption = 'XML Dosyas'#305' olu'#351'turuluyor'
        Style.LookAndFeel.Kind = lfOffice11
        Style.Shadow = False
        Style.TextColor = clRed
        StyleDisabled.LookAndFeel.Kind = lfOffice11
        StyleFocused.LookAndFeel.Kind = lfOffice11
        StyleHot.LookAndFeel.Kind = lfOffice11
        Visible = False
        Height = 17
        Width = 224
      end
      object BitBtn1: TBitBtn
        Left = 806
        Top = 116
        Width = 144
        Height = 25
        Caption = 'Stok Belgesini G'#246'r'#252'nt'#252'le'
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000230B0000230B00000001000000010000000000005A5A
          5A006B6B6B0073737300A5947B0084848400B584840094949C009C9C9C00A5A5
          9C00C6A59C00A5A5A500C6ADA500B5B5A500CEBDA500ADADAD00B5B5AD00D6B5
          AD00F7D6AD00CEC6B500DEC6B500BDBDBD00C6C6C600F7E7C600CECECE00D6D6
          D600FFEFDE00FFEFE700FFF7EF00FFF7F700FF00FF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF001E1E1E1E1E1E
          1E1E1E1E1E1E1E1E1E1E0606060606060606061E1E1E1E1E0F1E0A1212121212
          1212061E1E1E1E0F01080A1F1A1717171212061E1E1E0F0119050C1F1F1F1A1A
          1712061E1E0F0116051E0C1F0E0E0E05080802050F0108051E1E111F1F1F0802
          1A1A1A020108051E1E1E111F0E07051A1B1C1C0A05021E1E1E1E141F15021A00
          00001C0A1C02161E1E1E141F101A1B1D1C1C1C0A1C1D031E1E1E141F081A0000
          00001D0A1C1C051E1E1E1414101A1B1C1C1C1C0A1C1C051E1E1E1E1E15020A0A
          0A0A0A0A1D040B1E1E1E1E1E1E18021C1C1C1C1D050B1E1E1E1E1E1E1E1E1802
          1C1C1C0E151E1E1E1E1E1E1E1E1E1E0B0D0213091E1E1E1E1E1E}
        TabOrder = 5
        Visible = False
      end
      object GroupBox3: TGroupBox
        Left = 233
        Top = 11
        Width = 122
        Height = 61
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        TabOrder = 6
        object RbAktarilan: TRadioButton
          Left = 15
          Top = 22
          Width = 86
          Height = 16
          Caption = 'Aktar'#305'lanlar'
          TabOrder = 0
          OnClick = ListeleBtnClick
        end
        object RbTumu: TRadioButton
          Left = 15
          Top = 4
          Width = 49
          Height = 18
          Caption = 'T'#252'm'#252
          Checked = True
          TabOrder = 1
          TabStop = True
          OnClick = ListeleBtnClick
        end
        object RbAktarilmayan: TRadioButton
          Left = 15
          Top = 38
          Width = 96
          Height = 18
          Caption = 'Aktar'#305'lmayanlar'
          TabOrder = 2
          OnClick = ListeleBtnClick
        end
      end
      object MemoInsert: TcxMemo
        Left = 740
        Top = 11
        TabOrder = 7
        Visible = False
        Height = 20
        Width = 869
      end
      object cxLabel1: TcxLabel
        Left = 7
        Top = 12
        Caption = 'Ba'#351'lang'#305#231' Tarihi :'
      end
      object cxLabel2: TcxLabel
        Left = 32
        Top = 35
        Caption = 'Biti'#351' Tarihi :'
      end
      object lblTur: TcxLabel
        Left = 64
        Top = 59
        Caption = 'T'#252'r :'
      end
      object ComboTur: TcxImageComboBox
        Left = 97
        Top = 59
        Properties.Items = <>
        TabOrder = 11
        Width = 121
      end
      object OrkaKontrolBtn: TcxButton
        Left = 361
        Top = 71
        Width = 140
        Height = 25
        Caption = 'Orka Kontrol'
        DropDownMenu = PopupKontrol
        Kind = cxbkOfficeDropDown
        TabOrder = 12
      end
      object ListeleBtn: TcxButton
        Left = 361
        Top = 9
        Width = 140
        Height = 25
        Caption = 'Listele'
        TabOrder = 13
        OnClick = ListeleBtnClick
      end
      object btnSqlScriptOlustur: TcxButton
        Left = 361
        Top = 40
        Width = 140
        Height = 25
        Caption = 'SQL Script Dosya Olu'#351'tur'
        TabOrder = 14
        OnClick = btnSqlScriptOlusturClick
      end
      object LabelBaslik: TcxLabel
        Left = 8
        Top = 120
        Caption = '--'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.IsFontAssigned = True
      end
    end
  end
  object pnlListeler: TPanel
    Left = 0
    Top = 145
    Width = 1228
    Height = 487
    Align = alClient
    Caption = 'pnlListeler'
    TabOrder = 1
    object pcListeler: TcxPageControl
      Left = 1
      Top = 1
      Width = 1226
      Height = 485
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = TabSheetMuhasebeFisleri
      Properties.CustomButtons.Buttons = <>
      LookAndFeel.Kind = lfOffice11
      OnChange = pcListelerChange
      ClientRectBottom = 481
      ClientRectLeft = 4
      ClientRectRight = 1222
      ClientRectTop = 24
      object TabSheetHesapPlani: TcxTabSheet
        Caption = 'Hesap Plan'#305
        ImageIndex = 10
        object GridHesapPlani: TcxGrid
          Left = 0
          Top = 0
          Width = 1218
          Height = 457
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          object GridHesapPlaniDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = Tablo.DtsHesapPlani
            DataController.KeyFieldNames = 'SEC'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            object GridHesapPlaniDBTableView1SEC: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.NullStyle = nssUnchecked
            end
            object GridHesapPlaniDBTableView1TABLOADI: TcxGridDBColumn
              Caption = 'Tablo Ad'#305
              DataBinding.FieldName = 'TABLOADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 101
            end
            object GridHesapPlaniDBTableView1HESAPKODU: TcxGridDBColumn
              Caption = 'Hesap Kodu'
              DataBinding.FieldName = 'HESAPKODU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 159
            end
            object GridHesapPlaniDBTableView1HESAPADI: TcxGridDBColumn
              Caption = 'Hesap Ad'#305
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 473
            end
            object GridHesapPlaniDBTableView1PLANTURU: TcxGridDBColumn
              Caption = 'Plan T'#252'r'#252
              DataBinding.FieldName = 'PLANTURU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 217
            end
            object GridHesapPlaniDBTableView1ID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object GridHesapPlaniLevel1: TcxGridLevel
            GridView = GridHesapPlaniDBTableView1
          end
        end
      end
      object TabSheetSatisBelgeleri: TcxTabSheet
        Caption = 'Sat'#305#351' Faturalar'#305
        ImageIndex = 0
        TabVisible = False
        object PanelSatisDetay: TPanel
          Left = 0
          Top = 261
          Width = 1218
          Height = 196
          Align = alBottom
          TabOrder = 0
          object GroupFaturaDetay: TGroupBox
            Left = 1
            Top = 1
            Width = 1216
            Height = 194
            Align = alClient
            Caption = 'Fatura Detaylar'#305
            TabOrder = 0
            object FaturaDetay: TcxGrid
              Left = 2
              Top = 15
              Width = 1212
              Height = 177
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              object FaturaDetayView: TcxGridDBTableView
                PopupMenu = PopupMenu1
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = Tablo.DtsFaturaDetay
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = '###,###,###,###.00'
                    Kind = skSum
                    FieldName = 'FATURA_TUTARI'
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsView.Footer = True
                OptionsView.FooterAutoHeight = True
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.GroupRowStyle = grsOffice11
                object FaturaDetayViewTUR: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 97
                end
                object FaturaDetayViewKOD: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 86
                end
                object FaturaDetayViewMUHKODU21: TcxGridDBColumn
                  Caption = 'MUHKODU'
                  DataBinding.FieldName = 'MUHKODU21'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewAD: TcxGridDBColumn
                  Caption = 'Stok'
                  DataBinding.FieldName = 'AD'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 184
                end
                object FaturaDetayViewADET: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
                object FaturaDetayViewColumn1: TcxGridDBColumn
                  Caption = 'Birim Fiyat'
                  DataBinding.FieldName = 'BIRIMFIYAT'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.RepCurrencyBF
                  Options.Editing = False
                end
                object FaturaDetayViewBIRIM: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.repStokAnaBirim
                  Options.Editing = False
                end
                object FaturaDetayViewTUTAR: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'TUTAR'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                end
                object FaturaDetayViewKUR: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
                object FaturaDetayViewKDV: TcxGridDBColumn
                  DataBinding.FieldName = 'KDV'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
                object FaturaDetayViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewFATBASID: TcxGridDBColumn
                  DataBinding.FieldName = 'FATBASID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewREHBERID: TcxGridDBColumn
                  DataBinding.FieldName = 'REHBERID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewSEC: TcxGridDBColumn
                  DataBinding.FieldName = 'SEC'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewURUNID: TcxGridDBColumn
                  DataBinding.FieldName = 'URUNID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewACIKLAMA: TcxGridDBColumn
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                end
                object FaturaDetayViewMF: TcxGridDBColumn
                  DataBinding.FieldName = 'MF'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewMIKTAR: TcxGridDBColumn
                  DataBinding.FieldName = 'MIKTAR'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewISKONTO: TcxGridDBColumn
                  DataBinding.FieldName = 'ISKONTO'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewMASRAFID: TcxGridDBColumn
                  DataBinding.FieldName = 'MASRAFID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewOZELKOD: TcxGridDBColumn
                  DataBinding.FieldName = 'OZELKOD'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewMUHKODU: TcxGridDBColumn
                  DataBinding.FieldName = 'MUHKODU'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewDOVIZ_TUTARI: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZ_TUTARI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                  Width = 93
                end
                object FaturaDetayViewDOVIZ_KURU: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZ_KURU'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewISKONTO2: TcxGridDBColumn
                  DataBinding.FieldName = 'ISKONTO2'
                  DataBinding.IsNullValueType = True
                  Visible = False
                  Width = 96
                end
                object FaturaDetayViewIZLEME: TcxGridDBColumn
                  DataBinding.FieldName = 'IZLEME'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewIADEADET: TcxGridDBColumn
                  DataBinding.FieldName = 'IADEADET'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewIADEFATURAID: TcxGridDBColumn
                  DataBinding.FieldName = 'IADEFATURAID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewYERI: TcxGridDBColumn
                  DataBinding.FieldName = 'YERI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewYERID: TcxGridDBColumn
                  DataBinding.FieldName = 'YERID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewEKLEYEN: TcxGridDBColumn
                  DataBinding.FieldName = 'EKLEYEN'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewEKLEMETARIHI: TcxGridDBColumn
                  DataBinding.FieldName = 'EKLEMETARIHI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewDEGISTIREN: TcxGridDBColumn
                  DataBinding.FieldName = 'DEGISTIREN'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewDEGISTIRMETARIHI: TcxGridDBColumn
                  DataBinding.FieldName = 'DEGISTIRMETARIHI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZ_BIRIMFIYAT'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewDOVIZKURDEGERI: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZKURDEGERI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewPROJEID: TcxGridDBColumn
                  DataBinding.FieldName = 'PROJEID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewKAMPANYAID: TcxGridDBColumn
                  DataBinding.FieldName = 'KAMPANYAID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewVADE: TcxGridDBColumn
                  DataBinding.FieldName = 'VADE'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewSTOKDURUMDEGIS: TcxGridDBColumn
                  DataBinding.FieldName = 'STOKDURUMDEGIS'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewSUBEID: TcxGridDBColumn
                  DataBinding.FieldName = 'SUBEID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewKDVMUHAFIYETI: TcxGridDBColumn
                  DataBinding.FieldName = 'KDVMUHAFIYETI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewMERKEZID: TcxGridDBColumn
                  DataBinding.FieldName = 'MERKEZID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewMASRAFAD21: TcxGridDBColumn
                  DataBinding.FieldName = 'MASRAFAD21'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewAD21: TcxGridDBColumn
                  DataBinding.FieldName = 'AD21'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object FaturaDetayViewKOD21: TcxGridDBColumn
                  DataBinding.FieldName = 'KOD21'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
              end
              object cxGridLevel3: TcxGridLevel
                GridView = FaturaDetayView
              end
            end
            object SqlFatura: TMemo
              Left = 202
              Top = -90
              Width = 824
              Height = 286
              Lines.Strings = (
                'SELECT distinct FB.ID,FB.TUR,'
                'R.KOD,'
                'REHBERID=R.ID,'
                'R.FIRMA ,'
                'FB.BASLIK,'
                'FB.FATURANO,'
                'FB.FATURATARIH,'
                'KDVHARICTUTARI=ROUND(FB.FATURA_MATRAHI,2),'
                'KDV_TUTARI = ROUND(FB.KDV_TUTARI,2),'
                'KDVDAHILTUTARI= ROUND(FB.FATURA_TUTARI,2),'
                'FB.KUR,'
                'MUHAKTAR = ISNULL(FB.MUHAKTAR,0) ,'
                
                  'ORKA_BELGETIPI= (CASE WHEN FB.TUR=10 THEN 7 WHEN FB.TUR=11  and ' +
                  'FB.TIPI=1 THEN 20 WHEN FB.TUR =11  and FB.TIPI=2  THEN 21 WHEN F' +
                  'B.TUR =14 THEN '
                
                  '7 WHEN FB.TUR = 15 and FB.TIPI=1 THEN 20 WHEN FB.TUR = 15 and FB' +
                  '.TIPI=2 THEN 21 ELSE 0 END),'
                'FB.AKTARMATARIHI,'
                'FB.SUBEID'
                #9#9'    '#9#9'    '
                #9'FROM'
                #9#9'FATBASLIK FB INNER JOIN FATURA F on FB.ID=F.FATBASID'
                #9#9'inner join REHBER R on FB.REHBERID=R.ID')
              TabOrder = 0
              Visible = False
            end
          end
        end
        object PanelFaturalar: TPanel
          Left = 0
          Top = 0
          Width = 1218
          Height = 253
          Align = alClient
          BevelOuter = bvNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          object GroupBoxUstPanel: TGroupBox
            Left = 0
            Top = 0
            Width = 1218
            Height = 253
            Align = alClient
            TabOrder = 0
            object Panel4: TPanel
              Left = 2
              Top = 226
              Width = 1214
              Height = 25
              Align = alBottom
              TabOrder = 0
              object Label5: TLabel
                Left = 7
                Top = 7
                Width = 91
                Height = 13
                Caption = 'Toplam Kay'#305't Say'#305's'#305
              end
              object LblSatisKayitSay: TLabel
                Left = 108
                Top = 7
                Width = 7
                Height = 13
                Caption = '0'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clMaroon
                Font.Height = -11
                Font.Name = 'Tahoma'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object LblSatisSeciliKayitSay: TLabel
                Left = 348
                Top = 7
                Width = 7
                Height = 13
                Caption = '0'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clMaroon
                Font.Height = -11
                Font.Name = 'Tahoma'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object Label8: TLabel
                Left = 247
                Top = 7
                Width = 80
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
              end
              object Label9: TLabel
                Left = 704
                Top = 7
                Width = 129
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't KDV Dahil Tutar'#305
              end
              object Label14: TLabel
                Left = 465
                Top = 7
                Width = 130
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't KDV Hari'#231' Tutar'#305
              end
              object LblSatisSeciliHaricTutar: TcxCurrencyEdit
                Left = 601
                Top = 2
                RepositoryItem = Tablo.RepCurrencyGenel
                Enabled = False
                Properties.DisplayFormat = ',0.00;-,0.00'
                StyleDisabled.BorderColor = clBtnFace
                StyleDisabled.BorderStyle = ebsOffice11
                StyleDisabled.Color = 14532004
                StyleDisabled.TextColor = clWindowText
                TabOrder = 0
                Width = 88
              end
              object LblSatisSeciliDahilTutar: TcxCurrencyEdit
                Left = 839
                Top = 3
                RepositoryItem = Tablo.RepCurrencyGenel
                Enabled = False
                Properties.DisplayFormat = ',0.00;-,0.00'
                StyleDisabled.BorderColor = clBtnFace
                StyleDisabled.BorderStyle = ebsOffice11
                StyleDisabled.Color = 14532004
                StyleDisabled.TextColor = clWindowText
                TabOrder = 1
                Width = 88
              end
            end
            object GridSatisFaturalar: TcxGrid
              Left = 2
              Top = 15
              Width = 1214
              Height = 211
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              object SatisFaturalarView: TcxGridDBTableView
                PopupMenu = PopupMenu1
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCellClick = SatisFaturalarViewCellClick
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = Tablo.DtsFaturaListesi
                DataController.KeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = '###,###,###,###.00'
                    Kind = skSum
                    FieldName = 'FATURA_TUTARI'
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsView.Footer = True
                OptionsView.FooterAutoHeight = True
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.GroupRowStyle = grsOffice11
                object SatisFaturalarViewSEC: TcxGridDBColumn
                  Caption = 'Se'#231
                  DataBinding.ValueType = 'Boolean'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ImmediatePost = True
                  Properties.NullStyle = nssUnchecked
                  RepositoryItem = RepCheckBox
                  Width = 28
                end
                object SatisFaturalarViewTUR: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <
                    item
                      Description = 'Al'#305#351' '#304'rsaliyesi'
                      ImageIndex = 0
                      Value = 10
                    end
                    item
                      Description = 'Al'#305#351' Faturas'#305
                      Value = 11
                    end
                    item
                      Description = 'Al'#305#351' Fi'#351'i'
                      Value = 12
                    end
                    item
                      Description = 'Sat'#305#351' '#304'rsaliyesi'
                      Value = 14
                    end
                    item
                      Description = 'Sat'#305#351' Faturas'#305
                      Value = 15
                    end
                    item
                      Description = 'Sat'#305#351' Fi'#351'i'
                      Value = 16
                    end
                    item
                      Description = 'Alacak Tahakkuku'
                      Value = 13
                    end
                    item
                      Description = 'Bor'#231' Tahakkuku'
                      Value = 17
                    end>
                  Options.Editing = False
                  Width = 77
                end
                object SatisFaturalarViewORKA_BELGETIPI: TcxGridDBColumn
                  DataBinding.FieldName = 'ORKA_BELGETIPI'
                  DataBinding.IsNullValueType = True
                  Width = 48
                end
                object SatisFaturalarViewFATURANO: TcxGridDBColumn
                  Caption = 'Fatura No'
                  DataBinding.FieldName = 'FATURANO'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 75
                end
                object SatisFaturalarViewFATURATARIH: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'FATURATARIH'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 90
                end
                object SatisFaturalarViewKOD: TcxGridDBColumn
                  Caption = 'Cari Kod'
                  DataBinding.FieldName = 'KOD'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 84
                end
                object SatisFaturalarViewFIRMA: TcxGridDBColumn
                  Caption = 'Firma'
                  DataBinding.FieldName = 'FIRMA'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 226
                end
                object SatisFaturalarViewBASLIK: TcxGridDBColumn
                  Caption = 'Ba'#351'l'#305'k'
                  DataBinding.FieldName = 'BASLIK'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 108
                end
                object SatisFaturalarViewKDVHARICTUTARI: TcxGridDBColumn
                  Caption = 'Tutar (KDV Hari'#231')'
                  DataBinding.FieldName = 'KDVHARICTUTARI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                  Width = 92
                end
                object SatisFaturalarViewKDV_TUTARI: TcxGridDBColumn
                  Caption = 'KDV Tutar'#305
                  DataBinding.FieldName = 'KDV_TUTARI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                  Width = 71
                end
                object SatisFaturalarViewKDVDAHILTUTARI: TcxGridDBColumn
                  Caption = 'Tutar (KDV Dahil)'
                  DataBinding.FieldName = 'KDVDAHILTUTARI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                  Width = 92
                end
                object SatisFaturalarViewKUR: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                  DataBinding.IsNullValueType = True
                  Width = 37
                end
                object SatisFaturalarViewMUHAKTAR: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'MUHAKTAR'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  RepositoryItem = Tablo.RepMuhAktarDurum
                  Visible = False
                  Options.Editing = False
                  Width = 111
                end
                object SatisFaturalarViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object SatisFaturalarViewREHBERID: TcxGridDBColumn
                  Caption = 'RehberID'
                  DataBinding.FieldName = 'REHBERID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
              end
              object GridSatisFaturalarLevel1: TcxGridLevel
                GridView = SatisFaturalarView
              end
            end
          end
        end
        object cxSplitterSatis: TcxSplitter
          Left = 0
          Top = 253
          Width = 1218
          Height = 8
          HotZoneClassName = 'TcxSimpleStyle'
          AlignSplitter = salBottom
          AutoSnap = True
          Control = PanelSatisDetay
        end
      end
      object TabSheetAlisBelgeleri: TcxTabSheet
        Caption = 'Alis Faturalar'#305
        ImageIndex = 2
        TabVisible = False
        object PanelAlisDetay: TPanel
          Left = 0
          Top = 261
          Width = 1218
          Height = 196
          Align = alBottom
          TabOrder = 0
          object GroupAlisDetay: TGroupBox
            Left = 1
            Top = 1
            Width = 1216
            Height = 194
            Align = alClient
            Caption = 'Fatura Detaylar'#305
            TabOrder = 0
            object Memo1: TMemo
              Left = 248
              Top = 142
              Width = 824
              Height = 57
              Lines.Strings = (
                'SELECT DISTINCT FB.ID,'
                'R.KOD,'
                'R.FIRMA ,'
                'FB.BASLIK,'
                'FB.FATURANO,'
                'FB.FATURATARIH,'
                'KDVHARICTUTARI=ROUND(FB.FATURA_MATRAHI,2),'
                'KDV_TUTARI = ROUND(FB.KDV_TUTARI,2),'
                'KDVDAHILTUTARI= ROUND(FB.FATURA_TUTARI,2),'
                'MUHAKTAR = ISNULL(MUHAKTAR,0) ,'
                'AKTARMATARIHI,'
                'FB.SUBEID'#9#9'    '
                #9'FROM'
                #9#9'FATBASLIK FB INNER JOIN FATURA F on FB.ID=F.FATBASID'
                #9#9'inner join REHBER R on FB.REHBERID=R.ID')
              TabOrder = 0
              Visible = False
            end
            object GridAlisFatDetay: TcxGrid
              Left = 2
              Top = 15
              Width = 1212
              Height = 177
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              object AlisFatDetayView: TcxGridDBTableView
                PopupMenu = PopupMenu1
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = Tablo.DtsFaturaDetay
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = '###,###,###,###.00'
                    Kind = skSum
                    FieldName = 'FATURA_TUTARI'
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsView.Footer = True
                OptionsView.FooterAutoHeight = True
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.GroupRowStyle = grsOffice11
                object cxGridDBColumn1: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 70
                end
                object cxGridDBColumn2: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 86
                end
                object AlisFatDetayViewMUHKODU21: TcxGridDBColumn
                  Caption = 'MUHKODU'
                  DataBinding.FieldName = 'MUHKODU21'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object cxGridDBColumn3: TcxGridDBColumn
                  Caption = 'Stok'
                  DataBinding.FieldName = 'AD'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 184
                end
                object cxGridDBColumn4: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
                object cxGridDBColumn5: TcxGridDBColumn
                  Caption = 'Birim Fiyat'
                  DataBinding.FieldName = 'BIRIMFIYAT'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.RepCurrencyBF
                  Options.Editing = False
                end
                object cxGridDBColumn6: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.repStokAnaBirim
                  Options.Editing = False
                end
                object cxGridDBColumn7: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'TUTAR'
                  DataBinding.IsNullValueType = True
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                end
                object cxGridDBColumn8: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
                object cxGridDBColumn9: TcxGridDBColumn
                  DataBinding.FieldName = 'KDV'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
                object AlisFatDetayViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewFATBASID: TcxGridDBColumn
                  DataBinding.FieldName = 'FATBASID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewREHBERID: TcxGridDBColumn
                  DataBinding.FieldName = 'REHBERID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewSEC: TcxGridDBColumn
                  DataBinding.FieldName = 'SEC'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewURUNID: TcxGridDBColumn
                  DataBinding.FieldName = 'URUNID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewACIKLAMA: TcxGridDBColumn
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                end
                object AlisFatDetayViewMF: TcxGridDBColumn
                  DataBinding.FieldName = 'MF'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewMIKTAR: TcxGridDBColumn
                  DataBinding.FieldName = 'MIKTAR'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewISKONTO: TcxGridDBColumn
                  DataBinding.FieldName = 'ISKONTO'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewMASRAFID: TcxGridDBColumn
                  DataBinding.FieldName = 'MASRAFID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewIZLEMEKODU: TcxGridDBColumn
                  DataBinding.FieldName = 'IZLEMEKODU'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewOZELKOD: TcxGridDBColumn
                  DataBinding.FieldName = 'OZELKOD'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewMUHKODU: TcxGridDBColumn
                  DataBinding.FieldName = 'MUHKODU'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewKASA: TcxGridDBColumn
                  DataBinding.FieldName = 'KASA'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewONAY: TcxGridDBColumn
                  DataBinding.FieldName = 'ONAY'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewDOVIZ_TUTARI: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZ_TUTARI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewDOVIZ_KURU: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZ_KURU'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewISKONTO2: TcxGridDBColumn
                  DataBinding.FieldName = 'ISKONTO2'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewIZLEME: TcxGridDBColumn
                  DataBinding.FieldName = 'IZLEME'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewIADEADET: TcxGridDBColumn
                  DataBinding.FieldName = 'IADEADET'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewIADEFATURAID: TcxGridDBColumn
                  DataBinding.FieldName = 'IADEFATURAID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewYERI: TcxGridDBColumn
                  DataBinding.FieldName = 'YERI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewYERID: TcxGridDBColumn
                  DataBinding.FieldName = 'YERID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewEKLEYEN: TcxGridDBColumn
                  DataBinding.FieldName = 'EKLEYEN'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewEKLEMETARIHI: TcxGridDBColumn
                  DataBinding.FieldName = 'EKLEMETARIHI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewDEGISTIREN: TcxGridDBColumn
                  DataBinding.FieldName = 'DEGISTIREN'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewDEGISTIRMETARIHI: TcxGridDBColumn
                  DataBinding.FieldName = 'DEGISTIRMETARIHI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZ_BIRIMFIYAT'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewDOVIZKURDEGERI: TcxGridDBColumn
                  DataBinding.FieldName = 'DOVIZKURDEGERI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewPROJEID: TcxGridDBColumn
                  DataBinding.FieldName = 'PROJEID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewKAMPANYAID: TcxGridDBColumn
                  DataBinding.FieldName = 'KAMPANYAID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewVADE: TcxGridDBColumn
                  DataBinding.FieldName = 'VADE'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewSTOKDURUMDEGIS: TcxGridDBColumn
                  DataBinding.FieldName = 'STOKDURUMDEGIS'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewSUBEID: TcxGridDBColumn
                  DataBinding.FieldName = 'SUBEID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewKDVMUHAFIYETI: TcxGridDBColumn
                  DataBinding.FieldName = 'KDVMUHAFIYETI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewEKMALIYET: TcxGridDBColumn
                  DataBinding.FieldName = 'EKMALIYET'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewBASTAR: TcxGridDBColumn
                  DataBinding.FieldName = 'BASTAR'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewBITTAR: TcxGridDBColumn
                  DataBinding.FieldName = 'BITTAR'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewURETIMPLANID: TcxGridDBColumn
                  DataBinding.FieldName = 'URETIMPLANID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewURETIMPLANDETAYID: TcxGridDBColumn
                  DataBinding.FieldName = 'URETIMPLANDETAYID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewMERKEZID: TcxGridDBColumn
                  DataBinding.FieldName = 'MERKEZID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewMASRAFKOD21: TcxGridDBColumn
                  DataBinding.FieldName = 'MASRAFKOD21'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewMASRAFAD: TcxGridDBColumn
                  DataBinding.FieldName = 'MASRAFAD'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewPROJEKODU: TcxGridDBColumn
                  DataBinding.FieldName = 'PROJEKODU'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFatDetayViewTESLIMTARIHI: TcxGridDBColumn
                  DataBinding.FieldName = 'TESLIMTARIHI'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
              end
              object cxGridLevel4: TcxGridLevel
                GridView = AlisFatDetayView
              end
            end
          end
        end
        object PanelUstPanelAlis: TPanel
          Left = 0
          Top = 0
          Width = 1218
          Height = 253
          Align = alClient
          BevelOuter = bvNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          object GroupAlisUstPanel: TGroupBox
            Left = 0
            Top = 0
            Width = 1218
            Height = 253
            Align = alClient
            TabOrder = 0
            object Panel8: TPanel
              Left = 2
              Top = 226
              Width = 1214
              Height = 25
              Align = alBottom
              TabOrder = 0
              object Label1: TLabel
                Left = 7
                Top = 6
                Width = 91
                Height = 13
                Caption = 'Toplam Kay'#305't Say'#305's'#305
              end
              object LblAlisKayitSay: TLabel
                Left = 108
                Top = 6
                Width = 7
                Height = 13
                Caption = '0'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clMaroon
                Font.Height = -11
                Font.Name = 'Tahoma'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object LblAlisSeciliKayitSay: TLabel
                Left = 348
                Top = 6
                Width = 7
                Height = 13
                Caption = '0'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clMaroon
                Font.Height = -11
                Font.Name = 'Tahoma'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object Label6: TLabel
                Left = 247
                Top = 6
                Width = 80
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
              end
              object Label2: TLabel
                Left = 704
                Top = 7
                Width = 129
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't KDV Dahil Tutar'#305
              end
              object Label4: TLabel
                Left = 465
                Top = 7
                Width = 130
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't KDV Hari'#231' Tutar'#305
              end
              object LblAlisSeciliHaricTutar: TcxCurrencyEdit
                Left = 601
                Top = 2
                RepositoryItem = Tablo.RepCurrencyGenel
                Enabled = False
                Properties.DisplayFormat = ',0.00;-,0.00'
                StyleDisabled.BorderColor = clBtnFace
                StyleDisabled.BorderStyle = ebsOffice11
                StyleDisabled.Color = 14532004
                StyleDisabled.TextColor = clWindowText
                TabOrder = 0
                Width = 88
              end
              object LblAlisSeciliDahilTutar: TcxCurrencyEdit
                Left = 839
                Top = 3
                RepositoryItem = Tablo.RepCurrencyGenel
                Enabled = False
                Properties.DisplayFormat = ',0.00;-,0.00'
                StyleDisabled.BorderColor = clBtnFace
                StyleDisabled.BorderStyle = ebsOffice11
                StyleDisabled.Color = 14532004
                StyleDisabled.TextColor = clWindowText
                TabOrder = 1
                Width = 88
              end
            end
            object GridAlisFaturalar: TcxGrid
              Left = 2
              Top = 15
              Width = 1214
              Height = 211
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              object AlisFaturalarView: TcxGridDBTableView
                PopupMenu = PopupMenu1
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCellClick = SatisFaturalarViewCellClick
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = Tablo.DtsFaturaListesi
                DataController.KeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = '###,###,###,###.00'
                    Kind = skSum
                    FieldName = 'FATURA_TUTARI'
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsView.Footer = True
                OptionsView.FooterAutoHeight = True
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.GroupRowStyle = grsOffice11
                object AlisFaturalarViewSEC: TcxGridDBColumn
                  Caption = 'Se'#231
                  DataBinding.ValueType = 'Boolean'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ImmediatePost = True
                  Properties.NullStyle = nssUnchecked
                  RepositoryItem = RepCheckBox
                  Width = 31
                end
                object AlisFaturalarViewTUR: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <
                    item
                      Description = 'Al'#305#351' '#304'rsaliyesi'
                      ImageIndex = 0
                      Value = 10
                    end
                    item
                      Description = 'Al'#305#351' Faturas'#305
                      Value = 11
                    end
                    item
                      Description = 'Al'#305#351' Fi'#351'i'
                      Value = 12
                    end
                    item
                      Description = 'Sat'#305#351' '#304'rsaliyesi'
                      Value = 14
                    end
                    item
                      Description = 'Sat'#305#351' Faturas'#305
                      Value = 15
                    end
                    item
                      Description = 'Sat'#305#351' Fi'#351'i'
                      Value = 16
                    end
                    item
                      Description = 'Alacak Tahakkuku'
                      Value = 13
                    end
                    item
                      Description = 'Bor'#231' Tahakkuku'
                      Value = 17
                    end>
                  GroupSummaryAlignment = taRightJustify
                  Options.Editing = False
                  Width = 85
                end
                object AlisFaturalarViewORKA_BELGETIPI: TcxGridDBColumn
                  DataBinding.FieldName = 'ORKA_BELGETIPI'
                  DataBinding.IsNullValueType = True
                end
                object AlisFaturalarViewFATURANO: TcxGridDBColumn
                  Caption = 'Fatura No'
                  DataBinding.FieldName = 'FATURANO'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 75
                end
                object AlisFaturalarViewFATURATARIH: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'FATURATARIH'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 90
                end
                object AlisFaturalarViewKOD: TcxGridDBColumn
                  Caption = 'Cari Kod'
                  DataBinding.FieldName = 'KOD'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 84
                end
                object AlisFaturalarViewFIRMA: TcxGridDBColumn
                  Caption = 'Firma'
                  DataBinding.FieldName = 'FIRMA'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 381
                end
                object AlisFaturalarViewBASLIK: TcxGridDBColumn
                  Caption = 'Ba'#351'l'#305'k'
                  DataBinding.FieldName = 'BASLIK'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 108
                end
                object AlisFaturalarViewKDVHARICTUTARI: TcxGridDBColumn
                  Caption = 'Tutar (KDV Hari'#231')'
                  DataBinding.FieldName = 'KDVHARICTUTARI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                  Width = 92
                end
                object AlisFaturalarViewKDV_TUTARI: TcxGridDBColumn
                  Caption = 'KDV Tutar'#305
                  DataBinding.FieldName = 'KDV_TUTARI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                  Width = 71
                end
                object AlisFaturalarViewKDVDAHILTUTARI: TcxGridDBColumn
                  Caption = 'Tutar (KDV Dahil)'
                  DataBinding.FieldName = 'KDVDAHILTUTARI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Options.Editing = False
                  Width = 92
                end
                object AlisFaturalarViewKUR: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                  DataBinding.IsNullValueType = True
                  Width = 33
                end
                object AlisFaturalarViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object AlisFaturalarViewMUHAKTAR: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'MUHAKTAR'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  RepositoryItem = Tablo.RepMuhAktarDurum
                  Visible = False
                  Width = 93
                end
                object AlisFaturalarViewREHBERID: TcxGridDBColumn
                  Caption = 'RehberID'
                  DataBinding.FieldName = 'REHBERID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
              end
              object cxGridLevel5: TcxGridLevel
                GridView = AlisFaturalarView
              end
            end
          end
        end
        object cxSplitterAlis: TcxSplitter
          Left = 0
          Top = 253
          Width = 1218
          Height = 8
          HotZoneClassName = 'TcxSimpleStyle'
          AlignSplitter = salBottom
          AutoSnap = True
          Control = PanelAlisDetay
        end
      end
      object TabSheetMuhasebeFisleri: TcxTabSheet
        Caption = 'Muhasebe Fi'#351'leri'
        ImageIndex = 9
        object Panel12: TPanel
          Left = 0
          Top = 432
          Width = 1218
          Height = 25
          Align = alBottom
          TabOrder = 0
          Visible = False
          object Label20: TLabel
            Left = 7
            Top = 7
            Width = 91
            Height = 13
            Caption = 'Toplam Kay'#305't Say'#305's'#305
          end
          object lblToplamMuhFisSayisi: TLabel
            Left = 108
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblMuhFisSeciliKayitSayisi: TLabel
            Left = 348
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label26: TLabel
            Left = 247
            Top = 7
            Width = 80
            Height = 13
            Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
          end
        end
        object GridMuhasebeFisleri: TcxGrid
          Left = 185
          Top = 35
          Width = 1033
          Height = 397
          Align = alClient
          TabOrder = 1
          object GridMuhasebeFisleriView: TcxGridDBTableView
            PopupMenu = PopupMenu1
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = Tablo.DtsMuhasebeFis
            DataController.KeyFieldNames = 'ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skCount
                FieldName = 'FISTARIH'
                Column = GridMuhasebeFisleriViewFISTARIH
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.Footer = True
            object GridMuhasebeFisleriViewSEC: TcxGridDBColumn
              DataBinding.FieldName = 'SEC'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Width = 20
            end
            object GridMuhasebeFisleriViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              Visible = False
            end
            object GridMuhasebeFisleriViewMUHAKTAR: TcxGridDBColumn
              DataBinding.FieldName = 'MUHAKTAR'
              Options.Editing = False
              Width = 20
            end
            object GridMuhasebeFisleriViewSUBEID: TcxGridDBColumn
              DataBinding.FieldName = 'SUBEID'
              Options.Editing = False
              Width = 20
            end
            object GridMuhasebeFisleriViewFISTARIH: TcxGridDBColumn
              DataBinding.FieldName = 'FISTARIH'
              Options.Editing = False
              Width = 20
            end
            object GridMuhasebeFisleriViewFISTIP: TcxGridDBColumn
              DataBinding.FieldName = 'FISTIP'
              Options.Editing = False
              Width = 20
            end
            object GridMuhasebeFisleriViewTUR: TcxGridDBColumn
              DataBinding.FieldName = 'TUR'
              Width = 30
            end
            object GridMuhasebeFisleriViewTURAD: TcxGridDBColumn
              DataBinding.FieldName = 'TURAD'
              Width = 49
            end
            object GridMuhasebeFisleriViewFISNO: TcxGridDBColumn
              DataBinding.FieldName = 'FISNO'
              Options.Editing = False
              Width = 23
            end
            object GridMuhasebeFisleriViewFISACIKLAMA: TcxGridDBColumn
              DataBinding.FieldName = 'FISACIKLAMA'
              Options.Editing = False
              Width = 22
            end
            object GridMuhasebeFisleriViewHESAPKODU: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPKODU'
              Options.Editing = False
              Width = 25
            end
            object GridMuhasebeFisleriViewHESAPADI: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPADI'
              Options.Editing = False
              Width = 24
            end
            object GridMuhasebeFisleriViewBELGETARIH: TcxGridDBColumn
              DataBinding.FieldName = 'BELGETARIH'
              Options.Editing = False
              Width = 51
            end
            object GridMuhasebeFisleriViewBELGETIPI: TcxGridDBColumn
              DataBinding.FieldName = 'BELGETIPI'
              Width = 53
            end
            object GridMuhasebeFisleriViewBELGESERI: TcxGridDBColumn
              DataBinding.FieldName = 'BELGESERI'
              Width = 79
            end
            object GridMuhasebeFisleriViewBELGENO: TcxGridDBColumn
              DataBinding.FieldName = 'BELGENO'
              Width = 50
            end
            object GridMuhasebeFisleriViewACIKLAMA: TcxGridDBColumn
              DataBinding.FieldName = 'ACIKLAMA'
              Options.Editing = False
              Width = 23
            end
            object GridMuhasebeFisleriViewBORC: TcxGridDBColumn
              DataBinding.FieldName = 'BORC'
              Options.Editing = False
              Width = 21
            end
            object GridMuhasebeFisleriViewALACAK: TcxGridDBColumn
              DataBinding.FieldName = 'ALACAK'
              Options.Editing = False
              Width = 20
            end
            object GridMuhasebeFisleriViewZARF: TcxGridDBColumn
              DataBinding.FieldName = 'ZARF'
              Width = 23
            end
            object GridMuhasebeFisleriViewDOVIZCINSI: TcxGridDBColumn
              DataBinding.FieldName = 'DOVIZCINSI'
              PropertiesClassName = 'TcxTextEditProperties'
              Options.Editing = False
              Width = 41
            end
            object GridMuhasebeFisleriViewDOVIZKURU: TcxGridDBColumn
              DataBinding.FieldName = 'DOVIZKURU'
              Options.Editing = False
              Width = 86
            end
            object GridMuhasebeFisleriViewDOVIZMIKTAR: TcxGridDBColumn
              DataBinding.FieldName = 'DOVIZMIKTAR'
              Options.Editing = False
              Width = 28
            end
            object GridMuhasebeFisleriViewDVBORCTUTAR: TcxGridDBColumn
              DataBinding.FieldName = 'DVBORCTUTAR'
              Options.Editing = False
              Width = 28
            end
            object GridMuhasebeFisleriViewDVALACAKTUTAR: TcxGridDBColumn
              DataBinding.FieldName = 'DVALACAKTUTAR'
              Options.Editing = False
              Width = 30
            end
            object GridMuhasebeFisleriViewTABLO: TcxGridDBColumn
              DataBinding.FieldName = 'TABLOADI'
              Visible = False
            end
            object GridMuhasebeFisleriViewIDALAN: TcxGridDBColumn
              DataBinding.FieldName = 'IDALAN'
              Visible = False
            end
            object GridMuhasebeFisleriViewIDDEGER: TcxGridDBColumn
              DataBinding.FieldName = 'IDDEGER'
              Visible = False
            end
            object GridMuhasebeFisleriViewEKLEYEN: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEYEN'
              Width = 123
            end
            object GridMuhasebeFisleriViewEKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              Width = 102
            end
          end
          object GridMuhasebeFisleriLevel1: TcxGridLevel
            GridView = GridMuhasebeFisleriView
          end
        end
        object cxRadioGroup1: TcxRadioGroup
          Left = 0
          Top = 35
          Align = alLeft
          Caption = #304#351'lem Listesi'
          Properties.Items = <
            item
              Caption = 'T'#252'm'#252
            end
            item
              Caption = 'Al'#305#351' '#304'rsaliyeleri'
              Tag = 10
            end
            item
              Caption = 'Al'#305#351' Faturalar'#305
              Tag = 11
            end
            item
              Caption = 'Al'#305#351' Fi'#351'leri'
              Tag = 12
            end
            item
              Caption = 'Sat'#305#351' '#304'rsaliyeleri'
              Tag = 14
            end
            item
              Caption = 'Sat'#305#351' Faturalar'#305
              Tag = 15
            end
            item
              Caption = 'Sat'#305#351' Fi'#351'leri'
              Tag = 16
            end
            item
              Caption = 'Tahsilatlar'
            end
            item
              Caption = #214'demeler'
            end>
          ItemIndex = 0
          TabOrder = 2
          Visible = False
          Height = 397
          Width = 185
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1212
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 67
          Color = clTeal
          DockSite = True
          DrawingStyle = dsGradient
          EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
          EdgeInner = esLowered
          EdgeOuter = esNone
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          GradientEndColor = 11776947
          GradientStartColor = 14540253
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 3
          Transparent = True
          object YaziciYaz: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
        end
      end
      object TabSheetTahsilatlar: TcxTabSheet
        Caption = 'Tahsilatlar/'#214'demeler'
        ImageIndex = 1
        TabVisible = False
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 1218
          Height = 449
          Align = alClient
          BevelOuter = bvNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          object GroupBox2: TGroupBox
            Left = 0
            Top = 0
            Width = 1218
            Height = 449
            Align = alClient
            TabOrder = 0
            object GridTahsilat: TcxGrid
              Left = 2
              Top = 15
              Width = 1214
              Height = 407
              Align = alClient
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              object TahsilatView: TcxGridDBTableView
                PopupMenu = PopupMenu1
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = Tablo.dtsTahsilatListesi
                DataController.KeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = '###,###,###,###.00'
                    Kind = skSum
                    FieldName = 'BORC'
                  end
                  item
                    Format = '###,###,###,###.00'
                    Kind = skSum
                    FieldName = 'ALACAK'
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsView.Footer = True
                OptionsView.FooterAutoHeight = True
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.GroupRowStyle = grsOffice11
                object TahsilatViewSEC: TcxGridDBColumn
                  Caption = 'Se'#231
                  DataBinding.ValueType = 'Boolean'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  RepositoryItem = RepCheckBox
                end
                object TahsilatViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewMUHAKTAR: TcxGridDBColumn
                  DataBinding.FieldName = 'MUHAKTAR'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object TahsilatViewBELGETIPI: TcxGridDBColumn
                  DataBinding.FieldName = 'BELGETIPI'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewISLEMTIPI: TcxGridDBColumn
                  DataBinding.FieldName = 'ISLEMTIPI'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewHESAPKODU: TcxGridDBColumn
                  DataBinding.FieldName = 'HESAPKODU'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewHESAPADI: TcxGridDBColumn
                  DataBinding.FieldName = 'HESAPADI'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewBELGETARIHI: TcxGridDBColumn
                  DataBinding.FieldName = 'BELGETARIHI'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewBELGENO: TcxGridDBColumn
                  DataBinding.FieldName = 'BELGENO'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewTUTAR: TcxGridDBColumn
                  DataBinding.FieldName = 'TUTAR'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewACIKLAMA: TcxGridDBColumn
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewKARSIHESAPKODU: TcxGridDBColumn
                  DataBinding.FieldName = 'KARSIHESAPKODU'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewKARSIHESAPADI: TcxGridDBColumn
                  DataBinding.FieldName = 'KARSIHESAPADI'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewEKLEMETARIHI: TcxGridDBColumn
                  DataBinding.FieldName = 'EKLEMETARIHI'
                  DataBinding.IsNullValueType = True
                end
                object TahsilatViewSUBEID: TcxGridDBColumn
                  DataBinding.FieldName = 'SUBEID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
              end
              object cxGridLevel2: TcxGridLevel
                GridView = TahsilatView
              end
            end
            object Panel5: TPanel
              Left = 2
              Top = 422
              Width = 1214
              Height = 25
              Align = alBottom
              TabOrder = 1
              object Label3: TLabel
                Left = 7
                Top = 5
                Width = 91
                Height = 13
                Caption = 'Toplam Kay'#305't Say'#305's'#305
              end
              object LblTahKayitSay: TLabel
                Left = 108
                Top = 5
                Width = 7
                Height = 13
                Caption = '0'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clMaroon
                Font.Height = -11
                Font.Name = 'Tahoma'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object LblTahSeciliKayitSay: TLabel
                Left = 348
                Top = 5
                Width = 7
                Height = 13
                Caption = '0'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clMaroon
                Font.Height = -11
                Font.Name = 'Tahoma'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object Label11: TLabel
                Left = 246
                Top = 5
                Width = 80
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
              end
              object Label13: TLabel
                Left = 431
                Top = 5
                Width = 81
                Height = 13
                Caption = 'Se'#231'ili Kay'#305't Tutar'#305
                Visible = False
              end
              object LblTahSeciliKayitTutar: TcxCurrencyEdit
                Left = 537
                Top = 2
                RepositoryItem = Tablo.RepCurrencyGenel
                Enabled = False
                Properties.DisplayFormat = ',0.00;-,0.00'
                StyleDisabled.BorderColor = clBtnFace
                StyleDisabled.BorderStyle = ebsOffice11
                StyleDisabled.Color = 14532004
                StyleDisabled.TextColor = clWindowText
                TabOrder = 0
                Visible = False
                Width = 88
              end
            end
            object SqlTahsilat: TMemo
              Left = 110
              Top = 240
              Width = 642
              Height = 49
              Lines.Strings = (
                'Declare @TarihBas SmallDateTime'
                'Declare @TarihBit SmallDateTime'
                'set @TarihBas =:TBas'
                'set @TarihBit =:TBit'
                ''
                '--Kasa'
                
                  'Select  MG.KOD AS MASRAFKOD,K.ID, ISLEMTARIHI AS KAYITTARIH, PLA' +
                  'NTARIHI AS AKSIYONTARIH, K.TUR,BELGENO, '
                'REHBERID,'
                'CARIKOD=R.KOD, '
                'CARIAD=R.FIRMA, K.ACIKLAMA, HESAPID, '
                '     HESAPKODU=case HESAPTURU '
                
                  '         when '#39'B'#39' then (select HESAPKODU from BANKAHESAPLAR BH w' +
                  'here BH.ID=K.HESAPID) '
                
                  '         when '#39'K'#39' then (select KASAKODU from KASALAR K2 where K2' +
                  '.ID=K.HESAPID)'
                
                  '         when '#39'H'#39' then (select KASAKODU from KASALAR K2 where K2' +
                  '.ID=K.HESAPID)'
                
                  '         when '#39'P'#39' then (select HESAPKODU = KODU from POS P where' +
                  ' P.ID=K.HESAPID) '
                
                  '         when '#39'V'#39' then (select HESAPKODU = KODU from KREDIKARTI ' +
                  'KK where KK.ID=K.HESAPID) '
                '     end,'
                '     HESAPADI=case HESAPTURU '
                
                  '         when '#39'B'#39' then (select HESAPADI from BANKAHESAPLAR BH wh' +
                  'ere BH.ID=K.HESAPID) '
                
                  '         when '#39'K'#39' then (select KASAADI from KASALAR K2 where K2.' +
                  'ID=K.HESAPID)'
                
                  '         when '#39'H'#39' then (select KASAADI from KASALAR K2 where K2.' +
                  'ID=K.HESAPID)'
                
                  '         when '#39'P'#39' then (select ADI from POS P where P.ID=K.HESAP' +
                  'ID) '
                
                  '         when '#39'V'#39' then (select ADI from KREDIKARTI KK where KK.I' +
                  'D=K.HESAPID) '
                '         '
                '     end,'
                '     TUTAR=case when '
                
                  #9'  (case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51,52,53,' +
                  '54) and isnull(HESAPTURU,'#39#39')<>'#39#39' then '
                'ALACAK '
                'else BORC end)=0'
                #9'then '
                
                  #9'  case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51,52,53,5' +
                  '4) and  isnull(HESAPTURU,'#39#39')<>'#39#39' then '
                'BORC else '
                'ALACAK end'
                #9'else '
                
                  #9'  case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51,52,53,5' +
                  '4) and isnull(HESAPTURU,'#39#39')<>'#39#39' then '
                'ALACAK '
                'else BORC end'
                #9'end,'
                
                  '      BORC = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,' +
                  '51,52,53,54) and isnull(HESAPTURU,'#39#39')<>'#39#39' then '
                'ALACAK '
                'else BORC end,'
                
                  '     ALACAK = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48' +
                  ',51,52,53,54) and  isnull(HESAPTURU,'#39#39')<>'#39#39' then '
                'BORC '
                'else ALACAK end,'
                ''
                ' DOVIZ_TUTARI, KASA, ONAY, K.EKLEYEN, '
                '       MASRAFKOD=MG.KOD, MASRAFAD=MG.AD, '
                '       K.KUR, GERIDONUSID,  FATURAID, '
                'CEKSENETID,KREDIID ,'
                'K.YERI, K.YERID,K.SUBEID,K.MUHAKTAR  '
                'FROM KASA K (NOLOCK)'
                '     left outer join REHBER R on R.ID=K.REHBERID'
                '     left outer join MASRAFGELIR MG on MG.ID=K.MASRAFID'
                
                  ' Where  K.ISLEMTARIHI >= @TarihBas and K.ISLEMTARIHI < @TarihBit' +
                  ' and K.TUR<>1 and K.REHBERID <> 0 <SubeKasa>'
                'UNION ALL'
                '---'#231'ek '#246'deme / tahsilat'
                'SELECT '
                
                  #9' M.KOD AS MASRAFKOD, K.ID,K.TARIH as KAYITTARIH,K.VADE as AKSIY' +
                  'ONTARIH,   '
                
                  '                TUR=(Case When (Select ISNULL(CIROLU,0) From CEK' +
                  'LER Where ID=K.ID)=0 then K.TUR else 33 end ),'#9
                #9'MAKBUZNO as BELGENO,REHBERID, CARIKOD=R.KOD,'
                
                  '                CARIAD=case When isnull((Select ISNULL(CIROLU,0)' +
                  ' From CEKLER Where ID=K.ID),0)=0 then R.FIRMA else '
                'Rciro.FIRMA end,'
                #9'K.ACIKLAMA,'
                
                  #9'HESAPID=null,HESAPKODU=K.KOD,HESAPADI=(select HESAPADI from HES' +
                  'APPLANI where HESAPKODU=K.KOD),'
                
                  #9'TUTAR=case when (case when (Case When (Select ISNULL(CIROLU,0) ' +
                  'From CEKLER Where ID=K.ID)=0 then K.TUR '
                'else 33 end )=33  then '
                'K.TUTAR else 0    end)=0 '
                #9'then'
                
                  #9'  (case when (Case When (Select ISNULL(CIROLU,0) From CEKLER Wh' +
                  'ere ID=K.ID)=0 then K.TUR else 33 end )=23  '
                'then K.TUTAR else 0 end) '
                #9'else '
                
                  #9' (case when (Case When (Select ISNULL(CIROLU,0) From CEKLER Whe' +
                  're ID=K.ID)=0 then K.TUR else 33 end )=33  '
                'then K.TUTAR else 0    '
                'end) '
                #9'end, '
                
                  #9'BORC = case when (Case When (Select ISNULL(CIROLU,0) From CEKLE' +
                  'R Where ID=K.ID)=0 then K.TUR else 33 end '
                ')=33  then  K.TUTAR else '
                '0    end,'
                
                  #9'ALACAK = case when (Case When (Select ISNULL(CIROLU,0) From CEK' +
                  'LER Where ID=K.ID)=0 then K.TUR else 33 '
                'end )=23  then  K.TUTAR '
                'else 0    end,'
                #9'DOVIZ_TUTARI=0,KASA=0,ONAY=NULL, '
                #9'K.EKLEYEN ,MASRAFKOD = M.KOD,'#9'MASRAFAD=M.AD,'
                #9'K.KUR,GERIDONUSID=NULL,FATURAID, '
                #9'CEKSENETID=K.ID,KREDIID=null '
                ',YERI=NULL, YERID=NULL,K.SUBEID ,K.MUHAKTAR '
                'FROM '
                #9'CEKLER K'
                #9'left outer join REHBER R on R.ID=K.REHBERID'
                
                  '                left outer join REHBER Rciro on Rciro.ID=K.CIROR' +
                  'EHBERID'
                #9'left outer JOIN BANKASUBELER BS ON BS.ID = K.BANKASUBELERID'
                #9'left outer JOIN BANKALAR B ON B.BANKAKODU = BS.BANKAKODU'
                #9'left outer join MASRAFGELIR M on M.ID=K.MASRAFID'
                ' Where  K.TARIH >= @TarihBas and K.TARIH < @TarihBit '
                '  <SubeCekSenet>'
                ''
                'UNION ALL'
                '---senet '#246'deme / tahsilat'
                'SELECT '
                
                  #9'MG.KOD AS MASRAFKOD, K.ID,K.TARIH as KAYITTARIH,K.VADE as AKSIY' +
                  'ONTARIH,   K.TUR, '#9
                #9'MAKBUZNO as BELGENO,REHBERID, CARIKOD=R.KOD, CARIAD=R.FIRMA, '
                #9'K.ACIKLAMA,'
                #9'HESAPID=null,HESAPKODU=K.KOD,HESAPADI=null,'
                #9'TUTAR=case when '
                #9'  (case when K.TUR=34 then  K.TUTAR else 0    end)=0'
                #9'then '
                #9'  case when K.TUR=24 then  K.TUTAR else 0    end'
                #9'else '
                #9'  case when K.TUR=34 then  K.TUTAR else 0    end'
                #9'end,'
                #9'BORC = case when K.TUR=34 then  K.TUTAR else 0    end,'
                #9'ALACAK = case when K.TUR=24 then  K.TUTAR else 0    end,'
                #9'DOVIZ_TUTARI=0,KASA=0,ONAY=NULL, '
                #9'K.EKLEYEN, MASRAFKOD = MG.KOD,'#9'MASRAFAD=MG.AD,'
                #9'K.KUR,GERIDONUSID=NULL,FATURAID, '
                #9'CEKSENETID=NULL,KREDIID=null '
                ',YERI=NULL, YERID=NULL,K.SUBEID,K.MUHAKTAR '
                'FROM '
                #9'SENETLER K'
                #9'inner join REHBER R on R.ID=K.REHBERID'
                #9'left outer join MASRAFGELIR MG on MG.ID=K.MASRAFID'
                ' Where  K.TARIH >= @TarihBas and K.TARIH < @TarihBit '
                '   <SubeCekSenet>'
                ' order by 2 ')
              TabOrder = 2
              Visible = False
            end
          end
        end
        object cxSplitterTahsilat: TcxSplitter
          Left = 0
          Top = 449
          Width = 1218
          Height = 8
          HotZoneClassName = 'TcxSimpleStyle'
          AlignSplitter = salBottom
          AutoSnap = True
          Control = TabSheetTahsilatlar
        end
      end
      object TabSheetCekler: TcxTabSheet
        Caption = #199'ekler'
        ImageIndex = 8
        TabVisible = False
        object Panel11: TPanel
          Left = 0
          Top = 432
          Width = 1218
          Height = 25
          Align = alBottom
          TabOrder = 0
          object Label16: TLabel
            Left = 7
            Top = 5
            Width = 91
            Height = 13
            Caption = 'Toplam Kay'#305't Say'#305's'#305
          end
          object lblCeklerToplamKayitSayisi: TLabel
            Left = 108
            Top = 5
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblCeklerSeciliKayitSayisi: TLabel
            Left = 348
            Top = 5
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label23: TLabel
            Left = 246
            Top = 5
            Width = 80
            Height = 13
            Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
          end
          object Label24: TLabel
            Left = 431
            Top = 5
            Width = 81
            Height = 13
            Caption = 'Se'#231'ili Kay'#305't Tutar'#305
            Visible = False
          end
          object edtSeciliKayitTutari: TcxCurrencyEdit
            Left = 537
            Top = 2
            RepositoryItem = Tablo.RepCurrencyGenel
            Enabled = False
            Properties.DisplayFormat = ',0.00;-,0.00'
            StyleDisabled.BorderColor = clBtnFace
            StyleDisabled.BorderStyle = ebsOffice11
            StyleDisabled.Color = 14532004
            StyleDisabled.TextColor = clWindowText
            TabOrder = 0
            Visible = False
            Width = 88
          end
        end
        object GridCekler: TcxGrid
          Left = 0
          Top = 0
          Width = 1218
          Height = 432
          Align = alClient
          TabOrder = 1
          object GridCeklerView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = Tablo.DtsCekler
            DataController.KeyFieldNames = 'ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            object GridCeklerViewSec: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              RepositoryItem = RepCheckBox
            end
            object GridCeklerViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 54
            end
            object GridCeklerViewMUHAKTAR: TcxGridDBColumn
              DataBinding.FieldName = 'MUHAKTAR'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
            end
            object GridCeklerViewISLEMTIPI: TcxGridDBColumn
              DataBinding.FieldName = 'ISLEMTIPI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <
                item
                  Description = 'Tahsilat'
                  ImageIndex = 0
                  Value = -1
                end
                item
                  Description = 'Tediye'
                  Value = 1
                end>
              Options.Editing = False
              Width = 57
            end
            object GridCeklerViewBELGETIPI: TcxGridDBColumn
              DataBinding.FieldName = 'BELGETIPI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <
                item
                  Description = #199'ek'
                  ImageIndex = 0
                  Value = 1
                end>
              Options.Editing = False
              Width = 60
            end
            object GridCeklerViewCEKHAREKETTIPI: TcxGridDBColumn
              DataBinding.FieldName = 'CEKHAREKETTIPI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <
                item
                  Description = 'Portf'#246'yde'
                  ImageIndex = 0
                  Value = -1
                end
                item
                  Description = 'Ciro Edildi'
                  Value = '00'
                end
                item
                  Description = 'Tahsile Verildi'
                  Value = '01'
                end
                item
                  Description = 'Kar'#351#305'l'#305'ks'#305'z'
                  Value = '05'
                end
                item
                  Description = #199'ek '#304'ade'
                  Value = '04'
                end
                item
                  Description = 'Teminata Verildi'
                  Value = '02'
                end
                item
                  Description = 'Virman Edildi'
                  Value = '08'
                end>
              Options.Editing = False
              Width = 89
            end
            object GridCeklerViewHESAPKODU: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPKODU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewHESAPADI: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewBELGENO: TcxGridDBColumn
              DataBinding.FieldName = 'BELGENO'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewBELGETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'BELGETARIHI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewACIKLAMA: TcxGridDBColumn
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewKARSIHESAPKODU: TcxGridDBColumn
              DataBinding.FieldName = 'KARSIHESAPKODU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewKARSIHESAPADI: TcxGridDBColumn
              DataBinding.FieldName = 'KARSIHESAPADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewBANKAKODU: TcxGridDBColumn
              DataBinding.FieldName = 'BANKAKODU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewSUBEKODU: TcxGridDBColumn
              DataBinding.FieldName = 'SUBEKODU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewSUBEADI: TcxGridDBColumn
              DataBinding.FieldName = 'SUBEADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewCEKHESAPNO: TcxGridDBColumn
              DataBinding.FieldName = 'CEKHESAPNO'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewCEKNO: TcxGridDBColumn
              DataBinding.FieldName = 'CEKNO'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewTUTAR: TcxGridDBColumn
              DataBinding.FieldName = 'TUTAR'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object GridCeklerViewSUBEID: TcxGridDBColumn
              DataBinding.FieldName = 'SUBEID'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
            end
            object GridCeklerViewEKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
          end
          object GridCeklerLevel1: TcxGridLevel
            GridView = GridCeklerView
          end
        end
      end
      object TabSheetStokListesi: TcxTabSheet
        Caption = 'Stoklar'
        ImageIndex = 3
        TabVisible = False
        object GridStokListesi: TcxGrid
          Left = 0
          Top = 0
          Width = 1218
          Height = 432
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          object StokListesiView: TcxGridDBTableView
            PopupMenu = PopupMenu1
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = Tablo.DtsTabStoklar
            DataController.KeyFieldNames = 'ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = '###,###,###,###.00'
                Kind = skSum
                FieldName = 'FATURA_TUTARI'
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.GroupRowStyle = grsOffice11
            object StokListesiViewSEC: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              RepositoryItem = RepCheckBox
              Width = 28
            end
            object StokListesiViewSTOKID: TcxGridDBColumn
              DataBinding.FieldName = 'STOKID'
              DataBinding.IsNullValueType = True
            end
            object StokListesiViewSTOKTIPI: TcxGridDBColumn
              Caption = 'Tipi'
              DataBinding.FieldName = 'STOKTIPI'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 114
            end
            object StokListesiViewKOD: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 126
            end
            object StokListesiViewSTOKADI: TcxGridDBColumn
              Caption = 'Stok Ad'#305
              DataBinding.FieldName = 'STOKADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 216
            end
            object StokListesiViewMUHKODU: TcxGridDBColumn
              Caption = 'MuhKodu'
              DataBinding.FieldName = 'MUHKODU'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 140
            end
            object StokListesiViewSTOKMARKA: TcxGridDBColumn
              Caption = 'Marka'
              DataBinding.FieldName = 'STOKMARKA'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 99
            end
            object StokListesiViewSTOKMODEL: TcxGridDBColumn
              Caption = 'Model'
              DataBinding.FieldName = 'STOKMODEL'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 80
            end
            object StokListesiViewKDV: TcxGridDBColumn
              DataBinding.FieldName = 'KDV'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 34
            end
            object StokListesiViewMUHAKTAR: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'MUHAKTAR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepMuhAktarDurum
              Visible = False
              Options.Editing = False
              Width = 138
            end
            object StokListesiViewNOTLAR: TcxGridDBColumn
              Caption = 'Notlar'
              DataBinding.FieldName = 'NOTLAR'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 413
            end
            object StokListesiViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewTIPI: TcxGridDBColumn
              DataBinding.FieldName = 'TIPI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewMARKA: TcxGridDBColumn
              DataBinding.FieldName = 'MARKA'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewMODEL: TcxGridDBColumn
              DataBinding.FieldName = 'MODEL'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewGRUBU: TcxGridDBColumn
              DataBinding.FieldName = 'GRUBU'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewOZELLIK: TcxGridDBColumn
              DataBinding.FieldName = 'OZELLIK'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewICERIK: TcxGridDBColumn
              DataBinding.FieldName = 'ICERIK'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewOZELKOD: TcxGridDBColumn
              DataBinding.FieldName = 'OZELKOD'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewSUBEID: TcxGridDBColumn
              DataBinding.FieldName = 'SUBEID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewANABIRIM: TcxGridDBColumn
              DataBinding.FieldName = 'ANABIRIM'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewSTOKBIRIM: TcxGridDBColumn
              DataBinding.FieldName = 'STOKBIRIM'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewBIRIM2: TcxGridDBColumn
              DataBinding.FieldName = 'BIRIM2'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewBIRIM2MIKTAR: TcxGridDBColumn
              DataBinding.FieldName = 'BIRIM2MIKTAR'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewMINSTOK: TcxGridDBColumn
              DataBinding.FieldName = 'MINSTOK'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewDURUM: TcxGridDBColumn
              DataBinding.FieldName = 'DURUM'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewIZLEME: TcxGridDBColumn
              DataBinding.FieldName = 'IZLEME'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object StokListesiViewEKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object cxGridLevel6: TcxGridLevel
            GridView = StokListesiView
          end
        end
        object Panel6: TPanel
          Left = 0
          Top = 432
          Width = 1218
          Height = 25
          Align = alBottom
          TabOrder = 1
          object Label12: TLabel
            Left = 7
            Top = 7
            Width = 91
            Height = 13
            Caption = 'Toplam Kay'#305't Say'#305's'#305
          end
          object LblStokKayitSayisi: TLabel
            Left = 108
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object LblStokSeciliSayisi: TLabel
            Left = 348
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label17: TLabel
            Left = 247
            Top = 7
            Width = 80
            Height = 13
            Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
          end
        end
      end
      object TabSheetCariListesi: TcxTabSheet
        Caption = 'Cariler'
        ImageIndex = 4
        object Panel7: TPanel
          Left = 0
          Top = 432
          Width = 1218
          Height = 25
          Align = alBottom
          TabOrder = 0
          object Label15: TLabel
            Left = 7
            Top = 7
            Width = 91
            Height = 13
            Caption = 'Toplam Kay'#305't Say'#305's'#305
          end
          object LblCariKayitSayisi: TLabel
            Left = 108
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object LblCariSeciliSayisi: TLabel
            Left = 348
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label19: TLabel
            Left = 247
            Top = 7
            Width = 80
            Height = 13
            Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
          end
        end
        object GridCariListesi: TcxGrid
          Left = 0
          Top = 0
          Width = 1218
          Height = 432
          Align = alClient
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          object CariListesiView: TcxGridDBTableView
            PopupMenu = PopupMenu1
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = Tablo.DtsTabCari
            DataController.KeyFieldNames = 'ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = '###,###,###,###.00'
                Kind = skSum
                FieldName = 'FATURA_TUTARI'
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.GroupRowStyle = grsOffice11
            object CariListesiViewSEC: TcxGridDBColumn
              Caption = 'SE'#199
              DataBinding.ValueType = 'Boolean'
              RepositoryItem = RepCheckBox
            end
            object CariListesiViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 44
            end
            object CariListesiViewKOD: TcxGridDBColumn
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 146
            end
            object CariListesiViewFIRMA: TcxGridDBColumn
              DataBinding.FieldName = 'FIRMA'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 48
            end
            object CariListesiViewILGILI: TcxGridDBColumn
              DataBinding.FieldName = 'ILGILI'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 102
            end
            object CariListesiViewSINIF: TcxGridDBColumn
              DataBinding.FieldName = 'SINIF'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 38
            end
            object CariListesiViewMUHKODU: TcxGridDBColumn
              DataBinding.FieldName = 'MUHKODU'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 38
            end
            object CariListesiViewISTEL: TcxGridDBColumn
              DataBinding.FieldName = 'ISTEL'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 76
            end
            object CariListesiViewCEP: TcxGridDBColumn
              DataBinding.FieldName = 'CEP'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 73
            end
            object CariListesiViewFAX: TcxGridDBColumn
              DataBinding.FieldName = 'FAX'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 74
            end
            object CariListesiViewVNO: TcxGridDBColumn
              DataBinding.FieldName = 'VNO'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 73
            end
            object CariListesiViewVD: TcxGridDBColumn
              DataBinding.FieldName = 'VD'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 75
            end
            object CariListesiViewVDNO: TcxGridDBColumn
              DataBinding.FieldName = 'VDNO'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 46
            end
            object CariListesiViewADRES: TcxGridDBColumn
              DataBinding.FieldName = 'ADRES'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 44
            end
            object CariListesiViewILCE: TcxGridDBColumn
              DataBinding.FieldName = 'ILCE'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 76
            end
            object CariListesiViewIL: TcxGridDBColumn
              DataBinding.FieldName = 'IL'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 69
            end
            object CariListesiViewPK: TcxGridDBColumn
              DataBinding.FieldName = 'PK'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 77
            end
            object CariListesiViewWEB: TcxGridDBColumn
              DataBinding.FieldName = 'WEB'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 75
            end
            object CariListesiViewEMAIL: TcxGridDBColumn
              DataBinding.FieldName = 'EMAIL'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 73
            end
            object CariListesiViewMUHAKTAR: TcxGridDBColumn
              DataBinding.FieldName = 'MUHAKTAR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepMuhAktarDurum
              Options.Editing = False
              Width = 55
            end
            object CariListesiViewKATEGORI: TcxGridDBColumn
              DataBinding.FieldName = 'KATEGORI'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 44
            end
            object CariListesiViewSUBEID: TcxGridDBColumn
              DataBinding.FieldName = 'SUBEID'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 47
            end
            object CariListesiViewEKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 45
            end
          end
          object cxGridLevel7: TcxGridLevel
            GridView = CariListesiView
          end
        end
      end
      object TabSheetPersonelListesi: TcxTabSheet
        Caption = 'Personel'
        ImageIndex = 5
        object Panel2: TPanel
          Left = 0
          Top = 432
          Width = 1218
          Height = 25
          Align = alBottom
          TabOrder = 0
          object Label7: TLabel
            Left = 7
            Top = 7
            Width = 91
            Height = 13
            Caption = 'Toplam Kay'#305't Say'#305's'#305
          end
          object lblPersonelToplamKayitSayisi: TLabel
            Left = 108
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPersonelSeciliKayitSayisi: TLabel
            Left = 348
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label18: TLabel
            Left = 247
            Top = 7
            Width = 80
            Height = 13
            Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
          end
        end
        object GridPersonelListesi: TcxGrid
          Left = 0
          Top = 0
          Width = 1218
          Height = 432
          Align = alClient
          TabOrder = 1
          object PersonelListesiView: TcxGridDBTableView
            PopupMenu = PopupMenu1
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = Tablo.DtsPersonelListesi
            DataController.KeyFieldNames = 'ID'
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsView.CellAutoHeight = True
            OptionsView.ColumnAutoWidth = True
            object PersonelListesiViewSEC: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              RepositoryItem = RepCheckBox
            end
            object PersonelListesiViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewKOD: TcxGridDBColumn
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object PersonelListesiViewFIRMA: TcxGridDBColumn
              DataBinding.FieldName = 'FIRMA'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 266
            end
            object PersonelListesiViewKARTNO: TcxGridDBColumn
              DataBinding.FieldName = 'KARTNO'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object PersonelListesiViewTCKIMLIKNO: TcxGridDBColumn
              DataBinding.FieldName = 'TCKIMLIKNO'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object PersonelListesiViewCEPTELEFON: TcxGridDBColumn
              DataBinding.FieldName = 'CEPTELEFON'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 96
            end
            object PersonelListesiViewCEP: TcxGridDBColumn
              DataBinding.FieldName = 'CEP'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewMUHKODU: TcxGridDBColumn
              DataBinding.FieldName = 'MUHKODU'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
            end
            object PersonelListesiViewSINIF: TcxGridDBColumn
              DataBinding.FieldName = 'SINIF'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 272
            end
            object PersonelListesiViewEKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 163
            end
            object PersonelListesiViewMUHAKTAR: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'MUHAKTAR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepMuhAktarDurum
              Visible = False
              Options.Editing = False
              Width = 127
            end
            object PersonelListesiViewILGILI: TcxGridDBColumn
              DataBinding.FieldName = 'ILGILI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewISTEL: TcxGridDBColumn
              DataBinding.FieldName = 'ISTEL'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewFAX: TcxGridDBColumn
              DataBinding.FieldName = 'FAX'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewVNO: TcxGridDBColumn
              DataBinding.FieldName = 'VNO'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewVD: TcxGridDBColumn
              DataBinding.FieldName = 'VD'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewVDNO: TcxGridDBColumn
              DataBinding.FieldName = 'VDNO'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewADRES: TcxGridDBColumn
              DataBinding.FieldName = 'ADRES'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewILCE: TcxGridDBColumn
              DataBinding.FieldName = 'ILCE'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewIL: TcxGridDBColumn
              DataBinding.FieldName = 'IL'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewPK: TcxGridDBColumn
              DataBinding.FieldName = 'PK'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewWEB: TcxGridDBColumn
              DataBinding.FieldName = 'WEB'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewEMAIL: TcxGridDBColumn
              DataBinding.FieldName = 'EMAIL'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewKATEGORI: TcxGridDBColumn
              DataBinding.FieldName = 'KATEGORI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewSUBEID: TcxGridDBColumn
              DataBinding.FieldName = 'SUBEID'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
            object PersonelListesiViewAILESIRANO: TcxGridDBColumn
              DataBinding.FieldName = 'AILESIRANO'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewCILTNO: TcxGridDBColumn
              DataBinding.FieldName = 'CILTNO'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewCINSIYET: TcxGridDBColumn
              DataBinding.FieldName = 'CINSIYET'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewDOGUMYERI: TcxGridDBColumn
              DataBinding.FieldName = 'DOGUMYERI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewDOGUMTARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'DOGUMTARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewANAADI: TcxGridDBColumn
              DataBinding.FieldName = 'ANAADI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewBABAADI: TcxGridDBColumn
              DataBinding.FieldName = 'BABAADI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewNUFUSIL: TcxGridDBColumn
              DataBinding.FieldName = 'NUFUSIL'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewNUFUSILCE: TcxGridDBColumn
              DataBinding.FieldName = 'NUFUSILCE'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewBIREYSIRANO: TcxGridDBColumn
              DataBinding.FieldName = 'BIREYSIRANO'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewISTEL1: TcxGridDBColumn
              DataBinding.FieldName = 'ISTEL1'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewISTEL2: TcxGridDBColumn
              DataBinding.FieldName = 'ISTEL2'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewEPOSTA: TcxGridDBColumn
              DataBinding.FieldName = 'EPOSTA'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewPOSTAKOD: TcxGridDBColumn
              DataBinding.FieldName = 'POSTAKOD'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewKANGRUBU: TcxGridDBColumn
              DataBinding.FieldName = 'KANGRUBU'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewISEGIRISTARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'ISBASLANGIC'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 92
            end
            object PersonelListesiViewNETMAAS: TcxGridDBColumn
              DataBinding.FieldName = 'NETMAAS'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
            end
            object PersonelListesiViewISTENCIKISTARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'ISTENCIKISTARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
            end
            object PersonelListesiViewSIRA: TcxGridDBColumn
              DataBinding.FieldName = 'SIRA'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object PersonelListesiViewSSKBASLANGIC: TcxGridDBColumn
              DataBinding.FieldName = 'SSKBASLANGIC'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 99
            end
            object PersonelListesiViewMESLEKKODU: TcxGridDBColumn
              DataBinding.FieldName = 'MESLEKKODU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 84
            end
          end
          object GridPersonelListesiLevel1: TcxGridLevel
            GridView = PersonelListesiView
          end
        end
      end
      object TabSheetDemirbasListesi: TcxTabSheet
        Caption = 'Demirba'#351
        ImageIndex = 6
        object GridDemirbasListesi: TcxGrid
          Left = 0
          Top = 0
          Width = 1218
          Height = 457
          Align = alClient
          TabOrder = 0
          object GridDemirbasListesiView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
          end
          object GridDemirbasListesiLevel1: TcxGridLevel
            GridView = GridDemirbasListesiView
          end
        end
      end
      object TabSheetPDKSListesi: TcxTabSheet
        Caption = 'PDKS'
        ImageIndex = 7
        object Panel9: TPanel
          Left = 0
          Top = 432
          Width = 1218
          Height = 25
          Align = alBottom
          TabOrder = 0
          object Label10: TLabel
            Left = 7
            Top = 7
            Width = 91
            Height = 13
            Caption = 'Toplam Kay'#305't Say'#305's'#305
          end
          object lblPDKSToplamKayitSayisi: TLabel
            Left = 108
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPDKSSeciliKayitSayisi: TLabel
            Left = 348
            Top = 7
            Width = 7
            Height = 13
            Caption = '0'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label21: TLabel
            Left = 247
            Top = 7
            Width = 80
            Height = 13
            Caption = 'Se'#231'ili Kay'#305't Say'#305's'#305
          end
        end
        object Panel10: TPanel
          Left = 0
          Top = 0
          Width = 1218
          Height = 432
          Align = alClient
          TabOrder = 1
          object GridPDKSListesi: TcxGrid
            Left = 1
            Top = 1
            Width = 1216
            Height = 430
            Align = alClient
            TabOrder = 0
            object GridPDKSListesiView: TcxGridDBTableView
              PopupMenu = PopupMenu1
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = Tablo.DtsPDKSListesi
              DataController.KeyFieldNames = 'ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              object GridPDKSListesiViewSEC: TcxGridDBColumn
                Caption = 'SE'#199
                DataBinding.ValueType = 'Boolean'
                RepositoryItem = RepCheckBox
                Width = 23
              end
              object GridPDKSListesiViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 39
              end
              object GridPDKSListesiViewREHBERID: TcxGridDBColumn
                DataBinding.FieldName = 'REHBERID'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 50
              end
              object GridPDKSListesiViewR: TcxGridDBColumn
                DataBinding.FieldName = 'R'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridPDKSListesiViewMUHAKTAR: TcxGridDBColumn
                DataBinding.FieldName = 'MUHAKTAR'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepMuhAktarDurum
                Options.Editing = False
                Width = 53
              end
              object GridPDKSListesiViewKARTNO: TcxGridDBColumn
                DataBinding.FieldName = 'KARTNO'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 109
              end
              object GridPDKSListesiViewFIRMA: TcxGridDBColumn
                DataBinding.FieldName = 'FIRMA'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 151
              end
              object GridPDKSListesiViewGUNADI: TcxGridDBColumn
                DataBinding.FieldName = 'GUNADI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 44
              end
              object GridPDKSListesiViewGIRIS: TcxGridDBColumn
                DataBinding.FieldName = 'GIRIS'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Options.Editing = False
                Width = 65
              end
              object GridPDKSListesiViewCIKIS: TcxGridDBColumn
                DataBinding.FieldName = 'CIKIS'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 68
              end
              object GridPDKSListesiViewSUBEID: TcxGridDBColumn
                DataBinding.FieldName = 'SUBEID'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 50
              end
              object GridPDKSListesiViewDURUM: TcxGridDBColumn
                DataBinding.FieldName = 'DURUM'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 45
              end
              object GridPDKSListesiViewMUHKODU: TcxGridDBColumn
                DataBinding.FieldName = 'MUHKODU'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 51
              end
              object GridPDKSListesiViewISEGIRISTARIHI: TcxGridDBColumn
                DataBinding.FieldName = 'ISEGIRISTARIHI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 68
              end
              object GridPDKSListesiViewISDENAYRILMATARIHI: TcxGridDBColumn
                DataBinding.FieldName = 'ISDENAYRILMATARIHI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 73
              end
              object GridPDKSListesiViewTCNO: TcxGridDBColumn
                DataBinding.FieldName = 'TCNO'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 279
              end
              object GridPDKSListesiViewVARGIRISCIKIS: TcxGridDBColumn
                DataBinding.FieldName = 'VARGIRISCIKIS'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 91
              end
              object GridPDKSListesiViewGIRFARK: TcxGridDBColumn
                DataBinding.FieldName = 'GIRFARK'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 23
              end
              object GridPDKSListesiViewCALSURE: TcxGridDBColumn
                DataBinding.FieldName = 'CALSURE'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 20
              end
              object GridPDKSListesiViewCALFARK: TcxGridDBColumn
                DataBinding.FieldName = 'CALFARK'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 23
              end
              object GridPDKSListesiViewCIKFARK: TcxGridDBColumn
                DataBinding.FieldName = 'CIKFARK'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 20
              end
            end
            object GridPDKSListesiLevel1: TcxGridLevel
              GridView = GridPDKSListesiView
            end
          end
        end
      end
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xml'
    Filter = 'XML Dosyalar|*.xml'
    Left = 913
    Top = 66
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.ImageList1
    OwnerDraw = True
    Left = 352
    Top = 264
    object mnSe1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      ImageIndex = 3
      OnClick = mnSe1Click
    end
    object mnKaldr1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      ImageIndex = 7
      OnClick = mnKaldr1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object AktarlmadOlarakaretle1: TMenuItem
      Caption = 'Se'#231'ilenleri Aktar'#305'lmad'#305' Olarak '#304#351'aretle'
      ImageIndex = 15
      OnClick = AktarlmadOlarakaretle1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object ListeyiExceleAktar1: TMenuItem
      Caption = 'Listeyi Excel'#39'e Aktar'
      ImageIndex = 16
      OnClick = ListeyiExceleAktar1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object lkkaydse1: TMenuItem
      Caption = 'Se'#231'ilecek Kay'#305't Say'#305's'#305
      Visible = False
      object N5001: TMenuItem
        Caption = '500'
        Hint = '500'
        OnClick = N5001Click
      end
      object N4001: TMenuItem
        Caption = '400'
        Hint = '400'
        OnClick = N5001Click
      end
      object N3001: TMenuItem
        Caption = '300'
        Hint = '300'
        OnClick = N5001Click
      end
      object N2001: TMenuItem
        Caption = '200'
        Hint = '200'
        OnClick = N5001Click
      end
      object N1001: TMenuItem
        Caption = '100'
        Hint = '100'
        OnClick = N5001Click
      end
    end
    object N4: TMenuItem
      Caption = '-'
      Visible = False
    end
    object KimlieEriim1: TMenuItem
      Caption = 'Kimli'#287'e Eri'#351'im'
      Visible = False
      OnClick = KimlieEriim1Click
    end
    object N5: TMenuItem
      Caption = '-'
      Visible = False
    end
    object mnSecilenleriAktarimIcinOnayla: TMenuItem
      Tag = 1
      Caption = 'Se'#231'ilenleri Aktar'#305'm '#304#231'in Onayla'
      Visible = False
      OnClick = mnSecilenleriAktarimIcinOnaylaClick
    end
    object mnSecilenleriAktarimOnayIptal: TMenuItem
      Caption = 'Se'#231'ilenlerin Aktar'#305'labilir Onay'#305'n'#305' kald'#305'r'
      Visible = False
      OnClick = mnSecilenleriAktarimIcinOnaylaClick
    end
  end
  object StoreGridProperties: TcxPropertiesStore
    Components = <>
    StorageName = 'StoreGridProperties'
    StorageType = stRegistry
    Left = 586
    Top = 319
  end
  object pmFaturalar: TcxGridPopupMenu
    PopupMenus = <>
    Left = 512
    Top = 288
  end
  object DdeConv: TDdeClientConv
    Left = 816
    Top = 72
  end
  object DdeClientItem: TDdeClientItem
    DdeConv = DdeConv
    Left = 864
    Top = 72
  end
  object cxEditRepository1: TcxEditRepository
    Left = 432
    Top = 272
    PixelsPerInch = 96
    object RepCheckBox: TcxEditRepositoryCheckBoxItem
      Properties.ImmediatePost = True
      Properties.NullStyle = nssUnchecked
      Properties.OnChange = RepCheckBoxPropertiesChange
    end
  end
  object PopupKontrol: TPopupMenu
    Images = Tablo.ImageList1
    OwnerDraw = True
    Left = 376
    Top = 96
    object HatalFiler1: TMenuItem
      Caption = 'Gentegrede Hatal'#305' Fi'#351'ler (Bor'#231'-Alacak Fark'#305')'
      OnClick = HatalFiler1Click
    end
    object FiOrkadavarm1: TMenuItem
      Caption = 'Orka'#39'ya aktar'#305'lmayan fi'#351'ler'
      OnClick = FiOrkadavarm1Click
    end
    object OrkaHatalFiler1: TMenuItem
      Caption = 'Hatal'#305' Fi'#351'ler'
      OnClick = OrkaHatalFiler1Click
    end
  end
  object PopupMenuYaz: TPopupMenu
    Left = 117
    Top = 234
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YaziciyaYazdirMenu: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object MenuItem2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
  end
  object frxMUHASEBE: TfrxDBDataset
    UserName = 'MUHASEBE_FIS'
    CloseDataSource = False
    FieldAliases.Strings = (
      'ID=ID'
      'SEC=SEC'
      'SORGUNO=SORGUNO'
      'TABLOADI=TABLOADI'
      'IDALAN=IDALAN'
      'TUR=TUR'
      'MUHAKTAR=MUHAKTAR'
      'SUBEID=SUBEID'
      'FISTARIH=FISTARIH'
      'FISTIP=FISTIP'
      'FISNO=FISNO'
      'FISACIKLAMA=FISACIKLAMA'
      'HESAPKODU=HESAPKODU'
      'HESAPADI=HESAPADI'
      'BELGETARIH=BELGETARIH'
      'BELGENO=BELGENO'
      'ACIKLAMA=ACIKLAMA'
      'DOVIZCINSI=DOVIZCINSI'
      'DOVIZKURU=DOVIZKURU'
      'DOVIZMIKTAR=DOVIZMIKTAR'
      'DVBORCTUTAR=DVBORCTUTAR'
      'DVALACAKTUTAR=DVALACAKTUTAR'
      'BORC=BORC'
      'ALACAK=ALACAK'
      'ZARF=ZARF'
      'SONUC=SONUC'
      'IDDEGER=IDDEGER'
      'TURAD=TURAD'
      'YAZIYLATOPLAM=YAZIYLATOPLAM')
    DataSet = MUHASEBEFIS
    BCDToCurrency = False
    DataSetOptions = []
    Left = 298
    Top = 321
  end
  object MUHASEBEFIS: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT '
      
        'YAZIYLATOPLAM=( dbo.fn_ParaTextOlarakTumDiller((select sum(BORC)' +
        ' from MUHFISAKTAR where SEC=1),'#39'TL'#39','#39'Kuru'#351#39',0,-1)),'
      
        '--YAZIYLATOPLAMDOVIZ=( dbo.fn_ParaTextOlarakTumDiller(F.DOVIZ_TU' +
        'TARI,D.BUYUKBIRIMADI,D.KUCUKBIRIMADI,0,F.DIL)),'
      '* '
      'FROM MUHFISAKTAR'
      ''
      'WHERE SEC=1')
    Left = 424
    Top = 352
    object MUHASEBEFISID: TIntegerField
      FieldName = 'ID'
    end
    object MUHASEBEFISSEC: TBooleanField
      FieldName = 'SEC'
    end
    object MUHASEBEFISSORGUNO: TWideStringField
      FieldName = 'SORGUNO'
      Size = 10
    end
    object MUHASEBEFISTABLOADI: TWideStringField
      FieldName = 'TABLOADI'
      Size = 50
    end
    object MUHASEBEFISIDALAN: TWideStringField
      FieldName = 'IDALAN'
      Size = 50
    end
    object MUHASEBEFISTUR: TIntegerField
      FieldName = 'TUR'
    end
    object MUHASEBEFISMUHAKTAR: TIntegerField
      FieldName = 'MUHAKTAR'
    end
    object MUHASEBEFISSUBEID: TIntegerField
      FieldName = 'SUBEID'
    end
    object MUHASEBEFISFISTARIH: TDateTimeField
      FieldName = 'FISTARIH'
    end
    object MUHASEBEFISFISTIP: TIntegerField
      FieldName = 'FISTIP'
    end
    object MUHASEBEFISFISNO: TLargeintField
      FieldName = 'FISNO'
    end
    object MUHASEBEFISFISACIKLAMA: TWideStringField
      FieldName = 'FISACIKLAMA'
      Size = 500
    end
    object MUHASEBEFISHESAPKODU: TWideStringField
      FieldName = 'HESAPKODU'
      Size = 50
    end
    object MUHASEBEFISHESAPADI: TWideStringField
      FieldName = 'HESAPADI'
      Size = 50
    end
    object MUHASEBEFISBELGETARIH: TDateTimeField
      FieldName = 'BELGETARIH'
    end
    object MUHASEBEFISBELGENO: TWideStringField
      FieldName = 'BELGENO'
    end
    object MUHASEBEFISACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 500
    end
    object MUHASEBEFISDOVIZCINSI: TIntegerField
      FieldName = 'DOVIZCINSI'
    end
    object MUHASEBEFISDOVIZKURU: TWideStringField
      FieldName = 'DOVIZKURU'
      Size = 5
    end
    object MUHASEBEFISDOVIZMIKTAR: TBCDField
      FieldName = 'DOVIZMIKTAR'
      Precision = 19
    end
    object MUHASEBEFISDVBORCTUTAR: TBCDField
      FieldName = 'DVBORCTUTAR'
      Precision = 19
    end
    object MUHASEBEFISDVALACAKTUTAR: TBCDField
      FieldName = 'DVALACAKTUTAR'
      Precision = 19
    end
    object MUHASEBEFISBORC: TBCDField
      FieldName = 'BORC'
      Precision = 19
    end
    object MUHASEBEFISALACAK: TBCDField
      FieldName = 'ALACAK'
      Precision = 19
    end
    object MUHASEBEFISZARF: TWideStringField
      FieldName = 'ZARF'
      Size = 50
    end
    object MUHASEBEFISSONUC: TWideStringField
      FieldName = 'SONUC'
    end
    object MUHASEBEFISIDDEGER: TIntegerField
      FieldName = 'IDDEGER'
    end
    object MUHASEBEFISTURAD: TWideStringField
      FieldName = 'TURAD'
      Size = 50
    end
    object MUHASEBEFISYAZIYLATOPLAM: TStringField
      FieldName = 'YAZIYLATOPLAM'
      ReadOnly = True
      Size = 4000
    end
  end
end
