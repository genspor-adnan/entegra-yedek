unit UKullaniciDuzenle;

interface
 //yeni kayıt için 0 ,
 //eski kaydı düzenlemek için 1 ile çağırılır..
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, cxLookAndFeelPainters, cxGraphics, DB, FireDAC.Comp.Client, cxMaskEdit,
  cxDropDownEdit, cxImageComboBox, cxDBEdit, cxGroupBox, cxLabel, cxControls,
  cxContainer, cxEdit, cxTextEdit, GIFImg, cxImage, Menus, StdCtrls, cxButtons,UGenSifre,Utablo,
  cxButtonEdit, cxDBLabel, dxSkinLondonLiquidSky, cxLookAndFeels, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  cxCheckBox, cxMemo, Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TKullaniciDuzenleDlg = class(TForm)
    TabKullanici1: TFDQuery;
    DtsKullanici1: TDataSource;
    btnKaydet: TcxButton;
    btnIptal: TcxButton;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    EditSifre2: TcxTextEdit;
    EditSifre1: TcxTextEdit;
    cxImage1: TcxImage;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    EditCevap: TcxTextEdit;
    Panel1: TPanel;
    cxDBTextEdit2: TcxDBTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel6: TcxLabel;
    ComboRol: TcxDBImageComboBox;
    ComboDurum: TcxDBImageComboBox;
    BEditRehber: TcxTextEdit;
    cxLabel5: TcxLabel;
    LabelREHBERID: TcxDBLabel;
    cxLabel9: TcxLabel;
    ComboSoru: TcxImageComboBox;
    cxLabel10: TcxLabel;
    ComboSkin: TcxDBImageComboBox;
    procedure cxTextEdit1PropertiesChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure TabKullanici1BeforePost(DataSet: TDataSet);
    function Kontrol(Alan, Ad : String) : Boolean;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnIptalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabKullanici1AfterPost(DataSet: TDataSet);
    procedure TabKullanici1BeforeEdit(DataSet: TDataSet);
  private
    //function SifreKarisikMi(Sifre: string): Boolean;
    { Private declarations }
    Kapanabilir : Boolean;
  public
    { Public declarations }
    KulID,RehID, RolId, Durum:Integer;
  end;

var
  KullaniciDuzenleDlg: TKullaniciDuzenleDlg;

//Resourcestring
//  mukerrerkod = 'Seçtiğiniz kullanıcı kodu daha önce kullanılmıştır, lütfen düzeltip tekrar deneyiniz..';


implementation
uses
ULog, PrjConst,Fetautil,FetaKurulusSiniflari,LocOnFly;

{$R *.dfm}

var
   Mesaj, OncekiSifre : string;

procedure TKullaniciDuzenleDlg.btnKaydetClick(Sender: TObject);
begin
  TabKullanici1.Edit;
//  if cxImage1.Visible then
  TabKullanici1.Post;
//  else
//    ShowMessage(KUGecersiz_sifre);
//  if DtsKullanici1.State = dsBrowse then
//    Close;
end;

procedure TKullaniciDuzenleDlg.btnIptalClick(Sender: TObject);
begin
   Kapanabilir := True;
   TabKullanici1.Cancel;
end;

procedure TKullaniciDuzenleDlg.cxTextEdit1PropertiesChange(Sender: TObject);
begin
  {if EditSifre1.Text<>EditSifre2.Text then begin
    cxImage1.Visible:=False;
  end else begin
    case Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_SifreYontemi,0) of
      0:cxImage1.Visible:=True;
      1:cxImage1.Visible:=Trim(EditSifre1.Text)<>'';
      2:cxImage1.Visible:=SifreKontrolu(EditSifre1.Text, EditSifre2.Text);
    end;
  end;  }
  Mesaj := SifreKontrolu(OncekiSifre,EditSifre1.Text, EditSifre2.Text);
  cxImage1.Visible := Mesaj='';
end;

{function TKullaniciDuzenleDlg.SifreKarisikMi(Sifre:string):Boolean;
var
  i:Integer;
  SayiVar,HarfVar:Boolean;
begin
  SayiVar := False;
  HarfVar := False;
  for I := 0 to Length(Sifre) - 1 do begin
    if dize.BunlardanBiriVarMi(Copy(Sifre,(i+1),1),['0','1','2','3','4','5','6','7','8','9']) then
      SayiVar := True
    else
      HarfVar := True;
  end;
  if (SayiVar)and(HarfVar)and(Length(Sifre)>5) then
    Result := True
  else
    Result := False;
end; }

procedure TKullaniciDuzenleDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Kapanabilir then begin
     if DtsKullanici1.State in [dsEdit,dsInsert] then
        CanClose:= Application.MessageBox(PChar(KUKaydedilmeden_cikilsinmi),PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_YES ;
  end
  else
     CanClose:= False;
end;

procedure TKullaniciDuzenleDlg.FormCreate(Sender: TObject);
begin
     LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TKullaniciDuzenleDlg.FormShow(Sender: TObject);
begin
  if IntToStr(RehId) = Kullanan then begin
     EditCevap.properties.echomode := eemNormal;
     EditSifre1.properties.echomode := eemNormal;
     EditSifre2.properties.echomode := eemNormal;
     Panel1.Enabled := False;
  end;

  ComboSoru.Properties := Tablo.imgComboboxInit( 'SELECT DEGER,ANAHTAR FROM GENINI WHERE DIL='+IntToStr(Dil)+' AND  BOLUM ='+IntToStr(ops_guvenlik_sorusu)+' AND DEGER>0 ORDER BY 2 ');


  TabloYenile(TabKullanici1, [KulID]);

  // Gecis doneminde eski veritabaninda SKINADI olmayabilir. Bu durumda
  // kullanici ayarlari ekrani acilmaya devam eder ve mevcut gorunum korunur.
  if TabKullanici1.FindField('SKINADI') <> nil then begin
     ComboSkin.DataBinding.DataField := 'SKINADI';
     ComboSkin.Enabled := True;
  end else begin
     ComboSkin.DataBinding.DataField := '';
     ComboSkin.Enabled := False;
  end;

  OncekiSifre := TabKullanici1.FieldByName('SIFRE').AsString;
  ComboSoru.EditValue  :=  TabKullanici1.FieldByName('SORU').Value;
  EditCevap.Text :=   UGenSifre.DeSifre( TabKullanici1.FieldByName('CEVAP').AsString);
  EditSifre1.Text := UGenSifre.DeSifre(TabKullanici1.FieldByName('SIFRE').AsString);
  EditSifre2.Text := EditSifre1.Text;

  if RehID>0 then
     BEditRehber.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', inttostr(RehID));
end;

function TKullaniciDuzenleDlg.Kontrol(Alan, Ad : String) : Boolean;
Begin
  if Alan='' then Begin
    Application.MessageBox(PChar(Ad+IKDoldurun),PChar(Uyari),MB_OK+MB_ICONERROR);
    Result := False;
  End else
    Result := True;
end;

procedure TKullaniciDuzenleDlg.TabKullanici1BeforeEdit(DataSet: TDataSet);
begin
  if LogGun > 0 then Tablo.OncekiLogBelirle(TFDQuery(DataSet));
end;

procedure TKullaniciDuzenleDlg.TabKullanici1AfterPost(DataSet: TDataSet);
var  Sube  : String[5];
begin
   // Kullanici EKLE/DEGISTIR logu (LogOnceki dolu -> DEGISTIR, bos -> EKLE; sifre sifreli haliyle loglanir)
   if TabKullanici1.FieldByName('ID').AsInteger > 0 then
      LogDetaySatirPost(DataSet, TabNo_KULLANICI, TabNo_KULLANICI, TabKullanici1.FieldByName('ID').AsInteger);
   if (IntToStr(RehId) = Kullanan) and (DataSet.FindField('SKINADI') <> nil) then begin
      if DataSet.FieldByName('SKINADI').IsNull then
         Tablo.KullaniciSkinUygula('DEFAULT')
      else
         Tablo.KullaniciSkinUygula(DataSet.FieldByName('SKINADI').AsString);
   end;
   Sube:=Tablo.AciklamaGetir('ROLLER', 'SUBEID', TabKullanici1.FieldByName('ROLID').AsInteger);
   //veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update REHBER set SUBEID='+Sube+', SINIF='+TabKullanici1.FieldByName('ROLID').AsString+' where ID='+TabKullanici1.FieldByName('REHBERID').AsString,[],[]);
end;

procedure TKullaniciDuzenleDlg.TabKullanici1BeforePost(DataSet: TDataSet);
begin
   Kapanabilir := False;
   if not Kontrol(BEditRehber.Text,cxLabel1.Caption) then abort;
   if not Kontrol(cxDBTextEdit2.Text,cxLabel2.caption) then abort;
   //if not Kontrol(ComboRol.Text,cxLabel5.Caption) then abort;

   if Panel1.Enabled = False then begin //se�enekler kullan ayar �K kullan�yorsa �ifre girmesine gerek yok
       if not Kontrol(ComboSoru.Text,cxLabel7.Caption) then abort;
       if not Kontrol(EditCevap.Text,cxLabel8.Caption) then abort;
       // Sifre kural kontrolu YALNIZ sifre gercekten degistirildiyse yapilir.
       // (FormShow alanlara MEVCUT sifreyi doldurur -> SifreKontrolu 'onceki sifreyle ayni'
       // uyarisi uretir ve Mesaj hic bosalmazdi; sifreye dokunmadan soru/cevap dahil HICBIR
       // ayar kaydedilemiyordu.)
       if (UGenSifre.Sifre(EditSifre1.Text) <> OncekiSifre) and (Mesaj<>'') then begin
          Application.MessageBox(PChar(Mesaj),PChar(Uyari),MB_OK+MB_ICONERROR);
          abort;
       end Else begin
          TabKullanici1.FieldByName('SORU').Value := ComboSoru.EditValue;
          TabKullanici1.FieldByName('CEVAP').Value := UGenSifre.Sifre(EditCevap.Text);
          // SIFRE ve gecerlilik suresi yalniz sifre DEGISTIYSE yazilir (degismeden
          // her kaydette surenin uzamasi sifre politikasini bosa cikarir).
          if UGenSifre.Sifre(EditSifre1.Text) <> OncekiSifre then begin
             TabKullanici1.FieldByName('SIFRE').Value := UGenSifre.Sifre(EditSifre1.Text);
             TabKullanici1.FieldByName('SIFREDEGISME').AsDateTime := Tablo.GENINI.BugunTrhSaat + (Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_SifreSuresi, 6)*30);
          end;
          TabKullanici1.FieldByName('DEGISTIREN').Value := Kullanan;
          TabKullanici1.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      end;
   end;
  Kapanabilir := True;
end;

end.



