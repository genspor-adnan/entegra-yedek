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
Modul39 GenoTIP
}

unit ULisans;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, cxContainer, cxEdit, cxTextEdit, 
  Buttons, ExtCtrls, DB, UFDCompatHelpers, jpeg;
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
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

function DBGunTarihi :TDate;

var
  LisansDlg :TLisansDlg;
  LisansBilgileri :TLisans;
  GunTarihi :TDate;


implementation

uses UTablo, UGenSifre, FetaUtil, UGirisKutusuEx, LisansWs,PrjConst,LocOnFly,UVeriMotor;

{$R *.DFM}

var
  Kapat :boolean;

function Query(SQL :string) :TADOQuery;
var
  q :TADOQuery;
begin
  q := TADOQuery.Create(nil);
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
var  ctrls: TGirdiDenetimleri;
     KurumKod: Variant;
     st : string;
     procedure TabloOlustur;
     begin
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text :=  'CREATE TABLE [dbo].[ENTEGRA](' + #13#10 +
                  '	[ID] [int] IDENTITY(1,1) NOT NULL,' + #13#10 +
                  '	[KURUMID] [int] NULL,' + #13#10 +
                  '	[SABITTEXT] [varchar](250) NULL,' + #13#10 +
                  '	[SABIT] [varchar](250) NULL,' + #13#10 +
                  '	[DEGER] [text] NULL,' + #13#10 +
                  '	[DURUM] [smallint] NULL,' + #13#10 +
                  '	[EKLEYEN] [int] NULL,' + #13#10 +
                  '	[EKLEMETARIHI] [smalldatetime] NULL,' + #13#10 +
                  '	[DEGISTIREN] [int] NULL,' + #13#10 +
                  '	[DEGISTIRMETARIHI] [smalldatetime] NULL' + #13#10 +
                  ') ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]';
         try
           Tablo.Query1.ExecSQL;
         except
         end;
     end;
     procedure TabloDoldur;
     var res : TADOQuery;
     begin
         ctrls := TGirdiDenetimleri.Create.Edit(LKurumKodunuGir, @KurumKod);         if TGirisKutusuEx.BilgiAlEx(LKurumKodunuGir, ctrls) = mrOk then
            if trim(KurumKod) = '' then begin
              MessageDlg((LKurumKoduBosOlamaz), mtError, [mbOK], 0);
              Exit;
            End
            else begin
              //önce geçerli mi ona bakalım
              st := GetMACAdress;
              st := Lisanssrv.MACGuncelle(KurumKod, st);
              if st <> '' then begin
                 MessageDlg((st), mtError, [mbOK], 0);
                 Exit;
               End else begin
                 st := copy(KurumKod,9,6);
                 st := Lisanssrv.AcikLisans(127, StrToInt(st), GetMACAdress);
                 res := Query(' INSERT INTO ENTEGRA( SABIT, DEGER) ' +      // SABITTEXT,, DURUM
                              ' VALUES (''50'', ''' + Sifre(st) + ' '')');
                    //'  ''' + IntToStr(q1.FieldByName('MAXNO').AsInteger + 1) + ''',' +
        //            '  ''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''',1)');
                    //'  ''' + Sifre(GetMACAdress ) + ''',1)');
                 res.Free;
              end;
            end;

     end;
begin
{  with Query('select name from sysobjects where name = ''ENTEGRA''') do
  begin
    try
      if recordcount = 0 then begin
         TabloOlustur;
         TabloDoldur;
      end;
    finally
      Free;
    end;
  end;
  with Query('select '+DbUst(1)+'* from ENTEGRA '+DbSinir(1)) do
  begin
    try
      if recordcount = 0 then
         TabloDoldur;
    finally
      Free;
    end;
  end; }
end;

function ENTEGRA_MAC_AdresiMi :Boolean;
var
  res : TADOQuery;
begin
  res := Query('select * from ENTEGRA WHERE CAST(SABIT as INT) >= ''10000'' AND cast(DEGER as varchar(2000)) = ''' + sifre(GetMACAdress )+ '''');
  try
    result := res.RecordCount <> 0;
  finally
    res.Free;
  end;
end;

function DBSonLisansSorgulamaTarihi :TDateTime;
var
  a: string;
begin
  Result := GunTarihi - 365;
  with Query('Select * from ENTEGRA WHERE SABIT = ''55''') do
  begin
    try
      if recordcount <> 0 then
      begin
        if FieldByName('DEGER').AsString <> '' then
          a := DeSifre(FieldByName('DEGER').AsString);
          if StrToDateDef(a,1)<>1 then
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
//  with Query('SELECT * FROM ENTEGRA WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''')') do
  q1:=Query('Select count(*) SAYI, ISNULL(MAX(SABIT),''1000'') as MAXNO from ENTEGRA WHERE DURUM <> 0 AND SABIT between ''1000'' and ''9999''');
  with q1 do
   begin
     try
       if LisansBilgileri.LisansSayisi < q1.FieldByName('SAYI').AsInteger then
         raise ELisansHatasi.Create(LTerminalLimitinizDolu,  LTerminalSayisiniAyarlayiniz,lhHata,ldHataVerBitir,nil);
     finally
       Free;
     end;
   end;

  with Query('SELECT * FROM ENTEGRA WHERE SABIT >= ''1000'' AND	cast(DEGER as varchar(250)) = cast(''' + Sifre(GetMACAdress ) + ''' as varchar(250))') do
  begin
    try
      Result := recordcount <> 0;
      if FieldbyName('DURUM').AsString = '0' then
        raise ELisansHatasi.Create(LTerminalAktifDegil, LDuzenlemeYapmalisin, lhHata, ldHataVerBitir, nil);
      LisansBilgileri.TerminalAdi := DeSifre(FieldbyName('SABITTEXT').AsString);
      LisansBilgileri.TerminalMAC := DeSifre(FieldbyName('DEGER').AsString);
    finally
      Free;
    end;
  end;

  //with Query('SELECT * FROM ENTEGRA WHERE SABIT >= ''1000'' AND	convert(varchar(250),DEGER) = convert(varchar(250),''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''')') do
  with Query('SELECT * FROM ENTEGRA WHERE SABIT >= ''1000'' AND	cast(DEGER as varchar(250)) = cast(''' + Sifre(GetMACAdress ) + ''' as varchar(250))') do
  begin
    try
      Result := recordcount <> 0;
      if not Result then
        raise ELisansHatasi.Create(LTerminalKayitliDegil, LTerminaliKaydetmekicinOK, lhHata, ldTerminalTanitDevamEt, nil);
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
  res := Query('select * from ENTEGRA WHERE SABIT = ''50''');
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
  res := Query('select * from ENTEGRA WHERE SABIT = ''51''');
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
  s : string[20];
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
    KurumKod1 := StrToIntDef(Items.Values['KurumKod1'],0);
    KurumKod2 := StrToIntDef(Items.Values['KurumKod2'],0);
    case StrToInt(Items.Values['SatisTipi']) of
      0 :SatisTipi := stSatis;
      1 :SatisTipi := stKira;
      2 :SatisTipi := stDemo;
      3 :SatisTipi := stCalismasin;
    end;
    if Pos(FormatSettings.DateSeparator, Items.Values['LisansTarihi'])>0 then
       s := Items.Values['LisansTarihi']
    else if FormatSettings.DateSeparator = '.' then
          s := StringReplace(Items.Values['LisansTarihi'],'/','.',[rfReplaceAll])
    else if FormatSettings.DateSeparator = '/' then
          s := StringReplace(Items.Values['LisansTarihi'],'.','/',[rfReplaceAll]);
    LisansTarihi := StrToDate(s);
    LisansSuresi := StrToint(Items.Values['LisansSuresi']);
    UyariGunSayisi := StrToint(Items.Values['UyariGunSayisi']);
    Moduller := copy(PAcikLisans, pos('Modul1', PAcikLisans), maxint);
  end;
end;


procedure DBAciklisansGuncelle(pAcikLisans :string);
var
  res : TADOQuery;
begin
  res := Query(
    'UPDATE ENTEGRA SET DEGER = ''' + Sifre(pAcikLisans) + ''' WHERE SABIT = ''50'''#13#10 +
    'UPDATE ENTEGRA SET DEGER = ''' + Sifre(FormatDateTime(FormatSettings.ShortDateFormat, GunTarihi)) + ''' WHERE SABIT = ''55'''#13#10 +
    'Select DEGER FROM ENTEGRA WHERE SABIT = ''50''');
  res.Free;
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
  if Key = #13 then OKBtn.Click;
end;

procedure TLisansDlg.BtnLisansClick(Sender :TObject);
var
  q1, q2 :TADOQuery;
  res    : TADOQuery;
begin
  // Aktif Lisanslı kullanıcı sayısı
  q1 := Query('Select count(*) SAYI, ISNULL(MAX(SABIT),''1000'') as MAXNO from ENTEGRA WHERE DURUM <> 0 AND SABIT between ''1000'' and ''9999''');
  try
    if LisansBilgileri.LisansSayisi > q1.FieldByName('SAYI').AsInteger then
    begin
      q2 := Query('Select * from ENTEGRA WHERE SABIT between 1000 and 9999 AND cast(SABITTEXT as varchar(1000)) = ''' + Sifre(TxtTerminal.Text) + ''' and durum = ''1'' ');
      try
        if q2.RecordCount <> 0 then
        begin
          raise Exception.Create(LBuisimdeKayitliTerminalVar);
        end
        else
        begin
          res := Query(
            'INSERT INTO ENTEGRA(SABITTEXT, SABIT, DEGER, DURUM) ' +
            'VALUES (' +
            '  ''' + Sifre(TxtTerminal.Text) + ''',' +
            '  ''' + IntToStr(q1.FieldByName('MAXNO').AsInteger + 1) + ''',' +
//            '  ''' + Sifre('1  ' + GetMACAdress + '  ' + GetSID) + ''',1)');
            '  ''' + Sifre(GetMACAdress ) + ''',1)');
          res.Free;
          LblLisansMsg.Caption := LTerminalKaydedildi;
          pnlTerminalKaydet.Visible := False;
          OKBtn.Visible := true;
        end;
      finally
        q2.Free;
      end;
    end
    else
    begin
      LblLisansMsg.Caption := LTerminalLimitinizDolu;
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

procedure TLisansDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
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



