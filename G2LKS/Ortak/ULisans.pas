{
#### MODUL KOD Listesi ####

Modul1	Ajanda
Modul2	Ameliyat
Modul3	Anket
Modul4	Diyaliz
Modul5	DoðanBebek
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
Modul17	Hýzlý Giriþ
Modul18	KamuLab
Modul19	Kayýtkabul
Modul20	Kullanan
Modul21	Lab
Modul22	LIS - Cihaz baðlantýsý
Modul23	LISNET
Modul24	Medula Entegrasyon
Modul25	Muayene
Modul26	Persona
Modul27	Radyoloji
Modul28	Randevu
Modul29	Servis
Modul30	Stok
Modul31	Sýramatik
Modul32	Tüp Bebek
Modul33	Yönlendirme
Modul34	Ýþyeri Hekimliði
Modul35	Magic SAS
Modul36	Muhasebe Entegrasyonu
Modul37	Satýnalma
Modul38 Doktorlar
Modul39 GenoTIP
}

unit ULisans;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, cxContainer, cxEdit, cxTextEdit, 
  Buttons, ExtCtrls, DB, ADODB, jpeg;
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

uses UTablo, UGenSifre, FetaUtil;

{$R *.DFM}

var
  Kapat :boolean;

function Query(SQL :string) :TADOQuery;
var
  q :TADOQuery;
begin
  q := TADOQuery.Create(nil);
  q.Connection := Tablo.cnn;
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
  strSID :PAnsiChar;
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
    try
      if recordcount = 0 then
            raise ELisansHatasi.Create('Öncelikle GenLisanslama Modülünü Çalýþtýrmalýsýnýz', '', lhHata, ldHataVerBitir, nil);
    finally
      Free;
    end;
  end;
  with Query('select top 1 * from GENOTIP') do
  begin
    try
      if recordcount = 0 then
        raise ELisansHatasi.Create('Öncelikle GenLisanslama Modülünü Çalýþtýrmalýsýnýz', '', lhHata, ldHataVerBitir, nil);
    finally
      Free;
    end;
  end;
end;

function GenoTIPMACAdresiMi :Boolean;
var
  res : TADOQuery;
begin
  res := Query('select * from GENOTIP WHERE CONVERT(INT,SABIT) >= ''10000'' AND convert(varchar(2000),DEGER) = ''' + sifre(GetMACAdress )+ '''');
  try
    result := res.RecordCount <> 0;
  finally
    res.Free;
  end;
end;

function DBSonLisansSorgulamaTarihi :TDateTime;
begin
  Result := GunTarihi - 365;
  with Query('Select * from GENOTIP WHERE SABIT = ''55''') do
  begin
    try
      if recordcount <> 0 then
      begin
        if FieldByName('DEGER').AsString <> '' then
          Result := StrToDate(DeSifre(FieldByName('DEGER').AsString));
      end;
    finally
      Free;
    end;

  end;
end;

function DBTerminalKayitliMi :Boolean;
var
 q1 : TADOQuery;
begin
//  with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''')') do
  q1:=Query('Select count(*) SAYI, ISNULL(MAX(SABIT),''1000'') as MAXNO from GENOTIP WHERE DURUM <> 0 AND SABIT between ''1000'' and ''9999''');
  with q1 do
   begin
     try
       if LisansBilgileri.LisansSayisi < q1.FieldByName('SAYI').AsInteger then
         raise ELisansHatasi.Create('Terminal Limitiniz Dolu',  'Lütfen Lisanslama modülünden aktif terminal sayýsýný ayarlayýnýz.',lhHata,ldHataVerBitir,nil);
     finally
       Free;
     end;
   end;

  with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre(GetMACAdress ) + ''')') do
  begin
    try
      Result := recordcount <> 0;
      if FieldbyName('DURUM').AsString = '0' then
        raise ELisansHatasi.Create('Bu terminal aktif deðil', 'Aktif hale getirebilmek için GenLisanslama Modülünden, Terminaller bölümünden düzenleme yapmalýsýnýz', lhHata, ldHataVerBitir, nil);
      LisansBilgileri.TerminalAdi := DeSifre(FieldbyName('SABITTEXT').AsString);
      LisansBilgileri.TerminalMAC := DeSifre(FieldbyName('DEGER').AsString);
    finally
      Free;
    end;
  end;

  //with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''')') do
  with Query('SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre(GetMACAdress ) + ''')') do
  begin
    try
      Result := recordcount <> 0;
      if not Result then
        raise ELisansHatasi.Create('Bu terminal tanýmlý deðil', 'Terminali kaydetmek için ismi yazýp Tamama týklamalýsýnýz', lhHata, ldTerminalTanitDevamEt, nil);
    finally
      Free;
    end;
  end;

end;

function DBGunTarihi :TDate;
var
  res : TADOQuery;
begin
  res := Query('Select convert(datetime,convert(varchar(10),GETDATE(),103),103)');
  try
    result := res.Fields[0].AsDateTime;
  finally
    res.Free;
  end;
end;

function DBAcikLisans :string;
var
  res : TADOQuery;
begin
  res := Query('select * from GENOTIP WHERE SABIT = ''50''');
  try
    result := DeSifre(res.Fieldbyname('DEGER').AsString);
  finally
    res.Free;
  end;
end;

function DBKapaliLisans :string;
var
  res : TADOQuery;
begin
  res := Query('select * from GENOTIP WHERE SABIT = ''51''');
  try
    result := DeSifre(res.Fieldbyname('DEGER').AsString);
  finally
    res.Free;
  end;
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
      3 :SatisTipi := stCalismasin;
    end;
    LisansTarihi := StrToDate(StringReplace(Items.Values['LisansTarihi'],'.','/',[rfReplaceAll]));
    LisansSuresi := StrToint(Items.Values['LisansSuresi']);
    UyariGunSayisi := StrToint(Items.Values['UyariGunSayisi']);
    Moduller := copy(PAcikLisans, pos('Modul1', PAcikLisans), maxint);
  end;
end;

function ModulYetkisiVarmi :boolean;
begin
  result := pos(LisansModul + '=1', LisansBilgileri.Moduller) > 0;
end;

procedure DBAciklisansGuncelle(pAcikLisans :string);
var
  res : TADOQuery;
begin
  res := Query(
    'UPDATE GENOTIP SET DEGER = ''' + Sifre(pAcikLisans) + ''' WHERE SABIT = ''50'''#13#10 +
    'UPDATE GENOTIP SET DEGER = ''' + Sifre(FormatDateTime(FormatSettings.ShortDateFormat, GunTarihi)) + ''' WHERE SABIT = ''55'''#13#10 +
    'Select DEGER FROM GENOTIP WHERE SABIT = ''50''');
  res.Free;
end;

procedure LisansKntrl;
var
  AcikLisans :string;
  SonLisansSorgulamaTarihi :TDate;
  lws :smallint;
begin
  try
    try
      lws := 1;
      GunTarihi := DBGunTarihi;
      WEBLisansUygulandimi;

      // Makinenin MAC i Þirkete ait Bir MAC olarak kayýtlý mý?
      if GenoTIPMACAdresiMi then
         exit;

      // Sistemde var olan Açýk Lisans Bilgisi alýnýyor.
      LisansBilgileri := AcikLisansToTlisans(DBAcikLisans);

      //  Sistemin çalýþmasý için izin var mý?
      if not LisansBilgileri.YazilimCalissin then
      begin
        // Lisans Bilgilerinde Yazýlým Çalýþma izni kapalý olarak kayýtlý....
        raise ELisansHatasi.Create('Lisans', 'Sistemin çalýþma izni yok. GenoTIP ile irtibata geçmeniz gerekmektedir.', lhHata, ldHataVerBitir, nil);
      end;

      // Terminal kayýtlý mý?  Burada Terminalin Serverdaki MAC adresi de alýnýyor.
      if not DBTerminalKayitliMi then
      begin
        // Terminal sisteme tanýmlý deðil ise...
        raise ELisansHatasi.Create('Terminal', 'Bu terminal sistemde kayýtlý deðil.', lhHata, ldTerminalTanitDevamEt, nil);
      end;

      // Modul Yetkisi Var mý?
      if not ModulYetkisiVarMi then
      begin
        //  Modul kullanma için izin yoksa
        raise ELisansHatasi.Create('Modül Lisansý', 'Bu modül için lisansýnýz bulunmamaktadýr', lhHata, ldHataVerBitir, nil);
      end;

      // Sistemdeki SonLisansTarihi Alýnýyor...
      SonLisansSorgulamaTarihi := DBSonLisansSorgulamaTarihi;

      // Lisans Web Service'ten tekrar alýnmasý gerekiyor mu?
      if ((Round(DBGunTarihi - SonLisansSorgulamaTarihi)) >= LisansBilgileri.LisansSorgulamaSuresi) and (LisansModul = 'Modul19') then
      begin
        try
          // Web service'ten dönen deðer ile Lisans Güncellenecek...
    //idris      AcikLisans := Lisanssrv.AcikLisans(LisansBilgileri.KurumKod1, LisansBilgileri.KurumKod2, LisansBilgileri.MAC);

          // Lisans Web Service'ten gelen lisans bilgisi güncelleniyor
          LisansBilgileri := AcikLisansToTlisans(AcikLisans);

          // Sistemdeki KapalýLisans'taki Server MAC ile Merkezden alýnan AçýkLisans'tak, MAC ler tutuyormu?
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
      end; // Lisans Web Service'ten tekrar alýnmasý gerekiyor mu?

      if lws = 0 then
      begin
        // WEB Service ten dönen deðerler çalýþma iznini 0 yapmýþ. Sistem Server'ý ile FetaServer daki MAC ler farklý...
        raise ELisansHatasi.Create('Server ayarlarýnýz deðiþmiþ. Lütfen GenoTIP ile görüþünüz.', 'Yeni bir lisans almanýz gerekebilir.', lhHata, ldHataVerBitir, nil);
      end;

      // Web serviceten dönen deðer veya hiç sorgulamadan durum lisans kontrolü yapmaya müsait olduðunu belirtirse...
      case LisansBilgileri.SatisTipi of

        stDemo :
          begin
            // Demo Süresi içerisinde ise.
            if (GunTarihi - LisansBilgileri.LisansTarihi) <= LisansBilgileri.LisansSuresi then
              raise ELisansHatasi.Create('Demo süresi', 'Demo süresinin dolmasýna  ' + IntToStr(round(LisansBilgileri.LisansTarihi + LisansBilgileri.LisansSuresi - GunTarihi)) + ' gün kaldý', lhUyari, ldUyarDevamEt, nil)
            else // Demo süresi dolmuþ ise....
              raise ELisansHatasi.Create('Demo süresi', 'Demo süresi dolmuþtur.', lhHata, ldHataVerBitir, nil);
          end;

        stKira :
          begin
            if (GunTarihi - LisansBilgileri.LisansTarihi) <= LisansBilgileri.LisansSuresi then
            begin // Kira süresi içerisinde ise
              //  Kira Uyarý Opsiyon Günü süresi içersine girilmemiþ ise...
              if (LisansBilgileri.LisansSuresi) - (GunTarihi - LisansBilgileri.LisansTarihi) >= LisansBilgileri.UyariGunSayisi then
                exit
              else //  Kira Uyarý Opsiyon Günü süresi içersine gelinmiþ ise...
                raise ELisansHatasi.Create('Lisans süresi', 'Lisans süresinin dolmasýna ' + IntToStr((LisansBilgileri.LisansSuresi) - trunc((GunTarihi - LisansBilgileri.LisansTarihi))) + ' gün kalmýþtýr.', lhUyari, ldUyarDevamEt, nil);
            end
            else // Kira süresi dolmuþ ise
              raise ELisansHatasi.Create('Lisans süresi', 'Lisans süresi dolmuþtur.', lhHata, ldHataVerBitir, nil);
          end;

        stSatis :
          begin
            exit;
          end;

        stCalismasin :
          begin
            raise ELisansHatasi.Create('Lisans dondurulmuþtur', 'Yazýlým çalýþmayacaktýr', lhHata, ldHataVerBitir, nil);
          end;
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
  if (Key = #13) and (okbtn.Visible) then OKBtn.Click
   else
      SpeedButton1.Click;
end;

procedure TLisansDlg.BtnLisansClick(Sender :TObject);
var
  q1, q2 :TADOQuery;
  res    : TADOQuery;
begin
  // Aktif Lisanslý kullanýcý sayýsý
  q1 := Query('Select count(*) SAYI, ISNULL(MAX(SABIT),''1000'') as MAXNO from GENOTIP WHERE DURUM <> 0 AND SABIT between ''1000'' and ''9999''');
  try
    if LisansBilgileri.LisansSayisi > q1.FieldByName('SAYI').AsInteger then
    begin
      q2 := Query('Select * from GENOTIP WHERE SABIT between 1000 and 9999 AND convert(varchar(1000),SABITTEXT) = ''' + Sifre(TxtTerminal.Text) + ''' and durum = ''1'' ');
      try
        if q2.RecordCount <> 0 then
        begin
          raise Exception.Create('Bu isimde kayýtlý terminal var.');
        end
        else
        begin
          res := Query(
            'INSERT INTO GENOTIP(SABITTEXT, SABIT, DEGER, DURUM) ' +
            'VALUES (' +
            '  ''' + Sifre(TxtTerminal.Text) + ''',' +
            '  ''' + IntToStr(q1.FieldByName('MAXNO').AsInteger + 1) + ''',' +
//            '  ''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''',1)');
            '  ''' + Sifre(GetMACAdress ) + ''',1)');
          res.Free;
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

