{
#### MODUL KOD Listesi ####

Modul1	Ajanda
Modul2	Ameliyat
Modul3	Anket
Modul4	Diyaliz
Modul5	DoğanBebek
Modul6	Evrak Defteri
Modul7	Evrak Takip
Modul8	Fatura Takip
Modul9	GARS
Modul10	Gen95
Modul11	GenLAB
Modul12	GenMedula
Modul13	GenScan
Modul14	Genspor
Modul15	Gentegre
Modul16	Giykimbil
Modul17	Hızlı Giriş
Modul18	KamuLab
Modul19	Kayıtkabul
Modul20	Kullanan
Modul21	Lab
Modul22	LIS - Cihaz bağlantısı
Modul23	LISNET
Modul24	Medula Entegrasyon
Modul25	Muayene
Modul26	Persona
Modul27	Radyoloji
Modul28	Randevu
Modul29	Servis
Modul30	Stok
Modul31	Sıramatik
Modul32	Tüp Bebek
Modul33	Yönlendirme
Modul34	İşyeri Hekimliği
Modul35	Magic SAS
Modul36	Muhasebe Entegrasyonu
Modul37	Satınalma
Modul38 Doktorlar
Modul39 Yeni Versiyon Çalışmasın
}

unit ULisans;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, ComCtrls, ToolWin,
  Buttons, jpeg, ExtCtrls, DB, FireDAC.Comp.Client, Registry;
type

  TLisansHata = (lhUyari, lhHata);
  TLisansDevam = (ldUyarDevamEt, ldTerminalTanitDevamEt, ldHataVerBitir);

  ELisansHatasi = class(Exception)
  private
    FGercekHata :Exception;
    FIcerik :string;
    FHata :string;
    FLisansDevam :TLisansDevam;
    FLisansHata :TLisansHata;
    procedure SetlisansDevam(const Value :TLisansDevam);
    procedure SetlisansHata(const Value :TLisansHata);
  public
    constructor Create(pHata, pIcerik :string; pLisansHata :TLisansHata; pLisansDevam :TLisansDevam; E :Exception);
    destructor Destroy; override;
    property Hata :string read FHata write FHata;
    property Icerik :string read FIcerik write FIcerik;
    property GercekHata :Exception read FGercekHata write FGercekHata;
    property LisansHata :TLisansHata read FLisansHata write SetLisansHata;
    property LisansDevam :TLisansDevam read FLisansDevam write SetLisansDevam;
  end;
  TSatisTipi = (stSatis, stKira, stDemo, stCalismasin);
  TLisans = record
    MAC :string;
    LisansSayisi :Integer;
    YazilimCalissin :Boolean;
    LisansSorgulamaSuresi :Integer;
    KurumKod1 :integer;
    KurumKod2 :integer;
    SatisTipi :TSatisTipi;
    LisansTarihi :TDateTime;
    LisansSuresi :Integer;
    UyariGunSayisi :Integer;
    Moduller :string;
    YeniVersiyonDurumu : Boolean;
    TerminalAdi :string;
    TerminalMAC :string;
  end;

  TLisansDlg = class(TForm)
    LblLisansMsg :TLabel;
    imgLogo :TImage;
    Label1 :TLabel;
    pnlTerminalKaydet :TPanel;
    lblTerminalAdiBaslik :TLabel;
    txtTerminal :TEdit;
    BtnLisans :TSpeedButton;
    OKBtn :TSpeedButton;
    SpeedButton1 :TSpeedButton;
    procedure OKBtnClick(Sender :TObject);
    procedure CancelBtnClick(Sender :TObject);
    procedure FormKeyPress(Sender :TObject; var Key :Char);
    procedure BtnLisansClick(Sender :TObject);
    procedure FormClose(Sender :TObject; var Action :TCloseAction);
  private

  public

  end;

function DBGunTarihi :TDate;

var
  LisansDlg :TLisansDlg;
  LisansBilgileri :TLisans;
  GunTarihi :TDate;

procedure LisansKntrl;

implementation

uses UTablo, UGenSifre, FetaUtil, UVeriMotor;

{$R *.DFM}

var
  Kapat :boolean;

function Query(SQL :string) :TFDQuery;
var
  q :TFDQuery;
begin
  q := TFDQuery.Create(nil);
  q.Connection := Tablo.FDCnn;
  result := q;
  q.SQL.Text := SQL;
  try
    if pos('SELECT', uppercase(SQL)) > 0 then
      q.Open
    else
      q.ExecSQL;
  except
  end;
end;

function GetCurrentUserName :string;
const
  cnMaxUserNameLen = 254;
var
  sUserName :string;
  dwUserNameLen :DWord;
begin
  dwUserNameLen := cnMaxUserNameLen - 1;
  SetLength(sUserName, cnMaxUserNameLen);
  GetUserName(
    PChar(sUserName),
    dwUserNameLen);
  SetLength(sUserName, dwUserNameLen);
  Result := sUserName;
end;

function ConvertSidToStringSid(SID :PSID; var StringSid :LPSTR) :Boolean; stdcall;
  external 'advapi32.dll' name 'ConvertSidToStringSidA';

function GetAccountSid(const Server, User :WideString; var Sid :PSID) :DWORD;
var
  dwDomainSize, dwSidSize :DWord;
  R :LongBool;
  wDomain :WideString;
  Use :DWord;
begin
  Result := 0;
  SetLastError(0);
  dwSidSize := 0;
  dwDomainSize := 0;
  R := LookupAccountNameW(PWideChar(Server), PWideChar(User), nil, dwSidSize,
    nil, dwDomainSize, Use);
  if (not R) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
  begin
    SetLength(wDomain, dwDomainSize);
    Sid := GetMemory(dwSidSize);
    R := LookupAccountNameW(PWideChar(Server), PWideChar(User), Sid,
      dwSidSize, PWideChar(wDomain), dwDomainSize, Use);
    if not R then
    begin
      FreeMemory(Sid);
      Sid := nil;
    end;
  end
  else
    Result := GetLastError;
end;

function GetSID :string;
var
  SID :PSID;
  strSID :PChar;
  s :string;
  err :DWORD;
begin
  s := GetCurrentUserName;
  err := GetAccountSid('', s, SID);
  if err = 0 then
  begin
    if ConvertSidToStringSid(SID, strSID) then
      s := strSID
    else
      s := SysErrorMessage(err);
  end
  else
    s := SysErrorMessage(err);
  Result := (s);
end;

procedure WEBLisansUygulandiMi;
begin
  with Query('select name from sysobjects where name = ''GENOTIP''') do
  begin
    if recordcount = 0 then
      raise ELisansHatasi.Create('Öncelikle GenLisanslama Modülünü Çalıştırmalısınız', '', lhHata, ldHataVerBitir, nil);
  end;
  with Query('select '+DbUst(1)+'* from GENOTIP '+DbSinir(1)) do
  begin
    if recordcount = 0 then
      raise ELisansHatasi.Create('Öncelikle GenLisanslama Modülünü Çalıştırmalısınız', '', lhHata, ldHataVerBitir, nil);
  end;
end;

function GenoTIPMACAdresiMi :Boolean;
begin
  result := Query('select * from GENOTIP WHERE cast(SABIT as INT) >= ''10000'' AND cast(DEGER as varchar(2000)) = ''' + sifre(GetMACAdress )+ '''').RecordCount <> 0;
end;

function DBSonLisansSorgulamaTarihi :TDateTime;
begin
  Result := GunTarihi - 365;
  with Query('Select * from GENOTIP WHERE SABIT = ''55''') do
  begin
    if recordcount <> 0 then
    begin
      if FieldByName('DEGER').AsString <> '' then
        Result := StrToDate(DeSifre(FieldByName('DEGER').AsString));
    end;
  end;
end;

function DBTerminalKayitliMi :Boolean;
var
 q1 : TFDQuery;
begin
//  with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''')') do
  q1:=Query('Select count(*) SAYI, ISNULL(MAX(SABIT),''1000'') as MAXNO from GENOTIP WHERE DURUM <> 0 AND SABIT between ''1000'' and ''9999''');
  with q1 do
   begin
      if LisansBilgileri.LisansSayisi < q1.FieldByName('SAYI').AsInteger then
       raise ELisansHatasi.Create('Terminal Limitiniz Dolu',  'Lütfen Lisanslama modülünden aktif terminal sayısını ayarlayınız.',lhHata,ldHataVerBitir,nil);
   end;

  with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	cast(DEGER as varchar(250)) = cast(''' + Sifre(GetMACAdress ) + ''' as varchar(250))') do
  begin
    Result := recordcount <> 0;
    if FieldbyName('DURUM').AsString = '0' then
      raise ELisansHatasi.Create('Bu terminal aktif değil', 'Aktif hale getirebilmek için GenLisanslama Modülünden, Terminaller bölümünden düzenleme yapmalısınız', lhHata, ldHataVerBitir, nil);
    LisansBilgileri.TerminalAdi := DeSifre(FieldbyName('SABITTEXT').AsString);
    LisansBilgileri.TerminalMAC := DeSifre(FieldbyName('DEGER').AsString);
  end;

  //with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''')') do
{adnan  with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre(GetMACAdress ) + ''')') do
  begin
    Result := recordcount <> 0;
    if not Result then
      raise ELisansHatasi.Create('Bu terminal tanımlı değil', 'Terminali kaydetmek için ismi yazıp Tamama tıklamalısınız', lhHata, ldTerminalTanitDevamEt, nil);
  end;  }

end;

function DBGunTarihi :TDate;
begin
  result := Query('Select '+DbConv(DbConv('GETDATE()','varchar(10)',103),'datetime',103)).Fields[0].AsDateTime;
end;

function DBAcikLisans :string;
begin
  result := DeSifre(Query('select * from GENOTIP WHERE SABIT = ''50''').Fieldbyname('DEGER').AsString);
end;

function DBKapaliLisans :string;
begin
  result := DeSifre(Query('select * from GENOTIP WHERE SABIT = ''51''').Fieldbyname('DEGER').AsString);
end;

function VersiyonKontrol : String;
Begin
  // 09.09.2010 Okan ÜNAL
  // DB'deki versiyon alınıyor. 60 DBdeki versiyonu bulunan KOD.
  // Hiç versiyon kaydı yoksa 20.10.08.99 alınıyor. Bu sistemin başlamadan önceki son olası versiyon bilgisidir.
  Result := DeSifre(Query('select DEGER as DEGER from GENOTIP WHERE SABIT = ''60''').Fieldbyname('DEGER').AsString);;
  if Result = '' then
    Result := '20100899';
End;

function ModulYetkisiVarmi :boolean;
begin
  result := pos(LisansModul + '=1', LisansBilgileri.Moduller) > 0;
end;

function DBKapaliLisansMACAdres :string;
begin
  result := copy(DBKapaliLisans, 1, 12);
end;

function AcikLisansToTlisans(PAcikLisans :string) :TLisans;
var
  Items :TStrings;
begin
  Items := tstringlist.Create;
  Result.MAC := copy(PAcikLisans, 1, 12);
  Delete(PAcikLisans, 1, 12);
  Items.CommaText := StringReplace(PAcikLisans, ';', ',', [rfreplaceall]);
  with result do
  begin
    LisansSayisi := StrToInt(Items.Values['LisansSayisi']);
    YazilimCalissin := Items.Values['YazilimCalissin'] = '1';
    LisansSorgulamaSuresi := StrToInt(Items.Values['LisansSorgulamaSuresi']);
    KurumKod1 := StrToInt(Items.Values['KurumKod1']);
    KurumKod2 := StrToInt(Items.Values['KurumKod2']);
    case StrToInt(Items.Values['SatisTipi']) of
      0 :SatisTipi := stSatis;
      1 :SatisTipi := stKira;
      2 :SatisTipi := stDemo;
      //3 :SatisTipi := stCalismasin;
    end;
    LisansTarihi := StrToDate(StringReplace(Items.Values['LisansTarihi'],'.','/',[rfReplaceAll]));
    LisansSuresi := StrToint(Items.Values['LisansSuresi']);
    UyariGunSayisi := StrToint(Items.Values['UyariGunSayisi']);
    Moduller := copy(PAcikLisans, pos('Modul1', PAcikLisans), maxint);
    // 09.09.2010 Okan ÜNAL
    if Items.Values['YeniVersiyonDurumu'] <> '' then
      YeniVersiyonDurumu := StrToBool(Items.Values['YeniVersiyonDurumu'])
    else
      YeniVersiyonDurumu := True;
  end;
end;

procedure DBAciklisansGuncelle(pAcikLisans :string);
begin
  Query(
    'UPDATE GENOTIP SET DEGER = ''' + Sifre(pAcikLisans) + ''' WHERE SABIT = ''50'''#13#10 +
    'UPDATE GENOTIP SET DEGER = ''' + Sifre(FormatDateTime(ShortDateFormat, GunTarihi)) + ''' WHERE SABIT = ''55'''#13#10 +
    'Select DEGER FROM GENOTIP WHERE SABIT = ''50''');
end;

// 09.09.2010 Okan ÜNAL
// Yeni çalışan Versiyonun bilgilerini sisteme günceller...
procedure DBVersiyonGuncelle(Versiyon :string);
begin
  with Query('SELECT SABIT FROM GENOTIP WHERE SABIT >= ''60''') do
  begin
    if recordcount <> 0 then
    Query(
      'UPDATE GENOTIP SET DEGER = ''' + Sifre(Versiyon) + ''' WHERE SABIT = ''60''')
    else
    Query(
      'INSERT INTO GENOTIP(SABITTEXT, SABIT, DEGER) VALUES('''+ Sifre('Versiyon') +''', ''60'', '''+ Sifre(Versiyon) + ''')')
  end;

  with Query('SELECT DEGER FROM GENOTIPINI WHERE BOLUM = ''GenelOpsiyon'' AND ANAHTAR = ''Versiyon''') do
  begin
    if recordcount <> 0 then
    Query(
      'UPDATE GENOTIPINI SET DEGER = ''' + Sifre(Versiyon) + ''' WHERE BOLUM = ''GenelOpsiyon'' AND ANAHTAR = ''Versiyon''')
    else
    Query(
      'INSERT INTO GENOTIPINI(BOLUM, ANAHTAR, DEGER) VALUES(''GenelOpsiyon'', ''Versiyon'', '''+ Sifre(Versiyon) + ''')')
  end;

end;

procedure LisansKntrl;
var
  LisansSorgulandi : Boolean;
  AcikLisans :string;
  DBVersiyon : Integer;
  SonLisansSorgulamaTarihi :TDate;
  lws :smallint;
begin
  try
    try
      LisansSorgulandi := False;
      lws := 1;
      GunTarihi := DBGunTarihi;
      WEBLisansUygulandimi;

      // Makinenin MAC i Şirkete ait Bir MAC olarak kayıtlı mı?
      if GenoTIPMACAdresiMi then
         exit;

      // Sistemde var olan Açık Lisans Bilgisi alınıyor.
      LisansBilgileri := AcikLisansToTlisans(DBAcikLisans);

      //  Sistemin çalışması için izin var mı?
      if not LisansBilgileri.YazilimCalissin then
      begin
        // Lisans Bilgilerinde Yazılım Çalışma izni kapalı olarak kayıtlı....
        raise ELisansHatasi.Create('Lisans', 'Sistemin çalışma izni yok. GenoTIP ile irtibata geçmeniz gerekmektedir.', lhHata, ldHataVerBitir, nil);
      end;

      // Terminal kayıtlı mı?  Burada Terminalin Serverdaki MAC adresi de alınıyor.
      if not DBTerminalKayitliMi then
      begin
        // Terminal sisteme tanımlı değil ise...
        raise ELisansHatasi.Create('Terminal', 'Bu terminal sistemde kayıtlı değil.', lhHata, ldTerminalTanitDevamEt, nil);
      end;

      // Modul Yetkisi Var mı?
      if not ModulYetkisiVarMi then
      begin
        //  Modul kullanma için izin yoksa
        raise ELisansHatasi.Create('Modül Lisansı', 'Bu modül için lisansınız bulunmamaktadır', lhHata, ldHataVerBitir, nil);
      end;

       //LİSANS Versyion Kontrolü
       // 09.09.2010 Okan ÜNAL
      // Bu çalışan yeni versiyon mu DB deki ile kontrol edelim.
      DBVersiyon := StrToInt(VersiyonKontrol);

      // Çalıştırılmak istenen versiyon bilgisi Sistemdeki kayıtlı versiyon bilgisinden yeni ise...
      if (LisansModul = 'Modul19') and (StrToInt(StringReplace(Versiyon,'.','',[rfReplaceAll])) > DBVersiyon)  then
      Begin
        try
          AcikLisans := Lisanssrv.AcikLisans(LisansBilgileri.KurumKod1, LisansBilgileri.KurumKod2, LisansBilgileri.MAC);
          LisansBilgileri := AcikLisansToTlisans(AcikLisans);
          DBAciklisansGuncelle(Aciklisans);
          LisansSorgulandi := True;
          lws := 1;
        except //
          LisansSorgulandi := False;
          lws := 0;
          raise ELisansHatasi.Create('Yeni versiyonu kullanmaya çalıştığınız terminalin internet erişimi olmalıdır.', 'İnternet erişimi olan bir makineden tekrar deneyiniz.', lhHata, ldHataVerBitir, nil);
        end;

        if LisansSorgulandi then
        Begin
          // Lisans Sorgulandı ve Yeni versiyon kullanmaya yetkisi yok ise.
          //if not LisansBilgileri.YeniVersiyonDurumu then
         // if (LisansBilgileri.SatisTipi = stCalismasin) then
          if (pos('Modul39=1', LisansBilgileri.Moduller) <> 0 ) then
          Begin
            raise ELisansHatasi.Create('Lisans bilgilerinize ulaşılamadı. Lütfen GenoTIP ile görüşünüz.', 'Yeni lisans almanız gerekebilir.', lhHata, ldHataVerBitir, nil);
          End
          else // Lisans Sorgulandı ve Yeni versiyon kullanmaya yetkisi var ise.
          Begin
            DBVersiyonGuncelle(StringReplace(Versiyon,'.','',[rfREplaceAll]));
          End;
        End;
      End;
      
      // Sistemdeki SonLisansTarihi Alınıyor...
      SonLisansSorgulamaTarihi := DBSonLisansSorgulamaTarihi;

      // Lisans Web Service'ten tekrar alınması gerekiyor mu?
      if ((Round(DBGunTarihi - SonLisansSorgulamaTarihi)) >= LisansBilgileri.LisansSorgulamaSuresi) and (LisansModul = 'Modul19') then
      begin
        try
          if LisansSorgulandi = False then
          Begin
            // Web service'ten dönen değer ile Lisans Güncellenecek...
            AcikLisans := Lisanssrv.AcikLisans(LisansBilgileri.KurumKod1, LisansBilgileri.KurumKod2, LisansBilgileri.MAC);
            // Lisans Web Service'ten gelen lisans bilgisi güncelleniyor
            LisansBilgileri := AcikLisansToTlisans(AcikLisans);
          End;

          // Sistemdeki KapalıLisans'taki Server MAC ile Merkezden alınan AçıkLisans'tak, MAC ler tutuyormu?
          if LisansBilgileri.MAC = DBKapaliLisansMACAdres then
          begin
            lws := 1;
            DBAciklisansGuncelle(Aciklisans);
          end
          else
            lws := 0;
        except
          lws := 1;
        end;
      end; // Lisans Web Service'ten tekrar alınması gerekiyor mu?

      if lws = 0 then
      begin
        // WEB Service ten dönen değerler çalışma iznini 0 yapmış. Sistem Server'ı ile FetaServer daki MAC ler farklı...
        raise ELisansHatasi.Create('Server ayarlarınız değişmiş. Lütfen GenoTIP ile görüşünüz.', 'Yeni bir lisans almanız gerekebilir.', lhHata, ldHataVerBitir, nil);
      end;

      // Web serviceten dönen değer veya hiç sorgulamadan durum lisans kontrolü yapmaya müsait olduğunu belirtirse...
      case LisansBilgileri.SatisTipi of
        stDemo :
          begin
            // Demo Süresi içerisinde ise.
            if (GunTarihi - LisansBilgileri.LisansTarihi) <= LisansBilgileri.LisansSuresi then
              raise ELisansHatasi.Create('Demo süresi', 'Demo süresinin dolmasına  ' + IntToStr(round(LisansBilgileri.LisansTarihi + LisansBilgileri.LisansSuresi - GunTarihi)) + ' gün kaldı', lhUyari, ldUyarDevamEt, nil)
            else // Demo süresi dolmuş ise....
              raise ELisansHatasi.Create('Demo süresi', 'Demo süresi dolmuştur.', lhHata, ldHataVerBitir, nil);
          end;

        stKira :
          begin
            if (GunTarihi - LisansBilgileri.LisansTarihi) <= LisansBilgileri.LisansSuresi then
            begin // Kira süresi içerisinde ise
              //  Kira Uyarı Opsiyon Günü süresi içersine girilmemiş ise...
              if (LisansBilgileri.LisansSuresi) - (GunTarihi - LisansBilgileri.LisansTarihi) >= LisansBilgileri.UyariGunSayisi then
                exit
              else //  Kira Uyarı Opsiyon Günü süresi içersine gelinmiş ise...
                raise ELisansHatasi.Create('Lisans süresi', 'Lisans süresinin dolmasına ' + IntToStr((LisansBilgileri.LisansSuresi) - trunc((GunTarihi - LisansBilgileri.LisansTarihi))) + ' gün kalmıştır.', lhUyari, ldUyarDevamEt, nil);
            end
            else // Kira süresi dolmuş ise
              raise ELisansHatasi.Create('Lisans süresi', 'Lisans süresi dolmuştur.', lhHata, ldHataVerBitir, nil);
          end;

        stSatis :
          begin
            exit;
          end;
       { // 27.09.2010 Okan ÜNAL
         // Yeni Versiyon kontrolü ile birlikte çalışmasın kontrolünü değiştiriyoruz.
        stCalismasin :
          begin
            raise ELisansHatasi.Create('Lisans dondurulmuştur', 'Yazılım çalışmayacaktır', lhHata, ldHataVerBitir, nil);
          end;
        }
      end;

      // lisansHata := 0;

    except
      on eh :ELisansHatasi do
      begin
        Application.CreateForm(TLisansDlg, LisansDlg);

        LisansDlg.Caption := eh.Hata;
        LisansDlg.LblLisansMsg.Caption := eh.Hata + ': '#13#10 + eh.Icerik;

        LisansDlg.pnlTerminalKaydet.Visible := eh.FLisansDevam = ldTerminalTanitDevamEt;

        if LisansDlg.pnlTerminalKaydet.Visible then
        begin
          if LisansBilgileri.TerminalAdi <> '' then
            LisansDlg.txtTerminal.Text := LisansBilgileri.TerminalAdi
          else
            LisansDlg.txtTerminal.Text := GetCurrentUserName;
        end;

        LisansDlg.OKBtn.Visible := eh.LisansDevam <> ldHataVerBitir;

        LisansDlg.ShowModal;

        if LisansDlg.ModalResult = mrCancel then
        begin
          Application.Terminate;
        end;
        LisansDlg.Destroy;
      end;
      on e :Exception do
      begin
        ShowMessage(e.ClassName + ': ' + e.Message);
      end;
    end;

  finally

  end;

end;

procedure TLisansDlg.OKBtnClick(Sender :TObject);
begin
  if pnlTerminalKaydet.Visible then
  begin
    BtnLisans.Click;
  end;
  Kapat := True;
  ModalResult := mrOK;
end;

procedure TLisansDlg.CancelBtnClick(Sender :TObject);
begin
  Kapat := True;
  ModalResult := mrCancel;
  Close;
end;

procedure TLisansDlg.FormKeyPress(Sender :TObject; var Key :Char);
begin
 // if Key = #13 then OKBtn.Click;
end;

procedure TLisansDlg.BtnLisansClick(Sender :TObject);
var
  q1, q2 :TFDQuery;
begin
  // Aktif Lisanslı kullanıcı sayısı
  q1 := Query('Select count(*) SAYI, ISNULL(MAX(SABIT),''1000'') as MAXNO from GENOTIP WHERE DURUM <> 0 AND SABIT between ''1000'' and ''9999''');
  try
    if LisansBilgileri.LisansSayisi > q1.FieldByName('SAYI').AsInteger then
    begin
      q2 := Query('Select * from GENOTIP WHERE SABIT between 1000 and 9999 AND cast(SABITTEXT as varchar(1000)) = ''' + Sifre(TxtTerminal.Text) + ''' and durum = ''1'' ');
      try
        if q2.RecordCount <> 0 then
        begin
          raise Exception.Create('Bu isimde kayıtlı terminal var.');
        end
        else
        begin
          Query(
            'INSERT INTO GENOTIP(SABITTEXT, SABIT, DEGER, DURUM) ' +
            'VALUES (' +
            '  ''' + Sifre(TxtTerminal.Text) + ''',' +
            '  ''' + IntToStr(q1.FieldByName('MAXNO').AsInteger + 1) + ''',' +
//            '  ''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''',1)');
            '  ''' + Sifre(GetMACAdress ) + ''',1)');
          LblLisansMsg.Caption := 'Terminal kaydedildi.';
          pnlTerminalKaydet.Visible := False;
          OKBtn.Visible := true;
        end;
      finally
        q2.Free;
      end;
    end
    else
    begin
      LblLisansMsg.Caption := 'Terminal limitiniz dolu.';
      abort;
    end;
  finally
    q1.Free;
  end;
end;

{ ELisansHatasi }

constructor ELisansHatasi.Create(pHata, pIcerik :string; pLisansHata :TLisansHata; pLisansDevam :TLisansDevam; E :Exception);
begin
  Hata := pHata;
  Icerik := pIcerik;
  LisansHata := pLisansHata;
  LisansDevam := pLisansDevam;
  inherited Create(pHata);
end;

destructor ELisansHatasi.Destroy;
begin

  inherited;
end;

procedure TLisansDlg.FormClose(Sender :TObject; var Action :TCloseAction);
begin
  if not Kapat then Action := caNone;
end;

procedure ELisansHatasi.SetlisansDevam(const Value :TLisansDevam);
begin
  FlisansDevam := Value;
end;

procedure ELisansHatasi.SetlisansHata(const Value :TLisansHata);
begin
  FlisansHata := Value;
end;

end.



