unit UTakvimVirman;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore,  cxGraphics, DB, FireDAC.Comp.Client, jpeg, DBCtrls, JvDBImage,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxImage, cxDBEdit,
  cxControls, cxContainer, cxEdit, cxLabel, cxDBLabel, ExtCtrls, JvExExtCtrls,
  JvExtComponent, JvPanel, ComCtrls, ToolWin, Utablo, UResim, UGirisKutusuEx,
  dxSkinLondonLiquidSky,Fetautil, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTakvimVirmanDlg = class(TForm)
    tlb1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    SilTus: TToolButton;
    btn1: TToolButton;
    BelgeTus: TToolButton;
    ToolButton1: TToolButton;
    Iptal: TToolButton;
    PanelAd: TJvPanel;
    JvPanel4: TJvPanel;
    LabelGonAd: TcxDBLabel;
    JvPanel1: TJvPanel;
    LabelGonBanka: TcxDBLabel;
    PanelGonBanka: TJvPanel;
    PanelGonSube: TJvPanel;
    JvPanel6: TJvPanel;
    LabelGonSube: TcxDBLabel;
    JvPanel7: TJvPanel;
    LabelGonHesap: TcxDBLabel;
    PanelGonHesap: TJvPanel;
    PanelUst: TJvPanel;
    JvPanel10: TJvPanel;
    JvPanel11: TJvPanel;
    LabelDurum: TcxDBLabel;
    JvPanel12: TJvPanel;
    PanelVergino: TJvPanel;
    JvPanel14: TJvPanel;
    LabelGonVNo: TcxDBLabel;
    PanelAlAd: TJvPanel;
    JvPanel18: TJvPanel;
    LabelAlAd: TcxDBLabel;
    JvPanel19: TJvPanel;
    LabelAlBanka: TcxDBLabel;
    PanelAlBanka: TJvPanel;
    PanelAlSube: TJvPanel;
    JvPanel22: TJvPanel;
    LabelAlSube: TcxDBLabel;
    JvPanel23: TJvPanel;
    LabelAlHesap: TcxDBLabel;
    PanelAlHesap: TJvPanel;
    JvPanel25: TJvPanel;
    PanelAlVergi: TJvPanel;
    JvPanel27: TJvPanel;
    LabelAlVNo: TcxDBLabel;
    PanelTarih: TJvPanel;
    JvPanel3: TJvPanel;
    LabelTarih: TcxDBLabel;
    JvPanel5: TJvPanel;
    PanelTutar: TJvPanel;
    PanelAciklama: TJvPanel;
    JvPanel15: TJvPanel;
    LabelAciklama: TcxDBLabel;
    JvPanel29: TJvPanel;
    ImageGonBanka: TcxDBImage;
    ImageAlBanka: TcxDBImage;
    AlImg: TcxImage;
    GonImg: TcxImage;
    GonImg2: TcxImage;
    AlImg2: TcxImage;
    DtsBorcluKasa: TDataSource;
    TabBorcluKasa: TFDQuery;
    TabBorcluAyrinti: TFDQuery;
    DtsBorcluAyrinti: TDataSource;
    DtsAlacakliKasa: TDataSource;
    TabAlacakliKasa: TFDQuery;
    DtsAlacakliAyrinti: TDataSource;
    TabAlacakliAyrinti: TFDQuery;
    LabelBcm: TcxLabel;
    LabelATutar: TcxDBLabel;
    LabelBTutar: TcxDBLabel;
    LabelBKur: TcxDBLabel;
    LabelAKur: TcxDBLabel;
    procedure FormShow(Sender: TObject);
    procedure BorcluDuzenle(TUR: integer);
    procedure AlacakliDuzenle(TUR: integer);
    procedure IptalClick(Sender: TObject);
    procedure BelgeTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsAlacakliKasaStateChange(Sender: TObject);
    procedure LabelTarihClick(Sender: TObject);
    procedure TutarlariYerlestir;
    procedure TablariAc;
    procedure UstBilgileriOlustur;
    procedure PariteHesapla;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    HesapTuru:string;
  public
    { Public declarations }
    ID : Integer;
    IsTuru : SmallInt;
  end;

var
  TakvimVirmanDlg: TTakvimVirmanDlg;
 {
Resourcestring
//Errors
  BozukKayit= 'Açmaya çalıştığınız kaydın içeriği bozulmuştur lütfen silip tekrar oluşturunuz.';
//captions
  islem41= 'Kasadan bankaya para transferi'; //41
  islem42= 'Bankadan kasaya  para transferi'; //42
  islem43= 'Bankadaki hesaplar arası para transferi'; //43
  islem45= 'Kasadaki nakit paranın bir kısmıyla döviz alma'; //45
  islem46= 'Döviz kasasındaki paranın bir kısmını bozdurma'; //46
  islem47= 'Bankadaki nakit paranın bir kısmıyla döviz alma'; //47
  islem48= 'Döviz hesabındaki paranın bir kısmını bozdurma'; //48
  islem51= 'Elimzde bulunan çeki bankadan tahsil etme';  //51
  islem52= 'Elimzde bulunan senedi bankadan tahsil etme'; //52
  islem53= 'Verdiğimiz çek karşılığı bankadan ödeme';  //53
  islem54= 'Verdiğimiz senet karşılığı bankadan ödeme'; //54
  islem58= 'Alınmış olan kredi taksitlerinin ödemesi'; //58
  islem95= 'Bankoda tahsil edilmiş olan kredi kartlarının girişi';  //95
  islem91= 'Bankoda tahsil edilmiş olan nakit ödemelerin girişi';  //91
//Panels
  Tutar123='Tutar:  ';
  banka11='Banka:  ';
  sube11='Sube:  ';
  hesap11='Hesap:  ';
  kasaadi11='Kasa Adı:  ';
  kasakodu11='Kasa Kodu:  ';
  kasakur11='  ';
  posadi='Pos Adı:  ';
  poskodu='Pos Kodu:  ';
  posbankasi='Bankası:  ';

                }

implementation
      Uses PrjConst,LocOnFly,UVeriMotor;
{$R *.dfm}

procedure TTakvimVirmanDlg.BelgeTusClick(Sender: TObject);
begin
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.RehberId := TabAlacakliKasa.fieldbyname('ID').AsInteger;
   ResimDlg.Yeri := 1;
   ResimDlg.YerId := TabAlacakliKasa.fieldbyname('ID').AsInteger;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;
end;

procedure TTakvimVirmanDlg.BorcluDuzenle(TUR: integer);
begin
  case  TUR of
    1: begin //banka
       PanelGonBanka.Caption:=banka11;
       PanelGonSube.Caption:=sube11;
       PanelGonHesap.Caption:=hesap11;
       TabBorcluAyrinti.Close;
       TabBorcluAyrinti.SQL.Text:= 'select BANKA=B.BANKAADI,B.LOGO,SUBE=BS.SUBEADI,HESAP=BH.HESAPNO+'' ''+BH.HESAPADI,ACIKLAMA=BH.HESAPACIKLAMA '
             +' from KASA K INNER JOIN BANKAHESAPLAR BH on K.HESAPID=BH.ID INNER JOIN '
             +' BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID INNER JOIN BANKALAR B ON BS.BANKAKODU=B.BANKAKODU '
             +' WHERE K.ID= '+ TabBorcluKasa.FieldByName('ID').AsString;
       if AktifVeriMotor = vmPG then TabBorcluAyrinti.SQL.Text := PgSqlCevir(TabBorcluAyrinti.SQL.Text);
       LabelGonBanka.DataBinding.DataField := 'BANKA';
       LabelGonSube.DataBinding.DataField := 'SUBE';
       LabelGonHesap.DataBinding.DataField := 'HESAP';
       LabelGonVNo.DataBinding.DataField := 'ACIKLAMA';
       ImageGonBanka.DataBinding.DataField:= 'LOGO';
       TabBorcluAyrinti.Open;
       GonImg2.Visible:=False;//KK
       GonImg.Visible:=False;//KASA
       ImageGonBanka.Visible:=True;//Banka
    end;
    2: begin //kasa
       PanelGonBanka.Caption:=kasaadi11;
       PanelGonSube.Caption:=kasakodu11;
       PanelGonHesap.Caption:=kasakur11;
       TabBorcluAyrinti.Close;
       TabBorcluAyrinti.SQL.Text:= 'SELECT KS.KASAKODU,KS.KASAADI,ACIKLAMA=KS.HESAPACIKLAMA,KS.KUR,LOGO='''' '
             +' FROM KASA K INNER JOIN KASALAR KS ON K.HESAPID=KS.ID '
             +' WHERE K.ID= '+ TabBorcluKasa.FieldByName('ID').AsString;
       if AktifVeriMotor = vmPG then TabBorcluAyrinti.SQL.Text := PgSqlCevir(TabBorcluAyrinti.SQL.Text);
       LabelGonBanka.DataBinding.DataField := 'KASAADI';
       LabelGonSube.DataBinding.DataField := 'KASAKODU';
       LabelGonHesap.DataBinding.DataField := '';
       LabelGonVNo.DataBinding.DataField := 'ACIKLAMA';
       ImageGonBanka.DataBinding.DataField:= '';
       TabBorcluAyrinti.Open;
       GonImg2.Visible:=False;//KK
       GonImg.Visible:=True;//KASA
       ImageGonBanka.Visible:=False;//Banka
    end;
    3: begin  //pos-KK
       PanelGonBanka.Caption:=posadi;
       PanelGonSube.Caption:=poskodu;
       PanelGonHesap.Caption:=posbankasi;
       TabBorcluAyrinti.Close;
       TabBorcluAyrinti.SQL.Text:= 'SELECT P.ADI,P.KODU,BANKASI=B.BANKAADI,BH.KUR,LOGO='''' '
             +' FROM KASA K INNER JOIN POS P ON K.HESAPID=P.ID LEFT OUTER JOIN BANKAHESAPLAR BH ON BH.ID=P.BANKAHESAPID LEFT OUTER JOIN '
             +' BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID LEFT OUTER JOIN BANKALAR B ON BS.BANKAKODU=B.BANKAKODU '
             +' WHERE K.ID= '+ TabBorcluKasa.FieldByName('ID').AsString;
       if AktifVeriMotor = vmPG then TabBorcluAyrinti.SQL.Text := PgSqlCevir(TabBorcluAyrinti.SQL.Text);
       LabelGonBanka.DataBinding.DataField := 'ADI';
       LabelGonSube.DataBinding.DataField := 'KODU';
       LabelGonHesap.DataBinding.DataField := 'BANKASI';
       LabelGonVNo.DataBinding.DataField := '';
       ImageGonBanka.DataBinding.DataField:= '';
       TabBorcluAyrinti.Open;
       GonImg2.Visible:=True;//KK
       GonImg.Visible:=False;//KASA
       ImageGonBanka.Visible:=False;//Banka
    end;
    4: begin  //Çek
       PanelGonBanka.Caption:='';
       PanelGonSube.Caption:='';
       PanelGonHesap.Caption:='';
    end;
    5: begin  //Senet
       PanelGonBanka.Caption:='';
       PanelGonSube.Caption:='';
       PanelGonHesap.Caption:='';
    end;
  end;
end;

procedure TTakvimVirmanDlg.DtsAlacakliKasaStateChange(Sender: TObject);
begin
  if (DtsAlacakliKasa.State in [dsEdit]) or (DtsBorcluKasa.State in [dsEdit]) then begin
     KaydetTus.Visible:=True;
     IptalTus.Visible:=True;
  end else begin
     KaydetTus.Visible:=False;
     IptalTus.Visible:=False;
  end;
end;

procedure TTakvimVirmanDlg.AlacakliDuzenle(TUR: integer);
begin
  case  TUR of
    1: begin //banka
       PanelAlBanka.Caption:=banka11;
       PanelAlSube.Caption:=sube11;
       PanelAlHesap.Caption:=hesap11;
       TabAlacakliAyrinti.Close;
       TabAlacakliAyrinti.SQL.Text:= 'select BANKA=B.BANKAADI,B.LOGO,SUBE=BS.SUBEADI,HESAP=BH.HESAPNO+BH.HESAPADI,ACIKLAMA=BH.HESAPACIKLAMA '
             +' from KASA K INNER JOIN BANKAHESAPLAR BH on K.HESAPID=BH.ID INNER JOIN '
             +' BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID INNER JOIN BANKALAR B ON BS.BANKAKODU=B.BANKAKODU '
             +' WHERE K.ID= '+ TabAlacakliKasa.FieldByName('ID').AsString;
       if AktifVeriMotor = vmPG then TabAlacakliAyrinti.SQL.Text := PgSqlCevir(TabAlacakliAyrinti.SQL.Text);
       LabelAlBanka.DataBinding.DataField := 'BANKA';
       LabelAlSube.DataBinding.DataField := 'SUBE';
       LabelAlHesap.DataBinding.DataField := 'HESAP';
       LabelAlVNo.DataBinding.DataField := 'ACIKLAMA';
       ImageAlBanka.DataBinding.DataField:= 'LOGO';
       TabAlacakliAyrinti.Open;
       AlImg.Visible:=False; //kasa
       AlImg2.Visible:=False; //KK
       ImageAlBanka.Visible:=True; //banka
    end;
    2: begin //kasa
       PanelAlBanka.Caption:=kasaadi11;
       PanelAlSube.Caption:=kasakodu11;
       PanelAlHesap.Caption:=kasakur11;
       TabAlacakliAyrinti.Close;
       TabAlacakliAyrinti.SQL.Text:= 'SELECT KS.KASAKODU,KS.KASAADI,ACIKLAMA=KS.HESAPACIKLAMA,KS.KUR,LOGO='''' '
             +' FROM KASA K INNER JOIN KASALAR KS ON K.HESAPID=KS.ID '
             +' WHERE K.ID= '+ TabAlacakliKasa.FieldByName('ID').AsString;
       if AktifVeriMotor = vmPG then TabAlacakliAyrinti.SQL.Text := PgSqlCevir(TabAlacakliAyrinti.SQL.Text);
       LabelAlBanka.DataBinding.DataField := 'KASAADI';
       LabelAlSube.DataBinding.DataField := 'KASAKODU';
       LabelAlHesap.DataBinding.DataField := '';
       LabelAlVNo.DataBinding.DataField := 'ACIKLAMA';
       ImageAlBanka.DataBinding.DataField:= '';
       TabAlacakliAyrinti.Open;
       AlImg.Visible:=True; //kasa
       AlImg2.Visible:=False; //KK
       ImageAlBanka.Visible:=False; //banka
    end;
    3: begin  //pos-KK
       PanelAlBanka.Caption:='';
       PanelAlSube.Caption:='';
       PanelAlHesap.Caption:='';
    end;
    4: begin  //Çek
       PanelAlBanka.Caption:='';
       PanelAlSube.Caption:='';
       PanelAlHesap.Caption:='';
    end;
    5: begin  //Senet
       PanelAlBanka.Caption:='';
       PanelAlSube.Caption:='';
       PanelAlHesap.Caption:='';
    end;
  end;
end;

procedure TTakvimVirmanDlg.PariteHesapla;
var
   A,B:Double;
   AKur,BKur:string;
Begin
   AKur:= TabAlacakliKasa.FieldByName('KUR').AsString;
   BKur:= TabBorcluKasa.FieldByName('KUR').AsString;
   if (AKur<>'TL') or (BKur<>'TL') then begin
     PanelTutar.Caption := Tutar123;
     A:= TabAlacakliKasa.FieldByName('ALACAK').AsFloat;
     B:= TabBorcluKasa.FieldByName('BORC').AsFloat;

     if (LabelBKur.Caption<>'TL') then begin
       PanelTutar.Caption:= '(1'+BKur+' = '+FExtToStr((A/B),2)+ AKur+') ' + PanelTutar.Caption;
     end;
     if (LabelAKur.Caption<>'TL') then begin
       PanelTutar.Caption:= '(1'+AKur+' = '+FExtToStr((B/A),2)+ BKur+') ' + PanelTutar.Caption;
     end;
   end;
End;

procedure TTakvimVirmanDlg.TutarlariYerlestir;
Begin
   LabelATutar.Left := 8;
   LabelAKur.Left := LabelATutar.Left+LabelATutar.Width+1;
   LabelBcm.Left := LabelAKur.Left+LabelAKur.Width+1;
   LabelBTutar.Left := LabelBcm.Left+LabelBcm.Width+1;
   LabelBKur.Left := LabelBTutar.Left+LabelBTutar.Width+1;
End;

procedure TTakvimVirmanDlg.TablariAc;
Var
  kontrol:Integer;
begin
   //giren ve çıkan hesabın belirlenmesi;
   kontrol := 0;
   tablo.query1.Close;
   tablo.query1.SQL.text:='SELECT * FROM KASA WHERE ID = '+ IntToStr(ID);
   if AktifVeriMotor = vmPG then tablo.query1.SQL.Text := PgSqlCevir(tablo.query1.SQL.Text);
   tablo.query1.Open;
   //kayıt kontrolü ve querylerin açılması
   if tablo.query1.FieldByName('BORC').AsCurrency > 0.1 Then Begin  //borçlu
     Inc(kontrol);
     TabBorcluKasa.Close;
     if AktifVeriMotor = vmPG then TabBorcluKasa.SQL.Text := PgSqlCevir(TabBorcluKasa.SQL.Text);
     TabBorcluKasa.Params[0].Value:=ID;
     TabBorcluKasa.Open;
     TabAlacakliKasa.Close;
     if AktifVeriMotor = vmPG then TabAlacakliKasa.SQL.Text := PgSqlCevir(TabAlacakliKasa.SQL.Text);
     TabAlacakliKasa.Params[0].Value:=Tablo.Query1.FieldByName('GERIDONUSID').AsInteger;;
     TabAlacakliKasa.Open;
   End;
   if tablo.query1.FieldByName('ALACAK').AsInteger > 0 then Begin   //alacaklı
     Inc(kontrol);
     TabBorcluKasa.Close;
     if AktifVeriMotor = vmPG then TabBorcluKasa.SQL.Text := PgSqlCevir(TabBorcluKasa.SQL.Text);
     TabBorcluKasa.Params[0].Value:=Tablo.Query1.FieldByName('GERIDONUSID').AsInteger;
     TabBorcluKasa.Open;
     TabAlacakliKasa.Close;
     if AktifVeriMotor = vmPG then TabAlacakliKasa.SQL.Text := PgSqlCevir(TabAlacakliKasa.SQL.Text);
     TabAlacakliKasa.Params[0].Value:=ID;
     TabAlacakliKasa.Open;
   End;
   if kontrol in [0,2] then
      raise Exception.Create(BozukKayit);
End;

procedure TTakvimVirmanDlg.UstBilgileriOlustur;
Begin
   case IsTuru of
     41: begin  //kasa2-banka1
       TakvimVirmanDlg.Caption := islem41;
       BorcluDuzenle(1);
       AlacakliDuzenle(2);
     end;
     42: begin  //banka-kasa
       TakvimVirmanDlg.Caption := islem42;
       BorcluDuzenle(2);
       AlacakliDuzenle(1);
     end;
     43: begin  //banka-banka
       TakvimVirmanDlg.Caption := islem43;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;
     45: begin  //kasa-kasa
       TakvimVirmanDlg.Caption := islem45;
       BorcluDuzenle(2);
       AlacakliDuzenle(2);
     end;
     46: begin  //kasa-kasa
       TakvimVirmanDlg.Caption := islem46;
       BorcluDuzenle(2);
       AlacakliDuzenle(2);
     end;
     47: begin  //banka-kasa
       TakvimVirmanDlg.Caption := islem47;
       BorcluDuzenle(2);
       AlacakliDuzenle(1);
     end;
     48: begin //banka-kasa
       TakvimVirmanDlg.Caption := islem48;
       BorcluDuzenle(2);
       AlacakliDuzenle(1);
     end;  {
     51: begin //çek-banka
       TakvimVirmanDlg.Caption := islem51;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;
     52: begin //senet-banka
       TakvimVirmanDlg.Caption := islem52;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;
     53: begin  //banka-çek
       TakvimVirmanDlg.Caption := islem53;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;
     54: begin  //banka-senet
       TakvimVirmanDlg.Caption := islem54;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;
     58:begin  //banka-krediler
       TakvimVirmanDlg.Caption := islem111;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;
     95:begin  //banko-POS
       TakvimVirmanDlg.Caption := islem121;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;
     91:begin  //banko-Kasa
       TakvimVirmanDlg.Caption := islem122;
       BorcluDuzenle(1);
       AlacakliDuzenle(1);
     end;   }

   end;
End;

procedure TTakvimVirmanDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);
end;

procedure TTakvimVirmanDlg.FormShow(Sender: TObject);
Begin
   TablariAc;
   TutarlariYerlestir;
   UstBilgileriOlustur;
   PariteHesapla;
end;

procedure TTakvimVirmanDlg.IptalClick(Sender: TObject);
begin
  Close;
end;

procedure TTakvimVirmanDlg.IptalTusClick(Sender: TObject);
begin
  if DtsAlacakliKasa.State in [dsEdit] then
     TabAlacakliKasa.Cancel;
  if DtsBorcluKasa.State in [dsEdit] then
     TabBorcluKasa.Cancel;
end;

procedure TTakvimVirmanDlg.KaydetTusClick(Sender: TObject);
begin
  if DtsAlacakliKasa.State in [dsEdit] then
     TabAlacakliKasa.Post;
  if DtsBorcluKasa.State in [dsEdit] then
     TabBorcluKasa.Post;
end;

procedure TTakvimVirmanDlg.LabelTarihClick(Sender: TObject);
Var
   alanTuru,alanAdi,alanOwner : String;
   eskiad : Variant;
   ctrls : TGirdiDenetimleri;
   tab : TDataSet;
begin
   if TcxDBLabel(Sender) = LabelAKur then
     Sender := LabelATutar;
   if TcxDBLabel(Sender) = LabelBKur then
     Sender := LabelBTutar;

   alanAdi := TcxDBLabel(Sender).DataBinding.DataField ;
   eskiad := TcxDBLabel(Sender).Caption;
   tab := (TcxDBLabel(Sender).DataBinding.DataSource.DataSet as TFDQuery);
   case TcxDBLabel(Sender).Tag of
      //edit bilgi girişi
      1,3 : ctrls := TGirdiDenetimleri.Create.Edit(('Yeni '+alanAdi+' Değeri'),@eskiad);  //1 alacakli,3borclu ise
      //date bilgi girişi
      2 : begin
            if eskiad='' then eskiad :=Tablo.GENINI.BugunTrh;
            ctrls := TGirdiDenetimleri.Create.DateTimePicker(('Yeni '+alanAdi+' Değeri'),@eskiad);
          end;
   end;
   if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls) = mrOK then begin
     if Trim(eskiad) = '' then begin
        MessageDlg((BGYeni+alanAdi+BGDegeri_bos_olamaz),mtError,[mbOK],0);
        Exit; End
      else begin
        case TcxDBLabel(Sender).Tag of
          1: Begin
            TabAlacakliKasa.Edit;
            TabAlacakliKasa.FieldByName(alanAdi).AsVariant:= eskiad;
            TabAlacakliKasa.Post;
            TabAlacakliKasa.Close;
            TabAlacakliKasa.Open;
          End;
          2: Begin
            TabAlacakliKasa.Edit;
            TabAlacakliKasa.FieldByName(alanAdi).AsVariant:= eskiad;
            TabAlacakliKasa.Post;
            TabAlacakliKasa.Close;
            TabAlacakliKasa.Open;
            TabBorcluKasa.Edit;
            TabBorcluKasa.FieldByName(alanAdi).AsVariant:= eskiad;
            TabBorcluKasa.Post;
            TabBorcluKasa.Close;
            TabBorcluKasa.Open;
          End;
          3: Begin
            TabBorcluKasa.Edit;
            TabBorcluKasa.FieldByName(alanAdi).AsVariant:= eskiad;
            TabBorcluKasa.Post;
            TabBorcluKasa.Close;
            TabBorcluKasa.Open;
          End;
        end;
        FormShow(Self);
     end;
   end;
end;

procedure TTakvimVirmanDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabBorcluKasa.Delete;
     TabAlacakliKasa.Delete;
     Close;
  end;
end;

end.




