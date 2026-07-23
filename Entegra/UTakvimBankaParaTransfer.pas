unit UTakvimBankaParaTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel, ComCtrls, ToolWin,
  DBCtrls, JvDBImage,Utablo, DB, FireDAC.Comp.Client, dxSkinsCore,cxControls, cxContainer, cxEdit, cxLabel,
  cxDBLabel,UBankaSecimi,UGirisKutusuEx,UTakvimIslemleri, cxImage,
  cxDBEdit,UResim, cxGraphics, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxImageComboBox, jpeg, UParaDegisiklik, UHavaleEFT, Menus,UTalimatWizard,
  dxSkinLondonLiquidSky, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTakvimBankaParaTransferDLG = class(TForm)
    tlb1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    SilTus: TToolButton;
    btn1: TToolButton;
    Iptal: TToolButton;
    PanelAd: TJvPanel;
    JvPanel4: TJvPanel;
    JvPanel1: TJvPanel;
    PanelGonBanka: TJvPanel;
    PanelGonSube: TJvPanel;
    JvPanel6: TJvPanel;
    JvPanel7: TJvPanel;
    PanelGonHesap: TJvPanel;
    PanelUst: TJvPanel;
    JvPanel10: TJvPanel;
    JvPanel11: TJvPanel;
    JvPanel12: TJvPanel;
    PanelVergino: TJvPanel;
    JvPanel14: TJvPanel;
    JvPanel17: TJvPanel;
    JvPanel18: TJvPanel;
    JvPanel19: TJvPanel;
    PanelAlBanka: TJvPanel;
    PanelAlSube: TJvPanel;
    JvPanel22: TJvPanel;
    JvPanel23: TJvPanel;
    PanelAlHesap: TJvPanel;
    JvPanel25: TJvPanel;
    JvPanel26: TJvPanel;
    JvPanel27: TJvPanel;
    PanelTarih: TJvPanel;
    JvPanel3: TJvPanel;
    JvPanel5: TJvPanel;
    PanelTutar: TJvPanel;
    PanelAciklama: TJvPanel;
    JvPanel15: TJvPanel;
    JvPanel29: TJvPanel;
    DtsKasa: TDataSource;
    TabKasa: TFDQuery;
    LabelDurum: TcxDBLabel;
    LabelGonAd: TcxDBLabel;
    LabelGonBanka: TcxDBLabel;
    LabelGonSube: TcxDBLabel;
    LabelGonHesap: TcxDBLabel;
    LabelGonVNo: TcxDBLabel;
    LabelAlAd: TcxDBLabel;
    LabelAlBanka: TcxDBLabel;
    LabelAlSube: TcxDBLabel;
    LabelAlHesap: TcxDBLabel;
    LabelAlVNo: TcxDBLabel;
    LabelTarih: TcxDBLabel;
    LabelTutar: TcxDBLabel;
    LabelAciklama: TcxDBLabel;
    LabelKur: TcxDBLabel;
    ImageGonBanka: TcxDBImage;
    ImageAlBanka: TcxDBImage;
    TabMusteriBilgileri: TFDQuery;
    DtsMusteriBilgileri: TDataSource;
    TabBizimBilgiler: TFDQuery;
    DtsBizimBilgiler: TDataSource;
    AlImg: TcxImage;
    GonImg: TcxImage;
    ToolButton1: TToolButton;
    BelgeTus: TToolButton;
    JvPanel2: TJvPanel;
    JvPanel8: TJvPanel;
    ImageAl: TJvDBImage;
    ImageGon: TJvDBImage;
    ComboOdemeKanali: TcxImageComboBox;
    GonImg2: TcxImage;
    AlImg2: TcxImage;
    LabelDovizTutari: TcxLabel;
    LabelDovizKuru: TcxLabel;
    PopupParaTransfer: TPopupMenu;
    HavaleEftSihirbaznBalat1: TMenuItem;
    alimatSihirbazBalat1: TMenuItem;
    procedure LabelTutarClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DtsKasaStateChange(Sender: TObject);
    procedure IptalClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LabelGonBankaClick(Sender: TObject);
    procedure BelgeTusClick(Sender: TObject);
    procedure ComboOdemeKanaliPropertiesEditValueChanged(Sender: TObject);
    procedure LabelKurClick(Sender: TObject);
    procedure LabelAciklamaClick(Sender: TObject);
    procedure HavaleEftSihirbaznBalat1Click(Sender: TObject);
    procedure alimatSihirbazBalat1Click(Sender: TObject);
    procedure TabKasaNewRecord(DataSet: TDataSet);
    procedure TabKasaAfterPost(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ID, RehberId : Integer;
    IsTuru : SmallInt;
    IslemOp : Char;
    HesapTuru:string;
    MakbuzNo : String[10];
    MakbuzTarih : TDateTime;
  end;

var
  TakvimBankaParaTransferDLG: TTakvimBankaParaTransferDLG;
//Resourcestring
//   TutarGiren = 'Tutar(Giren):  ';
//   ParaGiren = 'Para Transferi(Giren)';
//   TutarCikan =  'Tutar(Çıkan):  ';
//   ParaCikan =  'Para Transferi(Çıkan)';
//   istarih = 'İşlem Tarihi:  ' ;
//   gerceklesen = 'Gerçekleşen ';
//   pltarih =  'Plan Tarihi:  ';
//   planlanan =  'Planlanan ';
//   kasa111 = 'Kasa:  ';
//   kasakodu = 'Kasa Kodu:  ';
//   nakit = 'Nakit    ';
//   banka111 = 'Banka:  ';
//   sube1 = 'Şube:  ';
//   hesap1 = 'Hesap:  ';
//   bankakk1 = 'Banka:  ';
//   subekk1 = 'Kart No:  ';
//   hesapkk1 = 'Tanımlı Kişi:  ';
//   bankakk2 = 'Banka:  ';
//   subekk2 = 'POS No:  ';
//   hesapkk2 = 'POS Adı:  ';
//   PosCihazi = 'POS   ';
//   KKarti = 'Kredi Kartı  ';

implementation
uses
  PrjConst,Fetautil,LocOnFly,UVeriMotor;

{$R *.dfm}

procedure TTakvimBankaParaTransferDLG.alimatSihirbazBalat1Click(
  Sender: TObject);
begin
    Application.CreateForm(TTalimatWizardDlg, TalimatWizardDlg);
    TalimatWizardDlg.TalimatID := TabKasa.FieldbyName('TALIMATID').AsInteger;
    TalimatWizardDlg.ShowModal;
    TalimatWizardDlg.Destroy;
end;

procedure TTakvimBankaParaTransferDLG.BelgeTusClick(Sender: TObject);
begin
   if TabKasa.State in [dsEdit, dsInsert] then
      TabKasa.Post;
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.RehberId := TabKasa.Fields[0].AsInteger;
   ResimDlg.Yeri := 1;
   ResimDlg.YerId := TabKasa.fieldbyname('ID').AsInteger;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;
end;

procedure TTakvimBankaParaTransferDLG.ComboOdemeKanaliPropertiesEditValueChanged(
  Sender: TObject);
Var
  tur:string;
begin
  tur:=ComboOdemeKanali.Properties.Items[ComboOdemeKanali.ItemIndex].Value;
  if tur='21' then begin
     Isturu:=21;
     HesapTuru:='K';
  end Else if tur='22' then begin
     Isturu:=22;
     HesapTuru:='B';
  end Else if tur='25' then begin
     Isturu:=25;
     HesapTuru:='P';
  end Else if tur='31' then begin
     Isturu:=31;
     HesapTuru:='K';
  end Else if tur='32' then begin
     Isturu:=32;
     HesapTuru:='B';
  end Else if tur='35' then begin
     Isturu:=35;
     HesapTuru:='V';
  end Else if tur='B61' then begin
     Isturu:=61;
     HesapTuru:='B';
  end Else if tur='B71' then begin
     Isturu:=71;
     HesapTuru:='B';
  end Else if tur='K61' then begin
     Isturu:=61;
     HesapTuru:='K';
  end Else if tur='K71' then begin
     Isturu:=71;
     HesapTuru:='K';
  end ;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='UPDATE KASA SET TUR = '+inttostr(Isturu)+' WHERE ID = ' + IntToStr(ID);
  if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
  Tablo.Query1.ExecSQL;
  if HesapTuru <> '' then begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text:='UPDATE KASA SET HESAPTURU = '''+HesapTuru+''' WHERE ID = ' + IntToStr(ID);
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.ExecSQL;
  end;
 // FormShow(Self);
end;

procedure TTakvimBankaParaTransferDLG.DtsKasaStateChange(Sender: TObject);
begin
   KaydetTus.visible := DtsKasa.State in [dsEdit, dsInsert];
   IptalTus.visible := KaydetTus.visible;
   SilTus.visible := not KaydetTus.visible;
end;

procedure TTakvimBankaParaTransferDLG.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTakvimBankaParaTransferDLG.FormShow(Sender: TObject);

begin
  TabMusteriBilgileri.Close;
  if AktifVeriMotor = vmPG then TabMusteriBilgileri.SQL.Text := PgSqlCevir(TabMusteriBilgileri.SQL.Text);
  TabBizimBilgiler.Close;
  if AktifVeriMotor = vmPG then TabBizimBilgiler.SQL.Text := PgSqlCevir(TabBizimBilgiler.SQL.Text);
  TabKasa.Close;
  if AktifVeriMotor = vmPG then TabKasa.SQL.Text := PgSqlCevir(TabKasa.SQL.Text);
  TabKasa.Params[0].Value := ID;
  TabKasa.Open;
  if IslemOp = 'E' then begin
     TabKasa.Append;
  end;

  HesapTuru := TabKasa.FieldByName('HESAPTURU').AsString;

  //ComboOdemeKanali itemlerini oluşturalım...
  if ComboOdemeKanali.Properties.Items.Count=0 then begin
    ComboOdemeKanali.Properties.Items.Clear;
    if IsTuru in[61] then begin
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Bankadan Tahsilat Planı';
         Value := 'B61';
       end;
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Kasadan Tahsilat Planı';
         Value := 'K61';
       end;
    end else if IsTuru in[71] then begin
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Bankadan Ödeme Planı';
         Value := 'B71';
       end;
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Kasadan Ödeme Planı';
         Value := 'K71';
       end;
    end Else if IsTuru in[21,22] then begin
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Kasadan Tahsilat';
         Value := '21';
       end;
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Bankadan Tahsilat';
         Value := '22';
       end;
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Pos ile Tahsilat';
         Value := '25';
       end;
    End else if IsTuru in[31,32] then begin
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Kasadan Ödeme';
         Value := '31';
       end;
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'Bankadan Ödeme';
         Value := '32';
       end;
       with ComboOdemeKanali.Properties.Items.Add do begin
         Description := 'KK ile Ödeme';
         Value := '35';
       end;
    end;
  end;
  //combodan item secelim...
  case IsTuru of
    21: ComboOdemeKanali.ItemIndex:=0;
    22: ComboOdemeKanali.ItemIndex:=1;
    25: ComboOdemeKanali.ItemIndex:=2;
    31: ComboOdemeKanali.ItemIndex:=0;
    32: ComboOdemeKanali.ItemIndex:=1;
    35: ComboOdemeKanali.ItemIndex:=2;
    61: begin
          if HesapTuru='B' then
             ComboOdemeKanali.ItemIndex:=0
          Else if HesapTuru='K' then
             ComboOdemeKanali.ItemIndex:=1
          Else if HesapTuru='P' then
             ComboOdemeKanali.ItemIndex:=2
        end;
    71: begin
          if HesapTuru='B' then
            ComboOdemeKanali.ItemIndex:=0
          Else if HesapTuru='K' then
            ComboOdemeKanali.ItemIndex:=1
          Else if HesapTuru='V' then
            ComboOdemeKanali.ItemIndex:=2
        end;
  end;

//ekranı düzenleme işlemleri
  //Dts secimleri..
  if IsTuru in[31,32,35,71] then begin //giren olması durumu;
     LabelGonAd.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelGonBanka.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelGonSube.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelGonHesap.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelGonVNo.DataBinding.DataSource := DtsMusteriBilgileri;
     ImageGon.DataSource := DtsMusteriBilgileri;
     ImageGonBanka.DataBinding.DataSource := DtsMusteriBilgileri;

     LabelAlAd.DataBinding.DataSource := DtsBizimBilgiler;
     LabelAlBanka.DataBinding.DataSource := DtsBizimBilgiler;
     LabelAlSube.DataBinding.DataSource := DtsBizimBilgiler;
     LabelAlHesap.DataBinding.DataSource := DtsBizimBilgiler;
     LabelAlVNo.DataBinding.DataSource := DtsBizimBilgiler;
     ImageAl.DataSource := DtsBizimBilgiler;
     ImageAlBanka.DataBinding.DataSource := DtsBizimBilgiler;

     PanelUst.Color := clRed;
     JvPanel12.Font.Color := clRed;
     JvPanel25.Font.Color := clRed;
     JvPanel29.Font.Color := clRed;

     PanelTutar.Caption := TutarGiren;
     LabelTutar.DataBinding.DataField := 'ALACAK';
     TakvimBankaParaTransferDLG.Caption := ParaGiren;
  end Else if IsTuru in[21,22,25,61] then begin //çıkan olması durumu;
     LabelGonAd.DataBinding.DataSource := DtsBizimBilgiler;
     LabelGonBanka.DataBinding.DataSource := DtsBizimBilgiler;
     LabelGonSube.DataBinding.DataSource := DtsBizimBilgiler;
     LabelGonHesap.DataBinding.DataSource := DtsBizimBilgiler;
     LabelGonVNo.DataBinding.DataSource := DtsBizimBilgiler;
     ImageGon.DataSource := DtsBizimBilgiler;
     ImageGonBanka.DataBinding.DataSource := DtsBizimBilgiler;

     LabelAlAd.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelAlBanka.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelAlSube.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelAlHesap.DataBinding.DataSource := DtsMusteriBilgileri;
     LabelAlVNo.DataBinding.DataSource := DtsMusteriBilgileri;
     ImageAl.DataSource := DtsMusteriBilgileri;
     ImageAlBanka.DataBinding.DataSource := DtsMusteriBilgileri;

     PanelUst.Color := clGreen;
     JvPanel12.Font.Color := clGreen;
     JvPanel25.Font.Color := clGreen;
     JvPanel29.Font.Color := clGreen;

     PanelTutar.Caption := TutarCikan;
     LabelTutar.DataBinding.DataField := 'BORC';
     TakvimBankaParaTransferDLG.Caption := ParaCikan;
  end;
  if IsTuru in[22,32] then begin //havale/eft olması durumu;
    AlImg.Visible := False;
    GonImg.Visible := False;
    AlImg2.Visible := False;
    GonImg2.Visible := False;
    PanelTarih.Caption := istarih;
    LabelTarih.DataBinding.DataField := 'ISLEMTARIHI' ;
    TakvimBankaParaTransferDLG.Caption := gerceklesen+TakvimBankaParaTransferDLG.Caption;
    PanelAlBanka.Caption := banka111;
    PanelAlSube.Caption := sube1;
    PanelAlHesap.Caption := hesap1;
    PanelGonBanka.Caption := banka111;
    PanelGonSube.Caption := sube1;
    PanelGonHesap.Caption := hesap1;
    LabelAlBanka.DataBinding.DataField := 'BANKAADI' ;
    LabelAlSube.DataBinding.DataField := 'SUBEADI' ;
    LabelAlHesap.DataBinding.DataField := 'HESAPNO' ;
    LabelGonBanka.DataBinding.DataField := 'BANKAADI' ;
    LabelGonSube.DataBinding.DataField := 'SUBEADI' ;
    LabelGonHesap.DataBinding.DataField := 'HESAPNO' ;

  end Else if IsTuru in[21,31] then begin //nakit tahsilatı olması durumu;
     AlImg.Visible := True;
     GonImg.Visible := True;
     AlImg2.Visible := False;
     GonImg2.Visible := False;
     PanelTarih.Caption := istarih;
     LabelTarih.DataBinding.DataField := 'ISLEMTARIHI' ;
     TakvimBankaParaTransferDLG.Caption := gerceklesen+TakvimBankaParaTransferDLG.Caption;
     if IsTuru = 21 then begin    //giren
        PanelAlBanka.Caption := kasa111;
        PanelAlSube.Caption := kasakodu;
        PanelAlHesap.Caption := '';
        LabelAlBanka.DataBinding.DataField := 'KASAADI' ;
        LabelAlSube.DataBinding.DataField := 'KASAKODU' ;
        LabelAlHesap.DataBinding.DataField := '' ;
        LabelGonBanka.DataBinding.DataField := '' ;
        LabelGonSube.DataBinding.DataField := '' ;
        LabelGonHesap.DataBinding.DataField := '' ;
        PanelGonBanka.Caption := cNakit;
        PanelGonSube.Caption := '';
        PanelGonHesap.Caption := '';
     end Else if IsTuru = 31 then begin //çıkan
        PanelGonBanka.Caption := kasa111;
        PanelGonSube.Caption := kasakodu;
        PanelGonHesap.Caption := '';
        LabelAlBanka.DataBinding.DataField := '' ;
        LabelAlSube.DataBinding.DataField := '' ;
        LabelAlHesap.DataBinding.DataField := '' ;
        LabelGonBanka.DataBinding.DataField := 'KASAADI' ;
        LabelGonSube.DataBinding.DataField := 'KASAKODU' ;
        LabelGonHesap.DataBinding.DataField := '' ;
        PanelAlBanka.Caption := cNakit;
        PanelAlSube.Caption := '';
        PanelAlHesap.Caption := '';
     end;
  end Else if IsTuru in[25,35] then begin //nakit tahsilatı olması durumu;
     AlImg.Visible := False;
     GonImg.Visible := False;
     AlImg2.Visible := True;
     GonImg2.Visible := True;
     PanelTarih.Caption := istarih;
     LabelTarih.DataBinding.DataField := 'ISLEMTARIHI' ;
     TakvimBankaParaTransferDLG.Caption := gerceklesen+TakvimBankaParaTransferDLG.Caption;
     if IsTuru = 25 then begin    //giren
        PanelAlBanka.Caption := bankakk2;
        PanelAlSube.Caption := subekk2;
        PanelAlHesap.Caption := hesapkk2;
        LabelAlBanka.DataBinding.DataField := 'POSBANKA' ;
        LabelAlSube.DataBinding.DataField := 'POSNO' ;
        LabelAlHesap.DataBinding.DataField := 'POSADI' ;
        LabelGonBanka.DataBinding.DataField := '' ;
        LabelGonSube.DataBinding.DataField := '' ;
        LabelGonHesap.DataBinding.DataField := '' ;
        PanelGonBanka.Caption := KKarti;
        PanelGonSube.Caption := '';
        PanelGonHesap.Caption := '';
     end Else if IsTuru = 35 then begin //çıkan
        PanelAlBanka.Caption := POSCihazi;
        PanelAlSube.Caption := '';
        PanelAlHesap.Caption := '';
        LabelAlBanka.DataBinding.DataField := '' ;
        LabelAlSube.DataBinding.DataField := '' ;
        LabelAlHesap.DataBinding.DataField := '' ;
        LabelGonBanka.DataBinding.DataField := 'KKBANKA' ;
        LabelGonSube.DataBinding.DataField := 'KKNO' ;
        LabelGonHesap.DataBinding.DataField := 'KKADI' ;
        PanelGonBanka.Caption := bankakk1;
        PanelGonSube.Caption := subekk1;
        PanelGonHesap.Caption := hesapkk1;
     end;
  end Else if IsTuru in[61,71] then begin //plan olması durumu;
     if HesapTuru = 'B' then begin
        PanelTarih.Caption := pltarih ;
        LabelTarih.DataBinding.DataField := 'PLANTARIHI' ;
        TakvimBankaParaTransferDLG.Caption := planlanan+TakvimBankaParaTransferDLG.Caption;
        AlImg.Visible := False;
        GonImg.Visible := False;
        PanelAlBanka.Caption := banka111;
        PanelAlSube.Caption := sube1;
        PanelAlHesap.Caption := hesap1;
        PanelGonBanka.Caption := banka111;
        PanelGonSube.Caption := sube1;
        PanelGonHesap.Caption := hesap1;
        LabelAlBanka.DataBinding.DataField := 'BANKAADI' ;
        LabelAlSube.DataBinding.DataField := 'SUBEADI' ;
        LabelAlHesap.DataBinding.DataField := 'HESAPNO' ;
        LabelGonBanka.DataBinding.DataField := 'BANKAADI' ;
        LabelGonSube.DataBinding.DataField := 'SUBEADI' ;
        LabelGonHesap.DataBinding.DataField := 'HESAPNO' ;

     end Else if HesapTuru = 'K' then Begin
        AlImg.Visible := True;
        GonImg.Visible := True;
        PanelTarih.Caption := istarih;
        LabelTarih.DataBinding.DataField := 'PLANTARIHI' ;
        TakvimBankaParaTransferDLG.Caption := gerceklesen+TakvimBankaParaTransferDLG.Caption;

        if IsTuru = 61 then begin //giren
          PanelAlBanka.Caption := kasa111;
          PanelAlSube.Caption := kasakodu;
          PanelAlHesap.Caption := '';
          LabelAlBanka.DataBinding.DataField := 'KASAADI' ;
          LabelAlSube.DataBinding.DataField := 'KASAKODU' ;

          PanelGonBanka.Caption := cNakit;
          PanelGonSube.Caption := '';
          PanelGonHesap.Caption := '';
        end Else if IsTuru = 71 then begin //çıkan
          PanelGonBanka.Caption := kasa111;
          PanelGonSube.Caption := kasakodu;
          PanelGonHesap.Caption := '';
          LabelGonBanka.DataBinding.DataField := 'KASAADI' ;
          LabelGonSube.DataBinding.DataField := 'KASAKODU' ;

          PanelAlBanka.Caption := cNakit;
          PanelAlSube.Caption := '';
          PanelAlHesap.Caption := '';
        end;
     End;
  end;

//  TabMusteriBilgileri.Params[0].Value := ID;
//  TabBizimBilgiler.Params[0].Value := ID;
  if IslemOp = 'E' then begin
      LabelTutarClick(Self);
      Tablo.query1.Close;
      Tablo.query1.SQL.Text := 'select ID from KASALAR where DURUM=1 and KUR = '''+TabKasa.FieldByName('KUR').AsString+''' ';
      if AktifVeriMotor = vmPG then Tablo.query1.SQL.Text := PgSqlCevir(Tablo.query1.SQL.Text);
      Tablo.query1.Open;
      TabKasa.FieldByName('HESAPID').AsString := Tablo.query1.Fields[0].AsString;
      TabBizimBilgiler.Params[0].Value := -1;
      TabBizimBilgiler.Params[1].Value := Tablo.query1.Fields[0].AsInteger;
      TabBizimBilgiler.Params[2].Value := -1;
      TabBizimBilgiler.Params[3].Value := -1;
      TabBizimBilgiler.Params[4].Value := RehberId;

      TabMusteriBilgileri.Params[0].Value := Tablo.query1.Fields[0].AsInteger;
      TabMusteriBilgileri.Params[1].Value := RehberId;
  end
  else begin
      TabBizimBilgiler.Params[0].Value := -1;
      TabBizimBilgiler.Params[1].Value := TabKasa.FieldByName('HESAPID').AsInteger;
      TabBizimBilgiler.Params[2].Value := -1;
      TabBizimBilgiler.Params[3].Value := -1;
      TabBizimBilgiler.Params[4].Value := RehberId;

      TabMusteriBilgileri.Params[0].Value := TabKasa.FieldByName('HESAPID').AsInteger;
      TabMusteriBilgileri.Params[1].Value := RehberId;
  end;
  TabMusteriBilgileri.Open;
  TabBizimBilgiler.Open;
  LabelKur.Left:= LabelTutar.Left+LabelTutar.Width +2;

  if TabKasa.FieldByName('DOVIZ_TUTARI').AsFloat>0 then begin
    LabelDovizTutari.Caption:= 'Karşılığı  '+FExtToStr(TabKasa.FieldByName('DOVIZ_TUTARI').AsFloat,2);
    LabelDovizKuru.Caption:=TabKasa.FieldByName('DOVIZ_KURU').AsString;
    LabelDovizTutari.Left:= LabelKur.Left+LabelKur.Width +2;
    LabelDovizKuru.Left:= LabelDovizTutari.Left+LabelDovizTutari.Width +2;
  end else begin
    LabelDovizTutari.Caption:= '';
    LabelDovizKuru.Caption:='';
  end;
end;

procedure TTakvimBankaParaTransferDLG.HavaleEftSihirbaznBalat1Click(
  Sender: TObject);
begin
    Application.CreateForm(THavaleEFTEkrani, HavaleEFTEkrani);
    HavaleEFTEkrani.Tarih := TabKasa.FieldbyName('ISLEMTARIHI').AsDatetime;
    HavaleEFTEkrani.ShowModal;
    HavaleEFTEkrani.Destroy;
end;

procedure TTakvimBankaParaTransferDLG.IptalClick(Sender: TObject);
begin
   Close;
end;

procedure TTakvimBankaParaTransferDLG.IptalTusClick(Sender: TObject);
begin
  TabKasa.Cancel;
end;

procedure TTakvimBankaParaTransferDLG.KaydetTusClick(Sender: TObject);
begin
   TabKasa.Post;
end;

procedure TTakvimBankaParaTransferDLG.LabelAciklamaClick(Sender: TObject);
var
   alanTuru,alanAdi,alanOwner : String;
   eskiad : Variant;
   ctrls : TGirdiDenetimleri;
begin
   alanAdi := TcxDBLabel(Sender).DataBinding.DataField ;
   eskiad := TcxDBLabel(Sender).Caption;
   case TcxDBLabel(Sender).Tag of
      //edit bilgi girişi
      1 : ctrls := TGirdiDenetimleri.Create.Edit(('Yeni '+alanAdi+' Değeri'),@eskiad);
      //date bilgi girişi
      2 : begin
            if eskiad='' then eskiad :=Tablo.GENINI.BugunTrh;
            ctrls := TGirdiDenetimleri.Create.DateTimePicker(('Yeni '+alanAdi+' Değeri'),@eskiad);
          end;
   end;
   if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls) = mrOK then begin
     if Trim(eskiad) = '' then begin
        MessageDlg(('Yeni '+alanAdi+' Değeri Boş Olamaz.'),mtError,[mbOK],0);
        Exit; End
      else begin
        TabKasa.Edit;
        TabKasa.FieldByName(alanAdi).AsVariant:= eskiad;
//        TabKasa.Post;
//        TabKasa.Close;
//        TabKasa.Open;
        LabelKur.Left:= LabelTutar.Left+LabelTutar.Width+2
     end;
   end;

end;

procedure TTakvimBankaParaTransferDLG.LabelGonBankaClick(Sender: TObject);
var
  HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR : String;
  st1:Tstringlist;
begin
   if (IsTuru in [21,31]) or (HesapTuru='K') then  begin
     if TcxDBLabel(Sender).DataBinding.DataSource.DataSet = TabBizimBilgiler then begin
       st1 := Tstringlist.create;
       if Tablo.ListedenBilgiGetir('Lütfen İşlem Yapılacak Kasanızı Seçiniz.','SELECT ID,KASAKODU,KASAADI,KUR FROM KASALAR WHERE KASAADI like ''%<ara>%'' and DURUM = 1',st1,[]) then  Begin
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text := 'UPDATE KASA SET HESAPID='''+st1.strings[0]+''' , HESAPTURU=''K'' WHERE ID= '+inttostr(ID);
         if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
         Tablo.Query1.ExecSQL;
       End;
       st1.free;
       TabBizimBilgiler.Close;
       TabBizimBilgiler.Params[0].Value := ID;
       TabBizimBilgiler.Open;
     end Else begin
       if Length(TabKasa.FieldByName('MUSTERIHESAPID').AsString)>0 then begin
         if MessageDlg('Bilgileri temizlemek ister misiniz?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then Begin
           tablo.query1.close;
           tablo.query1.SQL.Text:='UPDATE KASA SET MUSTERIHESAPID = NULL WHERE ID = '+inttostr(ID);
           if AktifVeriMotor = vmPG then tablo.query1.SQL.Text := PgSqlCevir(tablo.query1.SQL.Text);
           tablo.query1.ExecSQL;
           TabMusteriBilgileri.Close;
           TabMusteriBilgileri.Params[0].Value := ID;
           TabMusteriBilgileri.Open;
         End;
       end;
     end;
   end else  if (IsTuru in [22,32]) or (HesapTuru='B') then  begin
     if TcxDBLabel(Sender).DataBinding.DataSource.DataSet = TabBizimBilgiler then begin
       HESAPID := '-1';
       if Tablo.BankaHesapEkrani(22,HESAPID,HESAPKODU,HESAPNO, HESAPADI, KUR) then begin
          TabKasa.Edit;
          TabKasa.FieldByname('HESAPID').AsString := HESAPID;
          TabKasa.FieldByname('HESAPTURU').AsString := 'B';
          TabKasa.Post;
          TabBizimBilgiler.Close;
          TabBizimBilgiler.Params[0].Value := ID;
          TabBizimBilgiler.Open;
       end;
     end Else if TcxDBLabel(Sender).DataBinding.DataSource.DataSet = TabMusteriBilgileri then begin
       HESAPID := TabKasa.FieldByName('REHBERID').asstring;
       if Tablo.BankaHesapEkrani(41,HESAPID, HESAPKODU,HESAPNO, HESAPADI, KUR) then begin
          TabKasa.Edit;
          TabKasa.FieldByname('MUSTERIHESAPID').AsString := HESAPID;
          TabKasa.FieldByname('HESAPTURU').AsString := 'B';
          TabKasa.Post;
          TabMusteriBilgileri.Close;
          TabMusteriBilgileri.Params[0].Value := ID;
          TabMusteriBilgileri.Open;
       end;
     end;
   end else if (IsTuru in [25,35]) or (HesapTuru='V') or (HesapTuru='P') then  begin
     if TcxDBLabel(Sender).DataBinding.DataSource.DataSet = TabBizimBilgiler then begin
       st1 := Tstringlist.create;
       if IsTuru in [25,61] then Begin
         if Tablo.ListedenBilgiGetir('Lütfen İşlem Yapılacak Pos Cihazını Seçiniz.','SELECT ID,KODU,ADI,NOSU FROM POS --WHERE DURUM = 1',st1,[]) then  Begin
           Tablo.Query1.Close;
           Tablo.Query1.SQL.Text := 'UPDATE KASA SET HESAPID='''+st1.strings[0]+''' , HESAPTURU=''P'' WHERE ID= '+inttostr(ID);
           if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
           Tablo.Query1.ExecSQL;
         End;
       End Else if IsTuru in [35,71] then begin
          if Tablo.ListedenBilgiGetir('Lütfen İşlem Yapılacak Kredi Kartını Seçiniz.','SELECT ID,KODU,ADI,HAMILI FROM KREDIKARTI --WHERE DURUM = 1',st1,[]) then  Begin
           Tablo.Query1.Close;
           Tablo.Query1.SQL.Text := 'UPDATE KASA SET HESAPID='''+st1.strings[0]+''' , HESAPTURU=''V'' WHERE ID= '+inttostr(ID);
           if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
           Tablo.Query1.ExecSQL;
         End;
       end;
       st1.free;
       TabBizimBilgiler.Close;
       TabBizimBilgiler.Params[0].Value := ID;
       TabBizimBilgiler.Open;
     end Else begin
       if Length(TabKasa.FieldByName('MUSTERIHESAPID').AsString)>0 then begin
         if MessageDlg('Bilgileri temizlemek ister misiniz?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then Begin
           tablo.query1.close;
           tablo.query1.SQL.Text:='UPDATE KASA SET MUSTERIHESAPID = NULL WHERE ID = '+inttostr(ID);
           if AktifVeriMotor = vmPG then tablo.query1.SQL.Text := PgSqlCevir(tablo.query1.SQL.Text);
           tablo.query1.ExecSQL;
           TabMusteriBilgileri.Close;
           TabMusteriBilgileri.Params[0].Value := ID;
           TabMusteriBilgileri.Open;
         End;
       end;
     end;
   end;
End;

procedure TTakvimBankaParaTransferDLG.LabelKurClick(Sender: TObject);
var
   alanTuru,alanAdi,alanOwner : String;
   eskiad : Variant;
   ctrls : TGirdiDenetimleri;
begin
   alanAdi := TcxDBLabel(Sender).DataBinding.DataField ;
   eskiad := TcxDBLabel(Sender).Caption;
   case TcxDBLabel(Sender).Tag of
      //edit bilgi girişi
      1 : ctrls := TGirdiDenetimleri.Create.Edit(('Yeni '+alanAdi+' Değeri'),@eskiad);
      //date bilgi girişi
      2 : ctrls := TGirdiDenetimleri.Create.DateTimePicker(('Yeni '+alanAdi+' Değeri'),@eskiad);
      10: ctrls := TGirdiDenetimleri.Create.ComboBox(('Yeni '+alanAdi+' Değeri'),@eskiad,tablo.ComboboxInit('Select ANAHTAR from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM ='+IntToStr(Ops_KURLAR)+' ').items); //kur listesi

   end;

   if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls) = mrOK then begin
     if Trim(eskiad) = '' then begin
        MessageDlg(('Yeni '+alanAdi+' Değeri Boş Olamaz.'),mtError,[mbOK],0);
        Exit; End
      else begin
        TabKasa.Edit;
        TabKasa.FieldByName(alanAdi).AsVariant:= eskiad;
//        TabKasa.Post;
//        TabKasa.Close;
//        TabKasa.Open;
        LabelKur.Left:= LabelTutar.Left+LabelTutar.Width+2
     end;
   end;
end;

procedure TTakvimBankaParaTransferDLG.LabelTutarClick(Sender: TObject);
begin
  Application.CreateForm(TParaDegisiklikDlg,Paradegisiklikdlg);
  Paradegisiklikdlg.KurTarihi := TabKasa.FieldByName('ISLEMTARIHI').AsDateTime; //KasaTarihi.Date;
  Paradegisiklikdlg.GirenTutar := TabKasa.FieldByName(LabelTutar.DataBinding.DataField).AsCurrency; //EditTahsilatTutar.Value;
  Paradegisiklikdlg.GirenKur := TabKasa.FieldByName('KUR').AsString; //ComboKurTah.Text;
  Paradegisiklikdlg.CikanTutar := TabKasa.FieldByName('DOVIZ_TUTARI').AsCurrency; //EditDovizTutar.Value;
  Paradegisiklikdlg.CikanKur := TabKasa.FieldByName('DOVIZ_KURU').AsString; //ComboDovizTutar.Text;
  Paradegisiklikdlg.ShowModal;
  if Paradegisiklikdlg.ModalResult = mrOk then begin
     if DtsKasa.State <> dsEdit then
        TabKasa.Edit;
     TabKasa.FieldByName(LabelTutar.DataBinding.DataField).Value := Paradegisiklikdlg.GirenTutar;
     TabKasa.FieldByName('KUR').Value := Paradegisiklikdlg.GirenKur;
     TabKasa.FieldByName('DOVIZ_TUTARI').Value := Paradegisiklikdlg.CikanTutar;
     TabKasa.FieldByName('DOVIZ_KURU').Value := Paradegisiklikdlg.CikanKur;
//     TabKasa.Post;
  end;
  Paradegisiklikdlg.Free;
  //FormShow(Self);
 // TabKasa.Close;
 // TabKasa.Open;
end;

procedure TTakvimBankaParaTransferDLG.SilTusClick(Sender: TObject);
begin
   SilmeIslemler(TabKasa.FieldByName('TUR').AsInteger, ID);
   Close;
end;

procedure TTakvimBankaParaTransferDLG.TabKasaAfterPost(DataSet: TDataSet);
begin
   ID := TabKasa.FieldByName('REHBERID').AsInteger;
end;

procedure TTakvimBankaParaTransferDLG.TabKasaNewRecord(DataSet: TDataSet);
begin
  TabKasa.FieldByName('ISLEMTARIHI').AsDateTime := MakbuzTarih; //KasaTarihi.Date;
  TabKasa.FieldByName('PLANTARIHI').AsDateTime := MakbuzTarih; //KasaTarihi.Date;
  TabKasa.FieldByName('BELGENO').AsString := MakbuzNo;
  TabKasa.FieldByName('HESAPTURU').AsString := HesapTuru;
  TabKasa.FieldByName('REHBERID').AsInteger := RehberId;
  TabKasa.FieldByName(LabelTutar.DataBinding.DataField).AsCurrency := 0.0; //EditTahsilatTutar.Value;
  TabKasa.FieldByName('TUR').AsInteger:= IsTuru; //ComboKurTah.Text;
  TabKasa.FieldByName('KUR').AsString := CariDoviz; //ComboKurTah.Text;
  TabKasa.FieldByName('DOVIZ_TUTARI').AsCurrency := 0.0; //EditDovizTutar.Value;
  TabKasa.FieldByName('DOVIZ_KURU').AsString := ''; //ComboDovizTutar.Text;
  TabKasa.FieldByName('SUBEID').AsInteger := SubeID;

  //LabelAciklamaClick(Self);
end;

end.



