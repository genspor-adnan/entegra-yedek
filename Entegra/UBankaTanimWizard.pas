unit UBankaTanimWizard;


(*
IBAN format
TRkk BBBB BRCC CCCC CCCC CCCC CC
B = National bank code
R = Reserved for future use (currently "0")
C = Account Number
*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FMTBcd, dxSkinsCore, cxGraphics, Menus, cxLookAndFeelPainters, StdCtrls,
  cxButtons, cxImage, cxDBEdit, cxLabel, cxDBLabel, cxSpinEdit, cxCurrencyEdit,
  cxImageComboBox, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxControls,
  cxContainer, cxEdit, cxTextEdit, JvWizard, JvExControls, DB, SqlExpr, FireDAC.Comp.Client,
  ExtCtrls, dxSkinLondonLiquidSky, cxLookAndFeels, dxSkinLiquidSky;

type
  TBankaTanimWizardDlg = class(TForm)
    TabBankalar: TFDQuery;
    DtsBankalar: TDataSource;
    DtsBankaHesaplar: TDataSource;
    TabBankaHesaplar: TFDQuery;
    CariHesapEkstresi1: TPopupMenu;
    AcilisKaydiMenu: TMenuItem;
    N2: TMenuItem;
    KasaYenileMenu: TMenuItem;
    N1: TMenuItem;
    BtnKasalarnToplamlarnYenile1: TMenuItem;
    WizardKontrol: TJvWizard;
    HesapOlusturmaDuzenlemeEkr: TJvWizardWelcomePage;
    LabelHesapKodu: TcxLabel;
    LabelHesapAdi: TcxLabel;
    Label12: TcxLabel;
    Label14: TcxLabel;
    Label15: TcxLabel;
    Label24: TcxLabel;
    Label28: TcxLabel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    EditHESAPKODU: TcxDBTextEdit;
    EditHESAPADI: TcxDBTextEdit;
    ComboKUR: TcxDBComboBox;
    EditHESAPACIKLAMA: TcxDBTextEdit;
    EditHESAPNO: TcxDBTextEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    EditIBAN: TcxDBTextEdit;
    ComboBoxTIPI: TcxDBImageComboBox;
    LabelBANKASUBELERID: TcxDBLabel;
    Logo: TcxDBImage;
    LabelSubeKodu: TcxDBLabel;
    LabelSubeAdi: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    PanelAlt: TPanel;
    Label25: TcxLabel;
    Label29: TcxLabel;
    Label30: TcxLabel;
    Label5: TcxLabel;
    EditGERIDONUSHESAPKODU: TcxDBTextEdit;
    CheckKREDIKARTI: TcxDBCheckBox;
    EditKREDITUTARI: TcxDBCurrencyEdit;
    CheckKredi: TcxDBCheckBox;
    EditGERIDONUSGUNSAY: TcxDBSpinEdit;
    CheckCEKHESABI: TcxDBCheckBox;
    cxDBCheckBox1: TcxDBCheckBox;
    DevirFiiGir1: TMenuItem;
    cxDBCurrencyEdit1: TcxDBCurrencyEdit;
    Label3: TcxLabel;
    cxDBCheckBox2: TcxDBCheckBox;
    YeniBankaTanmla1: TMenuItem;
    YeniubeTanmla1: TMenuItem;
    cxDBCheckBox3: TcxDBCheckBox;
    EditBakiye: TcxDBCurrencyEdit;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxDBCheckBox4: TcxDBCheckBox;
    procedure TabBankaHesaplarAfterPost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure TabBankaHesaplarBeforePost(DataSet: TDataSet);
    procedure TabBankaHesaplarNewRecord(DataSet: TDataSet);
    procedure AcilisKaydiMenuClick(Sender: TObject);
    procedure LogoClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure TabBankaHesaplarAfterScroll(DataSet: TDataSet);
    function IBANControl(IBANNo:string):Boolean ;
    procedure YeniBankaTanmla1Click(Sender: TObject);
    procedure YeniubeTanmla1Click(Sender: TObject);
    procedure TabBankaHesaplarBeforeEdit(DataSet: TDataSet);
    procedure TabBankaHesaplarBeforeDelete(DataSet: TDataSet);
    procedure TabBankaHesaplarAfterDelete(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FEkleLogland: Boolean;   // ekleme logu tek sefer (AfterPost mukerrer tetiklenmesin)
  public
    { Public declarations }
    IslemOp:Char;
    Cagiran, BankaID, RehberId: Integer
  end;

var
  BankaTanimWizardDlg: TBankaTanimWizardDlg;

implementation

uses UAcilisKaydi, Utablo,UGirisKutusuEx,FetaKurulusSiniflari,PrjConst,LocOnFly, ULog, UVeriMotor;

{$R *.dfm}

type
  IBANHarf = record
    Harf : String[1];
    Deger : String[2];
  end;
var
  BugunTrh: TDateTime;
  OncekiKod, OncekiAd, OncekiRehberId : string;
  IBANHarfler : array[10..35] of IBANHarf = (
   (Harf:'A';Deger:'10'),
   (Harf:'B';Deger:'11'),
   (Harf:'C';Deger:'12'),
   (Harf:'D';Deger:'13'),
   (Harf:'E';Deger:'14'),
   (Harf:'F';Deger:'15'),
   (Harf:'G';Deger:'16'),
   (Harf:'H';Deger:'17'),
   (Harf:'I';Deger:'18'),
   (Harf:'J';Deger:'19'),
   (Harf:'K';Deger:'20'),
   (Harf:'L';Deger:'21'),
   (Harf:'M';Deger:'22'),
   (Harf:'N';Deger:'23'),
   (Harf:'O';Deger:'24'),
   (Harf:'P';Deger:'25'),
   (Harf:'Q';Deger:'26'),
   (Harf:'R';Deger:'27'),
   (Harf:'S';Deger:'28'),
   (Harf:'T';Deger:'29'),
   (Harf:'U';Deger:'30'),
   (Harf:'V';Deger:'31'),
   (Harf:'W';Deger:'32'),
   (Harf:'X';Deger:'33'),
   (Harf:'Y';Deger:'34'),
   (Harf:'Z';Deger:'35'));

procedure TBankaTanimWizardDlg.AcilisKaydiMenuClick(Sender: TObject);
var k:Word;
begin
   try
     if DtsBankaHesaplar.State IN [dsInsert,dsEdit] then
       TabBankaHesaplar.Post;
   finally
      Tablo.AcilisiFisiEkraniBaslat(3,TMenuItem(Sender).Tag,TabBankaHesaplar.FieldByname('ID').AsString,TabBankaHesaplar.FieldByname('HESAPNO').AsString,TabBankaHesaplar.FieldByname('HESAPADI').AsString, TabBankaHesaplar.FieldByname('KUR').AsString,0,Tablo.GENINI.BugunTrhSaat);
   end;
end;

function TBankaTanimWizardDlg.IBANControl(IBANNo:string):Boolean ;
var
  Int:Int64;
  ilk4char,Str:string;
  i : Integer;
begin
  Str:=StringReplace(IBANNo,' ','',[rfReplaceAll]);
  Str:=UpperCase(Str);
  ilk4char:=copy(Str,1,4);
  Str:=StringReplace(Str,ilk4char,'',[]);
  Str:=Str+ilk4char;
  for I := 10 to 35 do
    Str := StringReplace(Str,IBANHarfler[i].Harf,IBANHarfler[i].Deger,[rfReplaceAll]);
  Int:=StrToInt64def(Copy(Str,1,16),0);
  Int:= Int mod 97;
  Int:=StrToInt64def(IntToStr(Int)+Copy(Str,17,Length(Str)),0);
  Int:= Int mod 97;
  Result:=Int=1
end;

procedure TBankaTanimWizardDlg.FormCreate(Sender: TObject);
begin
  FEkleLogland := False;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.WizardTurkcelestir(WizardKontrol);
  HesapOlusturmaDuzenlemeEkr.Title.Text:=jvHesapOlusturmaDuzenleme;
  Tablo.GridTurkcelestir;
  ComboKUR.Enabled := DovizTakibi;
end;

procedure TBankaTanimWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // FALLBACK: yeni banka hesabi (islemOp='E') DB'ye yazilmis (dsBrowse, ID>0) ama
  // AfterPost gec kalirsa/tetiklenmezse ekleme logunu kapanista TEK SEFER garanti et.
  // FEkleLogland zaten True ise dokunma (mukerrer onleme).
  FEkleLogland := LogKartEkle(TabBankaHesaplar, TabNo_BANKAHESAPLAR, islemOp = 'E', FEkleLogland) or FEkleLogland;
end;

procedure TBankaTanimWizardDlg.FormShow(Sender: TObject);
begin
  YeniKayit:=False;
  PanelAlt.Visible := RehberId = -1;//Firmanın kendi hesapları için alt kısım görünsün
  LabelHesapKodu.Visible := PanelAlt.Visible;
  EditHESAPKODU.Visible := PanelAlt.Visible;
  LabelHesapAdi.Visible := PanelAlt.Visible;
  EditHESAPADI.Visible := PanelAlt.Visible;
  EditBakiye.Visible := Tablo.YetkiVarmi(250101,YetkiTur_Gorme);
  Label25.Visible := Tablo.YetkiVarmi(250101,YetkiTur_Gorme);

  if (EditHESAPKODU.Visible)and(EditHESAPKODU.Enabled) then
    EditHESAPKODU.SetFocus
  else if (EditHESAPNO.Visible)and(EditHESAPNO.Enabled) then
    EditHESAPNO.SetFocus;

  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;

end;

procedure TBankaTanimWizardDlg.LogoClick(Sender: TObject);
var HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR : String;
begin
   if (TabBankaHesaplar.State = dsEdit)and(TabBankaHesaplar.FieldByname('BANKASUBELERID').AsString<>'') then
       Tablo.SilmeKontrolu('KASA', 'HESAPID', TabBankaHesaplar.FieldByName('ID').AsString, 'Kasa');

   if Tablo.BankaHesapEkrani(2,HESAPID, HESAPKODU,HESAPNO, HESAPADI, KUR) then begin
      TabBankaHesaplar.Edit;
      TabBankaHesaplar.FieldByname('BANKASUBELERID').AsString := HESAPID;
   end;
end;

procedure TBankaTanimWizardDlg.TabBankaHesaplarAfterDelete(DataSet: TDataSet);
begin
    //İLETİŞİ SİL
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=1 and YER_ID=&id ',['&id'],[OncekiRehberId]);
      //ticari sil
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=2 and YER_ID=&id ',['&id'],[OncekiRehberId]);
      //kendisini sil
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBER where ID=&id ',['&id'],[OncekiRehberId]);
end;

procedure TBankaTanimWizardDlg.TabBankaHesaplarAfterPost(DataSet: TDataSet);
begin
  case islemOp of
    'D' : begin
             if TabBankaHesaplar.FieldByName('ILETREHBERID').AsString <> '' then begin
                if OncekiKod <> TabBankaHesaplar.FieldByName('HESAPKODU').AsString then
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update REHBER set KOD='''+TabBankaHesaplar.FieldByName('HESAPKODU').AsString+''' where ID='+TabBankaHesaplar.FieldByName('ILETREHBERID').AsString,[],[]);
                if OncekiAd <> TabBankaHesaplar.FieldByName('HESAPADI').AsString then
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update REHBER set FIRMA='''+TabBankaHesaplar.FieldByName('HESAPADI').AsString+''' where ID='+TabBankaHesaplar.FieldByName('ILETREHBERID').AsString,[],[]);
             end;
             LogKartDegisti(TabBankaHesaplar, TabNo_BANKAHESAPLAR, TabBankaHesaplar.Fields[0].AsInteger);
          end;
    'E' : // yeni banka hesabi: ekleme logu (LogIslemleri LogOnceki bos oldugundan ekleme'yi kacirir)
          FEkleLogland := LogKartEkle(TabBankaHesaplar, TabNo_BANKAHESAPLAR, True, FEkleLogland) or FEkleLogland;
   { 'E' : if TabBankaHesaplar.FieldByName('REHBERID').AsInteger < 0 then //Eğer kendi banka bilgimiz ise rehberde kart açsın
          begin //Eğer yeni kayıtsa otomatik olarak 0 miktarlı açılış fişi oluştursun
             Tablo.KasaKaydet(3001, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh)),0,'Açılış Fişi',
                          TabBankaHesaplar.FieldByName('ID').AsInteger, ComboKur.Text,'', 0,0,0,0,-1, -1,-1,-1,-1, SubeId,' ');
             //Cariye bu banka için kart açılır, bu carinin ID si bağ oluşturması için ILETREHBERID'ye kaydedilir
             if TabBankaHesaplar.FieldByName('ILETREHBERID').AsString = '' then begin
                Tablo.Query1.Close;
                Tablo.Query1.SQL.Text := 'Insert Into REHBER (STATU,KOD,FIRMA,DURUM,EKLEYEN,SUBEID)values(1,:KOD,:FIRMA,1,:EKLEYEN,'+IntToStr(SubeId)+') select scope_identity()';
                Tablo.Query1.Params[0].Value := TabBankaHesaplar.FieldByName('HESAPKODU').AsString;
                Tablo.Query1.Params[1].Value := TabBankaHesaplar.FieldByName('HESAPADI').AsString;
                Tablo.Query1.Params[2].Value := Kullanan;
                Tablo.Query1.Open;
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update BANKAHESAPLAR set ILETREHBERID='+Tablo.Query1.Fields[0].AsString+' where ID='+TabBankaHesaplar.Fields[0].AsString,[],[]);
                //TabBankaHesaplar.FieldByName('ILETREHBERID').AsInteger := Tablo.Query1.Fields[0].AsInteger;
             end;
         end; }
   end;
end;

procedure TBankaTanimWizardDlg.TabBankaHesaplarAfterScroll(DataSet: TDataSet);
begin
  Tabloyenile(TabBankalar, [TabBankaHesaplar.FieldByName('BANKASUBELERID').AsInteger]);
end;

procedure TBankaTanimWizardDlg.TabBankaHesaplarBeforeDelete(DataSet: TDataSet);
begin
  OncekiRehberId := TabBankaHesaplar.FieldByName('ILETREHBERID').AsString;
end;

procedure TBankaTanimWizardDlg.TabBankaHesaplarBeforeEdit(DataSet: TDataSet);
begin
   OncekiKod := TabBankaHesaplar.FieldByName('HESAPKODU').AsString;
   OncekiAd :=  TabBankaHesaplar.FieldByName('HESAPADI').AsString;
   if LogGun >0 then
      Tablo.OncekiLogBelirle(TabBankaHesaplar);
end;

procedure TBankaTanimWizardDlg.TabBankaHesaplarBeforePost(DataSet: TDataSet);
begin
  { if not BoslukKontrol(EditBANKAKODU.text, 'Banka Kodu') then Abort;
   if not BoslukKontrol(EditBANKAADI.text, 'Banka Adı') then Abort;
   if not BoslukKontrol(EditSUBEKODU.text, 'Banka Şube No') then Abort;
   if not BoslukKontrol(EditSUBEADI.text, 'Banka Şubesi') then Abort; }
   if Trim(EditIBAN.Text)<>'' then
      if (IBANControl(EditIBAN.Text)=False) then begin
          ShowMessage(BTWIBANGecersiz);
          Abort;
      end;
   TabBankaHesaplar.FieldByName('IBAN').AsString := StringReplace(EditIBAN.Text,' ','',[rfReplaceAll]);
   if not BoslukKontrol(LabelBANKASUBELERID.Caption, KontrolBankaSubesi) then Abort;
   if (EditHESAPKODU.Visible)and(not BoslukKontrol(EditHESAPKODU.text, KontrolHesapKodu)) then Abort;
   if (EditHESAPADI.Visible)and(not BoslukKontrol(EditHESAPADI.text, KontrolHesapAdi)) then Abort;
   if (EditIBAN.Text='')and(not BoslukKontrol(EditHESAPNO.text, KontrolHesapNo)) then Abort;
   if not BoslukKontrol(ComboKUR.text, KontrolParaBirimi) then Abort;
   if not BoslukKontrol(ComboBoxTIPI.text, KontrolHesapTipi) then Abort;

   TabBankaHesaplar.FieldByName('DEGISTIREN').AsString := Kullanan;
   TabBankaHesaplar.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
end;

procedure TBankaTanimWizardDlg.TabBankaHesaplarNewRecord(DataSet: TDataSet);
begin
  YeniKayit := True;
  TabBankaHesaplar.FieldByName('REHBERID').AsInteger := RehberId;
  TabBankaHesaplar.FieldByName('HESAPKODU').AsString := '0';

  TabBankaHesaplar.FieldByName('EKLEYEN').AsString := Kullanan;
  TabBankaHesaplar.FieldByName('KUR').AsString := CariDoviz;

  TabBankaHesaplar.FieldByName('DURUM').AsBoolean:= True;//ComboDURUM2.Items[0];
  TabBankaHesaplar.FieldByName('VARSAYILAN').AsBoolean:= TabBankaHesaplar.RecordCount<1;
  TabBankaHesaplar.FieldByName('CEKHESABI').AsBoolean:= False;
  TabBankaHesaplar.FieldByName('KREDILIHESAP').AsBoolean := False;
  TabBankaHesaplar.FieldByName('KREDIKARTI').AsBoolean := False;
  TabBankaHesaplar.FieldByName('MAASHESABI').AsBoolean := False;
  TabBankaHesaplar.FieldByName('GUNLUKAKSIYONDAGOSTER').AsBoolean := True;

  {if SubeVarmi then begin
     case Tablo.GENINI.ReadInteger(Ops_OpsiyonBanka_GorunecekSubeler,0) of
       0 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtak;
       1 : ComboSube.RepositoryItem := Tablo.RepSubelerKendiSubesi;
       2 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakKendiSubesi;
       3 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakTumSubeler;
     end;
     case Tablo.GENINI.ReadInteger(Ops_OpsiyonBanka_GorunecekSubeler,0) of
       0,2,3 : TabBankaHesaplar.FieldByName('SUBEID').AsInteger  := 0;
       1 : TabBankaHesaplar.FieldByName('SUBEID').AsInteger  := SubeID;
     end;
  end
  else
    TabBankaHesaplar.FieldByName('SUBEID').AsInteger := -1;}
  TabBankaHesaplar.FieldByName('SUBEID').AsInteger := SubeId;

end;

procedure TBankaTanimWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  TabBankaHesaplar.cancel;
end;

procedure TBankaTanimWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if TabBankaHesaplar.State in [dsInsert, dsEdit] then begin
    TabBankaHesaplar.post;
    BankaID := TabBankaHesaplar.Fields[0].asInteger;
  end;

  if TabBankalar.State=dsEdit then
    TabBankalar.Post;//sadece logo için
  ModalResult := mrOk;
end;

procedure TBankaTanimWizardDlg.YeniBankaTanmla1Click(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi := 'Banka';
  ctrls := TGirdiDenetimleri.Create.Edit(BTWYeniBankaGir, @Bilgi);
  if TGirisKutusuEx.BilgiAlEx(BTWBankaAdi, ctrls) = mrOk then begin
    if trim(Bilgi) = '' then begin
      MessageDlg((BTWBankaAdiBosOlamaz), mtError, [mbOK], 0);
      Exit;
    End else begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into BANKALAR(BANKAKODU,BANKAADI)values( (Select '+DbUst(1)+'BANKAKODU+1 from BANKALAR order by BANKAKODU desc '+DbSinir(1)+'),'''+Bilgi+''')',[],[]);
    end;
  end;
end;

procedure TBankaTanimWizardDlg.YeniubeTanmla1Click(Sender: TObject);
var
  Bilgi1,Bilgi2: Variant;
  ctrls: TGirdiDenetimleri;
  list:TStringList;
begin
  list:=TStringList.Create;
  //önce banka seçtirmemiz gerekiyor..
  if Tablo.ListedenBilgiGetir(BankaSecimi,'Select BANKAADI,BANKAKODU from BANKALAR ',List,[]) then begin
    Bilgi1 := KontrolSubeAdi;
    ctrls := TGirdiDenetimleri.Create.Edit(BTWYeniSubeGir, @Bilgi1);
    if TGirisKutusuEx.BilgiAlEx(BTWSubeAdi, ctrls) = mrOk then begin
      if trim(Bilgi1) = '' then begin
        MessageDlg((BTWSubeAdiBosOlamaz), mtError, [mbOK], 0);
        Exit;
      End else begin
        ctrls := TGirdiDenetimleri.Create.Edit(BTWYeniSubeKoduGir, @Bilgi2);
        Bilgi2 := KontrolSubeKodu;
        if TGirisKutusuEx.BilgiAlEx(KontrolSubeKodu+':', ctrls) = mrOk then begin
          if trim(Bilgi2) = '' then begin
            MessageDlg((BTWSubeKoduBosOlamaz), mtError, [mbOK], 0);
            Exit;
          End else begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into BANKASUBELER(BANKAKODU,SUBEKODU,SUBEADI)values('+List[1]+','+Bilgi2+','''+Bilgi1+''')',[],[]);
          end;
        end;
      end;
    end;
  end;

end;

end.





