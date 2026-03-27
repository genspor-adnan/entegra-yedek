unit uAyarForm;


interface
uses
  Registry, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, Spin, ShellCtrls, ShlObj,
  cxShellCommon, cxControls, cxContainer, cxShellTreeView,VCap,
  cxShellBrowserDialog, Menus, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy,
  dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, dxSkinscxPCPainter, cxGraphics, cxTimeEdit,
  cxDropDownEdit, cxCheckListBox, cxMaskEdit, cxSpinEdit, cxRadioGroup,
  cxMemo, cxEdit, cxTextEdit, cxListBox, cxPC,Generics.Collections, frxClass, frxExportPDF, cxButtonEdit, cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu;

type
  TAyarlarForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    CKSimge: TCheckBox;
    CKHizmet: TCheckBox;
    CKAcilis: TCheckBox;
    GroupBox1: TGroupBox;
    BTNKaydet: TSpeedButton;
    BTNIptal: TSpeedButton;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    txtOkuma: TSpinEdit;
    txtMaxCal: TSpinEdit;
    TabSheet3: TTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    SpeedButton1: TSpeedButton;
    txtSGiris: TEdit;
    SpeedButton2: TSpeedButton;
    txtSCikis: TEdit;
    SpeedButton3: TSpeedButton;
    txtSSure: TEdit;
    SpeedButton4: TSpeedButton;
    txtSGecersiz: TEdit;
    DGSesAc: TOpenDialog;
    TabSheet4: TTabSheet;
    Label9: TLabel;
    CBSurucu: TComboBox;
    BTNBicim: TSpeedButton;
    BTNKaynak: TSpeedButton;
    BTNEkran: TSpeedButton;
    BTNSikistir: TSpeedButton;
    CKKamera: TCheckBox;
    CKResim: TCheckBox;
    Label10: TLabel;
    txtResim: TEdit;
    SpeedButton5: TSpeedButton;
    Klasor: TcxShellBrowserDialog;
    Label12: TLabel;
    CBOkuyucu: TComboBox;
    Button1: TButton;
    chkHaraketListe: TCheckBox;
    chkMazeret: TCheckBox;
    chkizin: TCheckBox;
    chkPDKS: TCheckBox;
    chkYemekhane: TCheckBox;
    aygitAyarlariPopupMenu: TPopupMenu;
    MainMenu1: TMainMenu;
    GroupBox2: TGroupBox;
    txtPortNo: TEdit;
    txtYPortNo: TEdit;
    txtOkumaGecikme: TEdit;
    Label11: TLabel;
    Label4: TLabel;
    GroupBox3: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    txtIpNumber: TEdit;
    TxtPortNumber: TEdit;
    txtYIpNumber: TEdit;
    TxtYPortNumber: TEdit;
    TxtTimeout: TEdit;
    Label15: TLabel;
    TxtYTimeout: TEdit;
    TxtYPassword: TEdit;
    TxtPassword: TEdit;
    Label16: TLabel;
    lbludp: TLabel;
    ChkUDP: TCheckBox;
    ChkYUDP: TCheckBox;
    txtReaderNo: TEdit;
    txtYReaderNo: TEdit;
    Label3: TLabel;
    Label17: TLabel;
    txtCalismaAraligi: TSpinEdit;
    TabSheet5: TTabSheet;
    PCEPostaAyarlar: TcxPageControl;
    tsEPostaAyarlari: TcxTabSheet;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    lbAliciListesi: TcxListBox;
    txtKonu: TcxTextEdit;
    btnAliciEkle: TButton;
    btnAliciSil: TButton;
    btnAliciDuzenle: TButton;
    txtMesaj: TcxMemo;
    tsZamanlama: TcxTabSheet;
    Label21: TLabel;
    rbGunluk: TRadioButton;
    rbAylik: TRadioButton;
    rbHaftalik: TRadioButton;
    rbYillik: TRadioButton;
    pcZamanlama: TcxPageControl;
    tsGunluk: TcxTabSheet;
    Label22: TLabel;
    rbGunlukHerXGundeBir: TcxRadioButton;
    rbGunlukHaftaIci: TcxRadioButton;
    seGunlukGunSayisi: TcxSpinEdit;
    tsHaftalik: TcxTabSheet;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    seHaftalikHaftaSayisi: TcxSpinEdit;
    clbHaftalikGunListesi: TcxCheckListBox;
    tsAylik: TcxTabSheet;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    rbAylikOp1: TcxRadioButton;
    seAylikOp1AySayisi: TcxSpinEdit;
    seAylikOp1GunSayisi: TcxSpinEdit;
    rbAylikOp2: TcxRadioButton;
    seAylikOp2AySayisi: TcxSpinEdit;
    cbAylikOp2Kacinci: TcxComboBox;
    cbAylikOp2Aralik: TcxComboBox;
    tsYillik: TcxTabSheet;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    rbYillikOp1: TcxRadioButton;
    seYillikOp1YilSayisi: TcxSpinEdit;
    cbYillikOp1Ay: TcxComboBox;
    rbYillikOp2: TcxRadioButton;
    cbYillikOp2Ay: TcxComboBox;
    cbYillikOp2Kacinci: TcxComboBox;
    cbYillikOp2Gunu: TcxComboBox;
    teSuSaatte: TcxTimeEdit;
    tsHesap: TcxTabSheet;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    txtSmtpSunucusu: TEdit;
    txtKullaniciAdi: TEdit;
    txtSifre: TEdit;
    txtPort: TEdit;
    txtHesapEPosta: TEdit;
    txtGonderenAdi: TEdit;
    cbSifreleme: TcxComboBox;
    Label38: TLabel;
    frxPDFExport1: TfrxPDFExport;
    ChWindowsAcilirken: TCheckBox;
    OpenDialog1: TOpenDialog;
    procedure BTNKaydetClick(Sender: TObject);
    procedure BTNIptalClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure txtMaxCalKeyPress(Sender: TObject; var Key: Char);
    procedure txtReaderNoKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure BTNBicimClick(Sender: TObject);
    procedure BTNKaynakClick(Sender: TObject);
    procedure BTNEkranClick(Sender: TObject);
    procedure BTNSikistirClick(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DriverGetir();
    procedure EPostaAyarlariWrite;
    procedure EPostaAyarlariRead;
    procedure btnAliciEkleClick(Sender: TObject);
    procedure btnAliciDuzenleClick(Sender: TObject);
    procedure btnAliciSilClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  AyarlarForm: TAyarlarForm;
  Reg: TRegistry;

implementation

uses
  uTablo, uCamera, UCombo, uAnaForm ,UGirisKutusuEx;

{$R *.dfm}

procedure TAyarlarForm.BTNKaydetClick(Sender: TObject);
var
  ExeReg :TRegistry;
begin
  GENINI.WriteBoolean(Ops_PROGRAMHIZMET,  CKHizmet.Checked);
  GENINI.WriteBoolean(Ops_PROGRAMSIMGE, CKSimge.Checked);
  GENINI.WriteBoolean(Ops_PROGRAMSIFRE, CKAcilis.Checked);
  GENINI.WriteInteger(Ops_PROGRAMMAXVAR, txtMaxCal.Value);
  GENINI.WriteInteger(Ops_PROGRAMOKUMA, txtOkuma.Value);
  GENINI.WriteInteger(Ops_PROGRAMCALISMAARALIGI, txtCalismaAraligi.Value);
  GENINI.WriteInteger(Ops_BaudRate,115200);
  GENINI.WriteInteger(Ops_READERNO,strtoint(txtReaderNo.text) );
  GENINI.WriteInteger(Ops_PORTNO,strtoint(txtPortNo.text) );
  GENINI.WriteString(Ops_SGIRIS, txtSGiris.text);
  GENINI.WriteString(Ops_SCIKIS, txtSCikis.text);
  GENINI.WriteString(Ops_SSURE, txtSSure.text);
  GENINI.WriteString(Ops_SGECERSIZ, txtSGecersiz.text);
  GENINI.WriteString(Ops_CAMERA, CBSurucu.text);
  GENINI.WriteBoolean(Ops_CAMERAEKRAN, CKKamera.Checked);
  GENINI.WriteBoolean(Ops_RESIMEKRAN, CKResim.Checked);
  GENINI.WriteBoolean(Ops_PDKSVARMI, chkPDKS.Checked);
  GENINI.WriteBoolean(Ops_YemekhaneVARMI, chkYemekhane.Checked);
  GENINI.WriteString(Ops_RESIMYOL, txtResim.Text);
  GENINI.WriteString(Ops_OKUMAGECIKME, txtOkumaGecikme.Text);
  GENINI.WriteInteger(Ops_OKUYUCUTUR, CBOkuyucu.ItemIndex);
  GENINI.WriteBoolean(Ops_HARAKETLISTE, chkHaraketListe.Checked);
  GENINI.WriteBoolean(Ops_MAZERETGIRISI, chkMazeret.Checked);
  GENINI.WriteBoolean(Ops_IZINGIRISI, chkizin.Checked);

//  ExeReg :=TRegistry.Create;
//  ExeReg.RootKey := HKEY_LOCAL_MACHINE;
// // ExeReg.LazyWrite := false;
//  ExeReg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run',True);
//  if ChWindowsAcilirken.Checked then begin
//    GENINI.WriteBoolean(Ops_WindowsAcilirkenCalistir, True);
//    ExeReg.WriteString('Uygulamam',Application.ExeName ); //uygulamanýzýn_yolu_ve_adý
//  end else begin
//    GENINI.WriteBoolean(Ops_WindowsAcilirkenCalistir, False);
//    ExeReg.DeleteValue('Uygulamam');
//  end;
//  ExeReg.CloseKey;
//  ExeReg.free;

  EPostaAyarlariWrite;

  SifreSor := CKAcilis.Checked;
  SimgeDur := CKSimge.Checked;
  HizmetBas := CKHizmet.Checked;
  MaxVar := txtMaxCal.Value;
  OkumaAra := txtOkuma.Value;
  CalismaAraligi :=txtCalismaAraligi.Value * 60000;
  HaraketListe := chkHaraketListe.Checked;
  Mazeretgirisi := chkMazeret.Checked;

  SGiris := txtSGiris.Text;
  SCikis := txtSCikis.Text;
  SSure := txtSSure.Text;
  SGecersiz := txtSGecersiz.Text;

  SCamera := CBSurucu.Text;
  SCameraEkran := CKKamera.Checked;
  SResim := CKResim.Checked;
  SResimYol := txtResim.Text;
  ReaderNo := StrToIntDef(txtReaderNo.Text, 0);

  //Camera.OpenVideo(CBSurucu.Text);
  Close;

  reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey('\SOFTWARE\GENTEGRE2\GENPER\', true);
  Reg.WriteInteger('READERNO', strtoint(txtReaderNo.text));
  Reg.WriteInteger('PORTNO', strtoint(txtPortNo.text));
  Reg.WriteInteger('YREADERNO', strtoint(txtYReaderNo.text));
  Reg.WriteInteger('YPORTNO', strtoint(txtYPortNo.text));
  Reg.WriteBool('PDKS', chkPdks.Checked);
  Reg.WriteBool('YEMEKHANE', chkYemekhane.Checked);
  Reg.WriteString('IPNUMBER', txtIpNumber.Text);
  Reg.WriteString('YIPNUMBER', txtYIpNumber.Text);
  Reg.WriteString('YONLENDIRILENPORTNO', TxtPortNumber.Text);
  Reg.WriteString('YYONLENDIRILENPORTNO', TxtYPortNumber.Text);
  Reg.WriteString('VideoYol',txtResim.Text);
  Reg.WriteString('VideoSurucu',CBSurucu.Text);

  Reg.WriteString('TCPIPPASSWORD', TxtPassword.Text);
  Reg.WriteString('TCPIPPASSWORDY', TxtYPassword.Text);

  Reg.WriteString('TCPIPTIMEOUT', TxtTimeout.Text);
  Reg.WriteString('TCPIPTIMEOUTY', TxtYTimeout.Text);

  Reg.WriteBool('TCPIPUDP', ChkUDP.Checked);
  Reg.WriteBool('TCPIPUDPY', ChkYUDP.Checked);

  Reg.WriteString('CALISMAARALIGI', IntToStr(CalismaAraligi));
  Reg.WriteInteger('BoudRate', 115200);




  OkuyucuTur := CBOkuyucu.ItemIndex;
  anaform.Memo1.Visible := HaraketListe;
  AnaForm.izinler.Visible := IzinGirisi;
end;

procedure TAyarlarForm.EPostaAyarlariWrite;
var
i:integer;
a:string;
//aListe: TList<TAlici>;
begin
  {GENINI.WriteString(Ops_Konu,txtKonu.Text);

  aListe := TList<TAlici>.Create;
  for i := 0 to lbAliciListesi.Count - 1 do begin
    aListe.Add(TAlici(lbAliciListesi.Items.Objects[i]));
  end;
  GENINI.WriteString(Ops_AliciListesi,TAlici.ListedenStringe(aListe));
  GENINI.WriteString(Ops_Mesaj,txtMesaj.Lines.Text);

  GENINI.WriteBoolean(Ops_Gunluk, rbGunluk.Checked);
  GENINI.WriteString(Ops_Saat,teSuSaatte.Text);

  GENINI.WriteString(Ops_SmtpSunucusu,txtSmtpSunucusu.Text);
  GENINI.WriteString(Ops_KullaniciAdi,txtKullaniciAdi.Text);
  GENINI.WriteString(Ops_Sifre,txtSifre.Text);
  GENINI.WriteString(Ops_HesapEPosta,txtHesapEPosta.Text);
  GENINI.WriteString(Ops_GonderenAdi,txtGonderenAdi.Text);
  GENINI.WriteInteger(Ops_Port,StrToIntDef(txtPort.Text,587));
  GENINI.WriteInteger(Ops_Sifreleme,cbSifreleme.ItemIndex);   }

end;
procedure TAyarlarForm.EPostaAyarlariRead;
//var
//al:TAlici;
//aList : TList<TAlici>;
begin
 { txtKonu.Text := GENINI.ReadString(Ops_Konu,'');
  aList := TList<TAlici>.Create;
  TAlici.ListeyeYukle(GENINI.ReadString(Ops_AliciListesi,''),aList);

  lbAliciListesi.Items.Clear;
 for al in aList do begin
    lbAliciListesi.Items.AddObject(Format('%s <%s>',[ al.Adi,al.Email ]),al);
 end;

  txtMesaj.Lines.Text := GENINI.ReadString(Ops_Mesaj,'');

  rbGunluk.Checked:=GENINI.ReadBoolean(Ops_Gunluk,false);
  teSuSaatte.Text:=GENINI.ReadString(Ops_Saat,'12:00:00');

  txtSmtpSunucusu.Text := GENINI.ReadString(Ops_SmtpSunucusu,'');
  txtKullaniciAdi.Text := GENINI.ReadString(Ops_KullaniciAdi,'');
  txtSifre.Text := GENINI.ReadString(Ops_Sifre,'');
  txtHesapEPosta.Text := GENINI.ReadString(Ops_HesapEPosta,'');
  txtGonderenAdi.Text := GENINI.ReadString(Ops_GonderenAdi,'');
  txtPort.Text := IntToStr(GENINI.ReadInteger(Ops_Port,587));
  cbSifreleme.ItemIndex := GENINI.ReadInteger(Ops_Sifreleme,0); }
end;
procedure TAyarlarForm.BTNIptalClick(Sender: TObject);
begin
  Close;
end;

procedure TAyarlarForm.FormActivate(Sender: TObject);
begin
  CKAcilis.Checked := SifreSor;
  CKSimge.Checked := SimgeDur;
  CKHizmet.Checked := HizmetBas;
  txtMaxCal.value := MaxVar;
  txtOkuma.Value := OkumaAra;
//txtPortNo.Text:=GENINI.ReadString('OPSIYONLAR','PORTNO','');
//txtReaderNo.Text:=GENINI.ReadString('OPSIYONLAR','READERNO','');
  txtSGiris.Text := GENINI.ReadString(Ops_SGIRIS, '');
  txtSCikis.Text := GENINI.ReadString(Ops_SCIKIS, '');
  txtSSure.Text := GENINI.ReadString(Ops_SSURE, '');
  txtSGecersiz.Text := GENINI.ReadString(Ops_SGECERSIZ, '');
  CKKamera.Checked := GENINI.ReadBoolean(Ops_CAMERAEKRAN, false);
  CKResim.Checked := GENINI.ReadBoolean(Ops_RESIMEKRAN, false);
  //txtResim.Text := GENINI.ReadString('OPSIYONLAR', 'RESIMYOL', '');
  txtOkumaGecikme.Text := GENINI.ReadString(Ops_OKUMAGECIKME, '');
  CBOkuyucu.ItemIndex := GENINI.ReadInteger(Ops_OKUYUCUTUR, 0);
  chkHaraketListe.Checked := GENINI.ReadBoolean(Ops_HARAKETLISTE, False);
  chkMazeret.Checked := GENINI.ReadBoolean(Ops_MAZERETGIRISI, FALSE);
  chkizin.Checked := GENINI.ReadBoolean(Ops_IZINGIRISI, FALSE);
  chkPDKS.Checked := GENINI.ReadBoolean(Ops_PDKSVARMI, TRUE);
  chkYemekhane.Checked := GENINI.ReadBoolean(Ops_YemekhaneVARMI, FALSE);

//  ChWindowsAcilirken.Checked := GENINI.ReadBoolean(Ops_WindowsAcilirkenCalistir, FALSE);
  EPostaAyarlariRead;

  CBSurucu.Clear;
  DriverGetir();

  reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey('\SOFTWARE\GENTEGRE2\GENPER\', true);
  txtReaderNo.Text := inttostr(Reg.Readinteger('READERNO'));
  txtPortNo.Text := inttostr(Reg.Readinteger('PORTNO'));
  txtYReaderNo.Text := inttostr(Reg.Readinteger('YREADERNO'));
  txtYPortNo.Text := inttostr(Reg.Readinteger('YPORTNO'));
  chkPDKS.Checked:=Reg.ReadBool('PDKS');
  chkYemekhane.Checked:= Reg.ReadBool('YEMEKHANE');

  txtIpNumber.Text := Reg.ReadString('IPNUMBER');
  txtYIpNumber.Text := Reg.ReadString('YIPNUMBER');
  TxtPortNumber.Text := Reg.ReadString('YONLENDIRILENPORTNO');
  TxtYPortNumber.Text := Reg.ReadString('YYONLENDIRILENPORTNO');
  txtResim.Text := Reg.ReadString('VideoYol');
  CBSurucu.Text := Reg.ReadString('VideoSurucu');

//  TxtPassword.Text := Reg.ReadString('TCPIPPASSWORD');
//  TxtYPassword.Text := Reg.ReadString('TCPIPPASSWORDY');
//  TxtTimeout.Text := Reg.ReadString('TCPIPTIMEOUT');
//  TxtYTimeout.Text := Reg.ReadString('TCPIPTIMEOUTY');
  ChkUDP.Checked := Reg.ReadBool('TCPIPUDP');
  ChkYUDP.Checked := Reg.ReadBool('TCPIPUDPY');
  txtCalismaAraligi.Text := Reg.ReadString('CALISMAARALIGI');
end;

procedure TAyarlarForm.FormCreate(Sender: TObject);
begin
PageControl1.ActivePageIndex:=0;
end;

procedure TAyarlarForm.txtMaxCalKeyPress(Sender: TObject; var Key: Char);
begin
  if (strscan('0123456789', key) <> nil) or (key = #8) then
  begin
  end
  else
    key := #0;
end;

procedure TAyarlarForm.txtReaderNoKeyPress(Sender: TObject; var Key: Char);
begin
  if (strscan('0123456789', key) <> nil) or (key = #8) then
  begin
  end
  else
    key := #0;

end;

procedure TAyarlarForm.SpeedButton1Click(Sender: TObject);
begin
  if DGSesAc.Execute then
    txtSGiris.Text := DGSesAc.FileName;
end;

procedure TAyarlarForm.SpeedButton2Click(Sender: TObject);
begin
  if DGSesAc.Execute then
    txtSCikis.Text := DGSesAc.FileName;
end;

procedure TAyarlarForm.SpeedButton3Click(Sender: TObject);
begin
  if DGSesAc.Execute then
    txtSSure.Text := DGSesAc.FileName;
end;

procedure TAyarlarForm.SpeedButton4Click(Sender: TObject);
begin
  if DGSesAc.Execute then
    txtSGecersiz.Text := DGSesAc.FileName;
end;

procedure TAyarlarForm.btnAliciDuzenleClick(Sender: TObject);
var
  aliciAdi : Variant;
  email : Variant;
  r : TModalResult;
//  alici : TAlici;
 // item : TAlici;
  i : Integer;
begin
 { if lbAliciListesi.ItemIndex < 0 then Exit;
  alici := TAlici(lbAliciListesi.Items.Objects[lbAliciListesi.ItemIndex]);
  aliciAdi := alici.Adi;
  email := alici.EMail;
  r := TGirisKutusuEx.BilgiAlEx('Alýcý Düzenle', TGirdiDenetimleri.Create.Edit('Alýcý Adý',@aliciAdi).Edit('EPosta',@email));
  if (r = mrCancel) then Exit;
  email := LowerCase(Trim(email),TLocaleOptions.loInvariantLocale);
  for i := 0 to lbAliciListesi.Items.Count - 1 do begin
    item := TAlici(lbAliciListesi.Items.Objects[i]);
    if ((item <> alici) AND (item.Email = email) )  then begin
      MessageDlg('Ayný e-posta adresi iki defa eklenemez!',mtError,[mbOK],0);
      Exit;
    end;
  end;
  alici.Adi := aliciAdi;
  alici.Email := email;
  lbAliciListesi.Items[lbAliciListesi.ItemIndex] := Format('%s <%s>',[ alici.Adi,alici.Email ]);    }
end;

procedure TAyarlarForm.btnAliciEkleClick(Sender: TObject);
var
  aliciAdi : Variant;
  email : Variant;
  r : TModalResult;
//  item : TAlici;
  i : Integer;
begin
{  r:= TGirisKutusuEx.BilgiAlEx('Alýcý Ekle',TGirdiDenetimleri.Create.Edit('Alýcý Adý',@aliciAdi).Edit('EPosta',@email));
   if r=mrCancel then Abort;
  email := LowerCase(Trim(email),TLocaleOptions.loInvariantLocale);
   for i := 0 to lbAliciListesi.ITems.Count - 1 do begin
    item := TAlici(lbAliciListesi.Items.Objects[i]);
    if (item.Email = email) then begin
      MessageDlg('Ayný e-posta adresi iki defa eklenemez!',mtError,[mbOK],0);
      Exit;
    end;
   end;
  item := TAlici.Create;
  item.Adi := aliciAdi;
  item.Email := email;
  lbAliciListesi.Items.AddObject(Format('%s <%s>',[ item.Adi,item.Email ]),item);
                                                                                       }
end;

procedure TAyarlarForm.btnAliciSilClick(Sender: TObject);
//var
//  alici : TAlici;
begin
{  if lbAliciListesi.ItemIndex < 0 then Exit;
  alici := TAlici(lbAliciListesi.Items.Objects[lbAliciListesi.ItemIndex]);
  if (MessageDlg(alici.Adi + ' adlý alýcýyý gerçekten silmek istiyor musunuz?',
    mtConfirmation,[mbYes,mbNo],0) = mrNo) then Exit;
  alici.Free;
  lbAliciListesi.DeleteSelected;    }
end;

procedure TAyarlarForm.BTNBicimClick(Sender: TObject);
begin

 { if not Camera.video.IsOpen then
    Camera.OpenVideo(CBSurucu.Text);
  if Camera.video.DlgFormat then MessageBeep(0);  }
end;

procedure TAyarlarForm.BTNKaynakClick(Sender: TObject);
begin
  {if not Camera.video.IsOpen then
    Camera.OpenVideo(CBSurucu.Text);
  if Camera.video.DlgSource then MessageBeep(0);  }
end;

procedure TAyarlarForm.BTNEkranClick(Sender: TObject);
begin
  {if not Camera.video.IsOpen then
    Camera.OpenVideo(CBSurucu.Text);
  if Camera.video.DlgDisplay then MessageBeep(0); }
end;

procedure TAyarlarForm.BTNSikistirClick(Sender: TObject);
begin
  {if not Camera.video.IsOpen then
    Camera.OpenVideo(CBSurucu.Text);
  if Camera.video.DlgCompression then MessageBeep(0);  }
end;

procedure TAyarlarForm.SpeedButton5Click(Sender: TObject);
begin
  Klasor.Path := txtResim.Text;
  if Klasor.Execute then
    txtResim.Text := Klasor.Path;
end;

procedure TAyarlarForm.Button1Click(Sender: TObject);
begin
//  InileriAyarlama(GENINI);
end;

procedure TAyarlarForm.DriverGetir;
var
  currentVideoCapMode: TVCapMode;
  currentAudioCapMode: TACapMode;
  vidMode: TVCapMode;
  audMode: TACapMode;
  i: Integer;
  d: TCaptureDialog;
  item: TMenuItem;
begin
  currentVideoCapMode := Camera.Video.VCapMode;
  currentAudioCapMode := Camera.Video.ACapMode;
  CBSurucu.Items.Clear;
  for i := 0 to Camera.Video.VCapModeCount - 1 do
  begin
    vidMode := Camera.Video.VCapModes[i];
    CBSurucu.Items.Add(GetModeString(vidMode));
    if (IsEqualModes(vidMode, currentVideoCapMode)) then
      CBSurucu.ItemIndex := i;
  end;

  if StrToBool(GenRegIni.RegReadString('VideoAudio', 'SesiKaydet', 'False', 'C')) then
    for i := 0 to Camera.Video.ACapModeCount - 1 do
    begin
      audMode := Camera.Video.ACapModes[i];
      CBSurucu.Items.Add(GetModeString(audMode));
    end;
  aygitAyarlariPopupMenu.Items.Clear;
end;

end.

