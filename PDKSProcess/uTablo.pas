unit uTablo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Generics.Collections,cxImageComboBox,
  Db, DBTables, ImgList, dbctrls, ADODB, UCombo, Registry, ComCtrls, CPort,Mapi,UGENINIDuzenle,TlHelp32,
  AppEvnts, ExtCtrls, IdMessage,IdAttachmentFile, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, InvokeRegistry, Rio, SOAPHTTPClient;
type
  TLogbilgileri = record
    Kod: Integer;
    Tarih: TDateTime;
    ReaderNo : string;
  end;

  //SysUtils, Classes, DB, ADODB;

type
  TTablo = class(TDataModule)
    cnn: TADOConnection;
    TabYetki: TADOQuery;
    DtsKARTOKU: TDataSource;
    TabStatus: TADOQuery;
    DtsStatus: TDataSource;
    QTarSa: TADOQuery;
    IniSQL: TADOQuery;
    Query1: TADOQuery;
    Query2: TADOQuery;
    Query3: TADOQuery;
    Query4: TADOQuery;
    Query5: TADOQuery;
    Query6: TADOQuery;
    TabKimlik: TADOQuery;
    TabAraSQL: TADOQuery;
    TabMail: TADOQuery;
    TabSirket: TADOQuery;
    TabYemekhane: TADOQuery;
    DtsYemekhane: TDataSource;
    sp_KARTOKU_YEMEK: TADOStoredProc;
    DtsKARTOKUYEMEK: TDataSource;
    sp_KartOku: TADOQuery;
    ApplicationEvents: TApplicationEvents;
    tmrBaglantiYenile: TTimer;
    Gecicicnn: TADOConnection;
    qGeciciKartEkle: TADOQuery;
    qGeciciKartlarAktarilmayan: TADOQuery;
    qGeciciKartAktar: TADOQuery;
    TabBasitIzin: TADODataSet;
    TabBasitIzinID: TIntegerField;
    TabBasitIzinPERKOD: TIntegerField;
    TabBasitIzinBASTAR: TDateTimeField;
    TabBasitIzinBITTAR: TDateTimeField;
    TabBasitIzinGUN: TIntegerField;
    TabBasitIzinACIKLAMA: TStringField;
    dtsBasitIzin: TDataSource;
    dtsizinara: TDataSource;
    Tabizinara: TADOQuery;
    ImageGenel: TImageList;
    TabKullan: TADOQuery;
    DtsKullan: TDataSource;
    IdSMTP1: TIdSMTP;
    IdMessage1: TIdMessage;
    Query7: TADOQuery;
    Query8: TADOQuery;
    Query9: TADOQuery;
    Timer1: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure TabStatusAfterScroll(DataSet: TDataSet);
    procedure IzinHesap;
    procedure TabKimlikAfterScroll(DataSet: TDataSet);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure tmrBaglantiYenileTimer(Sender: TObject);
    procedure cnnAfterConnect(Sender: TObject);
    procedure GecicicnnBeforeConnect(Sender: TObject);
    procedure TabizinaraAfterScroll(DataSet: TDataSet);
    procedure TabStatusAfterOpen(DataSet: TDataSet);
    procedure RegistryDoldur;
    Function PERS_PDKSyeKayit(KartID,Tarih: string; OkuyucuNo,OkumaAra: integer):string;
    function fn_VardiyaGirisCikisSaat(RehberID:integer;VardiyaTuru,GirisMiCikisMi,Tarih:string):string;
  private

  public
  Database_Name:string;
    function KullaniciBilgisi(Kullanici, Ekran: string): Boolean;
    function BaudRateBul: TBaudRate;
    function BaudRateYaz: integer;
    procedure AktarilmayanGeciciKartlariAktar;
    procedure GeciciKartAktar(KartID: string; TarihSaat, EklemeTarihi, AktarimTarihi: TDateTime);
    function SendEMailGonder(Handle: THandle; Mail: TStrings): Cardinal;
    procedure GeciciKartEkle(KartID: string);
    procedure Komutlar(SQLText:String);
    procedure YeniEklenenlerSQL;
    procedure EPostaGonder;
    procedure EMailGonder;
    function ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string): String;
    function imgComboboxInit(Komut: string): TcxImageComboBoxProperties;
    function TablodanSorguAc(SorguNo: Integer; SQLText: String): Boolean;
    function SQLSatiriKopyala(TabloAdi: string; Id: integer; VarsAlanlar: array of String; VarsDegerler: array of Variant): integer;

  end;

    Moduller = record
    Cari, CRM, Fatura, Stok, Demirbas, Teklif, Ceksenet, Kasa, Banka,
      BankaDetay, Entegrasyon, Servis, Dokuman: Boolean;
  end;


  function BoslukKontrol(KontrolIci, Ad: String): Boolean;
  procedure TabloYenile(TabloAdi: TADOQuery; p: array of Variant);
  procedure Adim(s: string);
  function processExists(exeFileName: string): Boolean;

const
  LisansModul = 'Modul15';

var
  Tablo: TTablo;
  AdimAdimGoster,OzelTarihKullan: Boolean;
  Doklistesi: string[10];
  GENINI: TGENINIDuzenleDlg;
  KullanAdi, Kullanan, VeriTabaniEski: string[30];
  Sifresizler: SmallInt;
  RgstryLC: char;
  Modul: Moduller;
  silinen,SPID,SubeId: integer;
  OzelTarih:TDateTime;
  Super, Demo: Boolean;
  bolum, BasTar, BitTar, bitsaat: string[100];
  SifreSor, SimgeDur, HizmetBas, HaraketListe, MazeretGirisi, IzinGirisi,PDKSVarMi: Boolean;
  SGiris, SCikis, SSure, SGecersiz: string;
  MaxVar, OkumaAra,CalismaAraligi: integer;
  SCamera,GenYazilimIPAdress: string;
  SCameraEkran: boolean;
  SResim: Boolean;
  SResimYol: string;
  SonTarih, ReaderNo, PortNe, YReaderNo, YPortNe, CevrimdisiToplam: integer;
  Okuyucu2YedekPort, Pdks, Yemekhane: Boolean;
  GenRegIni: TRegIni;
  CnnRegIni :TRegIni;
  SirketKodu, IYIL, IAY: integer;
  Reg: TRegistry;
  CnnReg :TRegistry;
  BuBilgTarihi: boolean;
  OkuyucuTur: Byte;
  BoudRate: integer;
  IpNe , YIpNe , YonPortNe , YYonPortNe :String;
  VideoSurucu,VideoYol :string;
  UDPNe ,TimeoutNe  ,PassNe  ,YUDPNe ,YTimeoutNe  ,YPassNe : integer;
  Dil: Integer;
  Diller: array of Integer;
  DilAdlari: array of string;

  const
  {$REGION 'Opsiyon Sabitleri'}
    Ops_PROGRAMHIZMET = -100001;
    Ops_PROGRAMSIMGE = 100002;
    Ops_PROGRAMSIFRE = -100003;
    Ops_PROGRAMMAXVAR = -100004;
    Ops_PROGRAMOKUMA = -100005;
    Ops_PROGRAMCALISMAARALIGI = -100006;
    Ops_BaudRate = -100007;
    Ops_READERNO = -100008;
    Ops_PORTNO = -100009;
    Ops_SGIRIS = -100010;
    Ops_SCIKIS = -100011;
    Ops_SSURE = -100012;
    Ops_SGECERSIZ = -100013;
    Ops_CAMERA = -100014;
    Ops_CAMERAEKRAN = -100015;
    Ops_RESIMEKRAN = -100016;
    Ops_PDKSVARMI = -100017;
    Ops_YemekhaneVARMI = -100018;
    Ops_RESIMYOL = -100019;
    Ops_OKUMAGECIKME = -100020;
    Ops_OKUYUCUTUR = -100021;
    Ops_HARAKETLISTE = -100022;
    Ops_MAZERETGIRISI = -100023;
    Ops_IZINGIRISI = -100024;
    Ops_Konu = -100025;
    Ops_AliciListesi = -100026;
    Ops_Mesaj = -100027;
    Ops_Gunluk = -100028;
    Ops_Saat = -100029;
    Ops_SmtpSunucusu = -100030;
    Ops_KullaniciAdi = -100031;
    Ops_Sifre = -100032;
    Ops_HesapEPosta = -100033;
    Ops_GonderenAdi = -100034;
    Ops_Port = -100035;
    Ops_Sifreleme = -100036;
    Ops_Fetakey = -100037;
    Ops_UzmanlikSabit = -100038;
    Ops_PassWord = -100039;
    Ops_Registry = -100040;
    Ops_GenYazilimIPAdress = -100041;
    Ops_WindowsAcilirkenCalistir = -100042;
    {$ENDREGION }



implementation

uses UAnaForm, FetaUtil, Spin, DateUtils, Math, ComObj, ADOInt,UGirisKutusuEx,FetaKurulusSiniflari;

{$R *.dfm}

procedure Adim(s: string);
var
  list: TStringList;
begin

  if AdimAdimGoster then
  begin
    try
      list := TStringList.Create;
      if FileExists('PersonaLog.txt') then
        list.LoadFromFile('PersonaLog.txt');
      list.Add(FormatDateTime('yy-mm-dd hh:nn:ss.zzz'#9, +now) + s);
      list.SaveToFile('PersonaLog.txt');
    finally
      list.Free;
    end;
  end;
end;

function TTablo.BaudRateYaz: integer;
var
  BaudRate: integer;
  baud: TBaudRate;
begin
  Baud := AnaForm.ComPort1.BaudRate;

  if Baud = brCustom then
    BaudRate := 0
  else if Baud = br110 then
    BaudRate := 110
  else if Baud = br300 then
    BaudRate := 300
  else if Baud = br600 then
    BaudRate := 600
  else if Baud = br1200 then
    BaudRate := 1200
  else if Baud = br2400 then
    BaudRate := 2400
  else if Baud = br4800 then
    BaudRate := 4800
  else if Baud = br9600 then
    BaudRate := 9600
  else if Baud = br14400 then
    BaudRate := 14400
  else if Baud = br19200 then
    BaudRate := 19200
  else if Baud = br38400 then
    BaudRate := 38400
  else if Baud = br19200 then
    BaudRate := 19200
  else if Baud = br56000 then
    BaudRate := 56000
  else if Baud = br57600 then
    BaudRate := 57600
  else if Baud = br115200 then
    BaudRate := 115200
  else if Baud = br128000 then
    BaudRate := 128000
  else if Baud = br256000 then
    BaudRate := 256000;

  Result := BaudRate;
end;

function BoslukKontrol(KontrolIci, Ad: String): Boolean;
Begin
  if KontrolIci = '' then
  Begin
    Application.MessageBox(PChar(Ad + 'boþ býrakýlamaz '), 'U Y A R I',  MB_OK + MB_ICONERROR);
    Result := False;
  End
  else
    Result := True;
end;

function TTablo.BaudRateBul: TBaudRate;
var
  BaudRate: TBaudRate;
  baud: integer;
begin
  Baud := GENINI.ReadInteger(Ops_BaudRate, 0);

  if Baud = 0 then
    BaudRate := brCustom
  else if Baud = 110 then
    BaudRate := br110
  else if Baud = 300 then
    BaudRate := br300
  else if Baud = 300 then
    BaudRate := br300
  else if Baud = 600 then
    BaudRate := br600
  else if Baud = 1200 then
    BaudRate := br1200
  else if Baud = 2400 then
    BaudRate := br2400
  else if Baud = 4800 then
    BaudRate := br4800
  else if Baud = 9600 then
    BaudRate := br9600
  else if Baud = 14400 then
    BaudRate := br14400
  else if Baud = 19200 then
    BaudRate := br19200
  else if Baud = 38400 then
    BaudRate := br38400
  else if Baud = 19200 then
    BaudRate := br19200
  else if Baud = 56000 then
    BaudRate := br56000
  else if Baud = 57600 then
    BaudRate := br57600
  else if Baud = 115200 then
    BaudRate := br115200
  else if Baud = 128000 then
    BaudRate := br128000
  else if Baud = 256000 then
    BaudRate := br256000;

  Result := BaudRate;
end;


procedure TTablo.IzinHesap;
begin
//
end;

function TTablo.KullaniciBilgisi(Kullanici, Ekran: string): Boolean;
begin
  TabYetki.Close;
  TabYetki.Parameters[0].Value := Kullanici;
  TabYetki.Parameters[1].Value := Ekran;
  TabYetki.Open;
  if TabYetki.RecordCount > 0 then
    KullaniciBilgisi := True
  else
    KullaniciBilgisi := False;
end;

procedure TTablo.EPostaGonder;
 var
   Mail: TStringList;
begin
      Mail := TStringList.Create;
      try
        Mail.values['to'] :=GENINI.ReadString(Ops_AliciListesi,''); //'idris.85@hotmail.com';
        Mail.values['subject'] :=GENINI.ReadString(Ops_Konu,'');// 'Teklif mail gönderme sistemi';
        Mail.values['body'] :=GENINI.ReadString(Ops_Mesaj,'');// 'Teklif metniniz ektedir!';
        Mail.values['attachment0'] := 'D:\PersonaLog.txt';
   //     mail.values['attachment1']:='D:\PersonaLog.txt';
        // mail.values['attachment2']:='C:\Test3.txt';
        tablo.SendEMailGonder(Application.Handle, mail);
      finally
        Mail.Free;
      end;

end;


function TTablo.SendEMailGonder(Handle: THandle; Mail: TStrings): Cardinal;
type
  TAttachAccessArray = array [0 .. 0] of TMapiFileDesc;
  PAttachAccessArray = ^TAttachAccessArray;
var
  MapiMessage: TMapiMessage;
  Receip: TMapiRecipDesc;
  Attachments: PAttachAccessArray;
  AttachCount: Integer;
  i1: integer;
  filename: string;
  dwRet: Cardinal;
  MAPI_Session: Cardinal;
  WndList: Pointer;
begin
  dwRet := MapiLogon(Handle, PAnsiChar(''), PAnsiChar(''),
    MAPI_LOGON_UI or MAPI_NEW_SESSION, 0, @MAPI_Session);

  if (dwRet <> SUCCESS_SUCCESS) then
  begin
    MessageBox(Handle, PWideChar('Error while trying to send email'),
      PWideChar('Error'), MB_ICONERROR or MB_OK);
  end
  else
  begin
    FillChar(MapiMessage, SizeOf(MapiMessage), #0);
    Attachments := nil;
    FillChar(Receip, SizeOf(Receip), #0);

    if Mail.Values['to'] <> '' then
    begin
      Receip.ulReserved := 0;
      Receip.ulRecipClass := MAPI_TO;
      Receip.lpszName := StrPCopy(AnsiStrAlloc(length(Mail.Values['to'])),
        Mail.Values['to']); // PAnsiChar(Mail.Values['to']);
      Receip.lpszAddress := StrPCopy(AnsiStrAlloc(length(Mail.Values['to'])),
        Mail.Values['to']); // PAnsiChar(Mail.Values['to']);
      Receip.ulEIDSize := 0; // SMTP:
      MapiMessage.nRecipCount := 1;
      MapiMessage.lpRecips := @Receip;
    end;

    AttachCount := 0;

    for i1 := 0 to MaxInt do
    begin
      if Mail.Values['attachment' + IntToStr(i1)] = '' then
        break;
      Inc(AttachCount);
    end;

    if AttachCount > 0 then
    begin
      GetMem(Attachments, SizeOf(TMapiFileDesc) * AttachCount);

      for i1 := 0 to AttachCount - 1 do
      begin
        filename := Mail.Values['attachment' + IntToStr(i1)];
        Attachments[i1].ulReserved := 0;
        Attachments[i1].flFlags := 0;
        Attachments[i1].nPosition := ULONG($FFFFFFFF);
        Attachments[i1].lpszPathName := StrPCopy
          (AnsiStrAlloc(length(filename)), filename);
        Attachments[i1].lpszFileName := StrPCopy
          (AnsiStrAlloc(length(filename)), filename); ;
        Attachments[i1].lpFileType := nil;
      end;
      MapiMessage.nFileCount := AttachCount;
      MapiMessage.lpFiles := @Attachments^;
    end;

    if Mail.Values['subject'] <> '' then
      MapiMessage.lpszSubject := StrPCopy
        (AnsiStrAlloc(length(Mail.Values['subject'])),
        Mail.Values['subject']); // PAnsiChar(Mail.Values['subject']);
    if Mail.Values['body'] <> '' then
      MapiMessage.lpszNoteText := StrPCopy
        (AnsiStrAlloc(length(Mail.Values['body'])), Mail.Values['body']);
    // PAnsiChar(Mail.Values['body']);

    WndList := DisableTaskWindows(0);
    try
      Result := MapiSendMail(MAPI_Session, Handle, MapiMessage, MAPI_DIALOG, 0);
    finally
      EnableTaskWindows(WndList);
    end;
    for i1 := 0 to AttachCount - 1 do
    begin
      StrDispose(Attachments[i1].lpszPathName);
      StrDispose(Attachments[i1].lpszFileName);
    end;

    if Assigned(MapiMessage.lpszSubject) then
      StrDispose(MapiMessage.lpszSubject);
    if Assigned(MapiMessage.lpszNoteText) then
      StrDispose(MapiMessage.lpszNoteText);
    if Assigned(Receip.lpszAddress) then
      StrDispose(Receip.lpszAddress);
    if Assigned(Receip.lpszName) then
      StrDispose(Receip.lpszName);
    MapiLogOff(MAPI_Session, Handle, 0, 0);
  end;
end;

procedure TTablo.EMailGonder;
var
//al:TAlici;
//aList : TList<TAlici>;
Attachment : TIdAttachmentFile;
begin
{  aList := TList<TAlici>.Create;
  TAlici.ListeyeYukle(GENINI.ReadString(Ops_AliciListesi,''),aList);
  Try
    with IdSMTP1 do
    begin
      Host :=GENINI.ReadString(Ops_SmtpSunucusu,'');// 'mail.genyazilim.com';         //
      Port := 587;
      Username :=GENINI.ReadString(Ops_KullaniciAdi,'');// 'idris@genyazilim.com';         //Mail gönderecek kiþi
      Password :=GENINI.ReadString(Ops_Sifre,'');// 'Kurt2011';
      try
        Connect;
      except
        ShowMessage('Baðlantý Saðlanamadý...');
        exit;
      end;
    End;
  Except
    ShowMessage('Baðlantý Saðlanamadý...');
  End;
  Try
    with IdMessage1 do
    begin
      Clear;

      From.Name := GENINI.ReadString(Ops_GonderenAdi,'');// 'Ýdris KURT';                           //Kimden isim
      From.Address :=GENINI.ReadString(Ops_HesapEPosta,'');// 'idris@genyazilim.com';     //Kimden adres
      Subject := GENINI.ReadString(Ops_Konu,'');//'Mail Atma';                    //Baþlýk Konu
      Body.Text:=GENINI.ReadString(Ops_Mesaj,'');// Body.Assign();      //Mesaj
      ReplyTo.EMailAddresses:=GENINI.ReadString(Ops_HesapEPosta,'');  //Kimden

     for al in aList do begin
      //   lbAliciListesi.Items.AddObject(Format('%s <%s>',[ al.Adi,al.Email ]),al);
         Recipients.EMailAddresses := Recipients.EMailAddresses+';'+ Format('%s',[al.Email ]);// 'idris@genyazilim.com';   //Kime gidecek.
      end;
    end;                                                        // ,'GunlukDokum.xls'
      Attachment:= TIdAttachmentFile.Create(IdMessage1.MessageParts,'GunlukDokum.xls');

    IdSMTP1.Send(IdMessage1);
    IdSMTP1.Disconnect;
    ShowMessage ( 'Mailiniz Baþarýyla Gönderildi...');
  Except
    ShowMessage ( 'Mailiniz Gönderilemedi...');
    IdSMTP1.Disconnect;
  End;
  Attachment.Free;
  IdMessage1.Free;
  IdSMTP1.Free;    }
end;
function processExists(exeFileName: string): Boolean;
var
ContinueLoop: BOOL;
FSnapshotHandle: THandle;
FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := False;
  while Integer(ContinueLoop) <> 0 do    begin
      if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
        UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
        UpperCase(ExeFileName))) then   begin
        Result := True;
      end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
    end;
  CloseHandle(FSnapshotHandle);
end;
procedure TTablo.DataModuleCreate(Sender: TObject);
     {
  procedure RegYoksaYaz(anahtar: string;deger:string);
  var regAdi: string;
  begin
    regadi:=reg.ReadString(anahtar);
    if regadi='' then
      reg.WriteString(anahtar,deger);
  end;
}
begin

  Adim(' GENTEGRE2 ConnectionString ayarlarý kayýt ediliyor');
  CnnRegIni := TRegIni.Create('GENTEGRE2');
  CnnReg := TRegistry.Create;
  CnnReg.RootKey := HKEY_CURRENT_USER;
  CnnReg.OpenKey('\SOFTWARE\GENTEGRE2\', true);
  cnn.ConnectionString := CnnReg.ReadString('ConnectionString');
  Gecicicnn.ConnectionString := CnnReg.ReadString('ConnectionString');
  Adim(' cnn Üzerinden Baglantý saðlanýyor');
  if cnn.Connected then //or Gecicicnn.Connected then
  begin
    ShowMessage('Connection Nesnesi Açýk');
    halt;
  end;

  Adim(' Register ayarlarý kayýt edliyor (GenRegIni := TRegIni.Create)');
  GenRegIni := TRegIni.Create('GENTEGRE2\GENPER');

  Adim(' Þifre Kontrolu Yapýlýyor  VTSifreKontrolu(GenRegIni, cnn, False);    ');
  VTSifreKontrolu(CnnRegIni, cnn, False);
  Adim('GENINI := TIni.Create');

  GENINI := TGENINIDuzenleDlg.Create(nil);

  Doklistesi := 'DOKTOR';
  Adim('GENINI.ReadString eþittir C ise (if GENINI.ReadString)');
  if GENINI.ReadString(Ops_Registry, 'C') = 'C' then
    RgstryLC := 'C'
  else
    RgstryLC := 'L';

  GenYazilimIPAdress := GENINI.ReadString(Ops_GenYazilimIPAdress,'genupdate.genyazilim.com');//  GenelOpsiyon','GenYazilimIPAdress', 'genupdate.genyazilim.com');
  //Lisanssrv := lisansws.GetLisansServiceSoap(False, 'http://'+GenYazilimIPAdress+'/entegralisans/LisansWs.asmx',HTTPRIOLisans);

  Adim('QTarSa.Open;');
  QTarSa.Open;


  MazeretGirisi := GENINI.ReadBoolean(Ops_MAZERETGIRISI, FALSE);
//  TabStatus.Close;
//  TabStatus.Open;
//  TabYemekhane.Open;
  Adim('SifreSor := .Readbool');
  SifreSor := GENINI.ReadBoolean(Ops_PROGRAMSIFRE, False);
  SimgeDur := GENINI.ReadBoolean(Ops_PROGRAMSIMGE, FALSE);
  HizmetBas := GENINI.ReadBoolean(Ops_PROGRAMHIZMET, True);
  MaxVar := GENINI.ReadInteger(Ops_PROGRAMMAXVAR, 16);
  OkumaAra := GENINI.ReadInteger(Ops_PROGRAMOKUMA, 1);
  CalismaAraligi := GENINI.ReadInteger(Ops_PROGRAMCALISMAARALIGI,1);//'PROGRAMCALISMAARALIGI', 1);
  SGiris := GENINI.ReadString(Ops_SGIRIS, '');
  SCikis := GENINI.ReadString(Ops_SCIKIS, '');
  SSure := GENINI.ReadString(Ops_SSURE, '');
  SGecersiz := GENINI.ReadString(Ops_SGECERSIZ, '');
  SCamera := GENINI.ReadString(Ops_CAMERA, '');
  SCameraEkran := GENINI.ReadBoolean(Ops_CAMERAEKRAN, FALSE);
  HaraketListe := GENINI.ReadBoolean(Ops_HARAKETLISTE, FALSE);
  IzinGirisi := GENINI.ReadBoolean(Ops_IZINGIRISI, FALSE);
  SResim := GENINI.ReadBoolean(Ops_RESIMEKRAN, false);
  SResimYol := GENINI.ReadString(Ops_RESIMYOL, '');
  OkuyucuTur := GENINI.ReadInteger(Ops_OKUYUCUTUR, 0);

  RegistryDoldur;

  try
    Gecicicnn.Open;
  except
    ShowMessage('Geçici database''i kontrol ediniz');
  end;

end;

Procedure TTablo.RegistryDoldur;
var
  IpAdresi : Variant;
begin
  Adim('reg := TRegistry.Create;');
  reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey('\SOFTWARE\GENTEGRE2\GENPER\', true);

  Adim(' ReaderNo := Reg.Readinteger');
  try
    ReaderNo :=  Reg.ReadInteger('READERNO');
  except
    Reg.WriteInteger('READERNO',1);
  end;
  try
    PortNe := Reg.ReadInteger('PORTNO');
  except
    Reg.WriteInteger('PORTNO',7);
  end;

  Adim('YReaderNo := Reg.Readinteger');
  try
    YReaderNo := Reg.ReadInteger('YREADERNO');
  except
    Reg.WriteInteger('YREADERNO',2);
  end;

  try
    YPortNe := Reg.ReadInteger('YPORTNO');
  except
    Reg.WriteInteger('YPORTNO',7);
  end;

  if Reg.ReadString('IPNUMBER') <> '' then
    IpNe := Reg.ReadString('IPNUMBER')
  else begin
    if TGirisKutusuEx.BilgiAlEx('Yeni bilgi giriþi.', TGirdiDenetimleri.Create.Edit('Cihaza verilen IP adresini giriniz', @IPAdresi)
     ) = mrOk then
    Reg.WriteString('IPNUMBER',IpAdresi);  // 192.168.0.217
  end;
  if Reg.ReadString('YIPNUMBER') <> '' then
    YIpNe := Reg.ReadString('YIPNUMBER')
  else
     Reg.WriteString('YIPNUMBER',IpAdresi);

  if Reg.ReadString('YONLENDIRILENPORTNO') <> '' then
    YonPortNe := Reg.ReadString('YONLENDIRILENPORTNO')
  else
     Reg.WriteString('YONLENDIRILENPORTNO','4370');

  if Reg.ReadString('YYONLENDIRILENPORTNO') <> '' then
    YYonPortNe := Reg.ReadString('YYONLENDIRILENPORTNO')
  else
     Reg.WriteString('YYONLENDIRILENPORTNO','4370');

  try
    if Reg.ReadBool('TCPIPUDP') then
      UDPNe := 1 else  UDPNe := 0;
  except
    Reg.WriteBool('TCPIPUDP',False);
  end;

  try
  if Reg.ReadBool('TCPIPUDPY') then
    YUDPNe := 1 else  YUDPNe := 0;
  except
    Reg.WriteBool('TCPIPUDPY',false);
  end;

  if Reg.ReadString('CALISMAARALIGI') <> '' then
    CalismaAraligi := StrToInt(Reg.ReadString('CALISMAARALIGI')) * 60000
  else begin
    Reg.WriteString('CALISMAARALIGI','3600000');
    CalismaAraligi := 3600000
  end;

  try
   VideoSurucu := Reg.ReadString('VideoSurucu');
  except
    Reg.WriteString('VideoSurucu','');
  end;

  try
    VideoYol := Reg.ReadString('VideoYol');
  except
    Reg.WriteString('VideoYol','');
  end;

  try
    Pdks := Reg.ReadBool('PDKS');
  except
    Reg.WriteBool('PDKS',True);
  end;

  try
    Yemekhane := Reg.ReadBool('YEMEKHANE');
  except
    Reg.WriteBool('YEMEKHANE',False);
  end;


//  BoudRate := 115200;        //idris  9600; //
//  if Reg.OpenKey('ComPort1\', false) then
//  begin
//    BoudRate := StrToIntDef(Reg.ReadString('BaudRate'),115200);
//  end;

  try
    BoudRate := Reg.ReadInteger('BaudRate');
  except
    Reg.WriteInteger('BaudRate',115200);
    BoudRate := 115200;
  end;
end;


procedure TTablo.YeniEklenenlerSQL;
begin
  //Komutlar('Alter Table PERSONELINI alter column DEGER varchar(250)');
end;

procedure TTablo.Komutlar(SQLText:string);
begin
 Tablo.Query1.Close;
 Tablo.Query1.SQL.Text:=SQLText;
 try
   Tablo.Query1.ExecSQL;
 except
 end;
end;


procedure TTablo.TabStatusAfterScroll(DataSet: TDataSet);
var
  DosyaAdi: string;
begin
  if not Assigned(AnaForm) then
    Exit;

  if TabStatus.FieldByName('GIRIS').AsString <> '' then
  begin
    DosyaAdi := SResimYol + '\GIRIS' + TabStatus.FieldByName('ID').AsString + '.jpg';
    if FileExists(DosyaAdi) then
    begin
      AnaForm.IMGIRIS.Picture.LoadFromFile(DosyaAdi);
      AnaForm.IMGIRIS.Visible := true;
    end
    else
      AnaForm.IMGIRIS.Visible := false;
  end
  else
    AnaForm.IMGIRIS.Visible := false;
  if TabStatus.FieldByName('CIKIS').AsString <> '' then
  begin
    DosyaAdi := SResimYol + '\CIKIS' + TabStatus.FieldByName('ID').AsString + '.jpg';
    if FileExists(DosyaAdi) then
    begin
      AnaForm.IMCIKIS.Picture.LoadFromFile(DosyaAdi);
      AnaForm.IMCIKIS.Visible := true;
    end
    else
      AnaForm.IMCIKIS.Visible := false;
  end
  else
    AnaForm.IMCIKIS.Visible := false;
end;

procedure TTablo.TabKimlikAfterScroll(DataSet: TDataSet);
begin
//
end;

procedure TabloYenile(TabloAdi: TADOQuery; p: array of Variant);
var
  i: Byte;
begin
  TabloAdi.Close;
  if length(p) > 0 then
    for i := 0 to High(p) do
    begin
      TabloAdi.Parameters[i].Value := p[i];
    end;
  TabloAdi.Prepared := True;
  TabloAdi.Open;

end;
function TTablo.ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string)
  : String;
begin
  Result := 'Provider=SQLOLEDB.1;Password=' + Pass + ';Persist Security Info=True;User ID=' + UserN + ';Initial Catalog=' +
    DBName + ';Data Source=' + ServerName + ';Use Procedure for Prepare=1;Auto Translate=True;Packet Size=8192' +
    ';Application Name=' + Application.Title + ';Workstation ID=' + GetCurrentComputerName +';Use Encryption for Data=False;Tag with column collation when possible=False';
End;

function TTablo.imgComboboxInit(Komut: string): TcxImageComboBoxProperties;
var
  i: integer;
  cmblist: TcxImageComboBoxProperties;
begin
  i := 0;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := Komut;
  Tablo.Query1.Open;
  cmblist := TcxImageComboBoxProperties.Create(Self);
  cmblist.ImmediatePost := True;
  while not Tablo.Query1.Eof do
  begin
    cmblist.Items.Add;
    cmblist.Items[i].Description := Tablo.Query1.Fields[1].AsString;
    cmblist.Items[i].Value := Tablo.Query1.Fields[0].AsString;
    Inc(i);
    Tablo.Query1.Next;
  end;
  Result := cmblist;
end;


function TTablo.TablodanSorguAc(SorguNo: Integer; SQLText: String): Boolean;
var
  QueryX: TADOQuery;
Begin
  case SorguNo of
    1:
      QueryX := Query1;
    2:
      QueryX := Query2;
    3:
      QueryX := Query3;
    4:
      QueryX := Query4;
    5:
      QueryX := Query5;
    6:
      QueryX := Query6;
    7:
      QueryX := Query7;
    8:
      QueryX := Query8;
    9:
      QueryX := Query9;
  end;
  QueryX.Close;
  QueryX.SQL.Text := SQLText;
  try
    QueryX.Prepared := True;
    QueryX.Open;
    Result := True;
  Except
    Result := False;
  end;
End;
procedure TTablo.ApplicationEventsException(Sender: TObject; E: Exception);
begin
  if e is EOleException then
  begin

    case EOleException(e).ErrorCode of
      // Baðlantý baþarýsýz oldu
      -2147467259:
        begin
          AnaForm.lblMesaj.Caption := 'Baðlantý koptu yeniden baðlanýlacak.';
          cnn.Connected := False;
        end;
    else
      ShowMessage(IntToStr(EOleException(e).ErrorCode) + ' ' + EOleException(e).Source + ' ' + EOleException(e).Message);
    end;
  end
  else
  begin
    ShowMessage(e.classname + ': ' + e.Message);
  end;
end;

procedure TTablo.tmrBaglantiYenileTimer(Sender: TObject);
begin
  if not cnn.Connected then
  begin
    cnn.Open;
  end;
end;

procedure TTablo.cnnAfterConnect(Sender: TObject);
begin
  if AnaForm <> nil then
    AnaForm.lblMesaj.Caption := cnn.ConnectionObject.Properties['Data Source'].Value + ' server''ýnda ' + cnn.ConnectionObject.Properties['Initial Catalog'].Value + ' database''ine Baðlanýldý';

 // AktarilmayanGeciciKartlariAktar;
//  try
//    TabStatus.Close;
//    TabStatus.AfterOpen := nil;
//    TabStatus.Open;
//    TabStatus.AfterOpen := TabStatusAfterOpen;
//    TabStatus.Last;
//  except
//  end;
end;

procedure TTablo.AktarilmayanGeciciKartlariAktar;
begin

  with qGeciciKartlarAktarilmayan do
  begin
    Close;
    Open;
    while not eof do
    begin
      // Burada gerçek server'a verileri kaydedeceksin

      try
        GeciciKartAktar(
          FieldByName('KartID').AsString,
          FieldByName('TarihSaat').AsDateTime,
          FieldByName('EklemeTarihi').AsDateTime,
          FieldByName('AktarimTarihi').AsDateTime);


        Edit;
        FieldByName('AktarimTarihi').Value := Now;
        Post;

      except
      end;


      Next;
    end;
  end;
end;

procedure TTablo.GeciciKartEkle(KartID: string);
begin
  with qGeciciKartEkle do
  begin
    Close;
    Parameters.ParamByName('KartID').Value := KartID;
    try
      AnaForm.lblMesaj.Caption := KartID + ' çevrimdýþý eklenecek';
      ExecSQL;
      inc(CevrimdisiToplam);
      AnaForm.lblMesaj.Caption := KartID + ' çevrimdýþý eklendi. Eklenen toplam: ' + inttostr(CevrimdisiToplam);

    except
      on e: Exception do
        AnaForm.lblMesaj.Caption := KartID + ' KartID Okunamadý: ' + e.Message;
    end;
  end;
end;

procedure TTablo.GeciciKartAktar(KartID: string; TarihSaat, EklemeTarihi,
  AktarimTarihi: TDateTime);
begin
  //
  with qGeciciKartAktar do
  begin
    Close;
    Parameters.ParamByName('KartID').Value := KartID;
    Parameters.ParamByName('TarihSaat').Value := TarihSaat;
    Parameters.ParamByName('EklemeTarihi').Value := EklemeTarihi;
    Parameters.ParamByName('AktarimTarihi').Value := AktarimTarihi;
    ExecSQL;
  end;
end;

procedure TTablo.GecicicnnBeforeConnect(Sender: TObject);
begin
  Gecicicnn.ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;' +
    'Data Source=' + ExtractFilePath(Application.ExeName) + '\Gecici\Gecici.mdb;' +
    'Persist Security Info=False';
end;

procedure TTablo.TabizinaraAfterScroll(DataSet: TDataSet);
begin
  TabBasitIzin.Close;
  TabBasitIzin.Parameters[0].Value := Tabizinara.fieldbyname('PERKOD').AsInteger;
  TabBasitIzin.Open;
end;

procedure TTablo.TabStatusAfterOpen(DataSet: TDataSet);

var mazeret: string;
begin

  if MazeretGirisi then
  begin

    while not TabStatus.Eof do
    begin

     // if (TabStatus.FieldByName('GIRIS2').AsString >TabStatus.FieldByName('VARGIRIS').AsString )
      if (TabStatus.FieldByName('GIRFARK').AsString = 'GEÇ')
        //and (TabStatus.FieldByName('GIRCIK').AsString = 'GÝRÝS')
      and (TabStatus.FieldByName('GEC_MAZERET').AsString = '') then
      begin

        mazeret := InputBox('Mazeret', 'Sayýn ' + TabStatus.FieldByName('ADI').AsString + ' ' + TabStatus.FieldByName('SOYADI').AsString + ' lütfen gecikme mazeretinizi giriniz', '');


        TabStatus.edit;
        TabStatus.FieldByName('GEC_MAZERET').AsString := mazeret;
        TabStatus.post;
      end;
      if (TabStatus.FieldByName('CIKFARK').AsString = 'ERKEN')
        and (TabStatus.FieldByName('GIRCIK').AsString = 'ÇIKIÞ')
        and (TabStatus.FieldByName('ERKEN_MAZERET').AsString = '') then
      begin

        mazeret := InputBox('Mazeret', 'Sayýn ' + TabStatus.FieldByName('ADI').AsString + ' ' + TabStatus.FieldByName('SOYADI').AsString + ' lütfen erken çýkma mazeretinizi giriniz', '');

        TabStatus.edit;
        TabStatus.FieldByName('ERKEN_MAZERET').AsString := mazeret;
        TabStatus.post;
      end;
      TabStatus.Next;
    end;

  end;
end;

Function TTablo.PERS_PDKSyeKayit(KartID,Tarih: string;OkuyucuNo,OkumaAra: integer):string;
Var
  AdSoyad,VardiyaTuru,VardiyaBasSaat,VardiyaBitSaat,VardiyaDurum,YapilacakKayit,Sonuc,DonenSaat,Cikis,SonGiris:String;
  RehberID,Fark:integer;
  Saat : TTime;
begin
  SonGiris := '1900-01-01 00:00:00';
  Cikis := '1900-01-01 00:00:00';
  DonenSaat := '00:00:00';
  Fark:=0;

  Saat := StrToTime(Copy(Tarih,12,5));
  TablodanSorguAc(2,'SELECT R.FIRMA,R.ID , RB.BILGI,rb.ETIKET  FROM REHBERBILGI RB (nolock) left outer JOIN REHBERAYAR RA (nolock) ON RA.YERI=3 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
  ' left outer join REHBER R (nolock) ON R.ID=RB.YER_ID Where  RA.VARSAYILAN = 90 and RB.BILGI='''+KartID+''' ');

  AdSoyad := Tablo.Query2.FieldByName('FIRMA').AsString;
  RehberID := Tablo.Query2.FieldByName('ID').AsInteger;

  TablodanSorguAc(1,'SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=3 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID='+IntToStr(RehberID)+' AND RA.VARSAYILAN=91 ');
  if Tablo.Query1.RecordCount < 1 then begin
     VardiyaTuru:='Sabit'
  end else begin
     if Tablo.Query1.FieldByName('BILGI').AsString = 'Sabit' then
        VardiyaTuru:='Sabit'
     else
        VardiyaTuru:='Deðiþken';
  end;
  TablodanSorguAc(2,'SELECT SAYI=COUNT(*) FROM PERS_PDKS WHERE REHBERID = '+IntToStr(RehberID)+' AND ('''+Tarih+''' = GIRIS OR '''+Tarih+''' = CIKIS)');
  if Tablo.Query2.FieldByName('SAYI').AsInteger > 0 then begin
     Sonuc := 'MÜKERRER KAYIT';
     Abort;
  end else begin

     if AdSoyad <> '' then begin

        VardiyaBasSaat := fn_VardiyaGirisCikisSaat(RehberID,VardiyaTuru,'G',Tarih);
        VardiyaBitSaat := fn_VardiyaGirisCikisSaat(RehberID,VardiyaTuru,'Ç',Tarih);

        //GIRIS CIKIS VARMI BAKALIM OGUN VE BIR ERTESI GUN       --En son giriþ çýkýþ kayýtlarý alýnýyor.
        TablodanSorguAc(4,'SELECT TOP 1 CIKIS = isnull(CIKIS,''''), GIRIS = isnull(GIRIS,'''') FROM  PERS_PDKS WHERE  KARTNO='+KartID+' AND '+
        ' ( CONVERT(VARCHAR(10),GIRIS,120) = CONVERT(VARCHAR(10),'''+ Tarih +''',120) or  CONVERT(VARCHAR(10),CIKIS,120)=CONVERT(VARCHAR(10),'''+Tarih+''',120) )'+
        ' ORDER BY CIKIS,GIRIS DESC');
        if Tablo.Query4.RecordCount > 0   then begin
          SonGiris := FormatDateTime('yyyy-mm-dd hh:nn:00',Tablo.Query4.FieldByName('GIRIS').AsDateTime);
          Cikis := FormatDateTime('yyyy-mm-dd hh:nn:00',Tablo.Query4.FieldByName('CIKIS').AsDateTime);
        end;

        if TablodanSorguAc(3,'Select Saat = dbo.fn_SaatOlarak(dbo.fn_Dakika('''+Copy(SonGiris,12,5)+''') + '+IntToStr(OkumaAra)+') ') then begin
          DonenSaat := Tablo.Query3.FieldByName('Saat').AsString;
        end;


        if (Saat > StrToTime(Copy(SonGiris,12,5)) ) and (Saat < StrToTime(DonenSaat)) and (SonGiris <> '1900-01-01 00:00:00') then begin
           VardiyaDurum := 'OKUMA ARALIGI'
        end else if  ((SonGiris = '1900-01-01 00:00:00') and (Cikis = '1900-01-01 00:00:00')) or
        ((SonGiris <> '1900-01-01 00:00:00') and (Cikis <> '1900-01-01 00:00:00'))  then begin

           VardiyaDurum := 'GIRIS';
           YapilacakKayit := 'INSERT GIRIS';

        end else if (Saat > StrToTime(DonenSaat)) or ((SonGiris <> '1900-01-01 00:00:00') and (Cikis = '1900-01-01 00:00:00')) then begin
           VardiyaDurum := 'CIKIS';
           YapilacakKayit := 'UPDATE CIKIS';

        end;


        if Cikis <> '1900-01-01 00:00:00' then  begin
           //Fark Hesaplanýyor.  Çýkýþ boþ deðil ise fark hesaplanýyor
           TablodanSorguAc(3,'SELECT Fark =(DATEPART(MI,('''+Tarih+'''-MAX(CIKIS)))+(DATEPART(HH,('''+Tarih+'''-MAX(CIKIS)))*60)) FROM PERS_PDKS	WHERE '+
          ' DATEPART(M,CIKIS)=DATEPART(M,'''+Tarih+''') AND  DATEPART(D,CIKIS)=DATEPART(D,'''+Tarih+''') AND DATEPART(YY,CIKIS)=DATEPART(YY,'''+Tarih+''') '+
          ' AND KARTNO='+KartID+' ');
          Fark := Tablo.Query3.FieldByName('Fark').AsInteger;
        end else if SonGiris <> '1900-01-01 00:00:00' then begin
             //Fark Hesaplanýyor.  Songiriþ boþ deðil ise fark hesaplanýyor
             TablodanSorguAc(3,'SELECT Fark =(DATEPART(MI,('''+Tarih+'''-MAX(GIRIS)))+(DATEPART(HH,('''+Tarih+'''-MAX(GIRIS)))*60)) FROM PERS_PDKS	WHERE '+
            ' DATEPART(M,CIKIS)=DATEPART(M,'''+Tarih+''') AND  DATEPART(D,CIKIS)=DATEPART(D,'''+Tarih+''') AND DATEPART(YY,CIKIS)=DATEPART(YY,'''+Tarih+''') '+
            ' AND KARTNO='+KartID+' ');
            Fark := Tablo.Query3.FieldByName('Fark').AsInteger;
        end;
              // süre dolmadý uyarýsý veriliyor.
        if (Fark < OkumaAra) and ((VardiyaDurum = 'ÇIKIÞ') or  (VardiyaDurum = 'OKUMA ARALIGI')) then	begin
          Sonuc := AdSoyad + ' : SÜRE DOLMADI';
        end else begin
          IF ((YapilacakKayit = 'INSERT GIRIS') OR (YapilacakKayit ='UPDATE GIRIS'))  then	BEGIN
            Sonuc := AdSoyad + ' : GÝRÝÞ YAPTI'
          END	ELSE	BEGIN
            Sonuc := AdSoyad + ' : ÇIKIÞ YAPTI'
          END;

         //      SONDUR ÇIKIÞ  ise giriþ yapýlýyor , giriþ ise çýkýþ yapýlýyor.

         if YapilacakKayit = 'INSERT GIRIS' then begin
            //Giriþ ise insert yapýlýyor.
           Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'INSERT INTO PERS_PDKS([REHBERID], [KARTNO], [GIRIS], [CIKIS]) VALUES('+IntToStr(RehberID)+','+KartID+','''+Tarih+''',NULL ) ',[],[]);
         end else if YapilacakKayit = 'UPDATE CIKIS' then begin
            // Çýkýþ ise Update yapýlýyor.
           Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE PERS_PDKS SET CIKIS = '''+Tarih+''' 	WHERE	REHBERID = '+IntToStr(RehberID)+' AND KARTNO='+KartID+'  AND GIRIS='''+SonGiris+''' ',[],[]);
         end;
        end;
     end else begin
       Sonuc := 'GEÇERSÝZ KART';
     end;
  end;

  Result := Sonuc;
end;



function TTablo.fn_VardiyaGirisCikisSaat(RehberID: integer; VardiyaTuru, GirisMiCikisMi,Tarih : string): string;
var
  VardiyaGirisCikis,DurumAlanIsmý :string;
begin
  if GirisMiCikisMi = 'G' then
     DurumAlanIsmý := 'GIRIS'
  else
     DurumAlanIsmý := 'CIKIS';

  if VardiyaTuru = 'Sabit' then begin
    TablodanSorguAc(3,' Select GIRCIK = convert(varchar,'+DurumAlanIsmý+',108) from  PERS_VARDIYATANIM Where AY = 0 and GUN = DATEPART(WEEKDAY,'''+Tarih+''') and REHBERID = '+IntToStr(RehberID)+' ');
    VardiyaGirisCikis := Tablo.Query3.FieldByName('GIRCIK').AsString
  end else begin
    TablodanSorguAc(3,' Select GIRCIK = convert(varchar,'+DurumAlanIsmý+',108) from  PERS_VARDIYATANIM Where AY <> 0 and YIL <> 0  and GUN=DATEPART(DAY,'''+Tarih+''') and AY=DATEPART(MONTH,'''+Tarih+''') and REHBERID = '+IntToStr(RehberID)+'  ');
    VardiyaGirisCikis := Tablo.Query3.FieldByName('GIRCIK').AsString
  end;

  Result := VardiyaGirisCikis;
end;

function TTablo.SQLSatiriKopyala(TabloAdi: string; Id: integer;
  VarsAlanlar: Array of String; VarsDegerler: Array of Variant): integer;
var
  i, j: integer;
  listedevar: Boolean;
begin
  Tablo.TablodanSorguAc(1, 'select * from ' + TabloAdi + ' where ID= ' +     inttostr(Id));
  if Tablo.Query1.RecordCount <> 1 then
    abort;
  Tablo.TablodanSorguAc(2, 'select * from ' + TabloAdi + ' where 1=2 ');
  Tablo.Query2.Append;
  for I := 0 to Tablo.Query1.FieldCount - 1 do
  begin
    listedevar := False;
    for j := 0 to length(VarsAlanlar) - 1 do
    begin
      if VarsAlanlar[j] = Tablo.Query1.Fields[i].FieldName then
      begin
        listedevar := True;
        Tablo.Query2.Fields[i].Value := VarsDegerler[j];
      end;
    end;
    if not listedevar then
    begin
      if (Tablo.Query1.Fields[i].FieldName <> 'ID') and
        (Tablo.Query1.Fields[i].FieldName <> 'EKLEMETARIHI') and
        (Tablo.Query1.Fields[i].FieldName <> 'DEGISTIREN') and
        (Tablo.Query1.Fields[i].FieldName <> 'DEGISTIRMETARIHI') then
        Tablo.Query2.Fields[i].Value := Tablo.Query1.Fields[i].Value;
    end;
  end;
  Tablo.Query2.Post;
  Result := Tablo.Query2.FieldByName('ID').asinteger;
end;

end.

